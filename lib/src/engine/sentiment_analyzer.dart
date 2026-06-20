/// Sentiment score from our lightweight on-device analyzer.
enum SentimentLevel { distressed, low, neutral, hopeful }

class SentimentResult {
  const SentimentResult({
    required this.level,
    required this.score,
  });

  final SentimentLevel level;
  final double score;
}

/// Rule-based sentiment scoring — no ML models, fully deterministic.
class SentimentAnalyzer {
  static const _distressedWords = [
    'hopeless',
    'suicide',
    'die',
    'kill',
    'mar',
    'marna',
    'khatam',
    'cant go on',
    'give up',
    'haar',
    'tut',
    'broken',
    'empty',
  ];

  static const _lowWords = [
    'sad',
    'depressed',
    'lonely',
    'anxious',
    'scared',
    'tired',
    'exhausted',
    'udaas',
    'akela',
    'dar',
    'thak',
    'pareshan',
    'tension',
    'dukhi',
    'bechain',
    'nervous',
    'worried',
    'stress',
  ];

  static const _hopefulWords = [
    'better',
    'trying',
    'hope',
    'improve',
    'grateful',
    'thanks',
    'achha',
    'theek',
    'try',
    'koshish',
    'shukriya',
    'good',
  ];

  SentimentResult analyze(String text) {
    final lower = text.toLowerCase();
    var score = 0.0;

    for (final w in _distressedWords) {
      if (lower.contains(w)) score -= 2.0;
    }
    for (final w in _lowWords) {
      if (lower.contains(w)) score -= 1.0;
    }
    for (final w in _hopefulWords) {
      if (lower.contains(w)) score += 0.8;
    }

    final level = switch (score) {
      <= -3 => SentimentLevel.distressed,
      < -0.5 => SentimentLevel.low,
      > 0.5 => SentimentLevel.hopeful,
      _ => SentimentLevel.neutral,
    };

    return SentimentResult(level: level, score: score);
  }
}
