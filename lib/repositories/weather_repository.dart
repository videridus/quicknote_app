import '../models/weather.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class WeatherRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<Weather> getWeather(String city) async {
    print('🌤️ Получение погоды для $city');

    try {
      final cachedWeather = await _storageService.getCachedWeather(city);
      if (cachedWeather != null) {
        print('✅ Используем кэшированные данные');
        return cachedWeather;
      }

      print('📡 Запрашиваем с API...');
      final weather = await _apiService.fetchWeather(city);

      await _storageService.saveWeatherCache(city, weather);
      await _storageService.saveLastWeather(weather);

      return weather;
    } catch (e) {
      print('❌ Ошибка получения погоды: $e');

      final lastWeather = await _storageService.getLastWeather();
      if (lastWeather != null) {
        print('⚠️ Используем последнюю сохраненную погоду');
        return lastWeather;
      }

      rethrow;
    }
  }
}
