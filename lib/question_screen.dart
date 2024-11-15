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
        logger.info('Questions fetched successfully: ${questions.length}');
      }
    } catch (error) {
      logger.severe('Error fetching questions: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching questions: $error')),
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
    final questionText = question.description ?? question.question;

    if (questionText.isEmpty) {
      return const Center(child: Text('No question available'));
    }

    switch (question.type) {
      case 'text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Your response",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                textResponses[question.question] = value;
              },
            ),
          ],
        );
         case 'composite':
      final subfields = question.subfields?.split(',').map((e) => e.trim()).toList() ?? [];
      if (subfields.isEmpty) {
        return const Text('No subfields defined for this question.');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.description ?? 'No description available',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...subfields.map((subfield) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: subfield,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  compositeResponses[question.question] ??= {};
                  compositeResponses[question.question]![subfield] = value;
                },
              ),
            );
          }),
        ],
      );
      case 'email':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email address",
                border: const OutlineInputBorder(),
                errorText: isValidEmail ? null : 'Invalid email address',
              ),
              onChanged: (value) {
                setState(() {
                  isValidEmail = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
                });
              },
            ),
          ],
        );
      case 'single':
        final options = question.options?.map((e) => e.trim()).toList() ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...options.map((option) {
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
            }),
          ],
        );
      case 'multiple':
        final options = question.options?.map((e) => e.trim()).toList() ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...options.map((option) {
              final isChecked =
                  multipleResponses[question.question]?.contains(option) ?? false;
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
            }),
          ],
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
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
      ),
    );
  }
}
