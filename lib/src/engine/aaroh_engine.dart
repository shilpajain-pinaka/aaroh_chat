import 'dart:async';

import 'package:aaroh_chat/src/models/chat_message.dart';
import 'package:aaroh_chat/src/models/user_settings.dart';
import 'package:aaroh_chat/src/services/user_learning_service.dart';
import 'conversation_context.dart';
import 'smart_response_engine.dart';
import 'wellness_intent.dart';

/// Thin wrapper so ChatProvider API stays unchanged.
class ComposedResponse {
  const ComposedResponse({
    required this.text,
    required this.intent,
    required this.langCode,
  });
  final String text;
  final WellnessIntent intent;
  final String langCode;
}

class AarohEngine {
  AarohEngine();

  final SmartResponseEngine _smart = SmartResponseEngine();
  final ConversationContext _context = ConversationContext();

  bool get isReady => true;
  ConversationContext get context => _context;

  void restoreFromHistory(List<ChatMessage> history) {
    _context.turnCount =
        history.where((m) => m.role == MessageRole.user).length;
    _smart.restoreFromHistory(history);
  }

  void resetContext() {
    _context.reset();
    _smart.reset();
  }

  Future<ComposedResponse> streamResponse({
    required String userMessage,
    required UserSettings settings,
    required List<ChatMessage> history,
    UserLearningProfile? learning,
    required void Function(String partial) onPartial,
  }) async {
    _context.turnCount++;

    final text = await _smart.respond(
      userMessage: userMessage,
      history: history,
      settings: settings,
      onPartial: onPartial,
    );

    return ComposedResponse(
      text: text,
      intent: WellnessIntent.general,
      langCode: _langCode(settings),
    );
  }

  String _langCode(UserSettings s) => switch (s.languageTone) {
        LanguageTone.hindi => 'hi',
        LanguageTone.hinglish => 'hinglish',
        LanguageTone.english => 'en',
      };
}
