import 'package:aaroh_chat/src/models/user_settings.dart';
import 'sentiment_analyzer.dart';
import 'wellness_intent.dart';

/// Multilingual response building blocks — owned entirely by Aaroh.
class ResponseTemplates {
  static String acknowledge(
    LanguageTone tone,
    SentimentLevel sentiment,
    String? name,
  ) {
    final n = name != null && name.isNotEmpty ? '$name, ' : '';
    return switch (tone) {
      LanguageTone.hindi => switch (sentiment) {
          SentimentLevel.distressed =>
            '${n}मुझे पता है यह बहुत मुश्किल लग रहा है। तुम अकेले नहीं हो।',
          SentimentLevel.low =>
            '${n}सुनकर लगा कि तुम काफ़ी थके हुए महसूस कर रहे हो। यह महसूस करना ठीक है।',
          SentimentLevel.hopeful =>
            '${n}यह सुनकर अच्छा लगा कि तुम कोशिश कर रहे हो।',
          SentimentLevel.neutral => '${n}सुनो, मैं यहाँ हूँ।',
        },
      LanguageTone.english => switch (sentiment) {
          SentimentLevel.distressed =>
            "${n}I hear how heavy this feels. You're not alone in this.",
          SentimentLevel.low =>
            "${n}It sounds like you've been carrying a lot. That's valid.",
          SentimentLevel.hopeful =>
            "${n}I'm glad you're reaching out and trying.",
          SentimentLevel.neutral => "${n}I'm here with you.",
        },
      LanguageTone.hinglish => switch (sentiment) {
          SentimentLevel.distressed =>
            '${n}Mujhe pata hai yeh bohot tough lag raha hai... tum akeli/akele nahi ho.',
          SentimentLevel.low =>
            '${n}Sunke laga tum kaafi thak gaye ho. Yeh feel karna bilkul okay hai.',
          SentimentLevel.hopeful =>
            '${n}Yeh sunke achha laga ki tum try kar rahe ho 💛',
          SentimentLevel.neutral => '${n}Main yahan hoon, suno.',
        },
    };
  }

  static String bodyForIntent(WellnessIntent intent, LanguageTone tone) {
    return switch (intent) {
      WellnessIntent.greeting => _greeting(tone),
      WellnessIntent.sleep => _sleep(tone),
      WellnessIntent.anxiety => _anxiety(tone),
      WellnessIntent.depression => _depression(tone),
      WellnessIntent.loneliness => _loneliness(tone),
      WellnessIntent.stress => _stress(tone),
      WellnessIntent.anger => _anger(tone),
      WellnessIntent.physicalHealth => _physical(tone),
      WellnessIntent.relationship => _relationship(tone),
      WellnessIntent.motivation => _motivation(tone),
      WellnessIntent.routine => _routine(tone),
      WellnessIntent.gratitude => _gratitude(tone),
      WellnessIntent.thanks => _thanks(tone),
      WellnessIntent.crisis => _crisis(tone),
      WellnessIntent.followUp => _followUp(tone),
      WellnessIntent.general => _general(tone),
    };
  }

  static String followUpQuestion(WellnessIntent intent, LanguageTone tone) {
    return switch (tone) {
      LanguageTone.hindi => switch (intent) {
          WellnessIntent.sleep =>
            'क्या रात में ज़्यादा सोचते हो या बस नींद नहीं आती?',
          WellnessIntent.anxiety =>
            'यह feeling कब सबसे ज़्यादा होती है — सुबह या रात?',
          WellnessIntent.loneliness =>
            'क्या किसी से बात करने का मन है या पहले खुद को समझना चाहते हो?',
          _ => 'थोड़ा और बताओगे क्या चल रहा है?',
        },
      LanguageTone.english => switch (intent) {
          WellnessIntent.sleep =>
            'Do you overthink at night, or is it more physical restlessness?',
          WellnessIntent.anxiety =>
            'When does it hit hardest — mornings or nights?',
          WellnessIntent.loneliness =>
            'Do you want to talk to someone, or process this quietly first?',
          _ => "Would you like to share a bit more about what's going on?",
        },
      LanguageTone.hinglish => switch (intent) {
          WellnessIntent.sleep =>
            'Raat mein zyada sochte ho ya bas neend hi nahi aati?',
          WellnessIntent.anxiety =>
            'Yeh feeling kab sabse zyada hoti hai — subah ya raat?',
          WellnessIntent.loneliness =>
            'Kisi se baat karna chahte ho ya pehle khud samajhna?',
          _ => 'Thoda aur batayoge kya chal raha hai?',
        },
    };
  }

