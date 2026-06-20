import 'package:aaroh_chat/src/models/chat_message.dart';
import 'package:aaroh_chat/src/models/user_settings.dart';
import 'package:aaroh_chat/src/services/user_learning_service.dart';
import 'package:aaroh_chat/src/services/web_knowledge_service.dart';
import 'clarification_engine.dart';
import 'conversation_context.dart';
import 'intent_classifier.dart';
import 'language_detector.dart';
import 'neutral_guard.dart';
import 'response_templates.dart';
import 'sentiment_analyzer.dart';
import 'wellness_intent.dart';

/// Composes full Aaroh responses — multilingual, neutral, web-enriched, personalized.
class ResponseComposer {
  ResponseComposer({
    IntentClassifier? classifier,
    SentimentAnalyzer? sentimentAnalyzer,
    WebKnowledgeService? webKnowledge,
  })  : _classifier = classifier ?? IntentClassifier(),
        _sentiment = sentimentAnalyzer ?? SentimentAnalyzer(),
        _webKnowledge = webKnowledge ?? WebKnowledgeService();

  final IntentClassifier _classifier;
  final SentimentAnalyzer _sentiment;
  final WebKnowledgeService _webKnowledge;

  Future<ComposedResponse> composeAsync({
    required String userMessage,
    required UserSettings settings,
    required List<ChatMessage> history,
    required ConversationContext context,
    UserLearningProfile? learning,
  }) async {
    final detected = LanguageDetector.detect(userMessage);
    final langCode = settings.autoDetectLanguage
        ? (learning?.preferredLanguageCode ?? detected.code)
        : _settingsLangCode(settings);

    // Handle clarification follow-up
    var effectiveMessage = userMessage;
    if (context.awaitingClarification) {
      final merged = context.consumeClarificationAnswer(userMessage);
      if (merged != null) effectiveMessage = merged;
    }

    final match = _classifier.classify(
      effectiveMessage,
      lastIntent: context.pendingIntent ?? context.lastIntent,
    );

    var intent = match.intent;

    // BUG FIX: When the intent is followUp, do NOT blindly re-use lastIntent
    // for the response body — that caused duplicate answers. Instead, keep
    // followUp so the response template generates a contextual follow-up reply,
    // rather than repeating the previous topic's full guidance.
    // Only escalate to lastIntent when the message is truly ambiguous (very short
    // affirmation) AND the context explicitly marked it as awaiting continuation.
    if (intent == WellnessIntent.followUp) {
      final lowerMsg = effectiveMessage.toLowerCase().trim();
      final wordCount = lowerMsg.split(RegExp(r'\s+')).length;
      // Only treat as continuation for very short affirmations (≤3 words)
      // that have no substantive new content.
      final isShortAffirmation = wordCount <= 3 &&
          RegExp(r'^(yes|no|ok|okay|sure|yeah|nope|haan|nahi|theek|acha|hmm|mm|uh|yep)$')
              .hasMatch(lowerMsg.replaceAll(RegExp(r'[.!?,]'), '').trim());
      if (!isShortAffirmation) {
        // The user typed something with actual content — classify as general
        // so we give a fresh relevant response instead of a duplicate.
        intent = WellnessIntent.general;
      }
      // For true short affirmations, keep followUp intent so the followUp
      // template is used (not a repeated full topic body).
    }

    final sentiment = _sentiment.analyze(effectiveMessage);

    // Ask clarifying questions when understanding is incomplete
    if (ClarificationEngine.needsClarification(
      userMessage: effectiveMessage,
      intentConfidence: match.confidence,
      intent: intent,
      alreadyClarifying: context.awaitingClarification,
    )) {
      context.startClarification(
        originalMessage: effectiveMessage,
        intent: intent,
      );
      final name = settings.userName.isNotEmpty ? settings.userName : null;
      final text = ClarificationEngine.buildClarificationMessage(
        intent: intent,
        langCode: langCode,
        userName: name,
      );
      return ComposedResponse(
        text: NeutralGuard.frame(text, langCode),
        intent: intent,
        sentiment: sentiment.level,
        langCode: langCode,
        isClarification: true,
      );
    }

    context.record(intent);
    context.clearClarification();

    final name = settings.userName.isNotEmpty ? settings.userName : null;
    final tone = _langToTone(langCode, settings);
    final parts = <String>[];

    // Neutral ideology preamble (when web or health topics)
    if (settings.neutralIdeology &&
        (intent == WellnessIntent.physicalHealth ||
            intent == WellnessIntent.depression ||
            intent == WellnessIntent.anxiety)) {
      parts.add(NeutralGuard.neutralPreamble(langCode));
    }

    // Personalization from learning
    if (learning != null && settings.learnFromChats) {
      final serviceNote = _personalNote(learning, langCode);
      if (serviceNote != null) parts.add(serviceNote);
    }

    if (intent != WellnessIntent.thanks && intent != WellnessIntent.greeting) {
      if (_hasFullTemplates(tone)) {
        parts.add(
          ResponseTemplates.acknowledge(tone, sentiment.level, name),
        );
      } else {
        parts.add(NeutralGuard.acknowledge(langCode, name));
      }
    }

    // Core wellness guidance
    if (_hasFullTemplates(tone)) {
      parts.add(ResponseTemplates.bodyForIntent(intent, tone));
    } else {
      parts.add(ResponseTemplates.bodyForIntent(
        intent,
        LanguageTone.english,
      ));
    }

    // Internet knowledge enrichment
    KnowledgeSnippet? snippet;
    if (settings.useInternetKnowledge) {
      snippet = await _webKnowledge.fetchForIntent(
        intent: intent,
        userMessage: effectiveMessage,
        langCode: langCode,
      );
      if (snippet != null) {
        parts.add('📖 ${snippet.title}\n${snippet.summary}');
        parts.add(NeutralGuard.sourceLine(snippet.sourceUrl, langCode));
      }
    }

    if (settings.responseDepth != ResponseDepth.brief &&
        intent != WellnessIntent.crisis &&
        intent != WellnessIntent.thanks &&
        intent != WellnessIntent.greeting) {
      if (_hasFullTemplates(tone)) {
        parts.add(ResponseTemplates.followUpQuestion(intent, tone));
      } else {
        final qs = NeutralGuard.clarifyQuestions(intent, langCode);
        if (qs.isNotEmpty) parts.add(qs.first);
      }
    }

    if (settings.responseDepth == ResponseDepth.detailed &&
        intent != WellnessIntent.crisis &&
        intent != WellnessIntent.thanks) {
      parts.add(_extraTip(tone, langCode));
    }

    if (settings.learnFromChats) {
      parts.add(NeutralGuard.learnNote(langCode));
    }

    var response = NeutralGuard.frame(parts.join('\n\n'), langCode);

    if (_needsDisclaimer(intent)) {
      if (_hasFullTemplates(tone)) {
        response += ResponseTemplates.medicalDisclaimer(tone);
      } else {
        response += NeutralGuard.medicalDisclaimer(langCode);
      }
    }

    return ComposedResponse(
      text: response,
      intent: intent,
      sentiment: sentiment.level,
      langCode: langCode,
      isClarification: false,
      sourceUrl: snippet?.sourceUrl,
    );
  }

