import 'dart:convert';

class Weather {
  final double temperature;
  final double feelsLike;
  final String city;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;

  Weather({
    required this.temperature,
    required this.feelsLike,
    required this.city,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      city: json['name'] ?? 'Unknown',
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: (json['main']['pressure'] as num).toDouble(),
      visibility: json['visibility'] ?? 0,
      sunrise:
          DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'city': city,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'visibility': visibility,
      'sunrise': sunrise.millisecondsSinceEpoch,
      'sunset': sunset.millisecondsSinceEpoch,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      temperature: (map['temperature'] as num).toDouble(),
      feelsLike: (map['feelsLike'] as num).toDouble(),
      city: map['city'],
      description: map['description'],
      icon: map['icon'],
      humidity: map['humidity'],
      windSpeed: (map['windSpeed'] as num).toDouble(),
      pressure: (map['pressure'] as num).toDouble(),
      visibility: map['visibility'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(map['sunrise']),
      sunset: DateTime.fromMillisecondsSinceEpoch(map['sunset']),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Weather.fromJsonString(String json) =>
      Weather.fromMap(jsonDecode(json));

  String get formattedTemperature => '${temperature.toStringAsFixed(0)}°C';
  String get formattedFeelsLike =>
      'Ощущается как ${feelsLike.toStringAsFixed(0)}°C';
  String get formattedWindSpeed => '${windSpeed.toStringAsFixed(1)} м/с';
  String get formattedPressure => '${pressure.toStringAsFixed(0)} гПа';
  String get formattedVisibility =>
      '${(visibility / 1000).toStringAsFixed(1)} км';
  String get formattedHumidity => '$humidity%';

  String get formattedSunrise {
    return '${sunrise.hour.toString().padLeft(2, '0')}:${sunrise.minute.toString().padLeft(2, '0')}';
  }

  String get formattedSunset {
    return '${sunset.hour.toString().padLeft(2, '0')}:${sunset.minute.toString().padLeft(2, '0')}';
  }
}
