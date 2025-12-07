import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../repositories/weather_repository.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _repository = WeatherRepository();

  Weather? _weather;
  bool _isLoading = false;
  String _error = '';

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _weather = await _repository.getWeather(city);
      _error = '';
    } catch (e) {
      _error = e.toString();
      print('❌ Ошибка в WeatherViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
