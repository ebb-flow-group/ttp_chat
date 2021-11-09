import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// Intercepts Dio API calls
class AccessTokenInterceptor extends Interceptor {
  final Dio dio;
  final Logger _logger = Logger();

  AccessTokenInterceptor(this.dio);

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer fail';
      return options;
    }

    /*if (options.headers.containsKey('Authorization')) {
      return validateAccessToken(options);
    }*/

    return options;
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler errorInterceptorHandler) async {
    _logger.e(
      'Error on API call.'
      '\n${err.requestOptions.path}'
      '\n${err.response?.statusCode} ${err.response?.statusMessage}'
      '\n${err.response?.data}',
    );

    return err;
  }

  /// Checks if "Authorization" token is valid.
  /// If token is not valid fetches new token using [authProvider] and updates headers
  /*Future<RequestOptions> validateAccessToken(RequestOptions options) async {
    String token = options.headers['Authorization'];

    if (token == null || token.isEmpty) {
      return options;
    }

    bool isTokenExpired = GetIt.I<AuthProvider>().shouldUpdateAccessToken();

    if (!isTokenExpired) {
      return options;
    }

    _logger.w('Access token has expired. Refreshing access token.');
    String newToken = await GetIt.I<AuthProvider>().refreshAccessToken();
    _logger.i('Refreshed access token to $newToken');

    options.headers['Authorization'] = 'Bearer $newToken';

    return options;
  }*/
}
