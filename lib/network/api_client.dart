import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:retrofit/retrofit.dart';

import '../core/screens/chat_utils.dart';
import '../features/chat/domain/brand_firebase_token_model.dart';
import '../features/chat/domain/search_user_model.dart';
import '../features/chat/domain/user_firebase_token_model.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) {
    return _ApiClient(dio, baseUrl: GetIt.I<ChatUtils>().baseUrl);
  }

  @POST('/auth/firebase-token')
  Future<UserFirebaseTokenModel> getUserFirebaseToken(
    @Header('Authorization') String authorization,
  );

  @POST('/auth/brand-firebase-tokens')
  Future<BrandFirebaseTokenModel> getBrandFirebaseToken(
    @Header('Authorization') String authorization,
  );

  @GET('/api/chat-users/')
  Future<SearchUserModel> searchChatUser(
    @Header("Authorization") String authorization,
    @Query("search") String searchValue,
    @Query("limit") int limit,
    @Query("offset") int offset,
  );

  @PATCH('/api/my-home-orders/{orderId}/')
  Future<void> updateMyHomeOrder(
    @Header('Authorization') String authorization,
    @Path() int orderId,
    @Body() Map<String, dynamic> data,
  );

  @PATCH('/api/home-orders/{orderId}/')
  Future<void> updateHomeOrder(
    @Header('Authorization') String authorization,
    @Path() int orderId,
    @Body() Map<String, dynamic> data,
  );
}
