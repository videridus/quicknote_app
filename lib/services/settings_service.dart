import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _lastQuoteTimeKey = 'last_quote_time';
  static const String _quoteTextKey = 'last_quote_text';
  static const String _quoteAuthorKey = 'last_quote_author';

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
    final time = prefs.getString(_lastQuoteTimeKey) ?? 
        DateTime.now().toIso8601String();

    return {
      'text': text,
      'author': author,
      'time': time,
    };
  }
}