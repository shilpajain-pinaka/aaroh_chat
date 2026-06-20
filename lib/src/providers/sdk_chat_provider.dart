import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:aaroh_chat/src/engine/wellness_intent.dart';

import 'package:aaroh_chat/src/core/constants/crisis_helplines.dart';
import 'package:aaroh_chat/src/engine/aaroh_engine.dart';
import 'package:aaroh_chat/src/engine/language_detector.dart';
import 'package:aaroh_chat/src/engine/support_intent_detector.dart';
import 'package:aaroh_chat/src/models/aaroh_config.dart';
import 'package:aaroh_chat/src/models/chat_message.dart';
import 'package:aaroh_chat/src/models/chat_session.dart';
import 'package:aaroh_chat/src/models/user_settings.dart';
import 'package:aaroh_chat/src/services/claude_api_service.dart';
import 'package:aaroh_chat/src/services/local_chat_storage.dart';
import 'package:aaroh_chat/src/services/user_learning_service.dart';

/// The main state provider for the Aaroh SDK.
///
/// Supports two modes:
/// - **Aaroh Engine** (default): Built-in NLP engine, no API key needed.
/// - **Claude API**: Set [AarohConfig.claudeApiKey] to use Claude.
///
/// In built-in engine mode, replies are resolved in this priority order:
/// 1. [AarohConfig.topics] — exact rule matches (with optional actions)
/// 2. [AarohConfig.knowledgeBase] / `searchEngineData` — keyword match
/// 3. [AarohConfig.support] — if the message looks support-related
/// 4. [AarohConfig.fallbackReply] — if nothing else matched
/// 5. A generic safe default — if [fallbackReply] wasn't set either
class SdkChatProvider extends ChangeNotifier {
  SdkChatProvider({required this.config, this.onAction})
      : _engine = AarohEngine(),
        _storage = LocalChatStorage(),
        _learning = UserLearningService(),
        _claude =
            config.usesClaudeApi ? ClaudeApiService(config: config) : null;

  final AarohConfig config;
  final AarohEngine _engine;
  final LocalChatStorage _storage;
  final UserLearningService _learning;
  final ClaudeApiService? _claude;
  final _uuid = const Uuid();

  /// Called when the user taps a [MessageAction] button that has an
  /// [MessageAction.actionId] set. The host app can run any custom logic
  /// here (open a non-route screen, trigger analytics, etc).
  final void Function(String actionId)? onAction;

  UserSettings _settings = const UserSettings();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _error;
  bool _showCrisisBanner = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;
  String? get error => _error;
  bool get showCrisisBanner => _showCrisisBanner;
  bool get engineReady => true;
  List<ChatSession> get sessions => _storage.sessions;
  LanguageTone get languageTone => _settings.languageTone;
  UserSettings get settings => _settings;

  // ─── Lifecycle ───────────────────────────────────────────────

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _storage.initialize();
    await _learning.load();
    _storage.startNewSession();
    _messages.clear();
    _engine.resetContext();

