import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final ApiService _apiService = ApiService();
  final SettingsService _settingsService = SettingsService();
  
  String _quote = '';
  String _author = '';
  String _lastUpdate = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedQuote();
  }

  Future<void> _loadSavedQuote() async {
    final savedQuote = await _settingsService.getLastQuote();
    setState(() {
      _quote = savedQuote['text']!;
      _author = savedQuote['author']!;
      
      final savedTime = DateTime.parse(savedQuote['time']!);
      _lastUpdate = '${savedTime.hour}:${savedTime.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _fetchNewQuote() async {
    setState(() => _isLoading = true);

    try {
      final newQuote = await _apiService.fetchRandomQuote();
      
      await _settingsService.saveLastQuote(newQuote['text']!, newQuote['author']!);
      
      setState(() {
        _quote = newQuote['text']!;
        _author = newQuote['author']!;
        _lastUpdate = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Новая цитата загружена!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Цитата дня'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb,
                size: 64,
                color: _isLoading ? Colors.grey : Colors.orange,
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Text(
                        _quote,
                        style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    if (!_isLoading)
                      Text(
                        '— $_author',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchNewQuote,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isLoading ? 'Загрузка...' : 'Новая цитата'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Обновлено: $_lastUpdate',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}