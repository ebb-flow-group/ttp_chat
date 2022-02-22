import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../features/chat/domain/brand_firebase_token_model.dart';
import '../features/chat/domain/search_user_model.dart';
import '../features/chat/domain/user_firebase_token_model.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, String url) {
    return _ApiClient(dio, baseUrl: url);
  }

  @POST("/auth/firebase-token")
  Future<UserFirebaseTokenModel> getUserFirebaseToken(
    @Header("Authorization") String authorization,
  );

  @POST("/auth/brand-firebase-tokens")
  Future<BrandFirebaseTokenModel> getBrandFirebaseToken(
    @Header("Authorization") String authorization,
  );

  @GET('/api/chat-users/')
  Future<SearchUserModel> searchChatUser(
      @Header("Authorization") String authorization, @Query("search") String searchValue);

  // @POST('/api/auth/')
  // Future<ChatSignInModel> signInMVP(
  //     @Field('username') String username, @Field('password') String password);
}
