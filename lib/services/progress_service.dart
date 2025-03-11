import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/level_progress.dart';

class ProgressService {
  static const String _progressKeyPrefix = 'progress_';
  final SharedPreferences _prefs;
  final String username;

  ProgressService._({
    required SharedPreferences prefs,
    required this.username,
  }) : _prefs = prefs;

  static Future<ProgressService> create(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressService._(prefs: prefs, username: username);
  }

  String get _userProgressKey => '${_progressKeyPrefix}$username';

  List<LevelProgress> getProgress() {
    final String? jsonString = _prefs.getString(_userProgressKey);
    if (jsonString == null) {
      // Create and save initial progress for new user
      final initialProgress = List.generate(
        10,
        (index) => LevelProgress(
          level: index + 1,
          isUnlocked: index == 0,
          stars: 0,
          bestAttempts: 0,
          attempts: 0,
        ),
      );
      saveProgress(initialProgress);
      return initialProgress;
    }
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => LevelProgress.fromJson(json)).toList();
  }

  Future<void> saveProgress(List<LevelProgress> progress) async {
    final String jsonString = json.encode(
      progress.map((p) => p.toJson()).toList(),
    );
    await _prefs.setString(_userProgressKey, jsonString);
  }

  Future<void> updateLevelProgress(
    int level,
    int attempts,
    bool completed,
    int stars,
    int wins,
  ) async {
    final progress = getProgress();
    final levelIndex = level - 1;

    if (levelIndex >= 0 && levelIndex < progress.length) {
      final currentLevel = progress[levelIndex];
      progress[levelIndex] = LevelProgress(
        level: level,
        isUnlocked: true,
        stars: stars > currentLevel.stars ? stars : currentLevel.stars,
        bestAttempts: completed && (currentLevel.bestAttempts == 0 || attempts < currentLevel.bestAttempts)
            ? attempts
            : currentLevel.bestAttempts,
        attempts: attempts,
      );

      // Unlock next level if completed
      if (completed && levelIndex + 1 < progress.length) {
        progress[levelIndex + 1] = progress[levelIndex + 1].copyWith(isUnlocked: true);
      }

      await saveProgress(progress);
    }
  }

  Future<void> resetProgress() async {
    await _prefs.remove(_userProgressKey);
    // Progress will be re-initialized on next getProgress call
  }

  String getDebugInfo() {
    final levels = getProgress();
    final buffer = StringBuffer();
    buffer.writeln('\n=== LEVEL PROGRESS ===');
    
    for (var level in levels) {
      buffer.writeln('''
Level ${level.level}:
  Stars: ${level.stars}
  Status: ${level.isUnlocked ? 'Unlocked' : 'Locked'}
  Played: ${level.isPlayed ? 'Yes' : 'No'}
  Best Attempts: ${level.bestAttempts}
''');
    }
    
    buffer.writeln('===================');
    return buffer.toString();
  }
}