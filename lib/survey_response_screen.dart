import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SurveyResponseScreen extends StatefulWidget {
  const SurveyResponseScreen({super.key});

  @override
  SurveyResponseScreenState createState() => SurveyResponseScreenState();
}

class SurveyResponseScreenState extends State<SurveyResponseScreen> {
  final TextEditingController emailController = TextEditingController();
  List<dynamic> responses = [];
  bool isLoading = false;

  final String baseUrl = 'http://192.168.100.105:3000';

  Future<void> fetchResponses({String? email}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/responses?email=${email ?? ''}'),
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}'); 
        final responseData = jsonDecode(response.body);
        if (responseData is List) {
          setState(() {
            responses = responseData;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid response format')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch responses: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching responses: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadCertificate(String certificateUrl) async {
    try {
      final response = await http.get(Uri.parse(certificateUrl));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate downloaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to download certificate: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading certificate: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey Responses')),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  fetchResponses(email: emailController.text.trim());
                },
                child: const Text('Fetch Responses'),
              ),
              Expanded(
                child: responses.isEmpty
                    ? const Center(child: Text('No responses found'))
                    : ListView.builder(
                        itemCount: responses.length,
                        itemBuilder: (context, index) {
                          final response = responses[index];
                          return Card(
                            child: ListTile(
                              title: Text(response['email_address'] ??
                                  'No email provided'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Name: ${response['name'] ?? 'No name provided'}'),
                                  Text(
                                      'Description: ${response['description'] ?? 'No description'}'),
                                ],
                              ),
                              trailing: response['certificate_url'] != null
                                  ? ElevatedButton(
                                      onPressed: () {
                                        downloadCertificate(
                                            response['certificate_url']);
                                      },
                                      child: const Text('Download Certificate'),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
