import 'dart:math';
import 'package:aaroh_chat/src/models/chat_message.dart';
import 'package:aaroh_chat/src/models/user_settings.dart';
import 'sentiment_analyzer.dart';

// ─────────────────────────────────────────────
// TOPIC  (fine-grained, >50 patterns each)
// ─────────────────────────────────────────────
enum Topic {
  greeting,
  crisis,
  sleepProblem,
  sleepAdvice,
  anxietyFeelings,
  anxietyTips,
  depressionFeelings,
  depressionTips,
  stressWork,
  stressExam,
  stressFamily,
  lonelinessDeep,
  lonelinessLight,
  relationshipBreakup,
  relationshipFamily,
  relationshipFriends,
  angerFeelings,
  angerTips,
  motivationLow,
  motivationGoals,
  routineBuilding,
  routineStruggle,
  physicalPain,
  physicalGeneral,
  gratitude,
  thanks,
  continuationAffirm,
  continuationAskMore,
  general
}

// ─────────────────────────────────────────────
// CONVERSATION MEMORY
// ─────────────────────────────────────────────
class ConversationMemory {
  final List<_Turn> _turns = [];
  final Set<Topic> _covered = {};
  final Set<String> _usedOpenings = {};
  final Set<String> _usedResponses = {};
  Topic? lastTopic;
  int _consecutiveSameTopic = 0;

  void record(Topic topic, String response) {
    if (topic == lastTopic) {
      _consecutiveSameTopic++;
    } else {
      _consecutiveSameTopic = 0;
    }
    lastTopic = topic;
    _covered.add(topic);
    _usedResponses.add(response.substring(0, min(40, response.length)));
    _turns.add(_Turn(topic: topic, response: response));
  }

  bool hasCovered(Topic t) => _covered.contains(t);
  int get consecutiveSameTopic => _consecutiveSameTopic;

  // What has the user mentioned in recent turns?
  List<String> recentUserMessages(List<ChatMessage> history, {int n = 4}) =>
      history
          .where((m) => m.role == MessageRole.user)
          .toList()
          .reversed
          .take(n)
          .map((m) => m.content.toLowerCase())
          .toList();

  // Was a specific keyword mentioned recently?
  bool mentionedRecently(List<ChatMessage> history, List<String> keywords) {
    final recent = recentUserMessages(history, n: 6).join(' ');
    return keywords.any((k) => recent.contains(k));
  }

  String pickFresh(List<String> options) {
    final unused = options
        .where(
            (o) => !_usedOpenings.contains(o.substring(0, min(20, o.length))))
        .toList();
    final pool = unused.isNotEmpty ? unused : options;
    final pick = pool[Random().nextInt(pool.length)];
    _usedOpenings.add(pick.substring(0, min(20, pick.length)));
    return pick;
  }

  void reset() {
    _turns.clear();
    _covered.clear();
    _usedOpenings.clear();
    _usedResponses.clear();
    lastTopic = null;
    _consecutiveSameTopic = 0;
  }
}

class _Turn {
  _Turn({required this.topic, required this.response});
  final Topic topic;
  final String response;
}

