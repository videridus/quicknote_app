import 'dart:convert';

class Note {
  final String id;
  String title;
  String text;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.create({required String title, required String text}) {
    final now = DateTime.now();
    return Note(
      id: 'note_${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch}',
      title: title,
      text: text,
      createdAt: now,
      updatedAt: now,
    );
  }

  void update({String? title, String? text}) {
    if (title != null) this.title = title;
    if (text != null) this.text = text;
    updatedAt = DateTime.now();
  }

  String get formattedDate {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory Note.fromJson(String json) {
    try {
      final map = jsonDecode(json);
      return Note(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        text: map['text'] ?? '',
        createdAt: DateTime.parse(map['createdAt']),
        updatedAt: DateTime.parse(map['updatedAt']),
      );
    } catch (e) {
      print('❌ Ошибка парсинга Note из JSON: $e');
      rethrow;
    }
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
