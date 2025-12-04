import '../models/note.dart';
import '../services/storage_service.dart';

class NoteRepository {
  final StorageService _storageService = StorageService();
  List<Note> _memoryCache = [];

  Future<List<Note>> getAllNotes() async {
    print('📚 getAllNotes() вызван');
    
    // Если в кэше уже есть заметки - возвращаем их
    if (_memoryCache.isNotEmpty) {
      print('📦 Возвращаем из кэша: ${_memoryCache.length} заметок');
      return List.from(_memoryCache);
    }
    
    // Загружаем из хранилища
    final savedNotes = await _storageService.loadNotes();
    
    if (savedNotes.isNotEmpty) {
      print('📥 Загружено из хранилища: ${savedNotes.length} заметок');
      _memoryCache = savedNotes;
      return List.from(_memoryCache);
    }
    
    // Если ничего нет - создаем демо-заметки
    print('🎯 Создаем демо-заметки');
    _memoryCache = [
      Note.create(title: 'Добро пожаловать!', text: 'Ваши заметки сохраняются локально.'),
      Note.create(title: 'Пример заметки', text: 'Нажмите + чтобы создать новую заметку.'),
    ];
    
    // Сохраняем демо-заметки
    await _storageService.saveNotes(_memoryCache);
    
    return List.from(_memoryCache);
  }

  Future<void> insertNote(Note note) async {
    print('➕ insertNote(): "${note.title}"');
    _memoryCache.insert(0, note);
    await _storageService.saveNotes(_memoryCache);
    print('✅ Заметка сохранена');
  }

  Future<void> updateNote(Note note) async {
    print('✏️ updateNote(): "${note.title}"');
    final index = _memoryCache.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _memoryCache[index] = note;
      await _storageService.saveNotes(_memoryCache);
      print('✅ Заметка обновлена');
    }
  }

  Future<void> deleteNote(String id) async {
    print('🗑️ deleteNote(): id=$id');
    _memoryCache.removeWhere((note) => note.id == id);
    await _storageService.saveNotes(_memoryCache);
    print('✅ Заметка удалена');
  }

  Future<void> deleteAllNotes() async {
    print('🔥 deleteAllNotes()');
    _memoryCache.clear();
    await _storageService.clearNotes();
    print('✅ Все заметки удалены');
  }
}