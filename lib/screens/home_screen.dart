import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $username'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Login successful!'),
      ),
    );
  }
}
