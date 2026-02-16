import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Circular speedometer-style gauge for WPM display
class WpmGauge extends StatelessWidget {
  final double wpm;
  final double maxWpm;
  final double size;

  const WpmGauge({
    super.key,
    required this.wpm,
    this.maxWpm = 200,
    this.size = 150,
  });

  Color get _statusColor {
    if (wpm < 100) return AppTheme.warning;
    if (wpm > 170) return AppTheme.error;
    return AppTheme.success;
  }

  String get _statusText {
    if (wpm < 100) return 'Slow';
    if (wpm > 170) return 'Fast';
    return 'Good';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background arc
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              value: wpm / maxWpm,
              backgroundColor: AppTheme.surfaceLight,
              foregroundColor: _statusColor,
              strokeWidth: 12,
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wpm.toInt().toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
              ),
              Text(
                'WPM',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: Text(
                  _statusText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;

  _GaugePainter({
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = 0.75 * math.pi;
    const sweepAngle = 1.5 * math.pi;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Foreground arc
    final fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          foregroundColor.withValues(alpha: 0.6),
          foregroundColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * value.clamp(0, 1),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      value != oldDelegate.value ||
      foregroundColor != oldDelegate.foregroundColor;
}

/// Filler word counter badge
class FillerCounter extends StatelessWidget {
  final int count;
  final bool animate;

  const FillerCounter({
    super.key,
    required this.count,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: count > 5
            ? AppTheme.error.withValues(alpha: 0.2)
            : count > 2
                ? AppTheme.warning.withValues(alpha: 0.2)
                : AppTheme.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(
          color: count > 5
              ? AppTheme.error.withValues(alpha: 0.5)
              : count > 2
                  ? AppTheme.warning.withValues(alpha: 0.5)
                  : AppTheme.success.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 16,
            color: count > 5
                ? AppTheme.error
                : count > 2
                    ? AppTheme.warning
                    : AppTheme.success,
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: count > 5
                      ? AppTheme.error
                      : count > 2
                          ? AppTheme.warning
                          : AppTheme.success,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            'fillers',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}

/// Health points bar (gamification element)
class HealthBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final double width;

  const HealthBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = maxHp > 0 ? currentHp / maxHp : 0.0;

    Color barColor;
    if (percentage > 0.6) {
      barColor = AppTheme.success;
    } else if (percentage > 0.3) {
      barColor = AppTheme.warning;
    } else {
      barColor = AppTheme.error;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              size: 16,
              color: barColor,
            ),
            const SizedBox(width: 6),
            Text(
              '$currentHp / $maxHp HP',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: width,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    barColor.withValues(alpha: 0.8),
                    barColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: barColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// XP progress bar with level indicator
class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int xpToNextLevel;
  final int level;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final xpInLevel = currentXp % xpToNextLevel;
    final progress = xpToNextLevel > 0 ? xpInLevel / xpToNextLevel : 0.0;

    return Row(
      children: [
        // Level badge
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppTheme.glowShadow(AppTheme.primary),
          ),
          child: Center(
            child: Text(
              '$level',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        // Progress bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level $level',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '$xpInLevel / $xpToNextLevel XP',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
