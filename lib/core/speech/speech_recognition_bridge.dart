import 'speech_bridge_stub.dart' if (dart.library.js) 'speech_bridge_web.dart';

class SpeechRecognitionBridge {
  SpeechRecognitionBridge._();

  static void start(Function(String text) onResult) {
    SpeechBridgeImpl.start(onResult);
  }

  static void stop() {
    SpeechBridgeImpl.stop();
  }
}
