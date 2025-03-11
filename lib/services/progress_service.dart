import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/level_progress.dart';

class ProgressService {
  static const String _progressKey = 'level_progress';
  final SharedPreferences _prefs;

  ProgressService(this._prefs);

  static Future<ProgressService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressService(prefs);
  }

  Future<void> initializeProgress() async {
    if (_prefs.getString(_progressKey) == null) {
      List<LevelProgress> progress = List.generate(10, (index) => 
        LevelProgress(level: index + 1, isUnlocked: index == 0)
      );
      await saveProgress(progress);
    }
  }

  Future<void> saveProgress(List<LevelProgress> progress) async {
    final String json = jsonEncode(
      progress.map((p) => p.toJson()).toList()
    );
    await _prefs.setString(_progressKey, json);
  }

  List<LevelProgress> getProgress() {
    final String? json = _prefs.getString(_progressKey);
    if (json == null) {
      return List.generate(
        10,
        (index) => LevelProgress(
          level: index + 1,
          isUnlocked: index == 0,
        ),
      );
    }
    
    List<dynamic> list = jsonDecode(json);
    return list.map((item) => LevelProgress.fromJson(item)).toList();
  }

  Future<void> updateLevelProgress(
    int level,
    int attempts,
    bool completed,
    int newStars,
    int wins,
  ) async {
    List<LevelProgress> progress = getProgress();
    final index = level - 1;
    
    if (index < 0 || index >= progress.length) return;

    // Only update if player got required wins
    if (completed && wins >= 3) {
      final currentProgress = progress[index];
      
      // Update only if new score is better
      if (!currentProgress.isPlayed || newStars > currentProgress.stars || 
          (newStars == currentProgress.stars && attempts < currentProgress.bestAttempts)) {
        progress[index].attempts = attempts;
        progress[index].stars = newStars;
        progress[index].bestAttempts = attempts;
      }
      
      progress[index].isPlayed = true;

      // Unlock next level if it exists
      if (index + 1 < progress.length) {
        progress[index + 1].isUnlocked = true;
      }

      await saveProgress(progress);
    }
  }

  Future<void> resetProgress() async {
    await _prefs.remove(_progressKey);
    await initializeProgress();
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