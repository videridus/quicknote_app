import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../services/note_service.dart';
import 'note_edit_screen.dart';
import 'quote_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Заметки теперь загружаются автоматически в main.dart
  }

  void _addNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteEditScreen(isNewNote: true),
      ),
    );
  }

  void _openQuoteScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuoteScreen()),
    );
  }

  void _openWeatherScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeatherScreen()),
    );
  }

  void _openNoteDetail(BuildContext context, int index) {
    final noteService = Provider.of<NoteService>(context, listen: false);
    final note = noteService.notes[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(
          initialTitle: note.title,
          initialText: note.text,
          isNewNote: false,
          noteIndex: index,
        ),
      ),
    );
  }

  void _deleteNote(BuildContext context, int index) {
    final noteService = Provider.of<NoteService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: const Text('Заметка будет удалена из хранилища.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await noteService.deleteNote(index);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Заметка удалена из хранилища'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteAllNotes(BuildContext context) {
    final noteService = Provider.of<NoteService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все заметки?'),
        content:
            const Text('Все заметки будут удалены из локального хранилища.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await noteService.deleteAllNotes();
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Все заметки удалены'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text(
              'Очистить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _exportNotes(BuildContext context) async {
    final noteService = Provider.of<NoteService>(context, listen: false);

    try {
      final exportText = await noteService.exportNotes();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Экспорт заметок'),
          content: SingleChildScrollView(
            child: Text(exportText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: exportText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Скопировано в буфер'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Копировать'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка экспорта: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _refreshNotes(BuildContext context) {
    final noteService = Provider.of<NoteService>(context, listen: false);
    noteService.loadNotes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заметки обновлены'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteService = Provider.of<NoteService>(context);
    final notes = noteService.notes;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Мои Заметки'),
            Consumer<NoteService>(
              builder: (context, noteService, _) {
                return Text(
                  noteService.storageInfo,
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshNotes(context),
            tooltip: 'Обновить заметки',
          ),
          Consumer<NoteService>(
            builder: (context, noteService, _) {
              return PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Очистить все заметки'),
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _deleteAllNotes(context);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('Экспорт заметок'),
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _exportNotes(context);
                      });
                    },
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => _openQuoteScreen(context),
            tooltip: 'Цитата дня',
          ),
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed: () => _openWeatherScreen(context),
            tooltip: 'Погода',
          ),
          if (noteService.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addNote(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Новая заметка'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openQuoteScreen(context),
                  icon: const Icon(Icons.lightbulb),
                  label: const Text('Цитата'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openWeatherScreen(context),
                  icon: const Icon(Icons.cloud),
                  label: const Text('Погода'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          if (noteService.isLoading && notes.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Загружаем заметки из хранилища...'),
                  ],
                ),
              ),
            )
          else if (notes.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Нет заметок', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Создайте первую заметку!'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final noteService =
                      Provider.of<NoteService>(context, listen: false);
                  await noteService.loadNotes();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.note, color: Colors.indigo),
                        title: Text(note.title),
                        subtitle: Text(
                          note.text.length > 50
                              ? '${note.text.substring(0, 50)}...'
                              : note.text,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              note.formattedDate,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () => _deleteNote(context, index),
                              color: Colors.red,
                              padding: const EdgeInsets.only(left: 8.0),
                            ),
                          ],
                        ),
                        onTap: () => _openNoteDetail(context, index),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
