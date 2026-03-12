import 'package:sqflite/sqflite.dart';
import 'package:hive/hive.dart';
import '../../models/note_model.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> saveNote(NoteModel noteToCache);
  Future<String?> getCachedSummary(String text);
  Future<void> cacheSummary(String text, String summary);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final Database database;
  final Box cacheBox;

  NoteLocalDataSourceImpl({required this.database, required this.cacheBox});

  @override
  Future<List<NoteModel>> getNotes() async {
    final List<Map<String, dynamic>> maps = await database.query('notes');
    return List.generate(maps.length, (i) {
      return NoteModel.fromJson(maps[i]);
    });
  }

  @override
  Future<void> saveNote(NoteModel noteToCache) async {
    final noteJson = noteToCache.toJson();
    // แปลงวันที่เป็น String ให้ SQLite อ่านได้
    noteJson['createdAt'] = noteToCache.createdAt.toIso8601String(); 
    
    await database.insert(
      'notes',
      noteJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<String?> getCachedSummary(String text) async {
    // ใช้ HashCode ของข้อความเป็น Key ในการหา Cache
    return cacheBox.get(text.hashCode.toString());
  }

  @override
  Future<void> cacheSummary(String text, String summary) async {
    await cacheBox.put(text.hashCode.toString(), summary);
  }
}