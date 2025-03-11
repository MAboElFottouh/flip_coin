class LevelProgress {
  final int level;
  int stars;
  int attempts;
  bool isUnlocked;
  bool isPlayed;
  int bestAttempts;

  LevelProgress({
    required this.level,
    this.stars = 0,
    this.attempts = 0,
    this.isUnlocked = false,
    this.isPlayed = false,
    this.bestAttempts = 0,
  });

  Map<String, dynamic> toJson() => {
    'level': level,
    'stars': stars,
    'attempts': attempts,
    'isUnlocked': isUnlocked,
    'isPlayed': isPlayed,
    'bestAttempts': bestAttempts,
  };

  factory LevelProgress.fromJson(Map<String, dynamic> json) => LevelProgress(
    level: json['level'] as int,
    stars: json['stars'] as int? ?? 0,
    attempts: json['attempts'] as int? ?? 0,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    isPlayed: json['isPlayed'] as bool? ?? false,
    bestAttempts: json['bestAttempts'] as int? ?? 0,
  );
}