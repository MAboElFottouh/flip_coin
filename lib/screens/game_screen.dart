import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';
import '../models/level_requirements.dart';

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({
    super.key,
    required this.level,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  String? selectedChoice;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isAnimating = false;
  String? result;
  int attempts = 0;
  int wins = 0;  // Add this variable
  late final ProgressService _progressService;
  final int requiredWins = 3; // Each level needs 3 wins
  bool levelCompleted = false;
  late final LevelRequirement levelRequirement;
  
  @override
  void initState() {
    super.initState();
    levelRequirement = _getLevelRequirement();
    _initializeServices();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isAnimating = false;
          result = math.Random().nextBool() ? 'Head' : 'Tail';
          attempts++; // Increment attempts for each flip
          
          if (result == selectedChoice) {
            wins++; // Increment wins only on correct guess
            _checkLevelCompletion(); // Check if level is complete after win
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Correct! 🎉\nProgress: $wins/${levelRequirement.requiredWins} wins needed',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Wrong! It was $result 😢\nProgress: $wins/${levelRequirement.requiredWins} wins needed',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    });
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _progressService = ProgressService(prefs);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectChoice(String choice) {
    setState(() {
      selectedChoice = choice;
    });
  }

  void _startFlip() {
    if (selectedChoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Head or Tail first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      isAnimating = true;
      result = null;
    });
    _controller.reset();
    _controller.forward();
  }

  Color _getButtonColor(String choice, Color defaultColor) {
    return selectedChoice == choice ? Colors.blue.shade300 : defaultColor;
  }

  void _checkLevelCompletion() {
    if (wins == levelRequirement.requiredWins && !levelCompleted) {
      levelCompleted = true;
      int stars;
      if (attempts <= levelRequirement.threeStarsAttempts) {
        stars = 3;
      } else if (attempts <= levelRequirement.twoStarsAttempts) {
        stars = 2;
      } else {
        stars = 1;
      }
      
      _progressService.updateLevelProgress(
        widget.level,
        attempts,
        true,
        stars,
        wins,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Level Complete! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You completed the level in $attempts attempts!'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => Icon(
                  Icons.star,
                  color: index < stars ? Colors.yellow : Colors.grey,
                  size: 30,
                )),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to level selection with refresh flag
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  LevelRequirement _getLevelRequirement() {
    switch (widget.level) {
      case 1:
        return const LevelRequirement(
          requiredWins: 3,
          threeStarsAttempts: 5,  // 3 wins in 5 attempts
          twoStarsAttempts: 8,    // 3 wins in 8 attempts
        );
      case 2:
        return const LevelRequirement(
          requiredWins: 4,         // Increase by 1 from previous level
          threeStarsAttempts: 6,   // Increase by 1 from previous level
          twoStarsAttempts: 9,     // Increase by 1 from previous level
        );
      case 3:
        return const LevelRequirement(
          requiredWins: 5,         // Increase by 1 from previous level
          threeStarsAttempts: 7,   // Increase by 1 from previous level
          twoStarsAttempts: 10,    // Increase by 1 from previous level
        );
      default:
        return const LevelRequirement(
          requiredWins: 3,         // Default requirements
          threeStarsAttempts: 5,   // Default three stars threshold
          twoStarsAttempts: 8,     // Default two stars threshold
        );
    }
  }

  Widget _buildRequirementsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Level Requirements:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            '⭐⭐⭐',
            'Win ${levelRequirement.requiredWins} times within ${levelRequirement.threeStarsAttempts} attempts',
          ),
          _buildRequirementRow(
            '⭐⭐',
            'Win ${levelRequirement.requiredWins} times within ${levelRequirement.twoStarsAttempts} attempts',
          ),
          _buildRequirementRow(
            '⭐',
            'Win ${levelRequirement.requiredWins} times in more attempts',
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String stars, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            stars,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Add Score Display
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$wins / ${levelRequirement.requiredWins}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildRequirementsCard(),
          const Spacer(),
          // Coin Animation
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(isAnimating ? _animation.value * math.pi * 6 : 0),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        result == 'Tail' ? 'assets/tail.png' : 'assets/head.png'
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          // Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGameButton(
                      'Head',
                      _getButtonColor('Head', Colors.blue.shade600),
                      isAnimating ? null : () => _selectChoice('Head'),
                    ),
                    const SizedBox(width: 20),
                    _buildGameButton(
                      'Tail',
                      _getButtonColor('Tail', Colors.blue.shade600),
                      isAnimating ? null : () => _selectChoice('Tail'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildGameButton(
                  'Start',
                  Colors.green,
                  isAnimating ? null : _startFlip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton(String text, Color color, VoidCallback? onPressed) {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}