import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/features/chat/presentation/auth_provider.dart';

import '../global.dart';

/// Intercepts Dio API calls
class AccessTokenInterceptor extends Interceptor {
  final Dio? dio;

  AccessTokenInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {

    if (options.headers.containsKey('Authorization')) {
      return await validateAccessToken(options, handler);
    }

    return handler.next(options);
  }

  @override
  void onError(
      DioError err,
      ErrorInterceptorHandler handler,
      ) {
    // Ignore 404 errors from this path
    if (err.requestOptions.path.contains('/api/favorite-items')) {
      return handler.next(err);
    }

    logger.e(
      'Error on API call.'
          '\n${err.requestOptions.baseUrl}'
          '\n${err.requestOptions.path}'
          '\n${err.response?.statusCode} ${err.response?.statusMessage}'
          '\n${err.response?.data}',
    );

    return handler.next(err);
  }

  /// Checks if "Authorization" token is valid.
  /// If token is not valid fetches new token using [authProvider] and updates headers
  Future<void> validateAccessToken(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    String? token = options.headers['Authorization'];

    if (token == null || token.isEmpty) {
      return handler.next(options);
    }

    bool isTokenExpired = GetIt.I<AuthProvider>().shouldUpdateAccessToken();

    if (!isTokenExpired) {
      return handler.next(options);
    }

    logger.w('Access token has expired. Refreshing access token.');
    String? newToken = await GetIt.I<AuthProvider>().refreshAccessToken();
    logger.i('Refreshed access token to $newToken');

    options.headers['Authorization'] = 'Bearer $newToken';

    return handler.next(options);
  }
}
