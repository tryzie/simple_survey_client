import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sky_survey/model/question.dart';
import 'api_service.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  QuestionScreenState createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> {
  final logger = Logger('QuestionScreen');
  int currentPage = 0;
  List<Question> questions = [];
  
  Map<String, String?> textResponses = {};
  Map<String, Map<String, String>> compositeResponses = {};
  Map<String, String?> singleResponses = {};
  Map<String, List<String>> multipleResponses = {};

  TextEditingController emailController = TextEditingController();
  bool isValidEmail = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  void _fetchQuestions() async {
    try {
      logger.info('Fetching questions...');
      final fetchedQuestions = await ApiService().fetchQuestions();
      if (mounted) {
        setState(() {
          questions = fetchedQuestions;
        });
        logger.info('Questions fetched successfully: $questions');
      }
    } catch (error) {
      logger.severe('Error fetching questions: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  void submitResponses() async {
    final responses = {
      'textResponses': textResponses,
      'compositeResponses': compositeResponses,
      'email': emailController.text,
      'singleResponses': singleResponses,
      'multipleResponses': multipleResponses,
    };

    if (!isValidEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please correct invalid email")),
      );
      return;
    }

    try {
      final response = await ApiService().submitResponses(responses);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.success ? response.message : 'Submission failed')),
      );
    } catch (error) {
      logger.severe('Submission error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting responses: $error")),
      );
    }
  }

  Widget buildQuestionWidget(Question question) {
  switch (question.type) {
    case 'text':
      // General text input
      return TextField(
        decoration: InputDecoration(
          labelText: question.description ?? question.question,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          textResponses[question.question] = value;
        },
      );

    case 'email':
      // Email input with validation
      return Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: question.description ?? question.question,
              border: const OutlineInputBorder(),
              errorText: isValidEmail ? null : 'Invalid email address',
            ),
            onChanged: (value) {
              setState(() {
                isValidEmail = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value);
              });
            },
          ),
        ],
      );

    case 'composite':
      // Composite questions with multiple text fields for subfields
      final subfields = question.subfields?.split(',') ?? [];
      return Column(
        children: subfields.map((subfield) {
          return TextField(
            decoration: InputDecoration(
              labelText: subfield.trim(),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              compositeResponses[question.question] ??= {};
              compositeResponses[question.question]![subfield.trim()] = value;
            },
          );
        }).toList(),
      );

    case 'single':
      // Single-choice questions using RadioListTile
      final options = question.options ?? [];
      return Column(
        children: options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: singleResponses[question.question],
            onChanged: (value) {
              setState(() {
                singleResponses[question.question] = value;
              });
            },
          );
        }).toList(),
      );

    case 'multiple':
      // Multiple-choice questions using CheckboxListTile
      final options = question.options ?? [];
      return Column(
        children: options.map((option) {
          final isChecked = multipleResponses[question.question]?.contains(option) ?? false;
          return CheckboxListTile(
            title: Text(option),
            value: isChecked,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  multipleResponses[question.question] ??= [];
                  multipleResponses[question.question]!.add(option);
                } else {
                  multipleResponses[question.question]?.remove(option);
                }
              });
            },
          );
        }).toList(),
      );

    case 'choice':
      // Dropdown for choice-based questions
      final options = question.options ?? [];
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: question.description ?? question.question,
          border: const OutlineInputBorder(),
        ),
        value: singleResponses[question.question],
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            singleResponses[question.question] = value;
          });
        },
      );

    default:
      return const Text('Unsupported question type');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questions')),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildQuestionWidget(questions[currentPage]),
            ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentPage > 0)
            ElevatedButton(
              onPressed: () => setState(() => currentPage--),
              child: const Text('Previous'),
            ),
          if (currentPage < questions.length - 1)
            ElevatedButton(
              onPressed: () => setState(() => currentPage++),
              child: const Text('Next'),
            ),
          if (currentPage == questions.length - 1)
            ElevatedButton(
              onPressed: submitResponses,
              child: const Text('Submit'),
            ),
        ],
      ),
    );
  }
}
