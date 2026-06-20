import 'package:flutter/material.dart';

enum LanguageTone { hinglish, hindi, english }

enum ThemePreset {
  warmSunset,
  calmOcean,
  forestPeace,
  lavenderDream,
  midnightCalm,
}

enum ResponseDepth { brief, balanced, detailed }

class UserSettings {
  const UserSettings({
    this.userName = '',
    this.languageTone = LanguageTone.english,
    this.themePreset = ThemePreset.warmSunset,
    this.isDarkMode = false,
    this.fontScale = 1.0,
    this.responseDepth = ResponseDepth.balanced,
    this.showCrisisBanner = true,
    this.compactBubbles = false,
    this.useInternetKnowledge = true,
    this.learnFromChats = true,
    this.autoDetectLanguage = true,
    this.neutralIdeology = true,
  });

  final String userName;
  final LanguageTone languageTone;
  final ThemePreset themePreset;
  final bool isDarkMode;
  final double fontScale;
  final ResponseDepth responseDepth;
  final bool showCrisisBanner;
  final bool compactBubbles;
  final bool useInternetKnowledge;
  final bool learnFromChats;
  final bool autoDetectLanguage;
  final bool neutralIdeology;

  Color get seedColor => switch (themePreset) {
        ThemePreset.warmSunset => const Color(0xFFE07A5F),
        ThemePreset.calmOcean => const Color(0xFF3D8B9E),
        ThemePreset.forestPeace => const Color(0xFF5B8C5A),
        ThemePreset.lavenderDream => const Color(0xFF9B7EBD),
        ThemePreset.midnightCalm => const Color(0xFF6B7FD7),
      };

  String get toneKey => languageTone.name;

  UserSettings copyWith({
    String? userName,
    LanguageTone? languageTone,
    ThemePreset? themePreset,
    bool? isDarkMode,
    double? fontScale,
    ResponseDepth? responseDepth,
    bool? showCrisisBanner,
    bool? compactBubbles,
    bool? useInternetKnowledge,
    bool? learnFromChats,
    bool? autoDetectLanguage,
    bool? neutralIdeology,
  }) {
    return UserSettings(
      userName: userName ?? this.userName,
      languageTone: languageTone ?? this.languageTone,
      themePreset: themePreset ?? this.themePreset,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontScale: fontScale ?? this.fontScale,
      responseDepth: responseDepth ?? this.responseDepth,
      showCrisisBanner: showCrisisBanner ?? this.showCrisisBanner,
      compactBubbles: compactBubbles ?? this.compactBubbles,
      useInternetKnowledge: useInternetKnowledge ?? this.useInternetKnowledge,
      learnFromChats: learnFromChats ?? this.learnFromChats,
      autoDetectLanguage: autoDetectLanguage ?? this.autoDetectLanguage,
      neutralIdeology: neutralIdeology ?? this.neutralIdeology,
    );
  }

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'languageTone': languageTone.name,
        'themePreset': themePreset.name,
        'isDarkMode': isDarkMode,
        'fontScale': fontScale,
        'responseDepth': responseDepth.name,
        'showCrisisBanner': showCrisisBanner,
        'compactBubbles': compactBubbles,
        'useInternetKnowledge': useInternetKnowledge,
        'learnFromChats': learnFromChats,
        'autoDetectLanguage': autoDetectLanguage,
        'neutralIdeology': neutralIdeology,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userName: json['userName'] as String? ?? '',
      languageTone: LanguageTone.values.byName(
        json['languageTone'] as String? ?? 'english',
      ),
      themePreset: ThemePreset.values.byName(
        json['themePreset'] as String? ?? 'warmSunset',
      ),
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
      responseDepth: ResponseDepth.values.byName(
        json['responseDepth'] as String? ?? 'balanced',
      ),
      showCrisisBanner: json['showCrisisBanner'] as bool? ?? true,
      compactBubbles: json['compactBubbles'] as bool? ?? false,
      useInternetKnowledge: json['useInternetKnowledge'] as bool? ?? true,
      learnFromChats: json['learnFromChats'] as bool? ?? true,
      autoDetectLanguage: json['autoDetectLanguage'] as bool? ?? true,
      neutralIdeology: json['neutralIdeology'] as bool? ?? true,
    );
  }
}
