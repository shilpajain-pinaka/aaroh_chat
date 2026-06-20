import 'wellness_intent.dart';

class IntentMatch {
  const IntentMatch({required this.intent, required this.confidence});

  final WellnessIntent intent;
  final double confidence;
}

/// Keyword + pattern scoring classifier — 100% owned by Aaroh, no external models.
class IntentClassifier {
  static final _patterns = <WellnessIntent, List<String>>{
    WellnessIntent.crisis: [
      'suicide',
      'kill myself',
      'end my life',
      'want to die',
      'mar jana',
      'jaan dena',
      'khud ko mar',
      'self harm',
      'khud ko nuksan',
      'marna chahta',
    ],
    WellnessIntent.sleep: [
      'sleep',
      'neend',
      'insomnia',
      'sone',
      'night',
      'raat',
      'jag',
      'awake',
      'bed',
      'tired at night',
      'neend nahi',
    ],
    WellnessIntent.anxiety: [
      'anxiety',
      'anxious',
      'panic',
      'worry',
      'worried',
      'bechain',
      'ghabra',
      'nervous',
      'dar lag',
      'heart racing',
      'overthink',
      'tension',
    ],
    WellnessIntent.depression: [
      'depress',
      'sad',
      'hopeless',
      'empty',
      'udaas',
      'dukhi',
      'mann nahi',
      'motivation nahi',
      'cry',
      'rona',
      'feel low',
      'down feel',
    ],
    WellnessIntent.loneliness: [
      'lonely',
      'alone',
      'akela',
      'akele',
      'no friends',
      'koi nahi',
      'isolated',
      'disconnect',
      'belong nahi',
    ],
    WellnessIntent.stress: [
      'stress',
      'pressure',
      'overwhelm',
      'burnout',
      'kaam',
      'exam',
      'deadline',
      'boss',
      'family pressure',
      'tension',
      'load',
    ],
    WellnessIntent.anger: [
      'angry',
      'gussa',
      'frustrat',
      'irritat',
      'rage',
      'chillana',
      'fight',
    ],
    WellnessIntent.physicalHealth: [
      'pain',
      'headache',
      'fever',
      'sick',
      'ill',
      'dard',
      'bimari',
      'health',
      'body',
      'stomach',
      'chest',
      'doctor',
      'medicine',
      'weight',
    ],
    WellnessIntent.relationship: [
      'relationship',
      'breakup',
      'partner',
      'family',
      'parents',
      'friend',
      'pyaar',
      'rishta',
      'shaadi',
      'divorce',
      'boyfriend',
      'girlfriend',
    ],
    WellnessIntent.motivation: [
      'motivat',
      'purpose',
      'goal',
      'focus',
      'lazy',
      'procrastin',
      'start nahi',
      'mann nahi karta',
      'discipline',
    ],
    WellnessIntent.routine: [
      'routine',
      'habit',
      'schedule',
      'daily',
      'morning',
      'din bhar',
      'plan',
      'productiv',
      'time manage',
    ],
    WellnessIntent.gratitude: [
      'grateful',
      'thankful',
      'blessed',
      'shukr',
      'gratitude',
      'achha din',
    ],
    WellnessIntent.thanks: [
      'thank',
      'shukriya',
      'dhanyavad',
      'thanks aaroh',
      'helpful',
    ],
    WellnessIntent.greeting: [
      'hi',
      'hello',
      'hey',
      'namaste',
      'good morning',
      'good night',
      'kaise ho',
      'kya haal',
      'sup',
    ],
    WellnessIntent.followUp: [
      'haan',
      'yes',
      'ok',
      'theek',
      'samajh',
      'aur',
      'tell me more',
      'phir',
      'aage',
      'continue',
    ],
  };

  IntentMatch classify(String text, {WellnessIntent? lastIntent}) {
    final lower = text.toLowerCase().trim();
    if (lower.length < 2) {
      return const IntentMatch(intent: WellnessIntent.general, confidence: 0.3);
    }

    var best = WellnessIntent.general;
    var bestScore = 0.0;

    for (final entry in _patterns.entries) {
      var score = 0.0;
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          score += keyword.split(' ').length > 1 ? 2.5 : 1.0;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = entry.key;
      }
    }

    // Short affirmations continue previous topic
    if (bestScore < 1.0 && lastIntent != null && lower.split(' ').length <= 4) {
      return IntentMatch(intent: WellnessIntent.followUp, confidence: 0.6);
    }

    if (bestScore == 0) {
      return const IntentMatch(intent: WellnessIntent.general, confidence: 0.4);
    }

    return IntentMatch(
      intent: best,
      confidence: (bestScore / 4).clamp(0.0, 1.0),
    );
  }
}
