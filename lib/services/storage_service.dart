import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class StorageService {
  static const String _notesKey = 'saved_notes';

  Future<void> saveNotes(List<Note> notes) async {
    print('💾 СОХРАНЕНИЕ: ${notes.length} заметок');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences инициализирован');
      
      // Конвертируем заметки в простые строки
      final notesData = <String>[];
      for (final note in notes) {
        final data = '${note.id}|${note.title}|${note.text}|'
                     '${note.createdAt.millisecondsSinceEpoch}|'
                     '${note.updatedAt.millisecondsSinceEpoch}';
        notesData.add(data);
      }
      
      final success = await prefs.setStringList(_notesKey, notesData);
      print(success ? '✅ Успешно сохранено' : '❌ Ошибка сохранения');
      
    } catch (e) {
      print('❌ КРИТИЧЕСКАЯ ОШИБКА сохранения: $e');
    }
  }

  Future<List<Note>> loadNotes() async {
    print('💾 ЗАГРУЗКА заметок');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences инициализирован');
      
      final notesData = prefs.getStringList(_notesKey);
      if (notesData == null) {
        print('📭 Хранилище пустое');
        return [];
      }
      
      print('📥 Найдено ${notesData.length} заметок в хранилище');
      
      final notes = <Note>[];
      for (final data in notesData) {
        final parts = data.split('|');
        if (parts.length == 5) {
          notes.add(Note(
            id: parts[0],
            title: parts[1],
            text: parts[2],
            createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[3])),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[4])),
          ));
        }
      }
      
      print('✅ Загружено ${notes.length} заметок');
      return notes;
      
    } catch (e) {
      print('❌ ОШИБКА загрузки: $e');
      return [];
    }
  }

  Future<void> clearNotes() async {
    print('🗑️ ОЧИСТКА хранилища');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notesKey);
      print('✅ Хранилище очищено');
    } catch (e) {
      print('❌ Ошибка очистки: $e');
    }
  }
}