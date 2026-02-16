import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/recording/recording_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/achievements/achievements_screen.dart';
import 'features/practice/practice_selection_screen.dart';
import 'core/models/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SalitaKoApp(),
    ),
  );
}

class SalitaKoApp extends ConsumerStatefulWidget {
  const SalitaKoApp({super.key});

  @override
  ConsumerState<SalitaKoApp> createState() => _SalitaKoAppState();
}

class _SalitaKoAppState extends ConsumerState<SalitaKoApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Defer mDNS discovery to after first frame to avoid widget tree issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        _initializeServices();
      }
    });
  }
  
  Future<void> _initializeServices() async {
    if (!mounted) return;
    final api = ref.read(apiServiceProvider);
    final connected = await api.connect();
    if (!mounted) return;
    if (connected) {
      debugPrint('✅ Connected to server: ${api.serverUrl}');
    } else {
      debugPrint('⚠️ Server connection failed - some features may not work');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final isDarkMode = appState.settings.darkMode;
    
    return MaterialApp(
      title: 'SalitaKo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppShell(),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final navState = ref.watch(navigationProvider);
    final recordingState = ref.watch(recordingStateProvider);

    // Show onboarding if not completed
    if (!appState.isOnboardingComplete) {
      return OnboardingScreen(
        onComplete: () {
          ref.read(appStateProvider.notifier).completeOnboarding();
        },
      );
    }

    // Navigate based on current screen
    switch (navState.currentScreen) {
      case AppScreen.onboarding:
        return OnboardingScreen(
          onComplete: () {
            ref.read(appStateProvider.notifier).completeOnboarding();
            ref.read(navigationProvider.notifier).goHome();
          },
        );

      case AppScreen.home:
        return HomeScreen(
          userStats: appState.userStats,
          recentSessions: appState.sessions.take(5).toList(),
          onStartRecording: () {
            ref.read(recordingStateProvider.notifier).setPracticeMode(
                  PracticeMode.freeTalk,
                );
            ref.read(navigationProvider.notifier).goTo(AppScreen.recording);
          },
          onSelectMode: (mode) {
            if (mode == PracticeMode.freeTalk) {
              ref.read(recordingStateProvider.notifier).setPracticeMode(mode);
              ref.read(navigationProvider.notifier).goTo(AppScreen.recording);
            } else {
              ref.read(navigationProvider.notifier).goToPracticeSelection(mode);
            }
          },
          onViewProgress: () {
            ref.read(navigationProvider.notifier).goTo(AppScreen.progress);
          },
          onViewAchievements: () {
            ref.read(navigationProvider.notifier).goTo(AppScreen.achievements);
          },
        );

      case AppScreen.recording:
        final recorderNotifier = ref.read(recordingStateProvider.notifier);
        return RecordingScreen(
          practiceMode: recordingState.practiceMode,
          language: recordingState.language,
          currentPrompt: recordingState.currentPrompt,
          amplitudeStream: recorderNotifier.amplitudeStream,
          isRecording: recordingState.isRecording,
          isProcessing: recordingState.isProcessing,
          duration: recordingState.duration,
          currentWpm: recordingState.currentWpm,
          fillerCount: recordingState.fillerCount,
          healthPoints: recordingState.healthPoints,
          maxHealthPoints: recordingState.maxHealthPoints,
          transcript: recordingState.transcript,
          analysisResult: recordingState.analysisResult,
          onStartRecording: () async {
            await recorderNotifier.startRecording();
          },
          onStopRecording: () async {
            final session = await recorderNotifier.stopRecording();
            if (session != null) {
              ref.read(appStateProvider.notifier).addSession(session);
            }
          },
          onClose: () {
            recorderNotifier.reset();
            ref.read(navigationProvider.notifier).goHome();
          },
          onRetry: () {
            recorderNotifier.reset();
          },
        );

      case AppScreen.practiceSelection:
        return PracticeSelectionScreen(
          mode: navState.selectedMode ?? PracticeMode.guided,
          selectedLanguage: recordingState.language,
          selectedDifficulty: navState.selectedDifficulty,
          onLanguageChanged: (language) {
            ref.read(recordingStateProvider.notifier).setLanguage(language);
          },
          onDifficultyChanged: (difficulty) {
            ref.read(navigationProvider.notifier).setDifficulty(difficulty);
          },
          onStartPractice: (prompt) {
            ref.read(recordingStateProvider.notifier).setPrompt(prompt);
            ref.read(recordingStateProvider.notifier).setPracticeMode(
                  navState.selectedMode ?? PracticeMode.guided,
                );
            ref.read(navigationProvider.notifier).goTo(AppScreen.recording);
          },
          onBack: () {
            ref.read(navigationProvider.notifier).goHome();
          },
        );

      case AppScreen.progress:
        return ProgressScreen(
          userStats: appState.userStats,
          sessions: appState.sessions,
          onBack: () {
            ref.read(navigationProvider.notifier).goHome();
          },
        );

      case AppScreen.achievements:
        return AchievementsScreen(
          userStats: appState.userStats,
          onBack: () {
            ref.read(navigationProvider.notifier).goHome();
          },
        );
    }
  }
}
