import 'package:dio/dio.dart';

import '../features/chat/domain/brand_firebase_token_model.dart';
import '../features/chat/domain/search_user_model.dart';
import '../features/chat/domain/user_firebase_token_model.dart';
import '../models/base_model.dart';
import '../models/server_error.dart';
import '../utils/functions.dart';
import 'api_client.dart';

class ApiService {
  late Dio dio;
  late ApiClient apiClient;

  ApiService() {
    dio = Dio();
    apiClient = ApiClient(dio);
  }

  Future<BaseModel<UserFirebaseTokenModel>> getUserFirebaseToken(String accessToken) async {
    UserFirebaseTokenModel response;
    try {
      response = await apiClient.getUserFirebaseToken('Bearer $accessToken');
    } catch (error) {
      consoleLog('USERR ERRPRRRR: $error');
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<BrandFirebaseTokenModel>> getBrandFirebaseToken(String accessToken) async {
    BrandFirebaseTokenModel response;
    try {
      response = await apiClient.getBrandFirebaseToken('Bearer $accessToken');
    } catch (error) {
      consoleLog('BRANDD ERRPRRRR: $error');
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SearchUserModel>> searchUser(String token, String searchValue,
      {int limit = 15, int offset = 0}) async {
    SearchUserModel response;
    try {
      response = await apiClient.searchChatUser('Bearer $token', searchValue, limit, offset);
    } catch (error) {
      consoleLog('ERRPRRRR: $error');
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<void>> updateMyHomeOrder(String token, int orderId, Map<String, dynamic> data) async {
    try {
      await apiClient.updateMyHomeOrder('Bearer $token', orderId, data);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel();
  }

  Future<BaseModel<void>> updateHomeOrder(String token, int orderId, Map<String, dynamic> data) async {
    try {
      await apiClient.updateHomeOrder('Bearer $token', orderId, data);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel();
  }
}
