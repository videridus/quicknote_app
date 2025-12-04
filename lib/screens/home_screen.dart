import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_service.dart';
import 'note_edit_screen.dart';
import 'quote_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteService = Provider.of<NoteService>(context);
    final notes = noteService.notes;

    void _addNote() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NoteEditScreen(
            isNewNote: true,
          ),
        ),
      );
    }

    void _openQuoteScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuoteScreen(),
        ),
      );
    }

    void _openNoteDetail(int index) {
      final note = notes[index];
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

    void _deleteNote(int index) {
      noteService.deleteNote(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заметка удалена'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои Заметки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _openQuoteScreen,
            tooltip: 'Цитата дня',
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
                  onPressed: _addNote,
                  icon: const Icon(Icons.add),
                  label: const Text('Новая заметка'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _openQuoteScreen,
                  icon: const Icon(Icons.lightbulb),
                  label: const Text('Цитата'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.note, color: Colors.indigo),
                    title: Text(note.title),
                    subtitle: Text(note.text),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          note.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => _deleteNote(index),
                          color: Colors.red,
                          padding: const EdgeInsets.only(left: 8.0),
                        ),
                      ],
                    ),
                    onTap: () => _openNoteDetail(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}