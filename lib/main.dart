import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:logging/logging.dart';

void main() {
  // Configure logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

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

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  QuestionScreenState createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> {
  int currentIndex = 0;
  List<dynamic> questions = [];
  Map<int, String> answers = {};

  final logger = Logger('MyApp');

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // Fetch questions from the API
  void _fetchQuestions() async {
    try {
      final fetchedQuestions = await ApiService().fetchQuestions();
      if (mounted) {
        setState(() {
          questions = fetchedQuestions;
        });
      }
    } catch (error) {
      logger.severe('Failed to fetch questions', error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch questions')),
        );
      }
    }
  }

  // Submit answers to the API
  void _submitAnswers() async {
    try {
      final response = await ApiService().submitResponses(answers);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.success
                ? 'Responses submitted successfully!'
                : 'Error: ${response.message}'),
          ),
        );
      }
    } catch (e) {
      logger.severe('Submission failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission failed.')),
        );
      }
    }
  }

  // Build input widgets based on question type
  Widget buildQuestionInput(String type) {
    switch (type) {
      case 'short_text':
        return TextField(
          onChanged: (value) => answers[currentIndex] = value,
          decoration: const InputDecoration(labelText: 'Your Answer'),
        );
      case 'choice':
        final options = questions[currentIndex]['options']?.split(',') ?? [];
        return Column(
          children: options.map<Widget>((option) {
            return RadioListTile(
              value: option,
              groupValue: answers[currentIndex],
              onChanged: (value) {
                setState(() {
                  answers[currentIndex] = value.toString();
                });
              },
              title: Text(option),
            );
          }).toList(),
        );
      default:
        return const Text('Unsupported question type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
      ),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  questions[currentIndex]['name'] ?? 'Question',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                buildQuestionInput(questions[currentIndex]['type']),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentIndex > 0)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentIndex--;
                          });
                        },
                        child: const Text('Previous'),
                      ),
                    if (currentIndex < questions.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentIndex++;
                          });
                        },
                        child: const Text('Next'),
                      ),
                    if (currentIndex == questions.length - 1)
                      ElevatedButton(
                        onPressed: _submitAnswers,
                        child: const Text('Submit'),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
