import '../models/note.dart';
import '../services/storage_service.dart';

class NoteRepository {
  final StorageService _storageService = StorageService();

  Future<List<Note>> getAllNotes() async {
    print('📚 Загрузка заметок из хранилища');

    final savedNotes = await _storageService.loadNotes();

    if (savedNotes.isNotEmpty) {
      print('✅ Загружено ${savedNotes.length} заметок');
      return savedNotes;
    }

    print('📭 Хранилище пустое, создаем демо-заметки');
    final demoNotes = [
      Note.create(
          title: 'Добро пожаловать!',
          text: 'Ваши заметки сохраняются локально.'),
      Note.create(
          title: 'Пример заметки',
          text: 'Нажмите + чтобы создать новую заметку.'),
    ];

    await _storageService.saveNotes(demoNotes);

    return demoNotes;
  }

  Future<void> insertNote(Note note) async {
    print('➕ Добавление заметки: "${note.title}"');

    final notes = await getAllNotes();
    notes.insert(0, note);
    await _storageService.saveNotes(notes);

    print('✅ Заметка сохранена');
  }

  Future<void> updateNote(Note note) async {
    print('✏️ Обновление заметки: "${note.title}"');

    final notes = await getAllNotes();
    final index = notes.indexWhere((n) => n.id == note.id);

    if (index != -1) {
      notes[index] = note;
      await _storageService.saveNotes(notes);
      print('✅ Заметка обновлена');
    } else {
      print('❌ Заметка не найдена');
    }
  }

  Future<void> deleteNote(String id) async {
    print('🗑️ Удаление заметки: id=$id');

    final notes = await getAllNotes();
    notes.removeWhere((note) => note.id == id);
    await _storageService.saveNotes(notes);

    print('✅ Заметка удалена');
  }

  Future<void> deleteAllNotes() async {
    print('🔥 Удаление всех заметок');
    await _storageService.clearNotes();
    print('✅ Все заметки удалены');
  }
}
