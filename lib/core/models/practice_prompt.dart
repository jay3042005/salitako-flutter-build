import 'package:equatable/equatable.dart';
import 'practice_mode.dart';

class PracticePrompt extends Equatable {
  final String id;
  final String category;
  final String title;
  final String prompt;
  final int durationSeconds;
  final Difficulty difficulty;
  final Language language;

  const PracticePrompt({
    required this.id,
    required this.category,
    required this.title,
    required this.prompt,
    required this.durationSeconds,
    required this.difficulty,
    required this.language,
  });

  factory PracticePrompt.fromJson(Map<String, dynamic> json) {
    return PracticePrompt(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      durationSeconds: json['duration'] as int? ?? 60,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      language: Language.values.firstWhere(
        (l) => l.code == json['language'],
        orElse: () => Language.english,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'prompt': prompt,
      'duration': durationSeconds,
      'difficulty': difficulty.name,
      'language': language.code,
    };
  }

  @override
  List<Object?> get props => [
        id,
        category,
        title,
        prompt,
        durationSeconds,
        difficulty,
        language,
      ];
}

class ReadingPassage extends Equatable {
  final String id;
  final String title;
  final String content;
  final int wordCount;
  final Difficulty difficulty;
  final Language language;

  const ReadingPassage({
    required this.id,
    required this.title,
    required this.content,
    required this.wordCount,
    required this.difficulty,
    required this.language,
  });

  factory ReadingPassage.fromJson(Map<String, dynamic> json) {
    return ReadingPassage(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      wordCount: json['word_count'] as int? ?? 0,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      language: Language.values.firstWhere(
        (l) => l.code == json['language'],
        orElse: () => Language.english,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'word_count': wordCount,
      'difficulty': difficulty.name,
      'language': language.code,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        wordCount,
        difficulty,
        language,
      ];
}
