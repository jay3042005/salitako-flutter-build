import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../settings/settings_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  final UserStats userStats;
  final List<Session> recentSessions;
  final VoidCallback onStartRecording;
  final Function(PracticeMode) onSelectMode;
  final VoidCallback onViewProgress;
  final VoidCallback onViewAchievements;

  const HomeScreen({
    super.key,
    required this.userStats,
    required this.recentSessions,
    required this.onStartRecording,
    required this.onSelectMode,
    required this.onViewProgress,
    required this.onViewAchievements,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: AppTheme.spacingLg),

              // Stats overview
              _buildStatsOverview(context)
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: AppTheme.spacingLg),

              // XP Progress
              GlassCard(
                child: XpProgressBar(
                  currentXp: userStats.totalXp,
                  xpToNextLevel: userStats.xpToNextLevel,
                  level: userStats.level,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: AppTheme.spacingLg),

              // Quick start button
              _buildQuickStartButton(context)
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: AppTheme.spacingLg),

              // Practice modes
              Text(
                'Practice Modes',
                style: Theme.of(context).textTheme.headlineSmall,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: AppTheme.spacingMd),
              _buildPracticeModes(context)
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: AppTheme.spacingLg),

              // Recent sessions
              if (recentSessions.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Sessions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: onViewProgress,
                      child: const Text('View All'),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: AppTheme.spacingMd),
                _buildRecentSessions(context)
                    .animate()
                    .fadeIn(delay: 700.ms)
                    .slideY(begin: 0.1),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'SalitaKo',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = AppTheme.primaryGradient
                          .createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                  ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onViewAchievements,
              icon: const Icon(Icons.emoji_events_outlined),
              color: AppTheme.textSecondary,
            ),
            IconButton(
              onPressed: () {
                // Settings
                showSettingsBottomSheet(context);
              },
              icon: const Icon(Icons.settings_outlined),
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppTheme.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${userStats.currentStreak}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warning,
                          ),
                    ),
                  ],
                ),
                Text(
                  'Streak',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${userStats.totalSessions}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                ),
                Text(
                  'Sessions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${userStats.averageScore.toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                ),
                Text(
                  'Avg Score',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStartButton(BuildContext context) {
    return GradientCard(
      onTap: onStartRecording,
      gradient: AppTheme.primaryGradient,
      shadows: AppTheme.glowShadow(AppTheme.primary),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Practicing',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Record and improve your speaking',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeModes(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spacingMd,
      crossAxisSpacing: AppTheme.spacingMd,
      childAspectRatio: 1.0,
      children: PracticeMode.values.map((mode) {
        return GlassCard(
          onTap: () => onSelectMode(mode),
          borderColor: mode.color.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: mode.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mode.icon,
                    color: mode.color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  mode.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    mode.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentSessions(BuildContext context) {
    return Column(
      children: recentSessions.take(3).map((session) {
        final score = session.analysis?.overallScore ?? 0;
        return GlassCard(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: session.practiceMode.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  session.practiceMode.icon,
                  color: session.practiceMode.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.practiceMode.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${(session.duration / 60).toStringAsFixed(1)} min',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: Text(
                  '${score.toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getScoreColor(score),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return AppTheme.warning;
    return AppTheme.error;
  }
}
