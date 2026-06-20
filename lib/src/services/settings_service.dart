import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aaroh_chat/src/models/user_settings.dart';

class SettingsService extends ChangeNotifier {
  static const _settingsKey = 'aaroh_user_settings';
  static const _onboardingKey = 'aaroh_onboarding_done';

  UserSettings _settings = const UserSettings();
  bool _onboardingDone = false;
  bool _isLoading = true;

  UserSettings get settings => _settings;
  bool get onboardingDone => _onboardingDone;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw != null) {
      try {
        _settings = UserSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _settings = const UserSettings();
      }
    }
    _onboardingDone = prefs.getBool(_onboardingKey) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(newSettings.toJson()));
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> resetOnboarding() async {
    _onboardingDone = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
  }
}
