import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final settings = appState.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBackgroundSecondary : AppTheme.lightBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Title
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Dark Mode Toggle
          _buildSettingsTile(
            context: context,
            icon: settings.darkMode ? Icons.dark_mode : Icons.light_mode,
            iconColor: settings.darkMode ? AppTheme.primary : AppTheme.warning,
            title: 'Dark Mode',
            subtitle: settings.darkMode ? 'Dark theme enabled' : 'Light theme enabled',
            trailing: Switch(
              value: settings.darkMode,
              onChanged: (value) {
                ref.read(appStateProvider.notifier).updateSettings(
                      settings.copyWith(darkMode: value),
                    );
              },
            ),
          ),

          const Divider(height: 32),

          // Haptic Feedback
          _buildSettingsTile(
            context: context,
            icon: Icons.vibration,
            iconColor: AppTheme.secondary,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on interactions',
            trailing: Switch(
              value: settings.hapticFeedback,
              onChanged: (value) {
                ref.read(appStateProvider.notifier).updateSettings(
                      settings.copyWith(hapticFeedback: value),
                    );
              },
            ),
          ),

          // Show Live WPM
          _buildSettingsTile(
            context: context,
            icon: Icons.speed,
            iconColor: AppTheme.success,
            title: 'Show Live WPM',
            subtitle: 'Display words per minute while recording',
            trailing: Switch(
              value: settings.showLiveWpm,
              onChanged: (value) {
                ref.read(appStateProvider.notifier).updateSettings(
                      settings.copyWith(showLiveWpm: value),
                    );
              },
            ),
          ),

          // Show Filler Counter
          _buildSettingsTile(
            context: context,
            icon: Icons.filter_list,
            iconColor: AppTheme.accent,
            title: 'Show Filler Counter',
            subtitle: 'Display filler word count while recording',
            trailing: Switch(
              value: settings.showFillerCounter,
              onChanged: (value) {
                ref.read(appStateProvider.notifier).updateSettings(
                      settings.copyWith(showFillerCounter: value),
                    );
              },
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Version info
          Center(
            child: Text(
              'SalitaKo v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// Show the settings bottom sheet
void showSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const SettingsBottomSheet(),
  );
}
