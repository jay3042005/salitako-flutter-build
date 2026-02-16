import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';

class ProgressScreen extends StatelessWidget {
  final UserStats userStats;
  final List<Session> sessions;
  final VoidCallback onBack;

  const ProgressScreen({
    super.key,
    required this.userStats,
    required this.sessions,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP Progress
            GlassCard(
              child: XpProgressBar(
                currentXp: userStats.totalXp,
                xpToNextLevel: userStats.xpToNextLevel,
                level: userStats.level,
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Stats overview
            _buildStatsGrid(context)
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Score chart
            Text(
              'Score Trend',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppTheme.spacingMd),
            GlassCard(
              height: 200,
              child: _buildScoreChart(context),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Skill breakdown
            Text(
              'Skill Breakdown',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: AppTheme.spacingMd),
            GlassCard(
              child: _buildSkillBreakdown(context),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Filler words analysis
            Text(
              'Filler Words',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: AppTheme.spacingMd),
            _buildFillerWordsChart(context)
                .animate()
                .fadeIn(delay: 800.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Session history
            Text(
              'Session History',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(delay: 900.ms),
            const SizedBox(height: AppTheme.spacingMd),
            _buildSessionHistory(context)
                .animate()
                .fadeIn(delay: 1000.ms)
                .slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spacingMd,
      crossAxisSpacing: AppTheme.spacingMd,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          icon: Icons.local_fire_department,
          label: 'Current Streak',
          value: '${userStats.currentStreak} days',
          iconColor: AppTheme.warning,
        ),
        StatCard(
          icon: Icons.emoji_events,
          label: 'Longest Streak',
          value: '${userStats.longestStreak} days',
          iconColor: AppTheme.accent,
        ),
        StatCard(
          icon: Icons.timer,
          label: 'Practice Time',
          value: '${userStats.practiceMinutes} min',
          iconColor: AppTheme.secondary,
        ),
        StatCard(
          icon: Icons.star,
          label: 'Avg Score',
          value: '${userStats.averageScore.toInt()}%',
          iconColor: AppTheme.success,
          valueColor: AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildScoreChart(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          'No sessions yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
        ),
      );
    }

    final recentSessions = sessions.take(10).toList().reversed.toList();
    final spots = recentSessions.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.analysis?.overallScore ?? 0,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.glassBorder,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: AppTheme.primaryGradient,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.3),
                  AppTheme.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBreakdown(BuildContext context) {
    // Calculate average scores from sessions
    double avgFluency = 0, avgClarity = 0, avgVocab = 0, avgGrammar = 0;
    int count = 0;

    for (final session in sessions) {
      if (session.analysis != null) {
        avgFluency += session.analysis!.fluencyScore;
        avgClarity += session.analysis!.clarityScore;
        avgVocab += session.analysis!.vocabularyScore;
        avgGrammar += session.analysis!.grammarScore;
        count++;
      }
    }

    if (count > 0) {
      avgFluency /= count;
      avgClarity /= count;
      avgVocab /= count;
      avgGrammar /= count;
    }

    return Column(
      children: [
        _buildSkillRow(context, 'Fluency', avgFluency, AppTheme.primary),
        _buildSkillRow(context, 'Clarity', avgClarity, AppTheme.secondary),
        _buildSkillRow(context, 'Vocabulary', avgVocab, AppTheme.success),
        _buildSkillRow(context, 'Grammar', avgGrammar, AppTheme.accent),
      ],
    );
  }

  Widget _buildSkillRow(
    BuildContext context,
    String label,
    double score,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (score / 100).clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          SizedBox(
            width: 45,
            child: Text(
              '${score.toInt()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFillerWordsChart(BuildContext context) {
    // Aggregate filler words from all sessions
    final fillerCounts = <String, int>{};
    for (final session in sessions) {
      if (session.analysis != null) {
        for (final entry in session.analysis!.fillerWords.entries) {
          fillerCounts[entry.key] = (fillerCounts[entry.key] ?? 0) + entry.value;
        }
      }
    }

    if (fillerCounts.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Center(
          child: Text(
            'No filler words detected yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ),
      );
    }

    final sortedFillers = fillerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFillers = sortedFillers.take(6).toList();
    final maxCount =
        topFillers.isNotEmpty ? topFillers.first.value.toDouble() : 1.0;

    return GlassCard(
      child: Column(
        children: topFillers.map((entry) {
          final percentage = entry.value / maxCount;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '"${entry.key}"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.warning.withValues(alpha: 0.7),
                              AppTheme.warning,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                SizedBox(
                  width: 30,
                  child: Text(
                    '${entry.value}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionHistory(BuildContext context) {
    if (sessions.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.history,
                size: 48,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'No sessions yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: sessions.take(10).map((session) {
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
                    Row(
                      children: [
                        Text(
                          _formatDate(session.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${(session.duration / 60).toStringAsFixed(1)} min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                        ),
                      ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
