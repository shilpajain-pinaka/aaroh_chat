import 'wellness_intent.dart';

/// Tracks conversation state including clarification Q&A flow.
class ConversationContext {
  WellnessIntent? lastIntent;
  int turnCount = 0;
  final Set<WellnessIntent> discussedTopics = {};

  /// When true, next user message completes the clarification.
  bool awaitingClarification = false;
  String? pendingUserMessage;
  WellnessIntent? pendingIntent;
  int clarificationRound = 0;

  void record(WellnessIntent intent) {
    lastIntent = intent;
    turnCount++;
    if (intent != WellnessIntent.general &&
        intent != WellnessIntent.greeting &&
        intent != WellnessIntent.thanks) {
      discussedTopics.add(intent);
    }
  }

  void startClarification({
    required String originalMessage,
    required WellnessIntent intent,
  }) {
    awaitingClarification = true;
    pendingUserMessage = originalMessage;
    pendingIntent = intent;
    clarificationRound++;
  }

  String? consumeClarificationAnswer(String answer) {
    if (!awaitingClarification) return null;
    final merged =
        '${pendingUserMessage ?? ''}\n\n[More context]: $answer'.trim();
    awaitingClarification = false;
    pendingUserMessage = null;
    return merged;
  }

  void clearClarification() {
    awaitingClarification = false;
    pendingUserMessage = null;
    pendingIntent = null;
  }

  bool hasDiscussed(WellnessIntent intent) => discussedTopics.contains(intent);

  void reset() {
    lastIntent = null;
    turnCount = 0;
    discussedTopics.clear();
    clearClarification();
    clarificationRound = 0;
  }
}
