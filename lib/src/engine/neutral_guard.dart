import 'wellness_intent.dart';

/// Neutral, ideology-free framing — science & empathy, no bias.
class NeutralGuard {
  NeutralGuard._();

  static final _biasedPatterns = [
    RegExp(r'\b(only|always)\s+(hindu|muslim|christian|bjp|congress)\b',
        caseSensitive: false),
    RegExp(r'\bmen are\b|\bwomen are\b', caseSensitive: false),
  ];

  static String frame(String text, String langCode) {
    var result = text;
    for (final p in _biasedPatterns) {
      result = result.replaceAll(p, '');
    }
    return result.trim();
  }

  static String neutralPreamble(String langCode) {
    return switch (langCode) {
      'hi' =>
        '🧭 तटस्थ दृष्टि: मैं किसी राजनीति या धर्म को promote नहीं करता — केवल स्वास्थ्य और कल्याण पर ध्यान।',
      'es' =>
        '🧭 Perspectiva neutral: sin sesgo político o religioso — solo bienestar.',
      'fr' =>
        '🧭 Perspective neutre : pas de biais politique ou religieux — bien-être seulement.',
      'ar' => '🧭 منظور محايد: لا تحيز سياسي أو ديني — العافية فقط.',
      'zh' => '🧭 中立观点：无政治或宗教偏见——仅关注健康。',
      'ja' => '🧭 中立的な視点：政治・宗教の偏りなし—健康のみ。',
      _ =>
        '🧭 Neutral view: no political or religious bias — wellness & facts only.',
    };
  }

  static String sourceLine(String source, String langCode) {
    return switch (langCode) {
      'hi' => '\n\n📚 स्रोत: $source',
      'es' => '\n\n📚 Fuente: $source',
      'fr' => '\n\n📚 Source : $source',
      'ar' => '\n\n📚 المصدر: $source',
      _ => '\n\n📚 Source: $source',
    };
  }

  static String learnNote(String langCode) {
    return switch (langCode) {
      'hi' =>
        '\n\n📝 मैंने तुम्हारी बात याद रखी — अगली बार और बेहतर मदद करूँगा।',
      'es' =>
        '\n\n📝 Recordé lo que compartiste — mejoraré mis respuestas para ti.',
      _ =>
        '\n\n📝 I noted what you shared — I\'ll personalize better next time.',
    };
  }

  static List<String> clarifyQuestions(
    WellnessIntent intent,
    String langCode,
  ) {
    return switch (langCode) {
      'hi' => _hiClarify(intent),
      'es' => _esClarify(intent),
      'fr' => _frClarify(intent),
      'ar' => _arClarify(intent),
      'zh' => _zhClarify(intent),
      'ja' => _jaClarify(intent),
      'ko' => _koClarify(intent),
      'pt' => _ptClarify(intent),
      'ru' => _ruClarify(intent),
      'bn' => _bnClarify(intent),
      'ta' => _taClarify(intent),
      'te' => _teClarify(intent),
      'tr' => _trClarify(intent),
      'vi' => _viClarify(intent),
      'id' => _idClarify(intent),
      'hinglish' => _hinglishClarify(intent),
      _ => _enClarify(intent),
    };
  }

  static List<String> _enClarify(WellnessIntent intent) => switch (intent) {
        WellnessIntent.sleep => [
            'How long has sleep been difficult — days or weeks?',
            'Do you struggle to fall asleep or wake up during the night?',
          ],
        WellnessIntent.anxiety => [
            'When do you feel most anxious — morning, evening, or all day?',
            'Does anything specific trigger it?',
          ],
        WellnessIntent.depression => [
            'How long have you been feeling this way?',
            'Are you able to do daily tasks, or is everything feeling heavy?',
          ],
        WellnessIntent.loneliness => [
            'Do you feel lonely even around people, or mostly when alone?',
            'When did you last talk openly with someone you trust?',
          ],
        WellnessIntent.stress => [
            'What is the main source — work, family, studies, or health?',
            'On a scale of 1-10, how intense is the stress right now?',
          ],
        WellnessIntent.physicalHealth => [
            'What symptoms are you experiencing and for how long?',
            'Any pain, fever, or changes in appetite/sleep?',
          ],
        _ => [
            'Can you tell me a bit more about what you\'re going through?',
            'What would help most right now — listening, advice, or both?',
          ],
      };

  static List<String> _hinglishClarify(WellnessIntent intent) =>
      switch (intent) {
        WellnessIntent.sleep => [
            'Neend ki problem kitne din se hai?',
            'Sone mein problem hai ya beech mein uth jaate ho?',
          ],
        WellnessIntent.anxiety => [
            'Anxiety kab zyada hoti hai — subah, shaam, ya poora din?',
            'Koi specific trigger hai kya?',
          ],
        WellnessIntent.depression => [
            'Yeh feeling kitne time se hai?',
            'Daily kaam ho pa rahe hain ya sab bhari lag raha hai?',
          ],
        _ => [
            'Thoda aur detail mein bataoge kya chal raha hai?',
            'Abhi sunna chahte ho, advice, ya dono?',
          ],
      };

  static List<String> _hiClarify(WellnessIntent intent) => switch (intent) {
        WellnessIntent.sleep => [
            'नींद की समस्या कब से है?',
            'सोने में दिक्कत है या बीच में जाग जाते हो?',
          ],
        WellnessIntent.anxiety => [
            'चिंता कब सबसे ज़्यादा होती है?',
            'कोई खास कारण है?',
          ],
        _ => [
            'थोड़ा और बताएंगे क्या हो रहा है?',
            'सुनना चाहते हो या सलाह?',
          ],
      };

