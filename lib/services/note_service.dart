import 'package:flutter/material.dart';
import '../repositories/note_repository.dart';
import '../models/note.dart';

class NoteService extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();
  List<Note> _notes = [];
  bool _isLoading = false;
  String _storageInfo = 'Инициализация...';

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String get storageInfo => _storageInfo;

  Future<void> loadNotes() async {
    _isLoading = true;
    _storageInfo = 'Загрузка...';
    notifyListeners();

    try {
      _notes = await _repository.getAllNotes();
      _storageInfo = 'Заметок: ${_notes.length}';
      print('🎯 NoteService: Загружено ${_notes.length} заметок');
    } catch (e) {
      _storageInfo = 'Ошибка загрузки';
      print('❌ NoteService: Ошибка: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _repository.insertNote(note);
      await loadNotes(); // Перезагружаем заметки после добавления
      print('✅ NoteService: Заметка добавлена');
    } catch (e) {
      print('❌ NoteService: Ошибка добавления: $e');
      rethrow;
    }
  }

  Future<void> updateNote(int index, Note updatedNote) async {
    try {
      await _repository.updateNote(updatedNote);
      await loadNotes(); // Перезагружаем заметки после обновления
      print('✅ NoteService: Заметка обновлена');
    } catch (e) {
      print('❌ NoteService: Ошибка обновления: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(int index) async {
    final note = _notes[index];
    try {
      await _repository.deleteNote(note.id);
      await loadNotes(); // Перезагружаем заметки после удаления
      print('✅ NoteService: Заметка удалена');
    } catch (e) {
      print('❌ NoteService: Ошибка удаления: $e');
      rethrow;
    }
  }

  Future<void> deleteAllNotes() async {
    try {
      await _repository.deleteAllNotes();
      await loadNotes(); // Перезагружаем заметки после очистки
      print('✅ NoteService: Все заметки удалены');
    } catch (e) {
      print('❌ NoteService: Ошибка очистки: $e');
      rethrow;
    }
  }

  Future<String> exportNotes() async {
    if (_notes.isEmpty) return 'Нет заметок';

    final buffer = StringBuffer();
    buffer.writeln('=== ЭКСПОРТ ЗАМЕТОК ===');
    buffer.writeln('Всего: ${_notes.length} заметок\n');

    for (var i = 0; i < _notes.length; i++) {
      final note = _notes[i];
      buffer.writeln('${i + 1}. ${note.title}');
      buffer.writeln('   Текст: ${note.text}');
      buffer.writeln('   Дата: ${note.formattedDate}');
      buffer.writeln('   ID: ${note.id}\n');
    }

    return buffer.toString();
  }
}
