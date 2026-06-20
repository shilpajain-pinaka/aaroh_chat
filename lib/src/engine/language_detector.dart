/// Detected language with confidence score.
class DetectedLanguage {
  const DetectedLanguage({
    required this.code,
    required this.name,
    required this.confidence,
  });

  final String code;
  final String name;
  final double confidence;

  static const fallback = DetectedLanguage(
    code: 'en',
    name: 'English',
    confidence: 0.5,
  );
}

/// On-device language detection via script + keyword signals.
class LanguageDetector {
  static final _scriptPatterns = <String, RegExp>{
    'hi': RegExp(r'[\u0900-\u097F]'),
    'bn': RegExp(r'[\u0980-\u09FF]'),
    'ta': RegExp(r'[\u0B80-\u0BFF]'),
    'te': RegExp(r'[\u0C00-\u0C7F]'),
    'gu': RegExp(r'[\u0A80-\u0AFF]'),
    'kn': RegExp(r'[\u0C80-\u0CFF]'),
    'ml': RegExp(r'[\u0D00-\u0D7F]'),
    'pa': RegExp(r'[\u0A00-\u0A7F]'),
    'or': RegExp(r'[\u0B00-\u0B7F]'),
    'ar': RegExp(r'[\u0600-\u06FF]'),
    'zh': RegExp(r'[\u4E00-\u9FFF]'),
    'ja': RegExp(r'[\u3040-\u30FF\u4E00-\u9FFF]'),
    'ko': RegExp(r'[\uAC00-\uD7AF\u1100-\u11FF]'),
    'ru': RegExp(r'[\u0400-\u04FF]'),
    'th': RegExp(r'[\u0E00-\u0E7F]'),
    'he': RegExp(r'[\u0590-\u05FF]'),
  };

  static const _names = {
    'en': 'English',
    'hi': 'Hindi',
    'hinglish': 'Hinglish',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'ar': 'Arabic',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'bn': 'Bengali',
    'ta': 'Tamil',
    'te': 'Telugu',
    'mr': 'Marathi',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'ur': 'Urdu',
    'tr': 'Turkish',
    'vi': 'Vietnamese',
    'th': 'Thai',
    'id': 'Indonesian',
    'it': 'Italian',
    'nl': 'Dutch',
    'pl': 'Polish',
    'sw': 'Swahili',
  };

  static const _keywordSignals = <String, List<String>>{
    'es': ['hola', 'gracias', 'estoy', 'triste', 'ansiedad', 'no puedo dormir'],
    'fr': ['bonjour', 'merci', 'triste', 'anxieux', 'sommeil', 'je suis'],
    'de': ['hallo', 'danke', 'traurig', 'angst', 'schlaf', 'ich bin'],
    'pt': ['olá', 'obrigado', 'triste', 'ansiedade', 'sono', 'estou'],
    'ar': ['مرحبا', 'شكرا', 'حزين', 'قلق', 'نوم'],
    'ja': ['こんにちは', 'ありがとう', '悲しい', '不安', '眠れない'],
    'ko': ['안녕', '감사', '슬프', '불안', '잠'],
    'zh': ['你好', '谢谢', '难过', '焦虑', '失眠'],
    'ru': ['привет', 'спасибо', 'грустно', 'тревога', 'сон'],
    'tr': ['merhaba', 'teşekkür', 'üzgün', 'kaygı', 'uyku'],
    'vi': ['xin chào', 'cảm ơn', 'buồn', 'lo lắng', 'ngủ'],
    'id': ['halo', 'terima kasih', 'sedih', 'cemas', 'tidur'],
    'it': ['ciao', 'grazie', 'triste', 'ansia', 'sonno'],
    'nl': ['hallo', 'dank', 'verdrietig', 'angst', 'slaap'],
    'sw': ['habari', 'asante', 'huzuni', 'wasiwasi'],
    'hi': ['namaste', 'dhanyavad', 'udaas', 'bechain', 'neend', 'kaise'],
    'mr': ['नमस्कार', 'धन्यवाद', 'दुःखी'],
    'ta': ['வணக்கம்', 'நன்றி'],
    'te': ['నమస్కారం', 'ధన్యవాదాలు'],
  };

  static DetectedLanguage detect(String text) {
    if (text.trim().isEmpty) return DetectedLanguage.fallback;

    final scores = <String, double>{};

    for (final entry in _scriptPatterns.entries) {
      if (entry.value.hasMatch(text)) {
        scores[entry.key] = (scores[entry.key] ?? 0) + 3.0;
      }
    }

    final lower = text.toLowerCase();
    for (final entry in _keywordSignals.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw)) {
          scores[entry.key] = (scores[entry.key] ?? 0) + 1.5;
        }
      }
    }

    // Hinglish: mix of Latin + Hindi words
    final hasLatin = RegExp(r'[a-zA-Z]').hasMatch(text);
    final hasHindi = _scriptPatterns['hi']!.hasMatch(text);
    if (hasLatin && hasHindi) {
      scores['hinglish'] = (scores['hinglish'] ?? 0) + 4.0;
    } else if (hasLatin && scores.isEmpty) {
      scores['en'] = 2.0;
    }

    if (scores.isEmpty) {
      return DetectedLanguage.fallback;
    }

    final best = scores.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return DetectedLanguage(
      code: best.key,
      name: _names[best.key] ?? best.key,
      confidence: (best.value / 5).clamp(0.0, 1.0),
    );
  }

  static String nameFor(String code) => _names[code] ?? code;

  /// Wikipedia language code (some mappings).
  static String wikiLang(String code) {
    if (code == 'hinglish') return 'en';
    return code;
  }
}
