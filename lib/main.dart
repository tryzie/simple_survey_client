import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'logger.dart';

void main() {
  setupLogger();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Survey',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QuestionScreen(),
    );
  }
}