  static String medicalDisclaimer(LanguageTone tone) {
    return switch (tone) {
      LanguageTone.hindi =>
        '\n\n⚕️ मैं डॉक्टर नहीं हूँ — यह सामान्य मार्गदर्शन है। गंभीर समस्या में कृपया योग्य डॉक्टर या काउंसलर से मिलें।',
      LanguageTone.english =>
        '\n\n⚕️ I\'m not a doctor — this is general guidance only. Please see a qualified professional for serious concerns.',
      LanguageTone.hinglish =>
        '\n\n⚕️ Main doctor nahi hoon — yeh sirf general guidance hai. Serious ho to please qualified doctor ya counselor se consult karo.',
    };
  }

  static String _greeting(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'मैं आरोह हूँ — तुम्हारा साथी। स्वास्थ्य, मन और ज़िंदगी की बातें बिना जज किए कर सकते हो।',
        LanguageTone.english =>
          "I'm Aaroh — your companion for health, mind, and growth. Share freely, no judgment.",
        LanguageTone.hinglish =>
          'Main Aaroh hoon — health, mann aur growth ke liye tumhara saathi. Bina judgment share karo.',
      };

  static String _sleep(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'नींद के लिए छोटे कदम:\n• हर रात एक ही समय सोने की कोशिश\n• सोने से 1 घंटे पहले स्क्रीन कम\n• हल्की सांस: 4 सेकंड अंदर, 6 बाहर\n• दिन में 15 मिनट धूप या टहलना',
        LanguageTone.english =>
          'Small steps for sleep:\n• Same bedtime each night\n• Less screen 1 hour before bed\n• Breathing: 4 sec in, 6 sec out\n• 15 min daylight or walk daily',
        LanguageTone.hinglish =>
          'Neend ke liye chhote steps:\n• Roz same time sone ki koshish\n• Sone se 1 ghanta pehle screen kam\n• Breathing: 4 sec andar, 6 bahar\n• Din mein 15 min walk ya dhoop',
      };

  static String _anxiety(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'चिंता कम करने के लिए:\n• 5-4-3-2-1 ग्राउंडिंग: 5 चीज़ें देखो, 4 छुओ...\n• धीमी सांस 2 मिनट\n• एक बार में एक काम — पूरा दिन नहीं सोचना\n• कैफीन शाम को कम',
        LanguageTone.english =>
          'For anxiety:\n• 5-4-3-2-1 grounding: 5 things you see, 4 you touch...\n• Slow breath 2 minutes\n• One task at a time — not the whole day\n• Less caffeine after noon',
        LanguageTone.hinglish =>
          'Anxiety ke liye:\n• 5-4-3-2-1 grounding try karo\n• 2 min slow breathing\n• Ek time pe ek kaam — poora din ek saath mat socho\n• Shaam ko caffeine kam',
      };

  static String _depression(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'जब मन भारी हो:\n• छोटी जीत: बिस्तर से उठना, पानी पीना भी गिनती है\n• एक दोस्त/परिवार को एक मैसेज\n• 10 मिनट बाहर निकलना\n• खुद को बुरा महसूस करने की जगह आराम दो',
        LanguageTone.english =>
          'When mood is heavy:\n• Small wins count — getting up, drinking water\n• One message to someone you trust\n• 10 minutes outside\n• Rest instead of blaming yourself',
        LanguageTone.hinglish =>
          'Jab mann bhari ho:\n• Chhoti jeet count karo — uthna, paani peena bhi\n• Kisi trusted ko ek message\n• 10 min bahar nikalna\n• Khud ko blame ki jagah thoda rest',
      };

