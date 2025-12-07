import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

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

  Future<Weather> fetchWeather(String city) async {
    const apiKey = '12880a97f77b83f8c1f2dc966174002e';
    const baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric&lang=ru'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Weather.fromJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('Город "$city" не найден');
      } else if (response.statusCode == 401) {
        throw Exception('Неверный API ключ');
      } else {
        throw Exception('Ошибка API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка получения погоды: $e');
      rethrow;
    }
  }
}