// ─────────────────────────────────────────────
// TOPIC CLASSIFIER  (pattern scoring)
// ─────────────────────────────────────────────
class TopicClassifier {
  static const _patterns = <Topic, List<String>>{
    Topic.crisis: [
      'suicide',
      'kill myself',
      'end my life',
      'want to die',
      'no point living',
      'marna chahta',
      'mar jana',
      'jaan dena',
      'khud ko mar',
      'self harm',
      'khud ko nuksan',
      'hurt myself',
      'better off dead',
      'can\'t go on',
      'khatam karna chahta',
      'jeena nahi chahta',
    ],
    Topic.greeting: [
      'hi ',
      'hello',
      'hey ',
      'namaste',
      'good morning',
      'good evening',
      'good night',
      'good afternoon',
      'kaise ho',
      'kya haal',
      'sup ',
      'hola',
      'what\'s up',
      'howdy',
      'wassup',
      'yo ',
      'heya',
      'hii',
      'hyyy',
    ],
    Topic.sleepProblem: [
      'can\'t sleep',
      'neend nahi',
      'insomnia',
      'awake all night',
      'raat bhar jaga',
      'sone ki koshish',
      'tossing and turning',
      'can\'t fall asleep',
      'sleep problem',
      'neend nahi aati',
      'anidra',
      'jagta rehta',
      'late night',
      'sleep issues',
      'sleep disorder',
      'uthna nahi hota',
      'bed pe ghante baith',
      'overthink at night',
      '3am',
      '2am',
      '4am',
      'all night awake',
      'raat ko neend',
      'nahi sota',
    ],
    Topic.sleepAdvice: [
      'sleep better',
      'neend kaise aaye',
      'tips for sleep',
      'sleep hygiene',
      'improve sleep',
      'how to sleep',
      'sleeping tips',
      'kya karun neend',
    ],
    Topic.anxietyFeelings: [
      'anxious',
      'anxiety',
      'panic attack',
      'heart racing',
      'chest tight',
      'bechain',
      'ghabra',
      'dar lag',
      'nervous',
      'overthinking',
      'overthink karta',
      'racing thoughts',
      'can\'t stop thinking',
      'mind won\'t stop',
      'worried all time',
      'bahut dar',
      'bahut ghabra',
      'restless',
      'uneasy',
      'on edge',
      'pit in stomach',
      'cant breathe',
      'shallow breathing',
      'butterflies',
      'dread',
      'what if',
      'fear of',
      'phobia',
      'scared of',
      'bahut tense',
      'har cheez se darr',
    ],
    Topic.anxietyTips: [
      'anxiety tips',
      'how to calm',
      'control anxiety',
      'anxiety kaise kam',
      'stop overthinking',
      'grounding',
      'breathing exercise',
      'panic attack control',
    ],
    Topic.depressionFeelings: [
      'depressed',
      'feel empty',
      'numb',
      'hopeless',
      'worthless',
      'no point',
      'udaas',
      'dukhi',
      'mann nahi',
      'rona aa raha',
      'cry all day',
      'feel nothing',
      'can\'t get out of bed',
      'dark place',
      'don\'t want to do anything',
      'kuch nahi karna',
      'koi umeed nahi',
      'khud ko blame',
      'self blame',
      'feel like burden',
      'hate myself',
      'wish i wasn\'t here',
      'heavy feeling',
      'feeling low',
      'feel so low',
      'so low',
      'jee nahi lagta',
      'kuch bhi acha nahi',
      'duniya mein kya',
      'why even',
      'sab bekar',
      'kuch nahi bacha',
    ],
    Topic.depressionTips: [
      'how to feel better',
      'depression help',
      'get out of depression',
      'depression se kaise nikaale',
      'motivation nahi',
      'kuch karna nahi',
    ],
    Topic.stressWork: [
      'work stress',
      'job stress',
      'boss',
      'deadline',
      'office',
      'workload',
      'burnout',
      'kaam ka pressure',
      'job mein problem',
      'project',
      'meeting',
      'promotion',
      'salary',
      'career stress',
      'colleague',
      'coworker',
      'manager',
      'appraisal',
      'resignation',
      'quit job',
      'work life balance',
    ],
    Topic.stressExam: [
      'exam',
      'test stress',
      'study stress',
      'marks',
      'result',
      'fail',
      'failed',
      'board exam',
      'entrance',
      'competitive exam',
      'jee',
      'neet',
      'upsc',
      'padhai ka tension',
      'revision',
      'syllabus',
      'pressure of studies',
    ],
    Topic.stressFamily: [
      'family pressure',
      'parents pressure',
      'ghar ka tension',
      'family stress',
      'gharwale',
      'mummy papa',
      'mom dad',
      'expectations',
      'ghar mein ladai',
    ],
    Topic.lonelinessDeep: [
      'no one cares',
      'completely alone',
      'no friends at all',
      'nobody understands',
      'koi nahi samjhta',
      'bilkul akela',
      'koi mere liye nahi',
      'invisible',
      'feel invisible',
      'nobody notices',
      'don\'t belong',
      'never fit in',
      'isolated',
      'disconnected',
      'no one to talk to',
      'bohot akela',
    ],
    Topic.lonelinessLight: [
      'lonely',
      'akela',
      'miss people',
      'miss friends',
      'alone',
      'akelapan',
      'isolated feeling',
      'want connection',
      'want friends',
      'no friends',
    ],
    Topic.relationshipBreakup: [
      'breakup',
      'broke up',
      'ex',
      'heartbreak',
      'he left',
      'she left',
      'dumped',
      'relationship over',
      'dil toota',
      'pyaar mein dhoka',
      'betrayed',
      'cheated on',
      'he cheated',
      'she cheated',
      'end of relationship',
      'can\'t get over',
    ],
    Topic.relationshipFamily: [
      'parents fight',
      'family argument',
      'not talking to family',
      'family toxic',
      'parents don\'t understand',
      'gharwale nahi samjhte',
      'abusive family',
      'family issues',
      'ghar mein tension',
      'sibling fight',
      'brother sister fight',
    ],
    Topic.relationshipFriends: [
      'friend betrayed',
      'fake friends',
      'lost friends',
      'friend issue',
      'friendship over',
      'dost ne dhoka',
      'yaar ne chora',
      'no real friends',
      'friend fight',
      'dost se larai',
    ],
    Topic.angerFeelings: [
      'angry',
      'gussa',
      'so mad',
      'furious',
      'rage',
      'irritated',
      'frustrated',
      'want to scream',
      'bahut gussa',
      'chillana chahta',
      'hit something',
      'anger issues',
      'lose temper',
      'can\'t control anger',
      'passive aggressive',
    ],
    Topic.motivationLow: [
      'no motivation',
      'lazy',
      'procrastinating',
      'can\'t start',
      'stuck',
      'unmotivated',
      'mann nahi karta',
      'kuch nahi karna',
      'uthna nahi',
      'productive nahi',
      'wasting time',
      'doing nothing',
      'feel useless',
      'going nowhere',
    ],
    Topic.motivationGoals: [
      'achieve goals',
      'want to improve',
      'how to be productive',
      'discipline',
      'build habits',
      'success',
      'goal set',
      'focus karna',
      'better version',
    ],
    Topic.routineBuilding: [
      'build routine',
      'morning routine',
      'daily schedule',
      'how to be consistent',
      'habit formation',
      'routine banana',
      'productive day',
      'plan my day',
    ],
    Topic.routineStruggle: [
      'routine nahi banta',
      'can\'t stick to routine',
      'inconsistent',
      'no schedule',
      'irregular',
      'no discipline',
      'sleep schedule disturbed',
      'roz alag time',
    ],
    Topic.physicalPain: [
      'headache',
      'sir dard',
      'body pain',
      'badan dard',
      'back pain',
      'neck pain',
      'chest pain',
      'stomach pain',
      'pet dard',
      'nausea',
      'ulti',
      'vomit',
      'fatigue',
      'bahut thaka',
      'exhausted',
      'no energy',
      'fever',
      'bukhar',
    ],
    Topic.physicalGeneral: [
      'health',
      'weight',
      'diet',
      'exercise',
      'workout',
      'khaana',
      'khana nahi',
      'eat less',
      'eating disorder',
      'gym',
      'fitness',
      'doctor',
    ],
    Topic.gratitude: [
      'grateful',
      'thankful',
      'blessed',
      'so happy',
      'amazing',
      'feeling good',
      'feeling great',
      'today was good',
      'shukr',
      'bahut acha laga',
      'kuch achha',
    ],
    Topic.thanks: [
      'thank you',
      'thanks',
      'shukriya',
      'dhanyavad',
      'you helped',
      'so helpful',
      'this helped',
      'tum helpful',
      'appreciate it',
      'bahut acha',
    ],
    Topic.continuationAffirm: [
      'yes',
      'haan',
      'okay',
      'ok',
      'sure',
      'yep',
      'yeah',
      'hmm',
      'mm',
      'right',
      'i see',
      'go on',
      'tell me more',
      'aur',
      'phir',
      'aage bolo',
      'samajh gaya',
    ],
    Topic.continuationAskMore: [
      'what do you mean',
      'can you explain',
      'how',
      'elaborate',
      'more detail',
      'what should i do',
      'what can i do',
      'kya karun',
      'batao',
      'suggest',
    ],
  };