  static String _loneliness(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'अकेलापन मुश्किल है, पर अस्थायी हो सकता है:\n• वॉलंटियर या क्लब में जुड़ना\n• पुराने दोस्त को हाय बोलना\n• रोज़ एक छोटी दिनचर्या\n• याद रखो — connection छोटे कदमों से शुरू होता है',
        LanguageTone.english =>
          'Loneliness hurts, but can shift:\n• Join a club or volunteer\n• Say hi to an old friend\n• One small daily ritual\n• Connection starts with tiny steps',
        LanguageTone.hinglish =>
          'Akelapan tough hai par shift ho sakta hai:\n• Kisi club/volunteer mein judo\n• Purane dost ko hi bhi likho\n• Roz ek chhoti routine\n• Connection chhote steps se shuru hota hai',
      };

  static String _stress(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'तनाव कम करने के लिए:\n• सूची बनाओ — जरूरी vs बाद में\n• 5 मिनट ब्रेक लो हर घंटे\n• शरीर को हिलाओ — stretch या walk\n• "नहीं" कहना ठीक है',
        LanguageTone.english =>
          'For stress:\n• List tasks — urgent vs later\n• 5 min break each hour\n• Move your body — stretch or walk\n• Saying no is okay',
        LanguageTone.hinglish =>
          'Stress ke liye:\n• List banao — urgent vs baad mein\n• Har hour 5 min break\n• Body move karo — stretch/walk\n• "Nahi" kehna okay hai',
      };

  static String _anger(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'गुस्सा आना normal है:\n• गिनती 10 तक, फिर बोलो\n• ठंडा पानी या चेहरे पर पानी\n• लिखकर निकालो — भेजने की जरूरत नहीं\n• बाद में शांति से बात करो',
        LanguageTone.english =>
          'Anger is normal:\n• Count to 10 before reacting\n• Cool water on face\n• Write it out — don\'t have to send\n• Talk calmly later',
        LanguageTone.hinglish =>
          'Gussa normal hai:\n• 10 tak count karo, phir bolo\n• Thanda paani / face pe paani\n• Likho — bhejna zaroori nahi\n• Baad mein calmly baat karo',
      };

  static String _physical(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'शरीर की सेहत के लिए:\n• पानी और आराम जरूरी\n• लक्षण 2-3 दिन से ज्यादा हों तो डॉक्टर\n• दर्द की डायरी रखना मदद करता है\n• अपने आप दवा न लें',
        LanguageTone.english =>
          'For physical health:\n• Hydration and rest matter\n• See a doctor if symptoms last 2-3+ days\n• Pain diary can help\n• Don\'t self-medicate',
        LanguageTone.hinglish =>
          'Health ke liye:\n• Paani aur rest zaroori\n• 2-3 din se zyada symptom ho to doctor\n• Pain diary helpful hoti hai\n• Khud se medicine mat lo',
      };

  static String _relationship(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'रिश्तों में:\n• अपनी भावना "मैं" भाषा से बताओ\n• सुनना भी जरूरी है\n• सीमा तय करना स्वस्थ है\n• टूटा रिश्ता ठीक होने में समय लेता है',
        LanguageTone.english =>
          'In relationships:\n• Use "I feel" language\n• Listening matters too\n• Boundaries are healthy\n• Healing takes time',
        LanguageTone.hinglish =>
          'Rishton mein:\n• "Main feel karta/karti hoon" se bolo\n• Sunna bhi zaroori hai\n• Boundaries healthy hain\n• Healing mein time lagta hai',
      };

  static String _motivation(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'प्रेरणा के लिए:\n• सिर्फ 5 मिनट शुरू करो — बाकी अक्सर आ जाता है\n• बड़ा लक्ष्य छोटे टुकड़ों में\n• खुद को इनाम दो छोटी जीत पर\n• तुलना कम, अपनी गति पर ध्यान',
        LanguageTone.english =>
          'For motivation:\n• Start with just 5 minutes\n• Break big goals into tiny pieces\n• Reward small wins\n• Less comparison, your own pace',
        LanguageTone.hinglish =>
          'Motivation ke liye:\n• Sirf 5 min shuru karo — baaki often aa jata hai\n• Bada goal chhote parts mein\n• Chhoti jeet par khud ko treat\n• Compare kam, apni speed par focus',
      };

