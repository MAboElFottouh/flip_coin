import 'package:flutter/material.dart';
import 'dart:math' as math;

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

  @override
  void initState() {
    super.initState();
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
          // Generate random result
          result = math.Random().nextBool() ? 'Head' : 'Tail';
          // Check if player won
          if (result == selectedChoice) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You Won! 🎉'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Try Again! 😢'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
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