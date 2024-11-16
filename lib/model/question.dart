class Question {
  final int id;
  final String question;
  final String type;
  final List<String>? options;
  final String? description;
  final String? subfields;

  Question({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.description, 
    this.subfields,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      type: json['type'],
      description: json['description'], 
      options: json['options'] is String
          ? (json['options'] as String).split(',')
          : (json['options'] as List<dynamic>?)?.cast<String>(),
      subfields: json['subfields'],
    );
  }
}
