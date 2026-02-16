import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/models/models.dart';
import '../core/services/services.dart';

// Service providers
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(isDebug: kDebugMode);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final audioRecorderServiceProvider = Provider<AudioRecorderService>((ref) {
  return AudioRecorderService();
});

// State classes
class AppState {
  final bool isOnboardingComplete;
  final UserStats userStats;
  final List<Session> sessions;
  final AppSettings settings;

  const AppState({
    this.isOnboardingComplete = false,
    this.userStats = const UserStats(),
    this.sessions = const [],
    this.settings = const AppSettings(),
  });

  AppState copyWith({
    bool? isOnboardingComplete,
    UserStats? userStats,
    List<Session>? sessions,
    AppSettings? settings,
  }) {
    return AppState(
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      userStats: userStats ?? this.userStats,
      sessions: sessions ?? this.sessions,
      settings: settings ?? this.settings,
    );
  }
}

class RecordingState {
  final bool isRecording;
  final bool isProcessing;
  final Duration duration;
  final String transcript;
  final double currentWpm;
  final int fillerCount;
  final int healthPoints;
  final int maxHealthPoints;
  final AnalysisResult? analysisResult;
  final String? error;
  final PracticeMode practiceMode;
  final Language language;
  final PracticePrompt? currentPrompt;

  const RecordingState({
    this.isRecording = false,
    this.isProcessing = false,
    this.duration = Duration.zero,
    this.transcript = '',
    this.currentWpm = 0,
    this.fillerCount = 0,
    this.healthPoints = 100,
    this.maxHealthPoints = 100,
    this.analysisResult,
    this.error,
    this.practiceMode = PracticeMode.freeTalk,
    this.language = Language.english,
    this.currentPrompt,
  });

  RecordingState copyWith({
    bool? isRecording,
    bool? isProcessing,
    Duration? duration,
    String? transcript,
    double? currentWpm,
    int? fillerCount,
    int? healthPoints,
    int? maxHealthPoints,
    AnalysisResult? analysisResult,
    String? error,
    PracticeMode? practiceMode,
    Language? language,
    PracticePrompt? currentPrompt,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      duration: duration ?? this.duration,
      transcript: transcript ?? this.transcript,
      currentWpm: currentWpm ?? this.currentWpm,
      fillerCount: fillerCount ?? this.fillerCount,
      healthPoints: healthPoints ?? this.healthPoints,
      maxHealthPoints: maxHealthPoints ?? this.maxHealthPoints,
      analysisResult: analysisResult ?? this.analysisResult,
      error: error ?? this.error,
      practiceMode: practiceMode ?? this.practiceMode,
      language: language ?? this.language,
      currentPrompt: currentPrompt ?? this.currentPrompt,
    );
  }

  RecordingState reset() {
    return RecordingState(
      practiceMode: practiceMode,
      language: language,
    );
  }
}

// App State Notifier
class AppStateNotifier extends StateNotifier<AppState> {
  final StorageService _storage;

  AppStateNotifier(this._storage) : super(const AppState()) {
    _init();
  }

  Future<void> _init() async {
    await _storage.init();
    final isOnboardingComplete = await _storage.isOnboardingCompleted();
    final userStats = await _storage.getUserStats();
    final sessions = await _storage.getSessions();
    final settings = await _storage.getSettings();

    state = state.copyWith(
      isOnboardingComplete: isOnboardingComplete,
      userStats: userStats,
      sessions: sessions,
      settings: settings,
    );
  }

  Future<void> completeOnboarding() async {
    await _storage.setOnboardingCompleted();
    state = state.copyWith(isOnboardingComplete: true);
  }

  Future<void> addSession(Session session) async {
    final newSessions = [session, ...state.sessions];
    await _storage.saveSessions(newSessions);

    // Update user stats
    final newStats = _calculateUpdatedStats(session);
    await _storage.saveUserStats(newStats);

    state = state.copyWith(
      sessions: newSessions,
      userStats: newStats,
    );
  }

  UserStats _calculateUpdatedStats(Session session) {
    final stats = state.userStats;
    final now = DateTime.now();
    final lastPractice = stats.lastPracticeDate;

    // Calculate streak
    int newStreak = stats.currentStreak;
    if (lastPractice == null) {
      newStreak = 1;
    } else {
      final daysSinceLastPractice = now.difference(lastPractice).inDays;
      if (daysSinceLastPractice == 0) {
        // Same day, keep streak
      } else if (daysSinceLastPractice == 1) {
        newStreak = stats.currentStreak + 1;
      } else {
        newStreak = 1; // Reset streak
      }
    }

    // Calculate XP earned
    final score = session.analysis?.overallScore ?? 50;
    final xpEarned = (score * 0.5 + 10).toInt();

    // Update average score
    final totalSessions = stats.totalSessions + 1;
    final newAvgScore = ((stats.averageScore * stats.totalSessions) + score) /
        totalSessions;

    return stats.copyWith(
      currentStreak: newStreak,
      longestStreak:
          newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
      totalSessions: totalSessions,
      totalXp: stats.totalXp + xpEarned,
      averageScore: newAvgScore,
      practiceMinutes:
          stats.practiceMinutes + (session.duration / 60).ceil(),
      lastPracticeDate: now,
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _storage.saveSettings(settings);
    state = state.copyWith(settings: settings);
  }
}

// Recording State Notifier
class RecordingStateNotifier extends StateNotifier<RecordingState> {
  final AudioRecorderService _recorder;
  final ApiService _api;
  Timer? _durationTimer;
  StreamSubscription<double>? _amplitudeSubscription;
  Stream<double>? _amplitudeStream;

