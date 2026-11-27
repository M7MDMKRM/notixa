import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  static const String _dbName = 'notixa_local.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        // Alarms Table (Identified from APK binary)
        await db.execute('''
          CREATE TABLE scheduled_alarms (
            id TEXT PRIMARY KEY,
            meeting_id TEXT,
            title TEXT NOT NULL,
            scheduled_time INTEGER NOT NULL,
            offset_minutes INTEGER NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1
          )
        ''');

        // Cached Transactions Table (Wallet)
        await db.execute('''
          CREATE TABLE cached_transactions (
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            currency TEXT NOT NULL,
            note TEXT,
            date INTEGER NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 1
          )
        ''');

        // Cached Meetings Table (Calendar)
        await db.execute('''
          CREATE TABLE cached_meetings (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            start_time INTEGER NOT NULL,
            end_time INTEGER NOT NULL,
            repetition TEXT,
            is_synced INTEGER NOT NULL DEFAULT 1
          )
        ''');

        // Cached Notes Table (AI Voice Notes)
        await db.execute('''
          CREATE TABLE cached_notes (
            id TEXT PRIMARY KEY,
            raw_text TEXT NOT NULL,
            audio_path TEXT,
            created_at INTEGER NOT NULL,
            is_extracted INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
