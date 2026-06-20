import 'neutral_guard.dart';
import 'wellness_intent.dart';

/// Decides when Aaroh should ask clarifying questions before answering.
class ClarificationEngine {
  static const _minConfidence = 0.45;
  static const _minWordsForDirectAnswer = 6;

  static bool needsClarification({
    required String userMessage,
    required double intentConfidence,
    required WellnessIntent intent,
    required bool alreadyClarifying,
  }) {
    if (alreadyClarifying) return false;
    if (intent == WellnessIntent.crisis) return false;
    if (intent == WellnessIntent.greeting || intent == WellnessIntent.thanks) {
      return false;
    }

    final wordCount = userMessage.trim().split(RegExp(r'\s+')).length;

    if (wordCount < 3) return true;
    if (intent == WellnessIntent.general &&
        wordCount < _minWordsForDirectAnswer) {
      return true;
    }
    if (intentConfidence < _minConfidence) return true;

    return false;
  }

  static String buildClarificationMessage({
    required WellnessIntent intent,
    required String langCode,
    String? userName,
    int maxQuestions = 2,
  }) {
    final intro = NeutralGuard.clarifyIntro(langCode, userName);
    final questions = NeutralGuard.clarifyQuestions(intent, langCode);
    final selected = questions.take(maxQuestions).toList();
    final numbered = selected.asMap().entries.map((e) {
      return '${e.key + 1}. ${e.value}';
    }).join('\n');

    return '$intro\n\n$numbered';
  }
}