  // Score each topic and return best match
  static TopicMatch classify(String text, {Topic? lastTopic}) {
    final lower = text.toLowerCase();
    final wordCount = lower.trim().split(RegExp(r'\s+')).length;
    final scores = <Topic, double>{};

    for (final entry in _patterns.entries) {
      var score = 0.0;
      for (final kw in entry.value) {
        if (lower.contains(kw)) {
          // Multi-word patterns score higher
          score += kw.contains(' ') ? 2.5 : 1.0;
        }
      }
      if (score > 0) {
        scores[entry.key] = score;
      }
    }

    if (scores.isEmpty) {
      // Very short message with no keywords → continuation
      if (wordCount <= 4 && lastTopic != null) {
        return TopicMatch(
            topic: Topic.continuationAffirm,
            confidence: 0.6,
            lastTopic: lastTopic);
      }
      return TopicMatch(
          topic: Topic.general, confidence: 0.3, lastTopic: lastTopic);
    }

    final best = scores.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return TopicMatch(
      topic: best.key,
      confidence: (best.value / 5).clamp(0.0, 1.0),
      lastTopic: lastTopic,
      allScores: scores,
    );
  }
}

class TopicMatch {
  const TopicMatch({
    required this.topic,
    required this.confidence,
    this.lastTopic,
    this.allScores = const {},
  });
  final Topic topic;
  final double confidence;
  final Topic? lastTopic;
  final Map<Topic, double> allScores;

  bool get isLowConfidence => confidence < 0.4;
  bool get isContinuation =>
      topic == Topic.continuationAffirm || topic == Topic.continuationAskMore;
}

// ─────────────────────────────────────────────
// CONTEXT EXTRACTOR  (pulls specifics from text)
// ─────────────────────────────────────────────
class ContextExtractor {
  // Pull time mentions
  static String? extractTime(String text) {
    final t = text.toLowerCase();
    if (t.contains('3am') || t.contains('3 am')) {
      return '3 AM';
    }
    if (t.contains('2am') || t.contains('2 am')) {
      return '2 AM';
    }
    if (t.contains('4am') || t.contains('4 am')) {
      return '4 AM';
    }
    if (t.contains('midnight')) {
      return 'midnight';
    }
    if (t.contains('night')) {
      return 'at night';
    }
    if (t.contains('morning')) {
      return 'in the morning';
    }
    return null;
  }

  // Pull duration/frequency mentions
  static String? extractDuration(String text) {
    final t = text.toLowerCase();
    if (t.contains('month') || t.contains('mahine')) {
      return 'for months';
    }
    if (t.contains('week') || t.contains('hafte')) {
      return 'for weeks';
    }
    if (t.contains('year') || t.contains('saal')) {
      return 'for a long time';
    }
    if (t.contains('days') || t.contains('din se')) {
      return 'for a few days';
    }
    if (t.contains('today') || t.contains('aaj')) {
      return 'today';
    }
    if (t.contains('lately') || t.contains('kuch dino se')) {
      return 'lately';
    }
    return null;
  }

  // Pull a person/relationship mentioned
  static String? extractPerson(String text) {
    final t = text.toLowerCase();
    if (t.contains('boyfriend') || t.contains('bf')) {
      return 'boyfriend';
    }
    if (t.contains('girlfriend') || t.contains('gf')) {
      return 'girlfriend';
    }
    if (t.contains('partner') || t.contains('husband') || t.contains('wife')) {
      return 'partner';
    }
    if (t.contains('mom') ||
        t.contains('mummy') ||
        t.contains('mother') ||
        t.contains('maa')) {
      return 'mom';
    }
    if (t.contains('dad') ||
        t.contains('papa') ||
        t.contains('father') ||
        t.contains('baap')) {
      return 'dad';
    }
    if (t.contains('parent')) {
      return 'parents';
    }
    if (t.contains('friend') || t.contains('dost')) {
      return 'friend';
    }
    if (t.contains('boss') || t.contains('manager')) {
      return 'boss';
    }
    if (t.contains('sibling') ||
        t.contains('brother') ||
        t.contains('bhai') ||
        t.contains('sister') ||
        t.contains('behen')) {
      return 'sibling';
    }
    return null;
  }

  // Pull a specific cause/trigger
  static String? extractTrigger(String text) {
    final t = text.toLowerCase();
    if (t.contains('exam') || t.contains('test')) {
      return 'exam pressure';
    }
    if (t.contains('job') || t.contains('work') || t.contains('office')) {
      return 'work';
    }
    if (t.contains('money') || t.contains('paisa') || t.contains('financial')) {
      return 'financial stress';
    }
    if (t.contains('future') || t.contains('career')) {
      return 'future';
    }
    if (t.contains('health') || t.contains('bimari') || t.contains('sick')) {
      return 'health';
    }
    if (t.contains('loneliness') || t.contains('akela')) {
      return 'feeling alone';
    }
    return null;
  }

  // Detect if they're asking for advice vs venting
  static bool isAskingForAdvice(String text) {
    final t = text.toLowerCase();
    return t.contains('what should') ||
        t.contains('how do') ||
        t.contains('how can') ||
        t.contains('kya karun') ||
        t.contains('kaise') ||
        t.contains('batao') ||
        t.contains('suggest') ||
        t.contains('tips') ||
        t.contains('help me') ||
        t.contains('what to do') ||
        t.contains('advice') ||
        t.contains('solution') ||
        t.contains('tell me') ||
        t.contains('bata');
  }

  // Detect if they're just sharing/venting
  static bool isVenting(String text) {
    final t = text.toLowerCase();
    return t.contains('i feel') ||
        t.contains('i\'m feeling') ||
        t.contains('feel so') ||
        t.contains('mujhe') ||
        t.contains('main') ||
        t.contains('i am so') ||
        t.contains('it\'s so hard') ||
        t.contains('bahut mushkil') ||
        (!isAskingForAdvice(text) && text.split(' ').length < 12);
  }

