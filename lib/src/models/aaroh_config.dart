import 'package:aaroh_chat/src/models/knowledge_item.dart';
import 'package:aaroh_chat/src/models/topic_rule.dart';
import 'package:aaroh_chat/src/models/support_config.dart';

export 'package:aaroh_chat/src/models/knowledge_item.dart' show KnowledgeItem;
export 'package:aaroh_chat/src/models/topic_rule.dart' show TopicRule;
export 'package:aaroh_chat/src/models/support_config.dart' show SupportConfig;
export 'package:aaroh_chat/src/models/chat_message.dart' show MessageAction;

/// Configuration for the Aaroh Chat SDK.
///
/// Pass this to [AarohChatWidget] to customize the bot's behavior,
/// branding, knowledge base, and Claude API integration.
class AarohConfig {
  AarohConfig({
    required this.companyName,
    this.companyLogoUrl,
    this.claudeApiKey,
    List<Object> knowledgeBase = const [],
    List<Object> searchEngineData = const [],
    this.topics = const [],
    this.support,
    this.fallbackReply,
    this.botGreeting,
    this.primaryColor,
    this.accentColor,
    this.poweredByText = 'Powered by Aaroh',
    this.knowledgeMatchThreshold = 1,
  })  : knowledgeBase = knowledgeBase.map(normalizeKnowledgeEntry).toList(),
        searchEngineData =
            searchEngineData.map(normalizeKnowledgeEntry).toList();

  /// Your company/product name — shown in chat header.
  final String companyName;

  /// Optional URL to your company logo (shown in AppBar).
  final String? companyLogoUrl;

  /// Claude API key. If provided, the bot will use Claude for responses.
  /// If null, the built-in Aaroh engine is used.
  final String? claudeApiKey;

  /// Knowledge base — company info, FAQs, product docs, policies.
  ///
  /// Accepts either format, mix-and-match freely:
  /// ```dart
  /// knowledgeBase: [
  ///   'Plain string fact — works fine.',
  ///   KnowledgeItem(
  ///     question: 'What is your return policy?',
  ///     answer: '30-day hassle-free returns.',
  ///     category: 'Policies',
  ///     keywords: ['refund', 'exchange'],
  ///   ),
  /// ]
  /// ```
  ///
  /// Used in **both** modes:
  /// - Claude mode: all entries are joined into the system prompt.
  /// - Built-in engine mode: entries are keyword-matched per message; the
  ///   best match (if any) is answered directly. See [knowledgeMatchThreshold].
  final List<KnowledgeItem> knowledgeBase;

  /// Search engine data — structured Q&A pairs the bot should know about.
  /// Same accepted formats and behavior as [knowledgeBase]; kept as a
  /// separate list purely for your own organization (e.g. product catalog
  /// vs. general docs).
  final List<KnowledgeItem> searchEngineData;

  /// Rule-based replies: "when the user asks about X, reply with Y" —
  /// optionally with a tappable deep-link/callback action. This is the
  /// **highest-priority** match in built-in engine mode — checked before
  /// the knowledge base, in the order you provide the list.
  ///
  /// ```dart
  /// topics: [
  ///   TopicRule(
  ///     triggers: ['pricing', 'cost', 'how much'],
  ///     reply: 'Our Pro plan starts at ₹999/month.',
  ///     action: MessageAction(label: 'View Pricing', route: '/pricing'),
  ///   ),
  /// ]
  /// ```
  final List<TopicRule> topics;

  /// Configures support email / Contact Us link / phone number shown when
  /// a message looks support-related and nothing else matched. See
  /// [SupportConfig] for exact behavior (phone is opt-in only).
  final SupportConfig? support;

  /// Shown in built-in engine mode when **nothing** matches — no
  /// [TopicRule], no [KnowledgeItem], and the message isn't a support
  /// request. If null, a generic safe default is used.
  final String? fallbackReply;

  /// Custom greeting message shown when the chat opens.
  final String? botGreeting;

  /// Primary brand color (hex string, e.g. '#E07A5F').
  final String? primaryColor;

  /// Accent color (hex string).
  final String? accentColor;

  /// Footer branding text. Default: 'Powered by Aaroh'.
  final String poweredByText;

  /// Minimum keyword-overlap score (see [KnowledgeItem.relevanceScore])
  /// required before the **built-in engine** will answer directly from
  /// the knowledge base instead of falling through to support/fallback.
  /// Raise this if the bot is matching too eagerly on weak overlaps.
  final int knowledgeMatchThreshold;

  /// Whether Claude API mode is active.
  bool get usesClaudeApi => claudeApiKey != null && claudeApiKey!.isNotEmpty;

  /// All knowledge entries (knowledgeBase + searchEngineData) combined.
  List<KnowledgeItem> get allKnowledge => [
        ...knowledgeBase,
        ...searchEngineData,
      ];

  /// Combined knowledge context string for Claude's system prompt.
  /// Topics and support info are included too, so Claude stays consistent
  /// with the rules you've defined even though it doesn't need them to
  /// answer general questions.
  String get knowledgeContext {
    final parts = <String>[];
    if (knowledgeBase.isNotEmpty) {
      parts.add('=== Company Knowledge Base ===');
      parts.addAll(knowledgeBase.map((e) => e.toPromptText()));
    }
    if (searchEngineData.isNotEmpty) {
      parts.add('=== Product / Search Data ===');
      parts.addAll(searchEngineData.map((e) => e.toPromptText()));
    }
    if (topics.isNotEmpty) {
      parts.add('=== Predefined Topic Replies ===');
      parts.addAll(topics.map(
        (t) => 'When user asks about: ${t.triggers.join(", ")}\n'
            'Reply with: ${t.reply}',
      ));
    }
    if (support != null) {
      parts.add(
        '=== Support ===\nSupport email: ${support!.email}'
        '${support!.contactUsUrl != null ? '\nContact page: ${support!.contactUsUrl}' : ''}'
        '\nOnly mention the phone number if the user explicitly asks for it.'
        '${support!.phoneNumber != null ? ' Phone: ${support!.phoneNumber}' : ''}',
      );
    }
    return parts.join('\n\n');
  }

  /// Finds the best-matching knowledge entry for [query] using simple
  /// keyword overlap. Returns null if nothing clears
  /// [knowledgeMatchThreshold]. Used by the built-in engine.
  KnowledgeItem? findBestMatch(String query) {
    KnowledgeItem? best;
    var bestScore = 0;
    for (final item in allKnowledge) {
      final score = item.relevanceScore(query);
      if (score > bestScore) {
        bestScore = score;
        best = item;
      }
    }
    if (bestScore < knowledgeMatchThreshold) return null;
    return best;
  }

  /// Finds the first matching [TopicRule] for [query], in list order.
  TopicRule? findTopicMatch(String query) {
    for (final topic in topics) {
      if (topic.matches(query)) return topic;
    }
    return null;
  }
}
