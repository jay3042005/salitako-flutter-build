import 'package:equatable/equatable.dart';
import 'analysis_result.dart';
import 'practice_mode.dart';

class Session extends Equatable {
  final String id;
  final String transcript;
  final double duration;
  final AnalysisResult? analysis;
  final DateTime createdAt;
  final PracticeMode practiceMode;
  final int xpEarned;

  const Session({
    required this.id,
    required this.transcript,
    required this.duration,
    this.analysis,
    required this.createdAt,
    required this.practiceMode,
    this.xpEarned = 0,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      transcript: json['transcript'] as String? ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      analysis: json['analysis'] != null
          ? AnalysisResult.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      practiceMode: PracticeMode.values.firstWhere(
        (e) => e.name == json['practice_mode'],
        orElse: () => PracticeMode.freeTalk,
      ),
      xpEarned: json['xp_earned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transcript': transcript,
      'duration': duration,
      'analysis': analysis?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'practice_mode': practiceMode.name,
      'xp_earned': xpEarned,
    };
  }

  Session copyWith({
    String? id,
    String? transcript,
    double? duration,
    AnalysisResult? analysis,
    DateTime? createdAt,
    PracticeMode? practiceMode,
    int? xpEarned,
  }) {
    return Session(
      id: id ?? this.id,
      transcript: transcript ?? this.transcript,
      duration: duration ?? this.duration,
      analysis: analysis ?? this.analysis,
      createdAt: createdAt ?? this.createdAt,
      practiceMode: practiceMode ?? this.practiceMode,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transcript,
        duration,
        analysis,
        createdAt,
        practiceMode,
        xpEarned,
      ];
}
