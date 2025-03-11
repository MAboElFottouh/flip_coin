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
  String? resultMessage;
  Color? resultColor;
  
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
            resultMessage = 'Correct!';
            resultColor = Colors.green;
            _checkLevelCompletion(); // Check if level is complete after win
          } else {
            resultMessage = 'Wrong!';
            resultColor = Colors.red;
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
      resultMessage = null; // Clear previous result
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
      case 4:
        return const LevelRequirement(
          requiredWins: 6,
          threeStarsAttempts: 8,    // 6 wins in 8 attempts
          twoStarsAttempts: 11,     // 6 wins in 11 attempts
        );
      case 5:
        return const LevelRequirement(
          requiredWins: 7,
          threeStarsAttempts: 9,    // 7 wins in 9 attempts
          twoStarsAttempts: 12,     // 7 wins in 12 attempts
        );
      case 6:
        return const LevelRequirement(
          requiredWins: 8,
          threeStarsAttempts: 10,   // 8 wins in 10 attempts
          twoStarsAttempts: 13,     // 8 wins in 13 attempts
        );
      case 7:
        return const LevelRequirement(
          requiredWins: 9,
          threeStarsAttempts: 11,   // 9 wins in 11 attempts
          twoStarsAttempts: 14,     // 9 wins in 14 attempts
        );
      case 8:
        return const LevelRequirement(
          requiredWins: 10,
          threeStarsAttempts: 12,   // 10 wins in 12 attempts
          twoStarsAttempts: 15,     // 10 wins in 15 attempts
        );
      case 9:
        return const LevelRequirement(
          requiredWins: 11,
          threeStarsAttempts: 13,   // 11 wins in 13 attempts
          twoStarsAttempts: 16,     // 11 wins in 16 attempts
        );
      case 10:
        return const LevelRequirement(
          requiredWins: 12,
          threeStarsAttempts: 14,   // 12 wins in 14 attempts
          twoStarsAttempts: 17,     // 12 wins in 17 attempts
        );
      default:
        return const LevelRequirement(
          requiredWins: 3,         // Default requirements
          threeStarsAttempts: 5,   // Default three stars threshold
          twoStarsAttempts: 8,     // Default two stars threshold
        );
    }
  }

  Widget _buildRequirementsCard(Size screenSize, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level Requirements:',
            style: TextStyle(
              fontSize: screenSize.width * 0.05, // Increased from 0.04
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: padding * 0.8), // Increased from 0.5
          _buildRequirementRow(
            '⭐⭐⭐',
            'Win ${levelRequirement.requiredWins} times within ${levelRequirement.threeStarsAttempts} attempts',
            screenSize,
          ),
          _buildRequirementRow(
            '⭐⭐',
            'Win ${levelRequirement.requiredWins} times within ${levelRequirement.twoStarsAttempts} attempts',
            screenSize,
          ),
          _buildRequirementRow(
            '⭐',
            'Win ${levelRequirement.requiredWins} times in more attempts',
            screenSize,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String stars, String text, Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.008), // Increased from 0.005
      child: Row(
        children: [
          Text(
            stars,
            style: TextStyle(fontSize: screenSize.width * 0.045), // Increased from 0.035
          ),
          SizedBox(width: screenSize.width * 0.03), // Increased from 0.02
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: screenSize.width * 0.04), // Increased from 0.03
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressColumn([double? fontSize]) {
    return Column(
      children: [
        Text(
          'Progress',
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$wins/${levelRequirement.requiredWins}',
          style: TextStyle(
            fontSize: fontSize != null ? fontSize + 6 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptsColumn([double? fontSize]) {
    return Column(
      children: [
        Text(
          'Attempts',
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$attempts',
          style: TextStyle(
            fontSize: fontSize != null ? fontSize + 6 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.05; // Increased from 0.04
    final coinSize = screenSize.width * 0.5; // Reduced from 0.6 to 0.5

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress and Attempts
          Container(
            padding: EdgeInsets.all(padding),
            margin: EdgeInsets.all(padding * 0.5),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProgressColumn(screenSize.width * 0.045),
                Container(
                  width: 1,
                  height: screenSize.height * 0.06,
                  color: Colors.blue.withOpacity(0.3),
                ),
                _buildAttemptsColumn(screenSize.width * 0.045),
              ],
            ),
          ),

          // Main content area with proper spacing
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRequirementsCard(screenSize, padding),
                  if (resultMessage != null) ...[
                    SizedBox(height: padding * 0.5),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: padding),
                      padding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: padding * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: resultColor?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: resultColor?.withOpacity(0.5) ?? Colors.transparent,
                        ),
                      ),
                      child: Text(
                        resultMessage!,
                        style: TextStyle(
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: padding),
                  
                  // Coin with adjusted size
                  SizedBox(
                    width: coinSize,
                    height: coinSize,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(isAnimating ? _animation.value * math.pi * 6 : 0),
                          child: Container(
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
                  ),
                  SizedBox(height: padding),
                ],
              ),
            ),
          ),

          // Game buttons with adjusted size
          Padding(
            padding: EdgeInsets.all(padding),
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
                      screenSize,
                    ),
                    SizedBox(width: padding),
                    _buildGameButton(
                      'Tail',
                      _getButtonColor('Tail', Colors.blue.shade600),
                      isAnimating ? null : () => _selectChoice('Tail'),
                      screenSize,
                    ),
                  ],
                ),
                SizedBox(height: padding),
                _buildGameButton(
                  'Start',
                  Colors.green,
                  isAnimating ? null : _startFlip,
                  screenSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton(String text, Color color, VoidCallback? onPressed, Size screenSize) {
    return SizedBox(
      width: screenSize.width * 0.35,  // Increased from 0.3
      height: screenSize.height * 0.07, // Increased from 0.06
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: screenSize.width * 0.045, // Increased from 0.04
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}