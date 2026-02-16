import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Real-time audio visualizer with wave bars
class AudioVisualizer extends StatefulWidget {
  final Stream<double>? amplitudeStream;
  final bool isActive;
  final int barCount;
  final double height;
  final Color? color;

  const AudioVisualizer({
    super.key,
    this.amplitudeStream,
    required this.isActive,
    this.barCount = 32,
    this.height = 100,
    this.color,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<double> _barHeights;
  StreamSubscription<double>? _amplitudeSubscription;
  double _currentAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _barHeights = List.filled(widget.barCount, 0.1);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateBars);

    if (widget.isActive) {
      _animationController.repeat();
    }

    _subscribeToAmplitude();
  }
  
  void _subscribeToAmplitude() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = widget.amplitudeStream?.listen(
      (amplitude) {
        _currentAmplitude = amplitude;
      },
      onError: (error) {
        // Ignore stream errors
      },
    );
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amplitudeStream != oldWidget.amplitudeStream) {
      _subscribeToAmplitude();
    }
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.stop();
      setState(() {
        _barHeights = List.filled(widget.barCount, 0.1);
      });
    }
  }

  void _updateBars() {
    if (!widget.isActive) return;

    setState(() {
      for (int i = 0; i < widget.barCount; i++) {
        // Create wave effect with some randomness based on amplitude
        final baseHeight = _currentAmplitude * 0.8;
        final random = math.Random();
        final wave = math.sin((i / widget.barCount) * math.pi * 2 +
            DateTime.now().millisecondsSinceEpoch / 200);
        _barHeights[i] = (baseHeight + wave * 0.2 + random.nextDouble() * 0.1)
            .clamp(0.1, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primary;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 4,
            height: widget.height * _barHeights[index],
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.7),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: widget.isActive && _barHeights[index] > 0.5
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}

/// Circular audio visualizer with pulsing rings
class CircularVisualizer extends StatefulWidget {
  final Stream<double>? amplitudeStream;
  final bool isActive;
  final double size;
  final Widget? child;

  const CircularVisualizer({
    super.key,
    this.amplitudeStream,
    required this.isActive,
    this.size = 200,
    this.child,
  });

  @override
  State<CircularVisualizer> createState() => _CircularVisualizerState();
}

class _CircularVisualizerState extends State<CircularVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  StreamSubscription<double>? _amplitudeSubscription;
  double _amplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _subscribeToAmplitude();
  }
  
  void _subscribeToAmplitude() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = widget.amplitudeStream?.listen(
      (amplitude) {
        if (mounted) {
          setState(() {
            _amplitude = amplitude;
          });
        }
      },
      onError: (error) {
        // Ignore stream errors
      },
    );
  }
  
  @override
  void didUpdateWidget(CircularVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amplitudeStream != oldWidget.amplitudeStream) {
      _subscribeToAmplitude();
    }
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final baseScale = widget.isActive ? 1.0 + _amplitude * 0.15 : 1.0;
        final pulseValue = _pulseController.value;

        return SizedBox(
          width: widget.size + 60,
          height: widget.size + 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse rings
              if (widget.isActive) ...[
                _buildRing(widget.size + 40, pulseValue * 0.3 + _amplitude * 0.3),
                _buildRing(widget.size + 20, (pulseValue + 0.33) % 1 * 0.3 + _amplitude * 0.2),
                _buildRing(widget.size, (pulseValue + 0.66) % 1 * 0.3 + _amplitude * 0.1),
              ],
              // Center content
              Transform.scale(
                scale: baseScale,
                child: widget.child ?? Container(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRing(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: opacity.clamp(0, 0.5)),
          width: 2,
        ),
      ),
    );
  }
}

/// Waveform display for recorded audio
class WaveformDisplay extends StatelessWidget {
  final List<double> amplitudes;
  final double height;
  final Color? color;
  final double progress;

  const WaveformDisplay({
    super.key,
    required this.amplitudes,
    this.height = 60,
    this.color,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (amplitudes.isEmpty) {
      return SizedBox(height: height);
    }

    final barColor = color ?? AppTheme.primary;
    final progressIndex = (amplitudes.length * progress).floor();

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _WaveformPainter(
          amplitudes: amplitudes,
          color: barColor,
          playedColor: barColor.withValues(alpha: 0.4),
          progressIndex: progressIndex,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;
  final Color playedColor;
  final int progressIndex;

  _WaveformPainter({
    required this.amplitudes,
    required this.color,
    required this.playedColor,
    required this.progressIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final barWidth = size.width / amplitudes.length;
    final centerY = size.height / 2;

    for (int i = 0; i < amplitudes.length; i++) {
      final barHeight = amplitudes[i] * size.height * 0.8;
      final x = i * barWidth;
      final isPlayed = i < progressIndex;

      final paint = Paint()
        ..color = isPlayed ? playedColor : color
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth * 0.7,
          height: barHeight.clamp(2, size.height),
        ),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      amplitudes != oldDelegate.amplitudes ||
      progressIndex != oldDelegate.progressIndex;
}
