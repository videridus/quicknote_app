import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../models/weather.dart';

class StorageService {
  static const String _notesKey = 'saved_notes';
  static const String _lastQuoteTimeKey = 'last_quote_time';
  static const String _quoteTextKey = 'last_quote_text';
  static const String _quoteAuthorKey = 'last_quote_author';
  static const String _lastWeatherKey = 'last_weather';

  Future<void> saveNotes(List<Note> notes) async {
    print('💾 Сохранение ${notes.length} заметок');

    try {
      final prefs = await SharedPreferences.getInstance();
      final notesData = notes.map((note) => note.toJson()).toList();

      await prefs.setStringList(_notesKey, notesData);
      print('✅ Заметки сохранены');
    } catch (e) {
      print('❌ Ошибка сохранения заметок: $e');
    }
  }

  Future<List<Note>> loadNotes() async {
    print('💾 Загрузка заметок');

    try {
      final prefs = await SharedPreferences.getInstance();
      final notesData = prefs.getStringList(_notesKey);

      if (notesData == null) {
        print('📭 Хранилище пустое');
        return [];
      }

      final notes = <Note>[];
      for (final json in notesData) {
        try {
          notes.add(Note.fromJson(json));
        } catch (e) {
          print('⚠️ Ошибка парсинга заметки: $e');
        }
      }

      print('✅ Загружено ${notes.length} заметок');
      return notes;
    } catch (e) {
      print('❌ Ошибка загрузки заметок: $e');
      return [];
    }
  }

  Future<void> clearNotes() async {
    print('🗑️ Очистка хранилища заметок');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notesKey);
      print('✅ Хранилище очищено');
    } catch (e) {
      print('❌ Ошибка очистки: $e');
    }
  }

  Future<void> saveLastQuote(String text, String author) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quoteTextKey, text);
    await prefs.setString(_quoteAuthorKey, author);
    await prefs.setString(_lastQuoteTimeKey, DateTime.now().toIso8601String());
  }

  Future<Map<String, String>> getLastQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_quoteTextKey) ??
        '"Код — это поэзия, написанная на языке, понятном машинам."';
    final author = prefs.getString(_quoteAuthorKey) ?? 'Анонимный разработчик';
    final time =
        prefs.getString(_lastQuoteTimeKey) ?? DateTime.now().toIso8601String();

    return {
      'text': text,
      'author': author,
      'time': time,
    };
  }

  Future<void> saveLastWeather(Weather weather) async {
    print('💾 Сохранение погоды для ${weather.city}');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastWeatherKey, weather.toJson());
      print('✅ Погода сохранена');
    } catch (e) {
      print('❌ Ошибка сохранения погоды: $e');
    }
  }

  Future<Weather?> getLastWeather() async {
    print('💾 Загрузка сохраненной погоды');
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString(_lastWeatherKey);

      if (weatherJson != null) {
        final weather = Weather.fromJsonString(weatherJson);
        print('✅ Загружена погода для ${weather.city}');
        return weather;
      }
      print('📭 Нет сохраненной погоды');
      return null;
    } catch (e) {
      print('❌ Ошибка загрузки погоды: $e');
      return null;
    }
  }

  Future<void> saveWeatherCache(String city, Weather weather) async {
    print('💾 Кэширование погоды для $city');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_cache_$city', weather.toJson());
      await prefs.setInt(
          'weather_cache_time_$city', DateTime.now().millisecondsSinceEpoch);
      print('✅ Погода закэширована');
    } catch (e) {
      print('❌ Ошибка кэширования: $e');
    }
  }

  Future<Weather?> getCachedWeather(String city) async {
    print('💾 Проверка кэша для $city');
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString('weather_cache_$city');
      final cacheTime = prefs.getInt('weather_cache_time_$city');

      if (weatherJson != null && cacheTime != null) {
        final cacheAge = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(cacheTime));

        if (cacheAge.inMinutes < 10) {
          print('✅ Используем кэшированные данные');
          return Weather.fromJsonString(weatherJson);
        } else {
          print('📭 Кэш устарел');
          await prefs.remove('weather_cache_$city');
          await prefs.remove('weather_cache_time_$city');
        }
      }
      return null;
    } catch (e) {
      print('❌ Ошибка проверки кэша: $e');
      return null;
    }
  }
}
