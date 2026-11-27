import 'package:notixa/core/domain/result.dart';
import '../models/meeting.dart';

abstract class CalendarRepository {
  Future<Result<List<Meeting>>> getMeetings({DateTime? start, DateTime? end});
  Future<Result<Meeting>> createMeeting(Meeting meeting);
  Future<Result<Meeting>> updateMeeting(Meeting meeting);
  Future<Result<void>> deleteMeeting(String id);
}
