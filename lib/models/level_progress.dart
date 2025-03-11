class LevelProgress {
  final int level;
  final bool isUnlocked;
  final int stars;
  final int bestAttempts;
  final int attempts;

  const LevelProgress({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.bestAttempts,
    required this.attempts,
  });

  // Add isPlayed getter
  bool get isPlayed => bestAttempts > 0;

  LevelProgress copyWith({
    int? level,
    bool? isUnlocked,
    int? stars,
    int? bestAttempts,
    int? attempts,
  }) {
    return LevelProgress(
      level: level ?? this.level,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      stars: stars ?? this.stars,
      bestAttempts: bestAttempts ?? this.bestAttempts,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'isUnlocked': isUnlocked,
    'stars': stars,
    'bestAttempts': bestAttempts,
    'attempts': attempts,
  };

  factory LevelProgress.fromJson(Map<String, dynamic> json) => LevelProgress(
    level: json['level'],
    isUnlocked: json['isUnlocked'],
    stars: json['stars'],
    bestAttempts: json['bestAttempts'],
    attempts: json['attempts'],
  );
}