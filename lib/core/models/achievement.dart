import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final int requirement;
  final int progress;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.requirement,
    this.progress = 0,
    this.isUnlocked = false,
  });

  double get progressPercent =>
      requirement > 0 ? (progress / requirement).clamp(0.0, 1.0) : 0.0;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? xpReward,
    int? requirement,
    int? progress,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xpReward: xpReward ?? this.xpReward,
      requirement: requirement ?? this.requirement,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        xpReward,
        requirement,
        progress,
        isUnlocked,
      ];
}

class Achievements {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Complete your first practice session',
      icon: Icons.emoji_events,
      xpReward: 50,
      requirement: 1,
    ),
    Achievement(
      id: 'on_fire',
      title: 'On Fire',
      description: 'Maintain a 3-day streak',
      icon: Icons.local_fire_department,
      xpReward: 100,
      requirement: 3,
    ),
    Achievement(
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: Icons.military_tech,
      xpReward: 250,
      requirement: 7,
    ),
    Achievement(
      id: 'monthly_master',
      title: 'Monthly Master',
      description: 'Maintain a 30-day streak',
      icon: Icons.workspace_premium,
      xpReward: 1000,
      requirement: 30,
    ),
    Achievement(
      id: 'high_achiever',
      title: 'High Achiever',
      description: 'Score 80% or higher in a session',
      icon: Icons.star,
      xpReward: 75,
      requirement: 80,
    ),
    Achievement(
      id: 'excellence',
      title: 'Excellence',
      description: 'Score 90% or higher in a session',
      icon: Icons.stars,
      xpReward: 150,
      requirement: 90,
    ),
    Achievement(
      id: 'getting_serious',
      title: 'Getting Serious',
      description: 'Complete 10 practice sessions',
      icon: Icons.trending_up,
      xpReward: 200,
      requirement: 10,
    ),
    Achievement(
      id: 'dedicated_speaker',
      title: 'Dedicated Speaker',
      description: 'Complete 50 practice sessions',
      icon: Icons.campaign,
      xpReward: 500,
      requirement: 50,
    ),
    Achievement(
      id: 'hour_of_power',
      title: 'Hour of Power',
      description: 'Practice for 60 minutes total',
      icon: Icons.timer,
      xpReward: 100,
      requirement: 60,
    ),
    Achievement(
      id: 'bilingual_pro',
      title: 'Bilingual Pro',
      description: 'Practice in both English and Filipino',
      icon: Icons.translate,
      xpReward: 150,
      requirement: 2,
    ),
    Achievement(
      id: 'filipino_master',
      title: 'Filipino Master',
      description: 'Complete 10 sessions in Filipino',
      icon: Icons.flag,
      xpReward: 200,
      requirement: 10,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