  RecordingStateNotifier(this._recorder, this._api)
      : super(const RecordingState());

  Stream<double>? get amplitudeStream => _amplitudeStream;

  void setPracticeMode(PracticeMode mode) {
    state = state.copyWith(practiceMode: mode);
  }

  void setLanguage(Language language) {
    state = state.copyWith(language: language);
  }

  void setPrompt(PracticePrompt? prompt) {
    state = state.copyWith(currentPrompt: prompt);
  }

  Future<bool> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      final granted = await _recorder.requestPermission();
      if (!granted) {
        state = state.copyWith(error: 'Microphone permission denied');
        return false;
      }
    }

    // Create session on backend
    await _api.createSession(
      language: state.language,
      mode: state.practiceMode,
    );

    final started = await _recorder.startRecording();
    if (!started) {
      state = state.copyWith(error: 'Failed to start recording');
      return false;
    }

    state = state.copyWith(
      isRecording: true,
      duration: Duration.zero,
      transcript: '',
      currentWpm: 0,
      fillerCount: 0,
      healthPoints: 100,
      analysisResult: null,
      error: null,
    );

    // Start duration timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        duration: state.duration + const Duration(seconds: 1),
      );
    });

    // Start amplitude stream - use broadcast so multiple widgets can listen
    _amplitudeStream = _recorder.getAmplitudeStream().asBroadcastStream();

    return true;
  }

  Future<Session?> stopRecording() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    state = state.copyWith(
      isRecording: false,
      isProcessing: true,
    );

    final path = await _recorder.stopRecording();
    if (path == null) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to save recording',
      );
      return null;
    }

    // Get audio bytes
    final audioBytes = await _recorder.getRecordingBytes();
    if (audioBytes == null) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to read recording',
      );
      return null;
    }

    // Send for analysis
    final sessionId = _api.currentSessionId;
    if (sessionId != null) {
      final response = await _api.analyzeAudio(
        sessionId: sessionId,
        audioData: audioBytes,
        duration: state.duration.inSeconds.toDouble(),
      );

      if (response != null) {
        final analysis = response.toAnalysisResult();
        state = state.copyWith(
          isProcessing: false,
          analysisResult: analysis,
          transcript: analysis.transcript,
        );

        // Create session object
        final session = Session(
          id: const Uuid().v4(),
          transcript: analysis.transcript,
          duration: state.duration.inSeconds.toDouble(),
          analysis: analysis,
          createdAt: DateTime.now(),
          practiceMode: state.practiceMode,
          xpEarned: (analysis.overallScore * 0.5 + 10).toInt(),
        );

        // Cleanup recording file
        await _recorder.deleteRecording();

        return session;
      }
    }

    // Fallback - create session without analysis
    state = state.copyWith(isProcessing: false);
    await _recorder.deleteRecording();

    return Session(
      id: const Uuid().v4(),
      transcript: state.transcript,
      duration: state.duration.inSeconds.toDouble(),
      createdAt: DateTime.now(),
      practiceMode: state.practiceMode,
    );
  }

  void reset() {
    _durationTimer?.cancel();
    _amplitudeSubscription?.cancel();
    state = state.reset();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _amplitudeSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}

// Providers
final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AppStateNotifier(storage);
});

final recordingStateProvider =
    StateNotifierProvider<RecordingStateNotifier, RecordingState>((ref) {
  final recorder = ref.watch(audioRecorderServiceProvider);
  final api = ref.watch(apiServiceProvider);
  return RecordingStateNotifier(recorder, api);
});

// Navigation state
enum AppScreen {
  onboarding,
  home,
  recording,
  practiceSelection,
  progress,
  achievements,
}

class NavigationState {
  final AppScreen currentScreen;
  final PracticeMode? selectedMode;
  final Difficulty selectedDifficulty;

  const NavigationState({
    this.currentScreen = AppScreen.home,
    this.selectedMode,
    this.selectedDifficulty = Difficulty.medium,
  });

  NavigationState copyWith({
    AppScreen? currentScreen,
    PracticeMode? selectedMode,
    Difficulty? selectedDifficulty,
  }) {
    return NavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void goTo(AppScreen screen) {
    state = state.copyWith(currentScreen: screen);
  }

  void goToRecording(PracticeMode mode) {
    state = state.copyWith(
      currentScreen: AppScreen.recording,
      selectedMode: mode,
    );
  }

  void goToPracticeSelection(PracticeMode mode) {
    state = state.copyWith(
      currentScreen: AppScreen.practiceSelection,
      selectedMode: mode,
    );
  }

  void setDifficulty(Difficulty difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
  }

  void goHome() {
    state = state.copyWith(currentScreen: AppScreen.home);
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
