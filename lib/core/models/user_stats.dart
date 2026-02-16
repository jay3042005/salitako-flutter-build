import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int totalXp;
  final int level;
  final int xpToNextLevel;
  final double averageScore;
  final int practiceMinutes;
  final DateTime? lastPracticeDate;
  final List<String> unlockedAchievements;

  const UserStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.totalXp = 0,
    this.level = 1,
    this.xpToNextLevel = 100,
    this.averageScore = 0.0,
    this.practiceMinutes = 0,
    this.lastPracticeDate,
    this.unlockedAchievements = const [],
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xpToNextLevel: json['xp_to_next_level'] as int? ?? 100,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      practiceMinutes: json['practice_minutes'] as int? ?? 0,
      lastPracticeDate: json['last_practice_date'] != null
          ? DateTime.parse(json['last_practice_date'] as String)
          : null,
      unlockedAchievements: (json['unlocked_achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_sessions': totalSessions,
      'total_xp': totalXp,
      'level': level,
      'xp_to_next_level': xpToNextLevel,
      'average_score': averageScore,
      'practice_minutes': practiceMinutes,
      'last_practice_date': lastPracticeDate?.toIso8601String(),
      'unlocked_achievements': unlockedAchievements,
    };
  }

  double get xpProgress {
    final xpInCurrentLevel = totalXp % xpToNextLevel;
    return xpInCurrentLevel / xpToNextLevel;
  }

  UserStats copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalSessions,
    int? totalXp,
    int? level,
    int? xpToNextLevel,
    double? averageScore,
    int? practiceMinutes,
    DateTime? lastPracticeDate,
    List<String>? unlockedAchievements,
  }) {
    return UserStats(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      averageScore: averageScore ?? this.averageScore,
      practiceMinutes: practiceMinutes ?? this.practiceMinutes,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalSessions,
        totalXp,
        level,
        xpToNextLevel,
        averageScore,
        practiceMinutes,
        lastPracticeDate,
        unlockedAchievements,
      ];
}
