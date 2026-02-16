import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/reading_passages.dart';
import '../../shared/widgets/widgets.dart';
import '../reading/reading_passage_display.dart';

class PracticeSelectionScreen extends StatelessWidget {
  final PracticeMode mode;
  final Language selectedLanguage;
  final Difficulty selectedDifficulty;
  final Function(Language) onLanguageChanged;
  final Function(Difficulty) onDifficultyChanged;
  final Function(PracticePrompt?) onStartPractice;
  final VoidCallback onBack;

  const PracticeSelectionScreen({
    super.key,
    required this.mode,
    required this.selectedLanguage,
    required this.selectedDifficulty,
    required this.onLanguageChanged,
    required this.onDifficultyChanged,
    required this.onStartPractice,
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
        title: Text(mode.displayName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode info card
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: mode.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      mode.icon,
                      color: mode.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Language selection
            Text(
              'Language',
              style: Theme.of(context).textTheme.titleMedium,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppTheme.spacingSm),
            _buildLanguageSelector(context)
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Difficulty selection
            Text(
              'Difficulty',
              style: Theme.of(context).textTheme.titleMedium,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: AppTheme.spacingSm),
            _buildDifficultySelector(context)
                .animate()
                .fadeIn(delay: 500.ms)
                .slideX(begin: 0.1),
            const SizedBox(height: AppTheme.spacingLg),

            // Prompts, Reading Passages, or Quick Start
            if (mode == PracticeMode.freeTalk) ...[
              _buildFreeTalkSection(context)
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .slideY(begin: 0.1),
            ] else if (mode == PracticeMode.reading) ...[
              Text(
                'Choose a Passage',
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: AppTheme.spacingSm),
              _buildReadingPassagesList(context)
                  .animate()
                  .fadeIn(delay: 700.ms)
                  .slideY(begin: 0.1),
            ] else ...[
              Text(
                'Choose a Topic',
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: AppTheme.spacingSm),
              _buildPromptsList(context)
                  .animate()
                  .fadeIn(delay: 700.ms)
                  .slideY(begin: 0.1),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Row(
      children: Language.values.map((language) {
        final isSelected = selectedLanguage == language;
        return Expanded(
          child: GestureDetector(
            onTap: () => onLanguageChanged(language),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: isSelected
                    ? null
                    : Border.all(color: AppTheme.glassBorder),
              ),
              child: Column(
                children: [
                  Text(
                    language.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.displayName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySelector(BuildContext context) {
    return Row(
      children: Difficulty.values.map((difficulty) {
        final isSelected = selectedDifficulty == difficulty;
        return Expanded(
          child: GestureDetector(
            onTap: () => onDifficultyChanged(difficulty),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? difficulty.color.withValues(alpha: 0.2)
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? difficulty.color
                      : AppTheme.glassBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  difficulty.displayName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? difficulty.color
                            : AppTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFreeTalkSection(BuildContext context) {
    return GradientCard(
      onTap: () => onStartPractice(null),
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
                  'Start Free Talk',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Speak freely about any topic',
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

  Widget _buildPromptsList(BuildContext context) {
    // Sample prompts based on mode and difficulty
    final prompts = _getSamplePrompts();

    return Column(
      children: prompts.map((prompt) {
        return GlassCard(
          onTap: () => onStartPractice(prompt),
          margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: mode.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: mode.color,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prompt.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
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
                  color: prompt.difficulty.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: Text(
                  '${prompt.durationSeconds ~/ 60} min',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: prompt.difficulty.color,
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<PracticePrompt> _getSamplePrompts() {
    // Sample prompts - in real app these would come from API/database
    if (mode == PracticeMode.guided) {
      return [
        PracticePrompt(
          id: '1',
          category: 'Personal',
          title: 'Introduce Yourself',
          prompt: 'Tell us about yourself - your background, interests, and goals.',
          durationSeconds: 60,
          difficulty: selectedDifficulty,
          language: selectedLanguage,
        ),
        PracticePrompt(
          id: '2',
          category: 'Opinion',
          title: 'Favorite Hobby',
          prompt: 'Describe your favorite hobby and explain why you enjoy it.',
          durationSeconds: 90,
          difficulty: selectedDifficulty,
          language: selectedLanguage,
        ),
        PracticePrompt(
          id: '3',
          category: 'Storytelling',
          title: 'A Memorable Experience',
          prompt: 'Share a memorable experience from your life.',
          durationSeconds: 120,
          difficulty: selectedDifficulty,
          language: selectedLanguage,
        ),
      ];
    } else if (mode == PracticeMode.interview) {
      return [
        PracticePrompt(
          id: '4',
          category: 'Job Interview',
          title: 'Tell Me About Yourself',
          prompt: 'Answer the classic job interview question.',
          durationSeconds: 60,
          difficulty: selectedDifficulty,
          language: selectedLanguage,
        ),
        PracticePrompt(
          id: '5',
          category: 'Job Interview',
          title: 'Greatest Strength',
          prompt: 'What is your greatest strength?',
          durationSeconds: 60,
          difficulty: selectedDifficulty,
          language: selectedLanguage,
        ),
        PracticePrompt(
          id: '6',
          category: 'Job Interview',
          title: 'Why This Company?',
          prompt: 'Why do you want to work for this company?',
          durationSeconds: 90,
          difficulty: selectedDifficulty,
          language: selectedLanguage,
        ),
      ];
    } else {
      // Guided/other modes
      return [
        PracticePrompt(
          id: '7',
          category: 'Personal',
          title: 'Daily Routine',
          prompt: 'Describe your typical day from morning to night.',
          durationSeconds: 90,
          difficulty: selectedDifficulty,
          language: selectedLanguage,
        ),
        PracticePrompt(
          id: '8',
          category: 'Opinion',
          title: 'Favorite Place',
          prompt: 'Tell us about your favorite place to visit.',
          durationSeconds: 90,
          difficulty: selectedDifficulty,
          language: selectedLanguage,
        ),
      ];
    }
  }

  Widget _buildReadingPassagesList(BuildContext context) {
    final passages = ReadingPassages.getPassages(selectedLanguage, selectedDifficulty);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (passages.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: isDark ? AppTheme.darkTextTertiary : AppTheme.lightTextTertiary,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'No passages available for this combination',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppTheme.darkTextTertiary : AppTheme.lightTextTertiary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Try a different language or difficulty',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: passages.map((passage) {
        return PassageCard(
          passage: passage,
          onTap: () {
            // Convert passage to prompt and start
            final prompt = PracticePrompt(
              id: passage.id,
              category: passage.category,
              title: passage.title,
              prompt: passage.content,  // Store full content in prompt
              durationSeconds: (passage.wordCount / 2).round() * 60 ~/ 60 + 60, // Estimate time
              difficulty: passage.difficulty,
              language: passage.language,
            );
            onStartPractice(prompt);
          },
        );
      }).toList(),
    );
  }
}