  // Detect Hinglish vs Hindi vs English
  static String detectLang(String text) {
    final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(text);
    final hasLatin = RegExp(r'[a-zA-Z]').hasMatch(text);
    if (hasDevanagari && hasLatin) {
      return 'hinglish';
    }
    if (hasDevanagari && !hasLatin) {
      return 'hindi';
    }
    return 'english';
  }
}

// ─────────────────────────────────────────────
// THE SMART RESPONSE ENGINE
// ─────────────────────────────────────────────
class SmartResponseEngine {
  final ConversationMemory memory = ConversationMemory();
  final _rng = Random();
  final SentimentAnalyzer _sentiment = SentimentAnalyzer();

  void reset() => memory.reset();

  void restoreFromHistory(List<ChatMessage> history) {
    // Rebuild memory state from existing history
    // NOTE: topic is set to Topic.general here because the original topic
    // classification for past assistant turns is not persisted anywhere.
    // This means lastTopic/consecutiveSameTopic tracking resets to "general"
    // after an app restart even mid-conversation — worth fixing properly by
    // persisting the classified Topic alongside each ChatMessage if you want
    // true continuity across sessions.
    for (final msg in history) {
      if (msg.role == MessageRole.assistant && msg.content.isNotEmpty) {
        memory._turns.add(_Turn(topic: Topic.general, response: msg.content));
      }
    }
  }

  Future<String> respond({
    required String userMessage,
    required List<ChatMessage> history,
    required UserSettings settings,
    required void Function(String) onPartial,
  }) async {
    final lang = ContextExtractor.detectLang(userMessage);
    final match =
    TopicClassifier.classify(userMessage, lastTopic: memory.lastTopic);
    final sentiment = _sentiment.analyze(userMessage);
    final wantsAdvice = ContextExtractor.isAskingForAdvice(userMessage);
    final isVenting = ContextExtractor.isVenting(userMessage);
    final person = ContextExtractor.extractPerson(userMessage);
    final duration = ContextExtractor.extractDuration(userMessage);
    final trigger = ContextExtractor.extractTrigger(userMessage);
    final time = ContextExtractor.extractTime(userMessage);

    // Build context object for response generators
    final ctx = _ResponseCtx(
      userMessage: userMessage,
      lang: lang,
      topic: match.topic,
      lastTopic: memory.lastTopic,
      sentiment: sentiment.level,
      wantsAdvice: wantsAdvice,
      isVenting: isVenting,
      person: person,
      duration: duration,
      trigger: trigger,
      time: time,
      memory: memory,
      history: history,
      hasCoveredTopic: memory.hasCovered(match.topic),
      consecutiveSame: memory.consecutiveSameTopic,
      settings: settings,
    );

    final response = _buildResponse(ctx);
    memory.record(match.topic, response);

    // Stream word by word with natural delays
    final words = response.split(RegExp(r'(?<=\S)(?=\s)|(?<=\s)(?=\S)'));
    final buf = StringBuffer();
    for (final token in words) {
      buf.write(token);
      onPartial(buf.toString());
      final delay = _tokenDelay(token);
      if (delay > 0) {
        await Future<void>.delayed(Duration(milliseconds: delay));
      }
    }

    return response;
  }

  String _buildResponse(_ResponseCtx c) {
    return switch (c.topic) {
      Topic.crisis => _crisis(c),
      Topic.greeting => _greeting(c),
      Topic.thanks => _thanks(c),
      Topic.gratitude => _gratitude(c),
      Topic.sleepProblem => _sleepProblem(c),
      Topic.sleepAdvice => _sleepAdvice(c),
      Topic.anxietyFeelings => _anxietyFeelings(c),
      Topic.anxietyTips => _anxietyTips(c),
      Topic.depressionFeelings => _depressionFeelings(c),
      Topic.depressionTips => _depressionTips(c),
      Topic.stressWork => _stressWork(c),
      Topic.stressExam => _stressExam(c),
      Topic.stressFamily => _stressFamily(c),
      Topic.lonelinessDeep => _lonelinessDeep(c),
      Topic.lonelinessLight => _lonelinessLight(c),
      Topic.relationshipBreakup => _breakup(c),
      Topic.relationshipFamily => _relFamily(c),
      Topic.relationshipFriends => _relFriends(c),
      Topic.angerFeelings => _anger(c),
      Topic.angerTips => _angerTips(c),
      Topic.motivationLow => _motivationLow(c),
      Topic.motivationGoals => _motivationGoals(c),
      Topic.routineBuilding => _routineBuilding(c),
      Topic.routineStruggle => _routineStruggle(c),
      Topic.physicalPain => _physicalPain(c),
      Topic.physicalGeneral => _physicalGeneral(c),
      Topic.continuationAffirm => _continuation(c),
      Topic.continuationAskMore => _askMoreDetail(c),
      Topic.general => _general(c),
    };
  }

  // ─── CRISIS ───────────────────────────────────────────────────────────────
  String _crisis(_ResponseCtx c) {
    final responses = [
      "Hey — I'm really glad you said something. What you're feeling right now is real, and I don't want you to face it alone.\n\nPlease reach out right now:\n• **iCall**: 9152987821 (free, confidential)\n• **Vandrevala Foundation**: 1860-2662-345 (24/7)\n• **AASRA**: 9820466726\n\nI'm here too. Can you tell me a little about what's brought you to this point?",
      "That takes courage to say, and I'm grateful you did. You matter — even when it doesn't feel that way.\n\nPlease talk to someone right now:\n• **iCall**: 9152987821\n• **AASRA**: 9820466726 (24/7)\n\nWhile you consider reaching out, I'm here. What's been happening?",
      "I hear you, and I want you to know that reaching out — even here — was the right move.\n\nThese counselors are trained for exactly this moment:\n• **Vandrevala Foundation**: 1860-2662-345 (24/7, free)\n• **iCall**: 9152987821\n\nTell me what's going on. I'm listening, no judgment at all.",
    ];
    return _pick(responses);
  }

