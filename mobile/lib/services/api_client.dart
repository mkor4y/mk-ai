/// MK AI - Dio HTTP İstemcisi
///
/// Tüm API çağrıları için merkezi HTTP yapılandırması.
/// Timeout, hata yakalama ve loglama interceptor'ları içerir.
library;

import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  static Dio? _dio;

  /// Singleton Dio instance
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConfig.httpTimeout),
        receiveTimeout: const Duration(seconds: AppConfig.httpTimeout),
        sendTimeout: const Duration(seconds: AppConfig.httpTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Loglama interceptor (debug modda)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // Release modda log basma
          assert(() {
            // ignore: avoid_print
            print('[MK AI API] $obj');
            return true;
          }());
        },
      ),
    );

    return dio;
  }

  /// Base URL'yi runtime'da değiştirmek için (test / production geçişi)
  static void updateBaseUrl(String newUrl) {
    instance.options.baseUrl = newUrl;
  }
}
