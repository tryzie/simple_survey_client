import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.100.105:3000';

  Future<List<dynamic>> fetchQuestions() async {
    final response = await http.get(Uri.parse('http://192.168.100.105:3000/api/questions'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load questions');
    }
  }

  submitResponses(Map<int, String> answers) {}
}


//fetch questions
Future<List<dynamic>> fetchQuestions() async {
  final response = await http.get(Uri.parse('http://192.168.100.105:3000/api/questions'));


  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load questions');
  }
}

//submit a response
Future<void> submitResponse(Map<String, dynamic> responseData) async {
  final response = await http.post(
    Uri.parse('http://192.168.100.105:3000/api/responses'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(responseData),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to submit response');
  }
}


//fetch certificate
Future<List<dynamic>> fetchCertificates() async {
  final response = await http.get(Uri.parse('http://192.168.100.105:3000/api/certificates'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load certificates');
  }
}