    _isLoading = false;
    notifyListeners();
  }

  // ─── Language ────────────────────────────────────────────────

  void setLanguage(LanguageTone tone) {
    _settings = _settings.copyWith(languageTone: tone);
    notifyListeners();
  }

  // ─── Session ─────────────────────────────────────────────────

  Future<void> loadSession(String sessionId) async {
    _storage.setActiveSession(sessionId);
    final loaded = _storage.loadActiveMessages();
    _messages
      ..clear()
      ..addAll(loaded);
    _engine.resetContext();
    _engine.restoreFromHistory(_messages);
    notifyListeners();
  }

  Future<void> startNewChat() async {
    _storage.startNewSession();
    _messages.clear();
    _showCrisisBanner = false;
    _error = null;
    _engine.resetContext();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    await _storage.deleteSession(sessionId);
    notifyListeners();
  }

  // ─── Messaging ───────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isStreaming) return;

    _error = null;
    final detected = LanguageDetector.detect(trimmed);

    _showCrisisBanner = CrisisHelplines.containsCrisisSignal(trimmed);

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    _messages.add(userMsg);
    await _storage.saveMessage(userMsg);
    notifyListeners();

    final assistantId = _uuid.v4();
    final assistantMsg = ChatMessage(
      id: assistantId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    _messages.add(assistantMsg);
    _isStreaming = true;
    notifyListeners();

    try {
      final history = _messages.where((m) => m.id != assistantId).toList();

      if (_claude != null) {
        // Claude API mode — knowledgeBase/searchEngineData are already
        // injected into the system prompt by ClaudeApiService.
        await _claude!.sendMessage(
          userMessage: trimmed,
          history: history,
          onPartial: (partial) {
            _updateAssistantMessage(assistantId, assistantMsg, partial, true);
          },
        );
      } else {
        // Built-in Aaroh engine mode. Resolve in priority order:
        // 1. SDK-defined topic rules (with optional deep-link action)
        // 2. Knowledge base keyword match
        // 3. Support intent (email / contact link / phone-if-asked)
        // 4. SDK-defined fallback reply
        // 5. Generic safe default (not the wellness engine — it has no
        //    general knowledge and would otherwise guess irrelevantly)
        final topicMatch = config.findTopicMatch(trimmed);
        final knowledgeMatch =
            topicMatch == null ? config.findBestMatch(trimmed) : null;

        if (topicMatch != null) {
          await _streamKnowledgeAnswer(
            assistantId,
            assistantMsg,
            topicMatch.reply,
            action: topicMatch.action,
          );
        } else if (knowledgeMatch != null) {
          await _streamKnowledgeAnswer(
              assistantId, assistantMsg, knowledgeMatch.answer);
        } else if (SupportIntentDetector.isSupportRequest(trimmed)) {
          await _streamSupportReply(assistantId, assistantMsg, trimmed);
        } else {
          final fallback = config.fallbackReply ??
              "I don't have an answer for that yet. "
                  "Could you rephrase, or ask about ${config.companyName}'s "
                  "products and services?";
          await _streamKnowledgeAnswer(assistantId, assistantMsg, fallback);
        }
      }

      await _learning.learnFromMessage(
        userMessage: trimmed,
        intent: WellnessIntent.general,
        detected: detected,
        enabled: true,
      );

      // Mark complete
      final index = _messages.indexWhere((m) => m.id == assistantId);
      if (index != -1) {
        final completed = _messages[index].copyWith(isStreaming: false);
        _messages[index] = completed;
        await _storage.updateLastMessage(completed);
      }
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      if (kDebugMode) print('[AarohSDK] Error: $e');
      _messages.removeWhere((m) => m.id == assistantId);
    } finally {
      _isStreaming = false;
      notifyListeners();
    }
  }

  /// Streams a knowledge-base/topic-rule answer word-by-word, matching the
  /// pacing style of the built-in engine's own streaming responses.
  /// If [action] is provided, it's attached to the message once streaming
  /// completes so the UI can render a tappable button.
  Future<void> _streamKnowledgeAnswer(
    String assistantId,
    ChatMessage template,
    String answer, {
    MessageAction? action,
  }) async {
    final words = answer.split(RegExp(r'(?<=\S)(?=\s)|(?<=\s)(?=\S)'));
    final buf = StringBuffer();
    for (final token in words) {
      buf.write(token);
      _updateAssistantMessage(assistantId, template, buf.toString(), true);
      if (token.trim().isNotEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 35));
      }
    }
    if (action != null) {
      final index = _messages.indexWhere((m) => m.id == assistantId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(action: action);
      }
    }
  }

  /// Builds and streams the support fallback reply: email by default,
  /// Contact Us link if configured, phone number only if explicitly asked.
  Future<void> _streamSupportReply(
    String assistantId,
    ChatMessage template,
    String userMessage,
  ) async {
    final support = config.support;
    if (support == null) {
      final fallback = config.fallbackReply ??
          "I'm not able to help with that directly. "
              "Please reach out to ${config.companyName}'s support team.";
      await _streamKnowledgeAnswer(assistantId, template, fallback);
      return;
    }

    final buffer = StringBuffer(
      "I'm sorry you're running into trouble. You can reach our support "
      "team at ${support.email}",
    );

    MessageAction? action;
    if (support.phoneNumber != null &&
        SupportIntentDetector.wantsPhoneNumber(userMessage)) {
      buffer.write(' or call ${support.phoneNumber}');
    }
    buffer.write('.');

    if (support.contactUsUrl != null) {
      action = MessageAction(
        label: 'Contact Us',
        url: support.contactUsUrl,
      );
    }

    await _streamKnowledgeAnswer(
      assistantId,
      template,
      buffer.toString(),
      action: action,
    );
  }

  void _updateAssistantMessage(
    String id,
    ChatMessage template,
    String content,
    bool streaming,
  ) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = template.copyWith(
        content: content,
        isStreaming: streaming,
      );
      notifyListeners();
    }
  }

  /// Called by the UI when the user taps a [MessageAction] button.
  /// Fires [onAction] (if the action has an [MessageAction.actionId]) so
  /// the host app can run custom logic. Named-route navigation
  /// ([MessageAction.route]) is handled separately by the widget itself,
  /// since only it has a [BuildContext]/[Navigator].
  void handleAction(MessageAction action) {
    if (action.actionId != null) {
      onAction?.call(action.actionId!);
    }
  }

  void dismissCrisisBanner() {
    _showCrisisBanner = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
