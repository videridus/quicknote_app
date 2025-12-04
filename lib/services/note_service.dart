import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [
    Note.create(title: 'Покупки', text: 'Молоко, хлеб, яйца'),
    Note.create(title: 'Идеи', text: 'Создать новое приложение'),
    Note.create(title: 'Фильмы', text: 'Посмотреть новый фильм'),
  ];

  List<Note> get notes => _notes;

  void addNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void updateNote(int index, Note updatedNote) {
    _notes[index] = updatedNote;
    notifyListeners();
  }

  void deleteNote(int index) {
    _notes.removeAt(index);
    notifyListeners();
  }
}