  // ─── GREETING ─────────────────────────────────────────────────────────────
  String _greeting(_ResponseCtx c) {
    final name = c.settings.userName.isNotEmpty ? c.settings.userName : null;
    final hi = name != null ? 'Hey $name!' : 'Hey!';
    final r = _rng.nextInt(4);
    return switch (r) {
      0 => "$hi Good to see you. What's on your mind today?",
      1 => "$hi I'm here for you. How are you doing right now — honestly?",
      2 => "$hi How's everything going? Anything you want to talk through?",
      _ => "$hi I'm here. What would you like to talk about today?",
    };
  }

  // ─── THANKS / GRATITUDE ───────────────────────────────────────────────────
  String _thanks(_ResponseCtx c) => _pick([
    "I'm really glad it helped! You did the hard part — I just listened. Anything else on your mind?",
    "That means a lot to hear. You're doing better than you think. Anything else you want to talk about?",
    "Of course! Come back anytime. Is there anything else you'd like to explore today?",
  ]);

  String _gratitude(_ResponseCtx c) => _pick([
    "That's wonderful — hold onto that feeling! What made today feel good?",
    "Love hearing that! When things feel good, it's worth noticing what's working. What's been different lately?",
    "That's great! So what's been going well?",
  ]);

  // ─── SLEEP ────────────────────────────────────────────────────────────────
  String _sleepProblem(_ResponseCtx c) {
    final timeStr = c.time != null ? ' at ${c.time}' : '';
    final durStr = c.duration != null ? ' ${c.duration}' : '';

    if (c.hasCoveredTopic && c.consecutiveSame > 0) {
      // Already talked about sleep — go deeper
      return _pick([
        "Still not sleeping well$durStr? Let's get more specific. When you're lying in bed$timeStr, what's actually happening — is your mind racing, or is it physical restlessness, or something else?",
        "So this has been going on$durStr. Have you tried anything so far that helped even a little, or has nothing worked?",
        "You mentioned sleep again — I want to understand this better. Does it take you forever to fall asleep, or do you fall asleep but wake up in the middle of the night?",
      ]);
    }

    if (c.isVenting && !c.wantsAdvice) {
      return _pick([
        "Ugh, that's exhausting — lying there$timeStr${durStr.isNotEmpty ? ', $durStr' : ''}, willing yourself to sleep and it just won't come. What does the inside of your head sound like at those moments?",
        "Not being able to sleep$durStr is genuinely rough — it affects everything. Is it that you can't fall asleep, or you wake up and can't go back?",
        "Sleep deprivation is no joke. You're probably running on fumes. What does a typical night look like for you right now?",
      ]);
    }

    return _pick([
      "Not sleeping is one of the worst things — it affects mood, energy, everything. ${c.time != null ? 'So you\'re lying awake ${c.time}?' : 'When does it usually happen — trouble falling asleep, or waking up?'} How long has this been going on?",
      "Sleep issues can spiral quickly. Is this more about your mind not switching off, or is there something specific waking you up${c.time != null ? ' around ${c.time}' : ''}?",
      "That sounds really draining. Before I suggest anything, tell me — is this a new thing or has it been$durStr?",
    ]);
  }

  String _sleepAdvice(_ResponseCtx c) => _pick([
    "Sure! The biggest lever most people miss is **consistency** — going to bed and waking up at the same time every day, even weekends. Your brain needs a predictable rhythm.\n\nOther things that actually work:\n• No screens 45 mins before bed (the blue light delays melatonin)\n• Keep the room cool and dark\n• If you're lying awake 20+ mins, get up and do something boring until you feel sleepy\n\nWhat's your current bedtime situation like?",
    "Here's what the research actually backs up for sleep:\n\n• **Wind-down routine** — same 30 min ritual every night signals your brain it's sleep time\n• **4-7-8 breathing** — breathe in 4 sec, hold 7, out 8 sec. Does something real to your nervous system\n• **No caffeine after 2 PM** — it has a 6-hour half-life\n• **Worry journaling** — dump racing thoughts on paper before bed\n\nWhich of these feels most doable for you?",
    "The single most effective thing: **stop trying to force sleep**. The harder you try, the more awake you become. Instead, just lie there and say 'I'm just resting.'\n\nAlso — what are you doing in the hour before bed? That's usually where the problem hides.",
  ]);

  // ─── ANXIETY ──────────────────────────────────────────────────────────────
  String _anxietyFeelings(_ResponseCtx c) {
    final trigger = c.trigger != null ? ' about ${c.trigger}' : '';

    if (c.hasCoveredTopic) {
      return _pick([
        "Still feeling the anxiety$trigger? That's okay — it doesn't just disappear after one conversation. What's it feeling like right now — more physical (heart, breathing) or more mental (thoughts spiraling)?",
        "The anxious feeling is still there$trigger. What's the loudest thought in your head right now?",
        "It sounds like this is really persistent. Has there been any moment today where it eased up even a little?",
      ]);
    }

    if (c.isVenting) {
      return _pick([
        "That anxious feeling in your chest — I get why that's so uncomfortable. It's your nervous system doing its job, just overdoing it.\n\nIs this more of a constant low hum, or does it spike suddenly$trigger?",
        "Anxiety is exhausting — especially the kind that won't leave you alone$trigger. What does it feel like in your body right now?",
        "Ugh, anxiety is the worst. That combination of physical tension and racing thoughts is so draining. Has something specific triggered it, or does it feel like it came out of nowhere?",
      ]);
    }

    return _pick([
      "Anxiety is really hard to deal with, especially when it feels constant. Can you tell me more — is it more about specific worries$trigger, or is it more of a general, free-floating dread?",
      "When you say you're feeling anxious — is there a specific thing driving it$trigger, or does it feel like your mind is just... bracing for something you can't name?",
      "I hear you. Anxiety has this way of hijacking everything. How long have you been feeling this way$trigger?",
    ]);
  }

