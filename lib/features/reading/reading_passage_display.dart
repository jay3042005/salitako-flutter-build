import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/data/reading_passages.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';

/// Widget to display reading passage during recording
class ReadingPassageDisplay extends StatelessWidget {
  final ReadingPassage passage;
  final String transcript;
  final bool isRecording;

  const ReadingPassageDisplay({
    super.key,
    required this.passage,
    required this.transcript,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: AppTheme.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passage.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${passage.wordCount} words • ${passage.category}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? AppTheme.darkTextTertiary 
                            : AppTheme.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: passage.difficulty.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: Text(
                  passage.difficulty.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: passage.difficulty.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          const Divider(),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Passage text with highlighting
          _buildHighlightedText(context),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Instructions
          if (isRecording)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.mic,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Read the passage aloud clearly',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            ).fade(begin: 0.7, end: 1.0, duration: 1.seconds),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Split the passage into words
    final passageWords = passage.content.split(RegExp(r'\s+'));
    final transcriptWords = transcript.toLowerCase().split(RegExp(r'\s+'));
    
    // Simple word matching (can be improved with fuzzy matching)
    int matchedCount = 0;
    for (int i = 0; i < passageWords.length && i < transcriptWords.length; i++) {
      final passageWord = passageWords[i].toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      final transcriptWord = transcriptWords[i].replaceAll(RegExp(r'[^\w]'), '');
      if (passageWord == transcriptWord || 
          passageWord.contains(transcriptWord) || 
          transcriptWord.contains(passageWord)) {
        matchedCount = i + 1;
      }
    }
    
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.8,
          fontSize: 16,
        ),
        children: passageWords.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;
          
          // Determine word state
          final isSpoken = index < matchedCount;
          final isCurrent = index == matchedCount && transcript.isNotEmpty;
          
          Color textColor;
          FontWeight fontWeight = FontWeight.normal;
          Color? backgroundColor;
          
          if (isSpoken) {
            // Already read - green
            textColor = AppTheme.success;
            fontWeight = FontWeight.w500;
          } else if (isCurrent) {
            // Current word - highlighted
            textColor = AppTheme.primary;
            fontWeight = FontWeight.bold;
            backgroundColor = AppTheme.primary.withValues(alpha: 0.2);
          } else {
            // Not yet read
            textColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
          }
          
          return TextSpan(
            text: '$word ',
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
              backgroundColor: backgroundColor,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Compact passage selector card
class PassageCard extends StatelessWidget {
  final ReadingPassage passage;
  final VoidCallback onTap;

  const PassageCard({
    super.key,
    required this.passage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GlassCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppTheme.info,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passage.title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${passage.category} • ${passage.wordCount} words',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? AppTheme.darkTextTertiary 
                        : AppTheme.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: passage.difficulty.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Text(
              passage.difficulty.displayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: passage.difficulty.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
