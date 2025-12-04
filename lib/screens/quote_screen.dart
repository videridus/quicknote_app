import 'package:flutter/material.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String _quote = '"Код — это поэзия, написанная на языке, понятном машинам."';
  String _author = 'Анонимный разработчик';
  String _lastUpdate = '15:30';
  bool _isLoading = false;

  // Имитация загрузки цитаты из API
  Future<void> _fetchNewQuote() async {
    setState(() {
      _isLoading = true;
    });

    // Имитация задержки сети
    await Future.delayed(const Duration(seconds: 1));

    // Временные цитаты (в будущем заменим на реальный API)
    final quotes = [
      {
        'quote': '"Лучший способ предсказать будущее — создать его."',
        'author': 'Алан Кей'
      },
      {
        'quote': '"Программирование — это разбиение чего-то большого и невозможного на что-то маленькое и вполне реальное."',
        'author': 'Джозуа Блох'
      },
      {
        'quote': '"Прежде всего, нужно учиться коду не ради кода, а ради того, чтобы стать творцом и решать проблемы."',
        'author': 'Джефф Этвуд'
      },
      {
        'quote': '"Хороший программист смотрит в обе стороны, переходя дорогу с односторонним движением."',
        'author': 'Даг Линдер'
      },
    ];

    final randomIndex = DateTime.now().second % quotes.length;
    
    setState(() {
      _quote = quotes[randomIndex]['quote']!;
      _author = quotes[randomIndex]['author']!;
      _lastUpdate = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Новая цитата загружена!'),
        duration: Duration(seconds: 1),
      ),
    );
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
              
              // Контейнер с цитатой
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    if (!_isLoading)
                      Text(
                        '— $_author',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Кнопка обновления
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchNewQuote,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isLoading ? 'Загрузка...' : 'Новая цитата'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Время обновления
              Text(
                'Последнее обновление: $_lastUpdate',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}