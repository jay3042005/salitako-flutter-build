import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Animated orb-style record button with pulse effect
class RecordButton extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onPressed;
  final double size;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.isProcessing = false,
    this.size = 120,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isRecording ? AppTheme.error : AppTheme.primary;

    return GestureDetector(
      onTap: widget.isProcessing ? null : widget.onPressed,
      child: SizedBox(
        width: widget.size + 60,
        height: widget.size + 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            if (widget.isRecording)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: widget.size + 40 + (_pulseController.value * 20),
                    height: widget.size + 40 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: baseColor
                            .withValues(alpha: 0.3 - _pulseController.value * 0.2),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),

            // Rotating gradient ring
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Container(
                    width: widget.size + 20,
                    height: widget.size + 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: widget.isRecording
                            ? [
                                AppTheme.error.withValues(alpha: 0.5),
                                AppTheme.accent.withValues(alpha: 0.3),
                                Colors.transparent,
                                AppTheme.error.withValues(alpha: 0.5),
                              ]
                            : [
                                AppTheme.primary.withValues(alpha: 0.5),
                                AppTheme.secondary.withValues(alpha: 0.3),
                                Colors.transparent,
                                AppTheme.primary.withValues(alpha: 0.5),
                              ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main button orb
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale =
                    widget.isRecording ? 1.0 + _pulseController.value * 0.05 : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.3),
                        colors: widget.isRecording
                            ? [
                                AppTheme.error.withValues(alpha: 0.9),
                                AppTheme.error,
                                AppTheme.error.withValues(alpha: 0.8),
                              ]
                            : [
                                AppTheme.primaryLight,
                                AppTheme.primary,
                                AppTheme.primaryDark,
                              ],
                      ),
                      boxShadow: AppTheme.glowShadow(baseColor),
                    ),
                    child: widget.isProcessing
                        ? const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            widget.isRecording ? Icons.stop_rounded : Icons.mic,
                            size: widget.size * 0.4,
                            color: Colors.white,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ).animate(target: widget.isRecording ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 200.ms,
        );
  }
}

/// Smaller action button with gradient
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final bool isOutlined;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.gradient,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
