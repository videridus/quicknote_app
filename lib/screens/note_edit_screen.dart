import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_service.dart';
import '../models/note.dart';

class NoteEditScreen extends StatefulWidget {
  final String initialTitle;
  final String initialText;
  final bool isNewNote;
  final int? noteIndex;

  const NoteEditScreen({
    super.key,
    this.initialTitle = '',
    this.initialText = '',
    this.isNewNote = true,
    this.noteIndex,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _saveNote(BuildContext context) {
    final noteService = Provider.of<NoteService>(context, listen: false);
    final title = _titleController.text.trim();
    final text = _textController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Введите заголовок'), duration: Duration(seconds: 2)),
      );
      return;
    }

    if (widget.isNewNote) {
      final newNote = Note.create(title: title, text: text);
      noteService.addNote(newNote);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Заметка создана: $title'),
            duration: const Duration(seconds: 2)),
      );
    } else if (widget.noteIndex != null) {
      final existingNote = noteService.notes[widget.noteIndex!];
      existingNote.update(title: title, text: text);
      noteService.updateNote(widget.noteIndex!, existingNote);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Заметка обновлена: $title'),
            duration: const Duration(seconds: 2)),
      );
    }

    Navigator.pop(context);
  }

  void _deleteNote(BuildContext context) {
    final noteService = Provider.of<NoteService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (widget.noteIndex != null) {
                noteService.deleteNote(widget.noteIndex!);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Заметка удалена'),
                    duration: Duration(seconds: 2)),
              );
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewNote ? 'Новая заметка' : 'Редактирование'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveNote(context),
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Заголовок заметки...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Начните писать здесь...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _saveNote(context),
                    icon: const Icon(Icons.save),
                    label: const Text('Сохранить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (!widget.isNewNote)
                    OutlinedButton.icon(
                      onPressed: () => _deleteNote(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Удалить'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