  String _anxietyTips(_ResponseCtx c) => _pick([
    "The fastest thing when anxiety spikes: **box breathing**.\n\nBreathe in 4 counts → hold 4 → out 4 → hold 4. Do this 4-5 times. It literally activates your parasympathetic nervous system.\n\nFor the mental side — the 5-4-3-2-1 technique:\n• Name 5 things you can see\n• 4 you can touch\n• 3 you can hear\n• 2 you can smell\n• 1 you can taste\n\nThis pulls your brain back into the present. Want me to walk you through either one?",
    "A few things that genuinely help:\n\n• **Label it**: Saying 'I'm feeling anxious' (instead of just experiencing it) gives your prefrontal cortex control back\n• **Cold water** on your face — triggers the dive reflex and slows your heart rate\n• **Physical movement** — even a 10-min walk burns off the adrenaline\n• **Limit what-if thinking** by asking: 'What is actually happening RIGHT NOW?'\n\nWhich of these sounds most useful for your situation?",
    "Here's what I'd suggest trying:\n\n**Right now if it's bad**: Focus on the exhale. Make it longer than your inhale — like breathe in 4 counts, out 6-8. The long exhale activates your vagus nerve and calms things down.\n\n**Longer term**: Anxiety often gets worse when we avoid the thing causing it. Sometimes the best fix is slowly doing the scary thing. Is there something specific you've been avoiding?",
  ]);

  // ─── DEPRESSION ───────────────────────────────────────────────────────────
  String _depressionFeelings(_ResponseCtx c) {
    final durStr = c.duration != null ? ' ${c.duration}' : '';

    if (c.sentiment == SentimentLevel.distressed) {
      return _pick([
        "What you're describing sounds really heavy$durStr — that feeling of emptiness is one of the hardest things to sit with. You reached out, and that matters.\n\nIs there one specific thing that feels most unbearable right now?",
        "I'm really glad you said something. That feeling of hopelessness — like nothing will get better — it lies to you. It's a symptom, not the truth.\n\nCan I ask — have you been able to talk to anyone about this in real life?",
      ]);
    }

    if (c.hasCoveredTopic) {
      return _pick([
        "Still feeling low$durStr. I want to understand this better. When you say you feel ${c.userMessage.length < 30 ? '"' + c.userMessage + '"' : 'this way'} — what does a typical hour of your day actually look like?",
        "The low feeling hasn't lifted. Has anything changed at all — even slightly — or is it the same weight every day?",
        "You've been carrying this$durStr. What's the one thing that feels most stuck right now?",
      ]);
    }

    if (c.isVenting) {
      return _pick([
        "That heavy, empty feeling$durStr — it's real, and it's exhausting. You don't have to explain it or justify it.\n\nWhen did it start? Was there something that triggered it, or did it just... settle in gradually?",
        "Feeling this way$durStr takes everything out of you. I'm here.\n\nCan I ask — are you managing the basics okay? Eating, sleeping?",
        "Sometimes when everything feels pointless, the hardest part is just getting through each hour. Is that what it's like for you right now?",
      ]);
    }

    return _pick([
      "Thank you for sharing that. Low moods that stick around$durStr are worth paying attention to.\n\nIs this feeling constant, or does it come and go? And has anything in your life changed around the time this started?",
      "What you're describing sounds really difficult. How long has it felt like this? And is there anything — even small things — that makes it feel slightly better?",
      "I want to understand what you're going through. When you say you're feeling down — is it more of a sadness, or more like numbness, or something else entirely?",
    ]);
  }

  String _depressionTips(_ResponseCtx c) => _pick([
    "When you're in a low place, the goal isn't to 'fix' everything — it's just to do the next small thing.\n\n**What actually helps:**\n• One tiny win (shower, glass of water, open a window) — your brain registers it\n• Don't isolate, even if you want to — text one person anything\n• Sunlight. Even 10 minutes changes brain chemistry\n• Move your body in any way — walk, stretch, anything\n\nWhat's the smallest possible step that feels doable today?",
    "Depression makes everything feel 10x harder, so conventional advice like 'just exercise!' can feel impossible. Let's make it smaller.\n\n**Start with behavioral activation** — just doing ONE thing you used to like, even if it brings no joy right now. The feeling sometimes comes back after the action, not before.\n\nWhat's something small you used to enjoy?",
    "A few things that work even when nothing feels worth doing:\n\n• Get outside — even standing at your door for 5 minutes counts\n• Routine is medicine — same wake time every day anchors your mood\n• Talk to someone, even a little — isolation feeds depression\n• Be gentle with yourself — low productivity during this is not failure\n\nHave you spoken to a doctor or therapist about this? Even one session can help.",
  ]);

  // ─── STRESS ───────────────────────────────────────────────────────────────
  String _stressWork(_ResponseCtx c) {
    final durStr = c.duration != null ? ' ${c.duration}' : '';
    final personStr = c.person != null ? ' with your ${c.person}' : '';

    return _pick([
      "Work stress$durStr is real — especially when you're expected to just push through it. What's the main thing draining you right now? Is it the workload itself, or more the environment — people, culture$personStr?",
      "That work pressure can grind you down. Before I say anything useful — is this a temporary crunch situation, or does it feel like this is just... how this job is?",
      "Work stress often has layers — is it more about the amount of work, or more about feeling unappreciated, or not having control, or something else entirely?",
    ]);
  }

  String _stressExam(_ResponseCtx c) => _pick([
    "Exam pressure is real — it's not just 'in your head.' The stakes feel huge.\n\nA few things that actually help under pressure:\n• Study in 25-min blocks with 5-min breaks (Pomodoro) — your brain retains more\n• Sleep before exams beats cramming all night — memory consolidates during sleep\n• Test anxiety? Practice box breathing right before: in 4, hold 4, out 4\n\nHow much time do you have before the exam?",
    "That exam stress is so common, but that doesn't make it easier. What subject or area feels most daunting right now?",
    "I hear you. Is the stress more about not knowing the material, or more about the fear of the result and what it means for your future?",
  ]);

