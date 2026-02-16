import 'package:flutter/material.dart';

enum PracticeMode {
  freeTalk(
    displayName: 'Free Talk',
    description: 'Speak freely about any topic',
    icon: Icons.chat_bubble_outline,
    color: Color(0xFF6366F1),
  ),
  guided(
    displayName: 'Guided Practice',
    description: 'Follow prompts and topics',
    icon: Icons.lightbulb_outline,
    color: Color(0xFF8B5CF6),
  ),
  reading(
    displayName: 'Reading Mode',
    description: 'Read passages aloud',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF06B6D4),
  ),
  interview(
    displayName: 'Interview Prep',
    description: 'Practice job interview answers',
    icon: Icons.work_outline,
    color: Color(0xFF10B981),
  );

  final String displayName;
  final String description;
  final IconData icon;
  final Color color;

  const PracticeMode({
    required this.displayName,
    required this.description,
    required this.icon,
    required this.color,
  });
}

enum Language {
  english(
    displayName: 'English',
    code: 'en',
    flag: '🇺🇸',
  ),
  filipino(
    displayName: 'Filipino',
    code: 'fil',
    flag: '🇵🇭',
  ),
  taglish(
    displayName: 'Taglish',
    code: 'tl-en',
    flag: '🇵🇭🇺🇸',
  );

  final String displayName;
  final String code;
  final String flag;

  const Language({
    required this.displayName,
    required this.code,
    required this.flag,
  });
}

enum Difficulty {
  easy(
    displayName: 'Easy',
    color: Color(0xFF10B981),
  ),
  medium(
    displayName: 'Medium',
    color: Color(0xFFF59E0B),
  ),
  hard(
    displayName: 'Hard',
    color: Color(0xFFEF4444),
  );

  final String displayName;
  final Color color;

  const Difficulty({
    required this.displayName,
    required this.color,
  });
}
