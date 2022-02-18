import 'package:dio/dio.dart' hide Headers;

import 'error_message.dart';

class ServerError implements Exception {
  int? _errorCode;
  String? _errorMessage = "";
  Response? response;
  RequestOptions? request;

  ServerError.withError({DioError? error}) {
    _errorCode = error!.response?.statusCode;
    request = error.requestOptions;
    response = error.response;
    _handleError(error);
  }

  int getErrorCode() {
    return _errorCode!;
  }

  getErrorMessage() {
    return _errorMessage;
  }

  _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        _errorMessage = "Request was cancelled";
        break;
      case DioErrorType.connectTimeout:
        _errorMessage = "Connection timeout";
        break;
      case DioErrorType.other:
        _errorMessage = "Connection failed due to internet connection";
        break;
      case DioErrorType.receiveTimeout:
        _errorMessage = "Receive timeout in connection";
        break;

      case DioErrorType.sendTimeout:
        _errorMessage = "Receive timeout in send request";
        break;
      case DioErrorType.response:
        print(error.response!.data);

        // Try to get issue from response
        if (error.response?.data is Map) {
          ErrorMessage errorMessage = ErrorMessage.fromJson(error.response!.data);

          if (errorMessage.detail != null) {
            _errorMessage = errorMessage.detail;
            break;
          } else if (errorMessage.username != null && errorMessage.username!.isNotEmpty) {
            _errorMessage = errorMessage.username![0];
            break;
          } else if (errorMessage.email != null && errorMessage.email!.isNotEmpty) {
            _errorMessage = errorMessage.email![0];
            break;
          }
        }

        _errorMessage = "Received invalid status code: ${error.response!.statusCode}";
        break;
    }
    return _errorMessage;
  }
}