  String _stressFamily(_ResponseCtx c) {
    final personStr = c.person != null ? 'your ${c.person}' : 'your family';
    return _pick([
      "Family pressure is uniquely exhausting because you can't just 'leave work at the office' — it follows you everywhere. What's the main thing $personStr is pushing about?",
      "That kind of pressure from $personStr is really hard — especially when the people who are supposed to support you are also the source of stress. What does it look like?",
      "Family expectations can feel so heavy. Is it more about what they want you to do, or more about feeling like you can never measure up?",
    ]);
  }

  // ─── LONELINESS ───────────────────────────────────────────────────────────
  String _lonelinessDeep(_ResponseCtx c) {
    final durStr = c.duration != null ? ' ${c.duration}' : '';
    return _pick([
      "Feeling like nobody truly sees you$durStr — that's one of the most painful human experiences. It's not weakness. It's real.\n\nCan I ask — is this loneliness more about not having people around, or more about being around people but still feeling completely disconnected?",
      "What you're describing — that deep sense of nobody understanding — that's really painful. You're not invisible to me right now.\n\nHas this always been the case, or was there a time when you felt more connected?",
      "That kind of loneliness, where you feel unseen even when you're not alone$durStr, is particularly heavy. What does a typical day look like for you — who do you interact with?",
    ]);
  }

  String _lonelinessLight(_ResponseCtx c) => _pick([
    "That feeling of loneliness is something a lot of people carry quietly. Is it more that you don't have people around, or that the people around you don't really *get* you?",
    "Missing connection is so human. Has something changed recently — new place, lost touch with friends, different life stage?",
    "Loneliness can sneak up. Are you in a situation where you're physically alone, or is it more of an emotional disconnection even when you're around others?",
  ]);

  // ─── RELATIONSHIPS ────────────────────────────────────────────────────────
  String _breakup(_ResponseCtx c) {
    final durStr = c.duration != null ? ' ${c.duration}' : '';
    return _pick([
      "Heartbreak is one of the most disorienting pains — your whole future reshuffles. How long ago did this happen, and where are you with it right now — shock, sadness, anger, all of it?",
      "I'm sorry. Breakups hurt in this particular, whole-body way. Have you had time to process it, or is it still very raw?",
      "That's really hard$durStr. Was this sudden, or had it been building for a while?",
    ]);
  }

  String _relFamily(_ResponseCtx c) {
    final personStr = c.person != null ? 'your ${c.person}' : 'your family';
    return _pick([
      "Family conflict is complicated because love and frustration are all tangled together. What's the main thing causing tension with $personStr?",
      "What's happening with $personStr — is this a recent thing or a long-running dynamic?",
      "Family tensions can be exhausting when there's no escape from them. What does it look like at home right now?",
    ]);
  }

  String _relFriends(_ResponseCtx c) => _pick([
    "Friendship betrayal stings in a special way — these are people you chose. What happened, if you want to share?",
    "Losing a friend or realizing they're not who you thought — that's genuinely painful. Is this one person or more of a wider feeling?",
    "Friends can be complicated. What's going on — was there a specific incident, or has it been building?",
  ]);

  // ─── ANGER ────────────────────────────────────────────────────────────────
  String _anger(_ResponseCtx c) {
    final personStr = c.person != null ? ' about your ${c.person}' : '';
    return _pick([
      "That anger$personStr sounds intense. Anger is usually covering something else underneath — hurt, or feeling disrespected, or powerless. Does any of those fit?",
      "What happened? That level of frustration usually has a specific thing driving it — what set it off?",
      "Anger this strong usually has a point to it. What's the situation? I want to understand before I say anything.",
    ]);
  }

  String _angerTips(_ResponseCtx c) => _pick([
    "When anger is hot:\n• **Physical release first** — brisk walk, cold water on your face, squeeze something\n• **Don't act while in the peak** — give it 10 minutes before responding\n• Then ask: what's the actual need underneath this anger?\n\nWho or what is it directed at?",
    "The fastest way to take the edge off anger: **move your body**. Walk, run, anything physical. Anger is adrenaline — burn it off.\n\nOnce the heat passes, the useful question is: what do I actually need here that I'm not getting?",
    "A few practical things:\n• Slow the exhale — breathe out twice as long as you breathe in\n• Name what you're feeling precisely — 'I'm feeling disrespected' is more useful than 'I'm angry'\n• Separate the problem from the person if you can\n\nWhat's the situation — is it something ongoing or a one-time thing?",
  ]);

  // ─── MOTIVATION ───────────────────────────────────────────────────────────
  String _motivationLow(_ResponseCtx c) {
    final durStr = c.duration != null ? ' ${c.duration}' : '';
    return _pick([
      "That stuck, unmotivated feeling$durStr — is it more that you have things you want to do but can't get started, or more that you don't even know what you want anymore?",
      "Motivation disappearing$durStr usually means something. Is this a 'I know what I should do but I can't make myself' situation, or more 'I don't care about anything right now'?",
      "What does a day look like when you're in this mode? Walk me through what happens — like from when you wake up.",
    ]);
  }

  String _motivationGoals(_ResponseCtx c) => _pick([
    "What's the goal you're working toward? I want to understand the specific situation before suggesting anything generic.",
    "Motivation is tricky — it usually follows action, not the other way around. What's the one thing you keep putting off that would make the biggest difference?",
    "What have you tried so far? And what's the specific point where you usually stop?",
  ]);

  // ─── ROUTINE ──────────────────────────────────────────────────────────────
  String _routineBuilding(_ResponseCtx c) => _pick([
    "Building a routine that actually sticks starts with being realistic about your current life.\n\nWhat's your wake-up time? And what's the one thing you most want to make consistent — morning, work, sleep, exercise?",
    "The key to sustainable routines: **anchor habits to existing ones**. What's something you already do every day without thinking? We can build off that.\n\nAlso — what's the main goal behind wanting a routine?",
    "What does your current day actually look like? No judgment — I just need to know where we're starting from.",
  ]);