  static String _routine(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'दिनचर्या बनाने के लिए:\n• सुबह 1 आसान आदत (पानी / stretch)\n• 3 प्राथमिकता लिखो\n• एक ही समय सोना-उठना\n• परफेक्ट नहीं, consistent रहो',
        LanguageTone.english =>
          'Building routine:\n• 1 easy morning habit (water/stretch)\n• Write 3 priorities\n• Consistent sleep/wake time\n• Progress over perfect',
        LanguageTone.hinglish =>
          'Routine ke liye:\n• Subah 1 easy habit (paani/stretch)\n• 3 priorities likho\n• Same time sona-uthna\n• Perfect nahi, consistent raho',
      };

  static String _gratitude(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'कृतज्ञता अच्छी आदत है। रोज़ एक छोटी चीज़ लिखो जो आज ठीक रही — दिमाग धीरे-धीरे बदलता है।',
        LanguageTone.english =>
          'Gratitude helps. Write one small good thing daily — the mind slowly shifts.',
        LanguageTone.hinglish =>
          'Gratitude acchi habit hai. Roz ek chhoti cheez likho jo aaj theek rahi — mind slowly shift hota hai.',
      };

  static String _thanks(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'तुम्हारा धन्यवाद। जब भी जरूरत हो, मैं यहाँ हूँ। अपना ख्याल रखना 💛',
        LanguageTone.english =>
          'Thank you. I\'m here whenever you need. Take care of yourself 💛',
        LanguageTone.hinglish =>
          'Thank you yaar. Jab bhi chahiye main yahan hoon. Apna khayal rakhna 💛',
      };

  static String _crisis(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'तुम्हारी जान बहुत कीमती है। अभी किसी से बात करो:\n• iCall: 9152987821\n• AASRA: 9820466726\n• Vandrevala: 1860-2662-345\n• Tele-MANAS: 14416\n\nतुम अकेले नहीं हो। अभी कोई trusted व्यक्ति या हेल्पलाइन से संपर्क करो।',
        LanguageTone.english =>
          'Your life matters deeply. Please reach out now:\n• iCall: 9152987821\n• AASRA: 9820466726\n• Vandrevala: 1860-2662-345\n• Tele-MANAS: 14416\n\nYou are not alone. Contact someone you trust or a helpline right now.',
        LanguageTone.hinglish =>
          'Tumhari jaan bohot valuable hai. Abhi kisi se baat karo:\n• iCall: 9152987821\n• AASRA: 9820466726\n• Vandrevala: 1860-2662-345\n• Tele-MANAS: 14416\n\nTum akeli/akele nahi ho. Abhi kisi trusted insaan ya helpline ko call karo.',
      };

  static String _followUp(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'अच्छा। पिछली बात पर आगे बढ़ते हैं — छोटे कदम भी असर डालते हैं। एक चीज़ आज try कर सकते हो?',
        LanguageTone.english =>
          'Good. Building on what we discussed — small steps matter. One thing you could try today?',
        LanguageTone.hinglish =>
          'Theek hai. Jo pehle baat hui us par aage — chhote steps bhi matter karte hain. Aaj ek cheez try kar sakte ho?',
      };

  static String _general(LanguageTone t) => switch (t) {
        LanguageTone.hindi =>
          'मैं सुन रहा हूँ। थोड़ा और बताओ — नींद, तनाव, अकेलापन, या कुछ और? साथ में सोचते हैं।',
        LanguageTone.english =>
          "I'm listening. Tell me more — sleep, stress, loneliness, or something else? We'll figure it out together.",
        LanguageTone.hinglish =>
          'Main sun raha hoon. Thoda aur batao — neend, stress, akelapan, ya kuch aur? Saath mein sochte hain.',
      };
}
