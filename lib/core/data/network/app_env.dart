/// Environment configuration for Notixa API
class AppEnv {
  AppEnv._();

  static const String appName = 'Notixa';
  static const String appVersion = '1.0.6';
  static const int appVersionCode = 11;

  // Primary Production Endpoint
  static const String primaryApiBaseUrl = 'https://api.notixa.ai/api/v1';

  // Secondary/Fallback IP Endpoint discovered in binary
  static const String fallbackApiBaseUrl = 'http://178.105.190.54/api/v1';

  // Speech-to-Text Provider
  static const String deepgramSttUrl = 'wss://api.deepgram.com/v1/listen';
  static const String defaultDeepgramApiKey = 'YOUR_DEEPGRAM_API_KEY';

  static String currentBaseUrl = primaryApiBaseUrl;
}
