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

  // Создание новой заметки
  factory Note.create({required String title, required String text}) {
    final now = DateTime.now();
    return Note(
      id: 'note_${now.millisecondsSinceEpoch}',
      title: title,
      text: text,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Обновление заметки
  void update({String? title, String? text}) {
    if (title != null) this.title = title;
    if (text != null) this.text = text;
    updatedAt = DateTime.now();
  }

  // Форматированная дата для отображения
  String get formattedDate {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }

  // Преобразование в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}