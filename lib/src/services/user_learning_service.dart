import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aaroh_chat/src/engine/language_detector.dart';
import 'package:aaroh_chat/src/engine/wellness_intent.dart';

/// Locally learns from user input — no cloud, trains on-device over time.
class UserLearningProfile {
  const UserLearningProfile({
    this.intentCounts = const {},
    this.preferredLanguageCode = 'en',
    this.recentTopics = const [],
    this.totalMessages = 0,
    this.notedPhrases = const [],
  });

  final Map<String, int> intentCounts;
  final String preferredLanguageCode;
  final List<String> recentTopics;
  final int totalMessages;
  final List<String> notedPhrases;

  String? get topIntent {
    if (intentCounts.isEmpty) return null;
    return intentCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  UserLearningProfile copyWith({
    Map<String, int>? intentCounts,
    String? preferredLanguageCode,
    List<String>? recentTopics,
    int? totalMessages,
    List<String>? notedPhrases,
  }) {
    return UserLearningProfile(
      intentCounts: intentCounts ?? this.intentCounts,
      preferredLanguageCode:
          preferredLanguageCode ?? this.preferredLanguageCode,
      recentTopics: recentTopics ?? this.recentTopics,
      totalMessages: totalMessages ?? this.totalMessages,
      notedPhrases: notedPhrases ?? this.notedPhrases,
    );
  }

  Map<String, dynamic> toJson() => {
        'intentCounts': intentCounts,
        'preferredLanguageCode': preferredLanguageCode,
        'recentTopics': recentTopics,
        'totalMessages': totalMessages,
        'notedPhrases': notedPhrases,
      };

  factory UserLearningProfile.fromJson(Map<String, dynamic> json) {
    return UserLearningProfile(
      intentCounts: Map<String, int>.from(
        (json['intentCounts'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
      ),
      preferredLanguageCode: json['preferredLanguageCode'] as String? ?? 'en',
      recentTopics: List<String>.from(json['recentTopics'] as List? ?? []),
      totalMessages: json['totalMessages'] as int? ?? 0,
      notedPhrases: List<String>.from(json['notedPhrases'] as List? ?? []),
    );
  }
}

class UserLearningService extends ChangeNotifier {
  static const _key = 'aaroh_learning_profile';

  UserLearningProfile _profile = const UserLearningProfile();
  bool _loaded = false;

  UserLearningProfile get profile => _profile;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        _profile = UserLearningProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> learnFromMessage({
    required String userMessage,
    required WellnessIntent intent,
    required DetectedLanguage detected,
    required bool enabled,
  }) async {
    if (!enabled) return;

    final counts = Map<String, int>.from(_profile.intentCounts);
    counts[intent.name] = (counts[intent.name] ?? 0) + 1;

    final topics = List<String>.from(_profile.recentTopics);
    if (intent != WellnessIntent.general && intent != WellnessIntent.greeting) {
      final label = intent.name;
      topics.remove(label);
      topics.insert(0, label);
      if (topics.length > 8) topics.removeLast();
    }

    final phrases = List<String>.from(_profile.notedPhrases);
    if (userMessage.length > 15 && userMessage.length < 200) {
      phrases.remove(userMessage);
      phrases.insert(0, userMessage);
      if (phrases.length > 20) phrases.removeLast();
    }

    // Weighted language preference
    var lang = _profile.preferredLanguageCode;
    if (detected.confidence > 0.6) {
      lang = detected.code;
    }

    _profile = _profile.copyWith(
      intentCounts: counts,
      preferredLanguageCode: lang,
      recentTopics: topics,
      totalMessages: _profile.totalMessages + 1,
      notedPhrases: phrases,
    );

    await _persist();
    notifyListeners();
  }

  String? personalizationNote(String langCode) {
    if (_profile.totalMessages < 3) return null;
    final top = _profile.topIntent;
    if (top == null) return null;

    return switch (langCode) {
      'hi' =>
        '💭 पहले भी आपने ${_topicLabelHi(top)} के बारे में बात की थी — मैं याद रखता हूँ।',
      'hinglish' =>
        '💭 Pehle bhi tumne ${_topicLabelEn(top)} ke baare mein baat ki — yaad hai mujhe.',
      _ => '💭 You\'ve talked about ${_topicLabelEn(top)} before — I remember.',
    };
  }

  String _topicLabelEn(String key) => key.replaceAll('_', ' ');
  String _topicLabelHi(String key) => switch (key) {
        'sleep' => 'नींद',
        'anxiety' => 'चिंता',
        'depression' => 'उदासी',
        'loneliness' => 'अकेलापन',
        'stress' => 'तनाव',
        _ => key,
      };

  Future<void> clearLearning() async {
    _profile = const UserLearningProfile();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_profile.toJson()));
  }
}
