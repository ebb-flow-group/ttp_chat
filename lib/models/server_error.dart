import 'package:dio/dio.dart' hide Headers;
import 'package:ttp_chat/utils/functions.dart';

import 'error_message.dart';

class ServerError implements Exception {
  int? _statusCode;
  String? _errorMessage = "";
  Response? response;
  RequestOptions? request;
  List<ErrorMessage2>? errorMessages;

  ServerError.withError({required DioError error}) {
    _statusCode = error.response?.statusCode;
    request = error.requestOptions;
    response = error.response;
    _parseError(error);
  }

  ServerError.withDioError({required DioError error}) {
    _statusCode = error.response?.statusCode ?? 520;
    request = error.requestOptions;
    response = error.response;

    _parseError(error);
  }

  ServerError.withUnkownError({required Object error}) {
    _statusCode = 520;
    _errorMessage = 'Request failed due to unkown error. $error ${error.toString()}';
  }

  int? getStatusCode() {
    return _statusCode;
  }

  getErrorMessage() {
    return _errorMessage;
  }

  _parseError(DioError error) {
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
        consoleLog(error.response!.data);

        if (error.response?.data is Map && error.response!.data['errors'] is List) {
          final errors = error.response!.data['errors'] as List;
          errorMessages = <ErrorMessage2>[];
          for (Map<String, dynamic> e in errors) {
            errorMessages!.add(ErrorMessage2.fromJson(e));
          }
        }

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
          } else {
            if ((error.response!.data as Map).containsKey('errors')) {
              final errors = error.response!.data['errors'] as List;
              if (errors.isNotEmpty) {
                _errorMessage = errors.first['message'];
                break;
              }
            }
          }
        }

        _errorMessage = "Received invalid status code: ${error.response!.statusCode}";

        break;
    }

    return _errorMessage;
  }
}
