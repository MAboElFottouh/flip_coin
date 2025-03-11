import 'package:flutter/material.dart';
import '../models/level_progress.dart';
import '../services/progress_service.dart';
import 'login_screen.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  
  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<LevelProgress> progress;
  late ProgressService _progressService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    _progressService = await ProgressService.create();
    await _progressService.initializeProgress();
    setState(() {
      progress = _progressService.getProgress();
    });
  }

  int calculateTotalScore() {
    return progress.fold(0, (sum, level) {
      switch (level.stars) {
        case 1:
          return sum + 10;
        case 2:
          return sum + 30;
        case 3:
          return sum + 70;
        default:
          return sum;
      }
    });
  }

  Widget _buildLevelButton(LevelProgress levelProgress) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: levelProgress.isUnlocked ? () async {
            final shouldRefresh = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(level: levelProgress.level),
              ),
            );
            
            if (shouldRefresh == true && mounted) {
              setState(() {
                progress = _progressService.getProgress();
              });
            }
          } : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${levelProgress.level}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (levelProgress.isPlayed && levelProgress.bestAttempts > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Best: ${levelProgress.bestAttempts} attempts',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                if (!levelProgress.isUnlocked)
                  const Icon(Icons.lock, color: Colors.white54, size: 24)
                else
                  Row(
                    children: List.generate(3, (index) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.star,
                        color: index < levelProgress.stars 
                            ? Colors.yellow 
                            : Colors.white.withOpacity(0.3),
                        size: 24,
                      ),
                    )),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRulesCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scoring System',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Score: ${calculateTotalScore()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreRule('⭐⭐⭐', '70 pts'),
                _buildScoreRule('⭐⭐', '30 pts'),
                _buildScoreRule('⭐', '10 pts'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRule(String stars, String points) {
    return Column(
      children: [
        Text(
          stars,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          points,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        actions: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset Progress',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Progress'),
                  content: const Text(
                    'Are you sure you want to reset all progress? This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await _progressService.resetProgress();
                        setState(() {
                          progress = _progressService.getProgress();
                        });
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Progress has been reset'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Show Debug Info',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Debug Info'),
                  content: SingleChildScrollView(
                    child: SelectableText(
                      _progressService.getDebugInfo(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildScoreRulesCard(),
            Expanded(
              child: ListView.builder(
                itemCount: progress.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildLevelButton(progress[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
