import 'package:flutter/material.dart';
import 'package:sky_survey/survey_response_screen.dart';
import 'question_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuestionScreen()),
                );
              },
              child: const Text('Survey Form'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SurveyResponseScreen()),
                );
              },
              child: const Text('Survey Responses'),
            ),
          ],
        ),
      ),
    );
  }
}
