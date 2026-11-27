import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/error/failures.dart';
import '../models/meeting.dart';

abstract class CalendarRepository {
  Future<Result<List<Meeting>>> getMeetings({DateTime? start, DateTime? end});
  Future<Result<Meeting>> createMeeting(Meeting meeting);
  Future<Result<Meeting>> updateMeeting(Meeting meeting);
  Future<Result<void>> deleteMeeting(String id);
}

class CalendarRepositoryImpl implements CalendarRepository {
  final Dio _dio;
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  CalendarRepositoryImpl(this._dio, this._db);

  @override
  Future<Result<List<Meeting>>> getMeetings({DateTime? start, DateTime? end}) async {
    // 1. Try remote API
    try {
      final response = await _dio.get('/meetings', queryParameters: {
        if (start != null) 'start': start.toIso8601String(),
        if (end != null) 'end': end.toIso8601String(),
      });

      if (response.statusCode == 200 && response.data != null) {
        final list = (response.data['data'] as List? ?? response.data as List? ?? [])
            .map((item) => Meeting.fromJson(item as Map<String, dynamic>))
            .toList();

        await _cacheMeetingsLocally(list);
        return Success(list);
      }
    } catch (_) {}

    // Fallback SQLite
    try {
      final db = await _db.database;
      final rows = await db.query('cached_meetings', orderBy: 'start_time ASC');
      final list = rows.map((r) => Meeting(
        id: r['id'] as String,
        title: r['title'] as String,
        description: r['description'] as String?,
        startTime: DateTime.fromMillisecondsSinceEpoch(r['start_time'] as int),
        endTime: DateTime.fromMillisecondsSinceEpoch(r['end_time'] as int),
        repetition: r['repetition'] as String? ?? 'none',
      )).toList();

      return Success(list);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<Meeting>> createMeeting(Meeting meeting) async {
    final newId = meeting.id.isEmpty ? _uuid.v4() : meeting.id;
    final itemToSave = meeting.copyWith(id: newId);

    try {
      final db = await _db.database;
      await db.insert('cached_meetings', {
        'id': itemToSave.id,
        'title': itemToSave.title,
        'description': itemToSave.description,
        'start_time': itemToSave.startTime.millisecondsSinceEpoch,
        'end_time': itemToSave.endTime.millisecondsSinceEpoch,
        'repetition': itemToSave.repetition,
        'is_synced': 0,
      });
    } catch (_) {}

    try {
      await _dio.post('/meetings', data: itemToSave.toJson());
      return Success(itemToSave);
    } catch (_) {
      return Success(itemToSave);
    }
  }

  @override
  Future<Result<Meeting>> updateMeeting(Meeting meeting) async {
    try {
      final db = await _db.database;
      await db.update(
        'cached_meetings',
        {
          'title': meeting.title,
          'description': meeting.description,
          'start_time': meeting.startTime.millisecondsSinceEpoch,
          'end_time': meeting.endTime.millisecondsSinceEpoch,
          'repetition': meeting.repetition,
        },
        where: 'id = ?',
        whereArgs: [meeting.id],
      );

      await _dio.put('/meetings/${meeting.id}', data: meeting.toJson());
      return Success(meeting);
    } catch (e) {
      return Success(meeting);
    }
  }

  @override
  Future<Result<void>> deleteMeeting(String id) async {
    try {
      final db = await _db.database;
      await db.delete('cached_meetings', where: 'id = ?', whereArgs: [id]);
      await _dio.delete('/meetings/$id');
      return const Success(null);
    } catch (e) {
      return const Success(null);
    }
  }

  Future<void> _cacheMeetingsLocally(List<Meeting> meetings) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final m in meetings) {
      batch.insert(
        'cached_meetings',
        {
          'id': m.id,
          'title': m.title,
          'description': m.description,
          'start_time': m.startTime.millisecondsSinceEpoch,
          'end_time': m.endTime.millisecondsSinceEpoch,
          'repetition': m.repetition,
          'is_synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
