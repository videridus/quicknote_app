import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather.dart';
import '../viewmodels/weather_viewmodel.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<WeatherViewModel>(context, listen: false);
      viewModel.fetchWeather('Вологда');
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _searchWeather(BuildContext context) {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      final viewModel = Provider.of<WeatherViewModel>(context, listen: false);
      viewModel.fetchWeather(city);
      FocusScope.of(context).unfocus();
    }
  }

  void _fetchVologdaWeather(BuildContext context) {
    final viewModel = Provider.of<WeatherViewModel>(context, listen: false);
    viewModel.fetchWeather('Вологда');
    _cityController.text = 'Вологда';
  }

  IconData _getWeatherIcon(String iconCode) {
    if (iconCode.contains('01')) return Icons.wb_sunny;
    if (iconCode.contains('02')) return Icons.wb_cloudy;
    if (iconCode.contains('03') || iconCode.contains('04')) return Icons.cloud;
    if (iconCode.contains('09') || iconCode.contains('10'))
      return Icons.beach_access;
    if (iconCode.contains('11')) return Icons.flash_on;
    if (iconCode.contains('13')) return Icons.ac_unit;
    if (iconCode.contains('50')) return Icons.blur_on;
    return Icons.wb_sunny;
  }

  Color _getWeatherColor(String iconCode) {
    if (iconCode.contains('01')) return Colors.orange;
    if (iconCode.contains('02')) return Colors.blueGrey;
    if (iconCode.contains('03') || iconCode.contains('04')) return Colors.grey;
    if (iconCode.contains('09') || iconCode.contains('10')) return Colors.blue;
    if (iconCode.contains('11')) return Colors.deepPurple;
    if (iconCode.contains('13')) return Colors.cyan;
    if (iconCode.contains('50')) return Colors.grey;
    return Colors.orange;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Сегодня';
    }

    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final months = [
      'Января',
      'Февраля',
      'Марта',
      'Апреля',
      'Мая',
      'Июня',
      'Июля',
      'Августа',
      'Сентября',
      'Октября',
      'Ноября',
      'Декабря'
    ];

    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Введите город...',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _searchWeather(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _searchWeather(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon:
                            const Icon(Icons.location_city, color: Colors.blue),
                        onPressed: () => _fetchVologdaWeather(context),
                        tooltip: 'Погода в Вологде',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (viewModel.isLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Загружаем погоду для ${_cityController.text.isNotEmpty ? _cityController.text : viewModel.weather?.city ?? "Вологда"}...',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (viewModel.error.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red[300]),
                          const SizedBox(height: 20),
                          const Text(
                            'Ошибка загрузки',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              viewModel.error,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => viewModel.fetchWeather('Вологда'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Обновить'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (viewModel.weather != null)
                  _buildWeatherCard(context, viewModel.weather!)
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 20),
                          const Text(
                            'Введите город для получения погоды',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, Weather weather) {
    final iconColor = _getWeatherColor(weather.icon);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[50]!,
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather.city,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _getWeatherIcon(weather.icon),
                          size: 64,
                          color: iconColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weather.formattedTemperature,
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      weather.formattedFeelsLike,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _capitalize(weather.description),
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.water_drop,
                            label: 'Влажность',
                            value: weather.formattedHumidity,
                            color: Colors.blue,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.air,
                            label: 'Ветер',
                            value: weather.formattedWindSpeed,
                            color: Colors.green,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.compress,
                            label: 'Давление',
                            value: weather.formattedPressure,
                            color: Colors.deepPurple,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: Icons.remove_red_eye,
                            label: 'Видимость',
                            value: weather.formattedVisibility,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSunInfo(
                          icon: Icons.wb_sunny,
                          label: 'Восход',
                          value: weather.formattedSunrise,
                          color: Colors.orange,
                        ),
                        _buildSunInfo(
                          icon: Icons.nightlight,
                          label: 'Закат',
                          value: weather.formattedSunset,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 20, color: Colors.grey[500]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Данные из OpenWeatherMap',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Кэшировано на 10 минут',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSunInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
