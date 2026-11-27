import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../domain/result.dart';
import '../error/failures.dart';

class DeepgramSpeechService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;

  Future<Result<String>> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _currentRecordingPath = p.join(
          tempDir.path,
          'notixa_voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _currentRecordingPath!,
        );

        _isRecording = true;
        return Success(_currentRecordingPath!);
      } else {
        return const Error(ServerFailure('Microphone permission denied'));
      }
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<String?>> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      return Success(path ?? _currentRecordingPath);
    } catch (e) {
      _isRecording = false;
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
