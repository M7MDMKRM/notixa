import 'package:dio/dio.dart';
import 'app_env.dart';
import '../storage/token_storage.dart';

class DioFactory {
  final TokenStorage _tokenStorage;

  DioFactory(this._tokenStorage);

  Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.currentBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': AppEnv.appVersion,
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If unauthorized (401), can handle refresh token or clear session
          if (error.response?.statusCode == 401) {
            await _tokenStorage.clearTokens();
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