  String _routineStruggle(_ResponseCtx c) => _pick([
    "Routines are genuinely hard to build — most people underestimate how long it actually takes. What keeps breaking yours? Is it external things, or more internal motivation?",
    "The inconsistency is frustrating. What usually happens — do you start strong and then slip, or does it never get off the ground?",
    "What's the routine you're trying to build? And what's the biggest obstacle — time, energy, discipline, or not really knowing what routine you want?",
  ]);

  // ─── PHYSICAL ─────────────────────────────────────────────────────────────
  String _physicalPain(_ResponseCtx c) {
    return _pick([
      "Physical discomfort on top of everything else makes everything harder. ${c.trigger != null ? 'Is this ${c.trigger}-related, or something else?' : 'How long has this been going on, and is it constant or comes and goes?'}",
      "That sounds uncomfortable. Is this something new, or has it been going on for a while? And have you been able to see a doctor about it?",
      "Physical symptoms like this are worth taking seriously. Is it getting worse, or staying the same? Have you had any sense of what might be causing it?",
    ]);
  }

  String _physicalGeneral(_ResponseCtx c) => _pick([
    "What's the main thing on your mind with your health? I can talk through it with you — though for anything specific, a doctor is always the right first step.",
    "What's going on with your health? Give me more context — what are you dealing with or trying to improve?",
    "Health is so personal. What's the specific thing you're thinking about — something you're experiencing, or something you're trying to improve?",
  ]);

  // ─── CONTINUATION ─────────────────────────────────────────────────────────
  String _continuation(_ResponseCtx c) {
    final lastT = c.lastTopic;
    if (lastT == null) {
      return _general(c);
    }

    // Give a relevant follow-up based on what was just discussed
    return switch (lastT) {
      Topic.sleepProblem || Topic.sleepAdvice => _pick([
        "So what does a typical night look like? Like, what time do you get into bed, and what happens next?",
        "Has this been going on for long, or is it more recent?",
        "When you're lying there awake, what's going through your head?",
      ]),
      Topic.anxietyFeelings || Topic.anxietyTips => _pick([
        "What's the thing your mind keeps going back to when the anxiety hits?",
        "Is there a specific situation or trigger you've noticed, or does it just show up randomly?",
        "On a scale of 1-10, how bad has it been today?",
      ]),
      Topic.depressionFeelings || Topic.depressionTips => _pick([
        "What does the low feeling feel like in your body — is it heavy, numb, something else?",
        "Have you been able to talk to anyone about this in person?",
        "Is there anything — even something small — that brings a little relief?",
      ]),
      Topic.stressWork || Topic.stressExam || Topic.stressFamily => _pick([
        "What part of it feels most overwhelming right now?",
        "Is there anyone around you who knows what you're going through?",
        "What would 'good enough' look like here — what would take the pressure off even slightly?",
      ]),
      Topic.lonelinessDeep || Topic.lonelinessLight => _pick([
        "Has it always been this way, or is this new?",
        "What kind of connection do you miss most?",
        "Is there anyone from your past you've lost touch with that you wish you hadn't?",
      ]),
      Topic.relationshipBreakup => _pick([
        "Are you around people who know what's going on, or are you dealing with this mostly alone?",
        "What's the hardest part right now — the missing them, or the uncertainty about the future?",
        "Have you been able to give yourself space to actually feel it?",
      ]),
      Topic.motivationLow || Topic.motivationGoals => _pick([
        "When's the last time you felt actually motivated about something?",
        "Is there one thing — even something small — you've been putting off that you know would help?",
        "What does your inner voice say when you think about the thing you want to do?",
      ]),
      _ => _pick([
        "Tell me more — what's on your mind?",
        "What's the main thing you want to figure out right now?",
        "What would be most helpful — talking through it, or more concrete suggestions?",
      ]),
    };
  }

  String _askMoreDetail(_ResponseCtx c) => _pick([
    "Sure — what specifically would you like me to explain more?",
    "Of course. What part would be most helpful to go deeper on?",
    "Happy to. What's the part that feels unclear or you want more detail on?",
  ]);

  // ─── GENERAL ──────────────────────────────────────────────────────────────
  String _general(_ResponseCtx c) {
    if (c.userMessage.trim().split(' ').length <= 3) {
      return _pick([
        "Tell me more — I want to understand what you're going through.",
        "I'm here. What's on your mind?",
        "Say more — what's happening?",
      ]);
    }
    return _pick([
      "I want to make sure I understand what you're saying. Can you tell me a bit more about what's going on?",
      "That's interesting — I want to respond to what you're actually feeling, not guess. What's the main thing on your mind right now?",
      "I hear you. What would be most helpful right now — talking it through, or looking for concrete ideas?",
    ]);
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  String _pick(List<String> options) => memory.pickFresh(options);

  int _tokenDelay(String token) {
    final t = token.trim();
    if (t.isEmpty) {
      return 0;
    }
    if (t.endsWith('\n')) {
      return 30;
    }
    if (t.endsWith('.') || t.endsWith('?') || t.endsWith('!')) {
      return 40;
    }
    if (t.endsWith(',') || t.endsWith(':') || t.endsWith('—')) {
      return 22;
    }
    return 12;
  }
}

// ─────────────────────────────────────────────
// RESPONSE CONTEXT  (passed to all generators)
// ─────────────────────────────────────────────
class _ResponseCtx {
  _ResponseCtx({
    required this.userMessage,
    required this.lang,
    required this.topic,
    required this.lastTopic,
    required this.sentiment,
    required this.wantsAdvice,
    required this.isVenting,
    required this.person,
    required this.duration,
    required this.trigger,
    required this.time,
    required this.memory,
    required this.history,
    required this.hasCoveredTopic,
    required this.consecutiveSame,
    required this.settings,
  });

  final String userMessage;
  final String lang;
  final Topic topic;
  final Topic? lastTopic;
  final SentimentLevel sentiment;
  final bool wantsAdvice;
  final bool isVenting;
  final String? person;
  final String? duration;
  final String? trigger;
  final String? time;
  final ConversationMemory memory;
  final List<ChatMessage> history;
  final bool hasCoveredTopic;
  final int consecutiveSame;
  final UserSettings settings;
}
