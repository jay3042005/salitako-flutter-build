import 'package:equatable/equatable.dart';

/// Feedback messages from the backend (in Filipino)
class FeedbackMessages extends Equatable {
  final String general;
  final String pacing;
  final String fillers;
  final String coherence;

  const FeedbackMessages({
    this.general = '',
    this.pacing = '',
    this.fillers = '',
    this.coherence = '',
  });

  factory FeedbackMessages.fromJson(Map<String, dynamic> json) {
    return FeedbackMessages(
      general: json['general'] as String? ?? '',
      pacing: json['pacing'] as String? ?? '',
      fillers: json['fillers'] as String? ?? '',
      coherence: json['coherence'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [general, pacing, fillers, coherence];
}

class AnalysisResult extends Equatable {
  final String transcript;
  final double overallScore;
  final double fluencyScore;
  final double clarityScore;
  final double vocabularyScore;
  final double grammarScore;
  final double coherenceScore;
  final String paceStatus;
  final double? silenceRatio;
  final List<String> suggestions;
  final List<String> strengths;
  final int wordCount;
  final double wordsPerMinute;
  final String detectedLanguage;
  final Map<String, int> fillerWords;
  final FeedbackMessages? feedback;

  const AnalysisResult({
    required this.transcript,
    required this.overallScore,
    required this.fluencyScore,
    required this.clarityScore,
    required this.vocabularyScore,
    required this.grammarScore,
    this.coherenceScore = 0,
    this.paceStatus = 'Normal',
    this.silenceRatio,
    required this.suggestions,
    required this.strengths,
    required this.wordCount,
    required this.wordsPerMinute,
    required this.detectedLanguage,
    required this.fillerWords,
    this.feedback,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      transcript: json['transcript'] as String? ?? '',
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0.0,
      fluencyScore: (json['fluency_score'] as num?)?.toDouble() ?? 0.0,
      clarityScore: (json['clarity_score'] as num?)?.toDouble() ?? 0.0,
      vocabularyScore: (json['vocabulary_score'] as num?)?.toDouble() ?? 0.0,
      grammarScore: (json['grammar_score'] as num?)?.toDouble() ?? 0.0,
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      wordCount: json['word_count'] as int? ?? 0,
      wordsPerMinute: (json['words_per_minute'] as num?)?.toDouble() ?? 0.0,
      detectedLanguage: json['detected_language'] as String? ?? 'en',
      fillerWords: (json['filler_words'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcript': transcript,
      'overall_score': overallScore,
      'fluency_score': fluencyScore,
      'clarity_score': clarityScore,
      'vocabulary_score': vocabularyScore,
      'grammar_score': grammarScore,
      'suggestions': suggestions,
      'strengths': strengths,
      'word_count': wordCount,
      'words_per_minute': wordsPerMinute,
      'detected_language': detectedLanguage,
      'filler_words': fillerWords,
    };
  }

  int get totalFillerCount => fillerWords.values.fold(0, (a, b) => a + b);

  AnalysisResult copyWith({
    String? transcript,
    double? overallScore,
    double? fluencyScore,
    double? clarityScore,
    double? vocabularyScore,
    double? grammarScore,
    double? coherenceScore,
    String? paceStatus,
    double? silenceRatio,
    List<String>? suggestions,
    List<String>? strengths,
    int? wordCount,
    double? wordsPerMinute,
    String? detectedLanguage,
    Map<String, int>? fillerWords,
    FeedbackMessages? feedback,
  }) {
    return AnalysisResult(
      transcript: transcript ?? this.transcript,
      overallScore: overallScore ?? this.overallScore,
      fluencyScore: fluencyScore ?? this.fluencyScore,
      clarityScore: clarityScore ?? this.clarityScore,
      vocabularyScore: vocabularyScore ?? this.vocabularyScore,
      grammarScore: grammarScore ?? this.grammarScore,
      coherenceScore: coherenceScore ?? this.coherenceScore,
      paceStatus: paceStatus ?? this.paceStatus,
      silenceRatio: silenceRatio ?? this.silenceRatio,
      suggestions: suggestions ?? this.suggestions,
      strengths: strengths ?? this.strengths,
      wordCount: wordCount ?? this.wordCount,
      wordsPerMinute: wordsPerMinute ?? this.wordsPerMinute,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      fillerWords: fillerWords ?? this.fillerWords,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        transcript,
        overallScore,
        fluencyScore,
        clarityScore,
        vocabularyScore,
        grammarScore,
        coherenceScore,
        paceStatus,
        silenceRatio,
        suggestions,
        strengths,
        wordCount,
        wordsPerMinute,
        detectedLanguage,
        fillerWords,
      ];
}
