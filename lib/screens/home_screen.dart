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

  Widget _buildLevelButton(LevelProgress levelProgress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 80,
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    if (levelProgress.isPlayed) ...[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}'),
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
    );
  }
}