  static List<String> _esClarify(WellnessIntent intent) => [
        '¿Desde cuándo te sientes así?',
        '¿Qué es lo que más te preocupa ahora?',
      ];

  static List<String> _frClarify(WellnessIntent intent) => [
        'Depuis combien de temps ressentez-vous cela ?',
        'Qu\'est-ce qui vous préoccupe le plus ?',
      ];

  static List<String> _arClarify(WellnessIntent intent) => [
        'منذ متى وأنت تشعر بذلك؟',
        'ما أكثر شيء يقلقك الآن؟',
      ];

  static List<String> _zhClarify(WellnessIntent intent) => [
        '这种感觉持续多久了？',
        '现在最困扰你的是什么？',
      ];

  static List<String> _jaClarify(WellnessIntent intent) => [
        'いつからそう感じていますか？',
        '今いちばん気になることは何ですか？',
      ];

  static List<String> _koClarify(WellnessIntent intent) => [
        '언제부터 이런 기분이었나요?',
        '지금 가장 걱정되는 것은 무엇인가요?',
      ];

  static List<String> _ptClarify(WellnessIntent intent) => [
        'Há quanto tempo você se sente assim?',
        'O que mais te preocupa agora?',
      ];

  static List<String> _ruClarify(WellnessIntent intent) => [
        'Как давно вы так себя чувствуете?',
        'Что больше всего беспокоит сейчас?',
      ];

  static List<String> _bnClarify(WellnessIntent intent) => [
        'কতদিন ধরে এমন লাগছে?',
        'এখন সবচেয়ে বেশি কী চিন্তা করছেন?',
      ];

  static List<String> _taClarify(WellnessIntent intent) => [
        'எவ்வளவு நாட்களாக இப்படி உணர்கிறீர்கள்?',
        'இப்போது அதிகம் கவலை என்ன?',
      ];

  static List<String> _teClarify(WellnessIntent intent) => [
        'ఎంత కాలంగా ఇలా అనిపిస్తోంది?',
        'ఇప్పుడు ఎక్కువగా ఏమి చింతిస్తున్నారు?',
      ];

  static List<String> _trClarify(WellnessIntent intent) => [
        'Ne zamandan beri böyle hissediyorsun?',
        'Şu an en çok ne seni endişelendiriyor?',
      ];

  static List<String> _viClarify(WellnessIntent intent) => [
        'Bạn cảm thấy như vậy từ bao lâu rồi?',
        'Điều gì lo lắng bạn nhất bây giờ?',
      ];

  static List<String> _idClarify(WellnessIntent intent) => [
        'Sudah berapa lama kamu merasa seperti ini?',
        'Apa yang paling membuatmu khawatir sekarang?',
      ];

  static String clarifyIntro(String langCode, String? name) {
    final n = name != null && name.isNotEmpty ? '$name, ' : '';
    return switch (langCode) {
      'hi' => '${n}तुम्हारी बात पूरी तरह समझने के लिए, कुछ सवाल पूछना चाहूँगा:',
      'es' => '${n}Para entenderte mejor, déjame hacerte algunas preguntas:',
      'fr' =>
        '${n}Pour mieux vous comprendre, permettez-moi de poser quelques questions :',
      'ar' => '${n}لفهمك بشكل أفضل، دعني أسأل بعض الأسئلة:',
      'zh' => '${n}为了更好地理解你，我想问几个问题：',
      'ja' => '${n}よりよく理解するために、いくつか質問させてください：',
      'hinglish' =>
        '${n}Tumhari baat poori tarah samajhne ke liye, kuch sawaal poochhna chahunga/chahungi:',
      _ => '${n}To understand you better, let me ask a few questions:',
    };
  }

  static String acknowledge(String langCode, String? name) {
    final n = name != null && name.isNotEmpty ? '$name, ' : '';
    return switch (langCode) {
      'hi' => '${n}मैं सुन रहा हूँ। तुम्हारी भावनाएँ valid हैं।',
      'es' => '${n}Te escucho. Tus sentimientos son válidos.',
      'fr' => '${n}Je vous écoute. Vos sentiments sont valides.',
      'ar' => '${n}أسمعك. مشاعرك مهمة وصحيحة.',
      'zh' => '${n}我在听。你的感受是合理的。',
      'ja' => '${n}聞いています。あなたの気持ちは大切です。',
      'hinglish' => '${n}Main sun raha hoon. Tumhari feelings valid hain.',
      _ => '${n}I hear you. Your feelings are valid.',
    };
  }

  static String medicalDisclaimer(String langCode) {
    return switch (langCode) {
      'hi' =>
        '\n\n⚕️ मैं डॉक्टर नहीं हूँ — यह सामान्य मार्गदर्शन है। गंभीर समस्या में विशेषज्ञ से मिलें।',
      'es' =>
        '\n\n⚕️ No soy médico — orientación general. Consulte a un profesional.',
      'fr' =>
        '\n\n⚕️ Je ne suis pas médecin — conseils généraux. Consultez un professionnel.',
      'ar' => '\n\n⚕️ لست طبيباً — إرشاد عام فقط. راجع مختصاً عند الحاجة.',
      'zh' => '\n\n⚕️ 我不是医生——仅供参考。严重情况请咨询专业人士。',
      'hinglish' =>
        '\n\n⚕️ Main doctor nahi hoon — general guidance hai. Serious ho to specialist se consult karo.',
      _ =>
        '\n\n⚕️ I\'m not a doctor — general guidance only. See a professional for serious concerns.',
    };
  }
}
