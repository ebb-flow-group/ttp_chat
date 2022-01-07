import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../features/chat/domain/brand_firebase_token_model.dart';
import '../features/chat/domain/chat_sign_in_model.dart';
import '../features/chat/domain/search_user_model.dart';
import '../features/chat/domain/user_firebase_token_model.dart';
import '../global.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: BASE_URL)
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
      @Header("Authorization") String authorization,
      @Query("search") String searchValue);

  /*@GET("/api/app-config/")
  Future<AppConfig> getAppConfig();

  @GET("/api/brands/")
  Future<BrandListResponse> getBrands({
    @Query("name") String query = '',
    @Query("delivery") String delivery = '',
    @Query("dine_in") String dineIn = '',
    @Query("take_away") String takeAway = '',
  });

  @GET("/api/brands/{id}")
  Future<Brand> getBrand(@Path() int id);

  @GET("/api/tags/")
  Future<TagListResponse> getAvailableTags();

  @GET("/api/promotions/")
  Future<PromotionListResponse> getPromotions();

  @GET("/api/special-items/")
  Future<PromotionListResponse> getSignatures();

  @GET("/api/featured-discounts")
  Future<FeaturedDiscountsResponse> getFeaturedDiscounts();

  @GET("/api/chefs/")
  Future<ChefListResponse> getChefs();

  @GET("/api/chefs/{id}")
  Future<ChefWithBrandInfo> getChefDetail(@Path() int id);

  @GET("/api/chef-posts/")
  Future<ChefPostResponse> getChefPosts(
    @Header("Authorization") String authorization,
    @Query("chef") String chef,
    @Query("limit") int limit,
    @Query("offset") int offset,
  );

  @GET('/api/chef-recipes')
  Future<ChefRecipeResponse> getChefRecipes(
    @Field('chef') int chefId,
    @Field('limit') int limit,
    @Field('offset') int offset,
  );

  // action = like / unlike
  @PUT('/api/chef-posts/{id}/{action}/')
  Future<ChefPost> chefPostAction(
    @Header("Authorization") String authorization,
    @Path() int id,
    @Path() String action,
  );

  @GET('/api/chef-media')
  Future<ChefMediaResponse> getChefMedias(
    @Query('chef') int chef,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @GET('/api/time-slots')
  Future<TimeSlotResponse> getTimeSlots(
    @Query('brand') String brandId,
    @Query('days') int days,
    @Query('order_type') String orderType,
    // @Query('menu_item') String<int> menuItemIds,
  );

  @GET("/api/discounts/")
  Future<Discount> applyDiscount(
    @Header("Authorization") String authorization,
    @Query("code") String code,
    @Query("brand") int brand,
    @Query("order_type") String orderType,
  );

  @GET("/api/discounts/")
  Future<DiscountResponse> getDiscountCodes(
    @Header("Authorization") String authorization,
    @Query("brand") int brand,
  );

  @GET("/api/menu-items/")
  Future<PromotionListResponse> getMenuItems(
    @Query("brand") int brandId,
    @Query("offset") int offset,
    @Query("category") String category,
    @Query("limit") int limit,
  );

  @GET("/api/menu-items/{itemId}")
  Future<Item> getMenuItem(
    @Path("itemId") int itemId,
  );*/
  ///

  // ***************
  // User API
  // ***************

  /*@POST("/auth/phone")
  Future<OtpResponse> requestOTP(
      @Header("App-Name") String authorization,
      @Field("phone_number") String phoneNo);

  @POST("/auth/otp")
  Future<LoginResponse> verifyOTP(@Field("phone_number") String phoneNo,
      @Field("confirmation_code") String confirmationCode);*/

  @POST('/api/auth/')
  Future<ChatSignInModel> signInMVP(
      @Field('username') String username, @Field('password') String password);

  /*@PUT("/auth/users")
  Future<UserData> updateUser(
    @Header("Authorization") String authorization,
    @Body() Map<String, dynamic> map,
  );

  @GET("/auth/users")
  Future<UserData> getUser(
    @Header("Authorization") String authorization,
  );*/

  /*@POST("/auth/refresh-token/")
  Future<RefreshTokenResponse> refreshToken(@Field("refresh") String refresh);*/
  ///

  // ***************
  // Orders API
  // ***************

  /*@POST('/api/orders/')
  Future<OrderResponse> placeOrder(
    @Header("Authorization") String authorization,
    @Body() OrderRequest order,
  );

  @GET('/api/orders')
  Future<OrderListResponse> getOrders(
    @Header("Authorization") String authorization,
  );

  @GET('/api/orders/{orderId}')
  Future<OrderResponse> getOrderDetails(
    @Header("Authorization") String authorization,
    @Path() int orderId,
  );

  @GET('/api/fees')
  Future<FeesResponse> getFees(@Query('brand') int brandId);*/
  ///

  // ***************
  // Locations API
  // ***************

  /*@POST('/api/locations/')
  Future<Location> createLocation(
      @Header("Authorization") String authorization, @Body() Location location);

  @GET('/api/locations/')
  Future<LocationResponse> getLocations(
      @Header("Authorization") String authorization);

  @DELETE('/api/locations/{id}/')
  Future<void> deleteLocation(
    @Header("Authorization") String authorization,
    @Path() int id,
  );

  @PUT('/api/locations/{id}/')
  Future<Location> updateLocation(
    @Header("Authorization") String authorization,
    @Path() int id,
    @Body() Location location,
  );*/
  ///

  // ***************
  // Favorites API
  // ***************

  /*@GET('/api/favorite-items/')
  Future<FavoritesResponse> getFavorites(
    @Header("Authorization") String authorization,
  );

  @GET('/api/favorite-items/{id}/')
  Future<FavoriteItem> getFavoriteById(
    @Header("Authorization") String authorization,
    @Path() String id,
  );

  @POST('/api/favorite-items/')
  Future<FavoriteItem> addFavorite(
    @Header("Authorization") String authorization,
    @Body() AddFavoriteRequest favoriteItem,
  );

  @DELETE('/api/favorite-items/{id}/')
  Future<void> deleteFavorite(
    @Header("Authorization") String authorization,
    @Path() String id,
  );*/
}
