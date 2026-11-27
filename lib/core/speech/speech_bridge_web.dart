// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class SpeechBridgeImpl {
  static void start(Function(String text) onResult) {
    try {
      js.context.callMethod('startWebSpeechRecognition', [
        js.allowInterop((result) {
          if (result != null) {
            onResult(result.toString());
          }
        })
      ]);
    } catch (_) {}
  }

  static void stop() {
    try {
      js.context.callMethod('stopWebSpeechRecognition');
    } catch (_) {}
  }
}
