import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_http_cache_fix/dio_http_cache.dart';
import 'package:librarp_digital/app_constants.dart';
import 'package:librarp_digital/service/sessions.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  Dio init() {
    final dio = Dio();
    log("base_url : ${AppConstants.BASE_URL}");

    // Caching setup
    final cacheManager = DioCacheManager(
      CacheConfig(
        baseUrl: AppConstants.BASE_URL,
        defaultMaxAge: const Duration(minutes: 1),
      ),
    );

    // Set base options
    dio.options.baseUrl = AppConstants.BASE_URL;
    dio.options.connectTimeout = const Duration(milliseconds: 11500);
    dio.options.receiveTimeout = const Duration(milliseconds: 11500);
    dio.options.sendTimeout = const Duration(milliseconds: 11500);

    // Add interceptors
    dio.interceptors.add(ApiInterceptors());
    dio.interceptors.add(cacheManager.interceptor);
    dio.interceptors.add(PrettyDioLogger());

    return dio;
  }
}

class ApiInterceptors extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add token if needed
    if (options.headers.containsKey("requiresToken")) {
      options.headers.remove("requiresToken");

      final session = Session();
      final token = await session.getString(AppKeyEncrypted.TOKEN);

      // ignore: unnecessary_null_comparison
      if (token != null && token.isNotEmpty) {
        options.headers.addAll({"Authorization": "Bearer $token"});
        log("Token attached to request: $token");
      }
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    switch (statusCode) {
      case 401:
        // Unauthorized - clear session and logout
        final session = Session();
        await session.removeSF(AppKeyEncrypted.TOKEN);
        await session.removeSF(AppKeyEncrypted.REFRESH_TOKEN);
        await session.removeSF(AppKey.USER_ID);
        await session.clearSF();
        break;

      case 422:
      case 403:
      case 400:
      case 404:
        // Allow error to propagate
        log("HTTP Error [$statusCode]: ${err.response?.data}");
        break;

      default:
        // Unhandled error
        log("Unhandled Dio Error: $err");
    }

    return handler.next(err);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final verifyTokenHeader = response.headers.value("verifyToken");

    if (verifyTokenHeader != null) {
      final prefs = await SharedPreferences.getInstance();
      final savedVerifyToken = prefs.getString("VerifyToken");

      if (verifyTokenHeader == savedVerifyToken) {
        return handler.next(response); // Token valid, continue
      } else {
        log(
          "Invalid verifyToken: Header=$verifyTokenHeader, Stored=$savedVerifyToken",
        );
        // You may want to handle token mismatch here
        return handler.next(response);
      }
    } else {
      return handler.next(response); // No token to validate, continue
    }
  }
}
