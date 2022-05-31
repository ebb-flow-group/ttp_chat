import 'package:dio/dio.dart';

import '../features/chat/domain/brand_firebase_token_model.dart';
import '../features/chat/domain/search_user_model.dart';
import '../features/chat/domain/user_firebase_token_model.dart';
import '../models/base_model.dart';
import '../models/refresh_token_response.dart';
import '../models/server_error.dart';
import '../utils/functions.dart';
import 'api_client.dart';

class ApiService {
  final Dio dio = Dio();
  late ApiClient apiClient;
  ApiService() {
    apiClient = ApiClient(dio);
  }

  Future<BaseModel<RefreshTokenResponse>> _refreshToken(
    String? refreshToken,
  ) async {
    RefreshTokenResponse response;
    try {
      response = await apiClient.refreshToken(refreshToken);
    } on DioError catch (e) {
      return BaseModel()..setException(ServerError.withDioError(error: e));
    } catch (e) {
      return BaseModel()..setException(ServerError.withUnkownError(error: e));
    }
    return BaseModel()..data = response;
  }

  /// Check response for invalid token
  bool _isTokenInvalid(dynamic d) {
    try {
      String code = d['errors'][0]['code'];
      if (code == 'token_not_valid' || code == 'invalid_session') {
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<BaseModel<UserFirebaseTokenModel>> getUserFirebaseToken(String accessToken, String? refreshToken) async {
    UserFirebaseTokenModel response;
    try {
      response = await apiClient.getUserFirebaseToken('Bearer $accessToken');
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        consoleLog('401 error: checking token');

        // If token expired or invalid, try to refresh
        bool res = _isTokenInvalid(e.response?.data);

        if (res) {
          final tokenResp = await _refreshToken(refreshToken);
          if (tokenResp.data?.access != null) {
            return getUserFirebaseToken(tokenResp.data!.access!, refreshToken);
          }
        }
      }

      return BaseModel()..setException(ServerError.withDioError(error: e));
    } catch (e) {
      return BaseModel()..setException(ServerError.withUnkownError(error: e));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<BrandFirebaseTokenModel>> getBrandFirebaseToken(String accessToken, String? refreshToken) async {
    BrandFirebaseTokenModel response;
    try {
      response = await apiClient.getBrandFirebaseToken('Bearer $accessToken');
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        consoleLog('401 error: checking token');

        // If token expired or invalid, try to refresh
        bool res = _isTokenInvalid(e.response?.data);

        if (res) {
          final tokenResp = await _refreshToken(refreshToken);
          if (tokenResp.data?.access != null) {
            return getBrandFirebaseToken(tokenResp.data!.access!, refreshToken);
          }
        }
      }

      return BaseModel()..setException(ServerError.withDioError(error: e));
    } catch (e) {
      return BaseModel()..setException(ServerError.withUnkownError(error: e));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SearchUserModel>> searchUser(String accessToken, String? refreshToken,
      {required String searchValue, int limit = 15, int offset = 0}) async {
    SearchUserModel response;
    try {
      response = await apiClient.searchChatUser('Bearer $accessToken', searchValue, limit, offset);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        consoleLog('401 error: checking token');

        // If token expired or invalid, try to refresh
        bool res = _isTokenInvalid(e.response?.data);

        if (res) {
          final tokenResp = await _refreshToken(refreshToken);
          if (tokenResp.data?.access != null) {
            return searchUser(tokenResp.data!.access!, refreshToken,
                searchValue: searchValue, limit: limit, offset: offset);
          }
        }
      }

      return BaseModel()..setException(ServerError.withDioError(error: e));
    } catch (e) {
      return BaseModel()..setException(ServerError.withUnkownError(error: e));
    }
    return BaseModel()..data = response;
  }
}