  String? _personalNote(UserLearningProfile learning, String langCode) {
    if (learning.totalMessages < 3) return null;
    final top = learning.topIntent;
    if (top == null) return null;
    return switch (langCode) {
      'hi' => '💭 पहले भी ${_hiTopic(top)} पर बात हुई थी।',
      'hinglish' => '💭 Pehle bhi $top ke baare mein baat hui thi.',
      _ => '💭 We\'ve talked about $top before — I remember.',
    };
  }

  String _hiTopic(String key) => switch (key) {
        'sleep' => 'नींद',
        'anxiety' => 'चिंता',
        'depression' => 'उदासी',
        'loneliness' => 'अकेलापन',
        'stress' => 'तनाव',
        _ => key,
      };

  String _settingsLangCode(UserSettings settings) =>
      switch (settings.languageTone) {
        LanguageTone.hindi => 'hi',
        LanguageTone.english => 'en',
        LanguageTone.hinglish => 'hinglish',
      };

  LanguageTone _langToTone(String langCode, UserSettings settings) {
    if (langCode == 'hi') return LanguageTone.hindi;
    if (langCode == 'hinglish') return LanguageTone.hinglish;
    if (langCode == 'en') return LanguageTone.english;
    return settings.languageTone;
  }

  bool _hasFullTemplates(LanguageTone tone) =>
      tone == LanguageTone.hinglish ||
      tone == LanguageTone.hindi ||
      tone == LanguageTone.english;

  bool _needsDisclaimer(WellnessIntent intent) {
    return intent == WellnessIntent.physicalHealth ||
        intent == WellnessIntent.depression ||
        intent == WellnessIntent.anxiety ||
        intent == WellnessIntent.crisis;
  }

  String _extraTip(LanguageTone tone, String langCode) {
    if (_hasFullTemplates(tone)) {
      return switch (tone) {
        LanguageTone.hindi => '💡 नियमित छोटे कदम बड़े बदलाव लाते हैं।',
        LanguageTone.english => '💡 Small consistent steps create big change.',
        LanguageTone.hinglish =>
          '💡 Roz ka chhota step badi baat ban sakta hai.',
      };
    }
    return '💡 Small consistent steps matter.';
  }
}

class ComposedResponse {
  const ComposedResponse({
    required this.text,
    required this.intent,
    required this.sentiment,
    required this.langCode,
    this.isClarification = false,
    this.sourceUrl,
  });

  final String text;
  final WellnessIntent intent;
  final SentimentLevel sentiment;
  final String langCode;
  final bool isClarification;
  final String? sourceUrl;
}
