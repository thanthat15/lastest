import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_models.dart'; 

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB, onOpen: (db) async {
      // Ensure `position` column exists for older DBs
      try {
        final res = await db.rawQuery("PRAGMA table_info('notes')");
        final hasPosition = res.any((row) => row['name'] == 'position');
        if (!hasPosition) {
          await db.execute('ALTER TABLE notes ADD COLUMN position INTEGER');
        }
      } catch (_) {
        // ignore
      }
    });
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        summary TEXT,
        created_at TEXT
      )
    ''');
  }

  // ฟังก์ชัน: บันทึก
  Future<int> create(NoteModel note) async {
    final db = await instance.database;
    // if position not set, put at end (max position + 1)
    int? pos = note.position;
    if (pos == null) {
      final res = await db.rawQuery('SELECT MAX(position) as maxpos FROM notes');
      final maxpos = res.first['maxpos'] as int? ?? 0;
      pos = maxpos + 1;
    }
    final toInsert = note.toMap();
    toInsert['position'] = pos;
    return await db.insert('notes', toInsert);
  }

  // ฟังก์ชัน: อ่านทั้งหมด (เอามาโชว์หน้าแรก)
  Future<List<NoteModel>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'position ASC');
    return result.map((json) => NoteModel.fromMap(json)).toList();
  }
  // ฟังก์ชัน: ลบโน้ตตาม id
  Future<int> deleteById(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
  // ฟังก์ชัน: อัปเดตข้อมูล (แก้ไขโน้ตเดิม)
  Future<int> update(NoteModel note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // อัปเดตตำแหน่งชุดเดียว (ใช้เมื่ออัปเดตลำดับ)
  Future<void> updatePositions(List<NoteModel> notes) async {
    final db = await instance.database;
    final batch = db.batch();
    for (int i = 0; i < notes.length; i++) {
      final n = notes[i];
      batch.update('notes', {'position': i}, where: 'id = ?', whereArgs: [n.id]);
    }
    await batch.commit(noResult: true);
  }
}