import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';

class AchievementsScreen extends StatelessWidget {
  final UserStats userStats;
  final VoidCallback onBack;

  const AchievementsScreen({
    super.key,
    required this.userStats,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = Achievements.all.map((achievement) {
      final isUnlocked =
          userStats.unlockedAchievements.contains(achievement.id);
      return achievement.copyWith(isUnlocked: isUnlocked);
    }).toList();

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Achievements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress overview
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.glowShadow(AppTheme.primary),
                        ),
                        child: Center(
                          child: Text(
                            '$unlockedCount',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingLg),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievements Unlocked',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$unlockedCount of ${achievements.length}',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textTertiary,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 150,
                            child: LinearProgressIndicator(
                              value: unlockedCount / achievements.length,
                              backgroundColor: AppTheme.surfaceLight,
                              valueColor: const AlwaysStoppedAnimation(
                                AppTheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppTheme.warning,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${userStats.totalXp} XP',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          ' Total Earned',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textTertiary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Achievements grid
            Text(
              'All Achievements',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppTheme.spacingMd),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppTheme.spacingMd,
                crossAxisSpacing: AppTheme.spacingMd,
                childAspectRatio: 0.75,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return _buildAchievementCard(context, achievements[index])
                    .animate(delay: Duration(milliseconds: 300 + index * 50))
                    .fadeIn()
                    .scale(begin: const Offset(0.9, 0.9));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      backgroundColor: achievement.isUnlocked
          ? AppTheme.primary.withValues(alpha: 0.1)
          : AppTheme.glassBackground,
      borderColor: achievement.isUnlocked
          ? AppTheme.primary.withValues(alpha: 0.5)
          : AppTheme.glassBorder,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glow effect for unlocked
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: achievement.isUnlocked
                  ? AppTheme.primaryGradient
                  : null,
              color: achievement.isUnlocked ? null : AppTheme.surfaceLight,
              shape: BoxShape.circle,
              boxShadow: achievement.isUnlocked
                  ? AppTheme.glowShadow(AppTheme.primary)
                  : null,
            ),
            child: Icon(
              achievement.icon,
              size: 24,
              color: achievement.isUnlocked
                  ? Colors.white
                  : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),

          // Title
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: achievement.isUnlocked
                      ? AppTheme.textPrimary
                      : AppTheme.textTertiary,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Description
          Flexible(
            child: Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),

          // XP reward
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppTheme.success.withValues(alpha: 0.2)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  achievement.isUnlocked ? Icons.check : Icons.star_outline,
                  size: 14,
                  color: achievement.isUnlocked
                      ? AppTheme.success
                      : AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  achievement.isUnlocked
                      ? 'Unlocked'
                      : '+${achievement.xpReward} XP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: achievement.isUnlocked
                            ? AppTheme.success
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
