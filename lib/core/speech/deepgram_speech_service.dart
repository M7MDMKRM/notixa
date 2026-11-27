import 'dart:async';
import '../domain/result.dart';

class DeepgramSpeechService {
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;

  Future<Result<String>> startRecording() async {
    _isRecording = true;
    _currentRecordingPath = 'notixa_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return Success(_currentRecordingPath!);
  }

  Future<Result<String?>> stopRecording() async {
    _isRecording = false;
    return Success(_currentRecordingPath);
  }

  Future<void> dispose() async {}
}
