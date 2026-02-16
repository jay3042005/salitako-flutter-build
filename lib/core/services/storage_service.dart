import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class StorageService {
  static const String _userStatsKey = 'user_stats';
  static const String _sessionsKey = 'sessions';
  static const String _settingsKey = 'settings';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // User Stats
  Future<UserStats> getUserStats() async {
    await init();
    final json = _prefs.getString(_userStatsKey);
    if (json == null) return const UserStats();
    return UserStats.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveUserStats(UserStats stats) async {
    await init();
    await _prefs.setString(_userStatsKey, jsonEncode(stats.toJson()));
  }

  // Sessions
  Future<List<Session>> getSessions() async {
    await init();
    final json = _prefs.getString(_sessionsKey);
    if (json == null) return [];

    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => Session.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSessions(List<Session> sessions) async {
    await init();
    final json = sessions.map((s) => s.toJson()).toList();
    await _prefs.setString(_sessionsKey, jsonEncode(json));
  }

  Future<void> addSession(Session session) async {
    final sessions = await getSessions();
    sessions.insert(0, session);
    // Keep only last 100 sessions
    if (sessions.length > 100) {
      sessions.removeRange(100, sessions.length);
    }
    await saveSessions(sessions);
  }

  // Settings
  Future<AppSettings> getSettings() async {
    await init();
    final json = _prefs.getString(_settingsKey);
    if (json == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await init();
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // Onboarding
  Future<bool> isOnboardingCompleted() async {
    await init();
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    await init();
    await _prefs.setBool(_onboardingCompletedKey, true);
  }

  // Clear all data
  Future<void> clearAll() async {
    await init();
    await _prefs.clear();
  }
}

class AppSettings {
  final Language selectedLanguage;
  final bool hapticFeedback;
  final bool showLiveWpm;
  final bool showFillerCounter;
  final bool darkMode;

  const AppSettings({
    this.selectedLanguage = Language.english,
    this.hapticFeedback = true,
    this.showLiveWpm = true,
    this.showFillerCounter = true,
    this.darkMode = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      selectedLanguage: Language.values.firstWhere(
        (l) => l.code == json['selected_language'],
        orElse: () => Language.english,
      ),
      hapticFeedback: json['haptic_feedback'] as bool? ?? true,
      showLiveWpm: json['show_live_wpm'] as bool? ?? true,
      showFillerCounter: json['show_filler_counter'] as bool? ?? true,
      darkMode: json['dark_mode'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_language': selectedLanguage.code,
      'haptic_feedback': hapticFeedback,
      'show_live_wpm': showLiveWpm,
      'show_filler_counter': showFillerCounter,
      'dark_mode': darkMode,
    };
  }

  AppSettings copyWith({
    Language? selectedLanguage,
    bool? hapticFeedback,
    bool? showLiveWpm,
    bool? showFillerCounter,
    bool? darkMode,
  }) {
    return AppSettings(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showLiveWpm: showLiveWpm ?? this.showLiveWpm,
      showFillerCounter: showFillerCounter ?? this.showFillerCounter,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
