import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/reading_passages.dart' as reading_data;
import '../../shared/widgets/widgets.dart';
import '../reading/reading_passage_display.dart';

class RecordingScreen extends StatefulWidget {
  final PracticeMode practiceMode;
  final Language language;
  final PracticePrompt? currentPrompt;  // Add prompt for reading mode
  final Stream<double>? amplitudeStream;
  final bool isRecording;
  final bool isProcessing;
  final Duration duration;
  final double currentWpm;
  final int fillerCount;
  final int healthPoints;
  final int maxHealthPoints;
  final String transcript;
  final AnalysisResult? analysisResult;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const RecordingScreen({
    super.key,
    required this.practiceMode,
    required this.language,
    this.currentPrompt,
    this.amplitudeStream,
    required this.isRecording,
    this.isProcessing = false,
    required this.duration,
    this.currentWpm = 0,
    this.fillerCount = 0,
    this.healthPoints = 100,
    this.maxHealthPoints = 100,
    required this.transcript,
    this.analysisResult,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onClose,
    required this.onRetry,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  @override
  Widget build(BuildContext context) {
    final hasResult = widget.analysisResult != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
        title: Text(widget.practiceMode.displayName),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppTheme.spacingMd),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.language.flag),
                const SizedBox(width: 4),
                Text(
                  widget.language.displayName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: hasResult ? _buildResultsView(context) : _buildRecordingView(context),
      ),
    );
  }

  Widget _buildRecordingView(BuildContext context) {
    // Check if we're in reading mode with a prompt
    final isReadingMode = widget.practiceMode == PracticeMode.reading && 
                          widget.currentPrompt != null;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Reading passage display for reading mode
                  if (isReadingMode) ...[
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: _buildReadingPassageCard(context),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  ] else
                    const Spacer(),

                  // Live stats (only during recording)
                  if (widget.isRecording) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WpmGauge(wpm: widget.currentWpm, size: 100),
                          Column(
                            children: [
                              FillerCounter(count: widget.fillerCount),
                              const SizedBox(height: AppTheme.spacingMd),
                              HealthBar(
                                currentHp: widget.healthPoints,
                                maxHp: widget.maxHealthPoints,
                                width: 120,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppTheme.spacingXl),
                  ],

                  // Audio visualizer
                  if (widget.isRecording)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      child: AudioVisualizer(
                        amplitudeStream: widget.amplitudeStream,
                        isActive: widget.isRecording,
                        height: 80,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Duration display
                  Text(
                    _formatDuration(widget.duration),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Status text
                  Text(
                    widget.isProcessing
                        ? 'Analyzing your speech...'
                        : widget.isRecording
                            ? 'Recording...'
                            : 'Tap to start recording',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Record button
                  Center(
                    child: CircularVisualizer(
                      amplitudeStream: widget.amplitudeStream,
                      isActive: widget.isRecording,
                      size: 120,
                      child: RecordButton(
                        isRecording: widget.isRecording,
                        isProcessing: widget.isProcessing,
                        onPressed: widget.isRecording ? widget.onStopRecording : widget.onStartRecording,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Live transcript
                  if (widget.transcript.isNotEmpty && widget.isRecording)
                    GlassCard(
                      margin: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.success,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.success.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Live Transcript',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.textTertiary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.transcript,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: AppTheme.spacingMd),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadingPassageCard(BuildContext context) {
    final prompt = widget.currentPrompt!;
    
    // Create a ReadingPassage from the prompt
    final passage = reading_data.ReadingPassage(
      id: prompt.id,
      title: prompt.title,
      category: prompt.category,
      content: prompt.prompt,
      wordCount: prompt.prompt.split(RegExp(r'\s+')).length,
      difficulty: prompt.difficulty,
      language: prompt.language,
    );
    
    return ReadingPassageDisplay(
      passage: passage,
      transcript: widget.transcript,
      isRecording: widget.isRecording,
    );
  }

  Widget _buildResultsView(BuildContext context) {
    final result = widget.analysisResult!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          // Overall score
          _buildOverallScore(context, result)
              .animate()
              .fadeIn(delay: 100.ms)
              .scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: AppTheme.spacingLg),

          // Stats row
          _buildStatsRow(context, result)
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: AppTheme.spacingLg),
          
          // AI Feedback (Filipino)
          _buildFeedbackCard(context, result)
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: AppTheme.spacingLg),

          // Score breakdown
          _buildScoreBreakdown(context, result)
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: AppTheme.spacingLg),

          // Filler words breakdown
          if (result.fillerWords.isNotEmpty)
            _buildFillerBreakdown(context, result)
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.1),
          if (result.fillerWords.isNotEmpty)
            const SizedBox(height: AppTheme.spacingLg),

          // Transcript
          _buildTranscript(context, result)
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: AppTheme.spacingXl),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.replay),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
  
  Widget _buildFillerBreakdown(BuildContext context, AnalysisResult result) {
    final sortedFillers = result.fillerWords.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: AppTheme.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filler Words Detected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortedFillers.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  border: Border.all(
                    color: AppTheme.warning.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '"${entry.key}"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.warning,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${entry.value}×',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore(BuildContext context, AnalysisResult result) {
    final score = result.overallScore;
    final color = score >= 80
        ? AppTheme.success
        : score >= 60
            ? AppTheme.warning
            : AppTheme.error;

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      child: Column(
        children: [
          Text(
            'Overall Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '${score.toInt()}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Text(
              score >= 80
                  ? 'Excellent!'
                  : score >= 60
                      ? 'Good job!'
                      : 'Keep practicing!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(BuildContext context, AnalysisResult result) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildScoreRow(context, 'Fluency', result.fluencyScore),
          _buildScoreRow(context, 'Clarity', result.clarityScore),
          _buildScoreRow(context, 'Vocabulary', result.vocabularyScore),
          _buildScoreRow(context, 'Grammar', result.grammarScore),
        ],
      ),
    );
  }

  Widget _buildScoreRow(BuildContext context, String label, double score) {
    final color = score >= 80
        ? AppTheme.success
        : score >= 60
            ? AppTheme.warning
            : AppTheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
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
            width: 40,
            child: Text(
              '${score.toInt()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AnalysisResult result) {
    final paceColor = result.paceStatus == 'Normal' 
        ? AppTheme.success 
        : result.paceStatus == 'Fast' 
            ? AppTheme.error 
            : AppTheme.warning;
    
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speed, color: paceColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  '${result.wordsPerMinute.toInt()}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  result.paceStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: paceColor,
                        fontWeight: FontWeight.w600,
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
                const Icon(Icons.text_fields, color: AppTheme.secondary, size: 20),
                const SizedBox(height: 4),
                Text(
                  '${result.wordCount}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Words',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
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
                Icon(
                  Icons.format_quote,
                  size: 20,
                  color: result.totalFillerCount > 5
                      ? AppTheme.error
                      : result.totalFillerCount > 2 
                          ? AppTheme.warning 
                          : AppTheme.success,
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.totalFillerCount}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Fillers',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
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
                const Icon(Icons.psychology, color: AppTheme.primary, size: 20),
                const SizedBox(height: 4),
                Text(
                  '${result.coherenceScore.toInt()}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Clarity',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeedbackCard(BuildContext context, AnalysisResult result) {
    if (result.feedback == null) return const SizedBox.shrink();
    
    final feedback = result.feedback!;
    
    return GlassCard(
      borderColor: AppTheme.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assistant, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Feedback',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      feedback.general,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Divider(color: AppTheme.glassBorder),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Pacing feedback
          if (feedback.pacing.isNotEmpty)
            _buildFeedbackItem(
              context, 
              Icons.speed, 
              'Pacing', 
              feedback.pacing,
              result.paceStatus == 'Normal' ? AppTheme.success : AppTheme.warning,
            ),
          
          // Filler feedback
          if (feedback.fillers.isNotEmpty)
            _buildFeedbackItem(
              context, 
              Icons.format_quote, 
              'Filler Words', 
              feedback.fillers,
              result.totalFillerCount <= 2 ? AppTheme.success : AppTheme.warning,
            ),
          
          // Coherence feedback
          if (feedback.coherence.isNotEmpty)
            _buildFeedbackItem(
              context, 
              Icons.psychology, 
              'Coherence', 
              feedback.coherence,
              result.coherenceScore >= 70 ? AppTheme.success : AppTheme.warning,
            ),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    String message,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscript(BuildContext context, AnalysisResult result) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppTheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Transcript',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            result.transcript,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
