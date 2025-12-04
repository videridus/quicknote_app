import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, String>> fetchRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          'text': json['content'] ?? 'Нет текста',
          'author': json['author'] ?? 'Неизвестный автор',
        };
      }
      throw Exception('API не ответил');
    } catch (e) {
      return {
        'text': '"Лучший код — это тот, который работает."',
        'author': 'Мудрый разработчик',
      };
    }
  }
}