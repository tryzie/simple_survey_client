import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sky_survey/model/question.dart';
import 'package:sky_survey/model/respose_result.dart';
import 'package:logging/logging.dart';

class ApiService {
  final String baseUrl = 'http://192.168.100.105:3000';
  final Logger logger = Logger('ApiService');

  // Fetch questions from the server
  Future<List<Question>> fetchQuestions() async {
    final response = await http.get(Uri.parse('$baseUrl/api/questions'));
    logger.info("Response status: ${response.statusCode}");
    logger.info("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => Question.fromJson(json)).toList();
        } else {
          logger.severe("Expected a List but got: ${data.runtimeType}");
          throw Exception("Invalid response format: Expected a list of questions");
        }
      } catch (e) {
        logger.severe("Error decoding JSON: $e");
        throw Exception("Error parsing questions data");
      }
    } else {
      logger.severe("Failed to load questions: ${response.body}");
      throw Exception('Failed to load questions');
    }
  }

  // Submit responses to the server
Future<ResponseResult> submitResponses(Map<String, dynamic> answers) async {
  logger.info("Submitting responses: ${jsonEncode(answers)}");

  try {
    print("Payload being sent: ${jsonEncode(answers)}");

    final Uri url = Uri.parse('$baseUrl/api/responses');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(answers), 
    );

    logger.info("Response status: ${response.statusCode}");
    logger.info("Response body: ${response.body}");

    if (response.statusCode == 201) {
      // Successful response
      return ResponseResult(success: true, message: 'Responses submitted successfully!');
    } else {
      // Handle error responses
      final errorMessage = response.body.isNotEmpty
          ? jsonDecode(response.body)['message'] ?? 'Failed to submit response'
          : 'Failed to submit response';

      logger.severe("Submission failed: $errorMessage");
      return ResponseResult(success: false, message: errorMessage);
    }
  } catch (e) {
    // Handle exceptions
    logger.severe("Submission error: $e");
    return ResponseResult(success: false, message: 'An error occurred during submission.');
  }
}


  // Fetch certificates from the server
  Future<List<dynamic>> fetchCertificates() async {
    final response = await http.get(Uri.parse('$baseUrl/api/certificates'));
    logger.info("Response status: ${response.statusCode}");
    logger.info("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        logger.severe("Error decoding certificates JSON: $e");
        throw Exception("Error parsing certificates data");
      }
    } else {
      logger.severe("Failed to load certificates: ${response.body}");
      throw Exception('Failed to load certificates');
    }
  }
}
