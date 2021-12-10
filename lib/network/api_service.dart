
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:ttp_chat/features/chat/domain/brand_firebase_token_model.dart';
import 'package:ttp_chat/features/chat/domain/chat_sign_in_model.dart';
import 'package:ttp_chat/features/chat/domain/search_user_model.dart';
import 'package:ttp_chat/features/chat/domain/user_firebase_token_model.dart';
import 'package:ttp_chat/global.dart';
import 'package:ttp_chat/models/base_model.dart';
import 'package:ttp_chat/models/server_error.dart';
import 'package:ttp_chat/network/api_client.dart';
import 'package:ttp_chat/utils/access_token_interceptor.dart';

class ApiService {
  late Dio dio;
  late ApiClient apiClient;

  Logger logger = Logger();

  ApiService({String url = BASE_URL}) {
    dio = Dio();
    // dio.interceptors.add(AccessTokenInterceptor(dio));

    apiClient = ApiClient(dio, url);
  }

  Future<BaseModel<ChatSignInModel>> signInMVP(String username, String password) async {
    ChatSignInModel response;
    try {
      dio = Dio();
      apiClient = ApiClient(dio, 'https://django-firebase-mvp.herokuapp.com');
      response = await apiClient.signInMVP(username, password);
    } catch (error) {
      print('ERRPRRRR: $error');
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<UserFirebaseTokenModel>> getUserFirebaseToken(String accessToken) async {
    UserFirebaseTokenModel response;
    try {
      response = await apiClient.getUserFirebaseToken('Bearer $accessToken');
    } catch (error) {
      print('USERR ERRPRRRR: $error');
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<BrandFirebaseTokenModel>> getBrandFirebaseToken(String accessToken) async {
    BrandFirebaseTokenModel response;
    try {
      response = await apiClient.getBrandFirebaseToken('Bearer $accessToken');
    } catch (error) {
      print('BRANDD ERRPRRRR: $error');
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SearchUserModel>> searchUser(String token, String searchValue) async {
    SearchUserModel response;
    try {
      response = await apiClient.searchChatUser('Bearer $token', searchValue);
      print('SEARCH USER RESP: ${response.toJson()}');
    } catch (error) {
      print('ERRPRRRR: $error');
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel()..data = response;
  }

/*Future<BaseModel<AppConfig>> getAppConfig() async {
    AppConfig response;
    try {
      response = await apiClient.getAppConfig();
    } catch (e) {
      return BaseModel()..setException(ServerError.withError(error: e));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<OtpResponse>> requestOTP(String phoneNo) async {
    OtpResponse response;
    try {
      response = await apiClient.requestOTP(phoneNo);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<LoginResponse>> verifyOTP(
    String phoneNo,
    String confirmationCode,
  ) async {
    LoginResponse response;
    try {
      response = await apiClient.verifyOTP(phoneNo, confirmationCode);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<UserData>> getUser(String token) async {
    UserData response;

    try {
      response = await apiClient.getUser('Bearer $token');
    } catch (e) {
      return BaseModel()..setException(ServerError.withError(error: e));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<UserData>> updateUser(String token, Map map) async {
    UserData response;
    try {
      if (map != null) {
        map.removeWhere((k, v) => (v == null || v.toString().isEmpty));
      }
      response = await apiClient.updateUser('Bearer $token', map);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<BrandListResponse>> getBrands({
    bool delivery,
    bool dineIn,
    bool takeAway,
  }) async {
    String deliveryStr = delivery == null ? '' : delivery.toString();
    String dinInStr = dineIn == null ? '' : dineIn.toString();
    String takeAwayStr = takeAway == null ? '' : takeAway.toString();

    BrandListResponse response;
    try {
      response = await apiClient.getBrands(
        delivery: deliveryStr,
        dineIn: dinInStr,
        takeAway: takeAwayStr,
      );
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<BrandListResponse>> searchBrands({
    String searchQuery,
    bool delivery = false,
    bool dineIn = false,
  }) async {
    String deliveryStr = delivery == null ? '' : delivery.toString();
    String dineInStr = dineIn == null ? '' : dineIn.toString();

    BrandListResponse response;
    try {
      response = await apiClient.getBrands(
          query: searchQuery, delivery: deliveryStr, dineIn: dineInStr);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<Brand>> getBrand(int id) async {
    Brand response;
    try {
      response = await apiClient.getBrand(id);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<TagListResponse>> getAvailableTags() async {
    TagListResponse response;
    try {
      response = await apiClient.getAvailableTags();
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<PromotionListResponse>> getPromotions() async {
    PromotionListResponse response;
    try {
      response = await apiClient.getPromotions();
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<PromotionListResponse>> getSignatures() async {
    PromotionListResponse response;
    try {
      response = await apiClient.getSignatures();
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<FeaturedDiscountsResponse>> getFeaturedDiscounts() async {
    FeaturedDiscountsResponse response;
    try {
      response = await apiClient.getFeaturedDiscounts();
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ChefListResponse>> getChefs() async {
    ChefListResponse response;
    try {
      response = await apiClient.getChefs();
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ChefWithBrandInfo>> getChefDetail(int id) async {
    ChefWithBrandInfo response;
    try {
      response = await apiClient.getChefDetail(id);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ChefPostResponse>> getChefPosts(
    String token,
    String id,
    int limit,
    int offset,
  ) async {
    ChefPostResponse response;
    try {
      token = token != null ? 'Bearer $token' : '';

      response = await apiClient.getChefPosts(
        token,
        id.toString(),
        limit,
        offset,
      );
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ChefPost>> chefPostAction(
    String token,
    int id,
    String action,
  ) async {
    ChefPost response;
    try {
      response = await apiClient.chefPostAction('Bearer $token', id, action);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ChefRecipeResponse>> getChefRecipes(
    int chefId, {
    int limit = 10,
    int offset = 0,
  }) async {
    ChefRecipeResponse response;
    try {
      response = await apiClient.getChefRecipes(chefId, limit, offset);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ChefMediaResponse>> getChefMedias(
    int chefId, {
    int limit = 100,
    int offset = 0,
  }) async {
    ChefMediaResponse response;
    try {
      response = await apiClient.getChefMedias(chefId, limit, offset);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  /// Not using [ApiClient] to make API request since there is no way
  /// to send multiple query params with the same name using Dio/Retrofit library
  /// See open issue on Github: https://github.com/trevorwang/retrofit.dart/issues/360
  Future<BaseModel<TimeSlotResponse>> getTimeSlots(
    String brandId,
    int days,
    String orderType,
    List<int> itemIds,
  ) async {
    TimeSlotResponse response;
    try {
      Map<String, dynamic> queryParams = {
        'brand': brandId ?? '',
        'days': days?.toString() ?? '',
        'order_type': orderType ?? '',
        'menu_item': itemIds?.map<String>((e) => e.toString()) ?? '',
      };

      String baseUrl =
          BASE_URL.replaceFirst('https://', '').replaceFirst('http://', '');
      Uri uri = Uri.https(baseUrl, 'api/time-slots', queryParams);

      http.Response httpResponse = await http.get(uri);

      if (httpResponse.statusCode == 200) {
        Map<String, dynamic> data = json.decode(httpResponse.body);
        response = TimeSlotResponse.fromJson(data);
      } else {
        logger.e(
            'Error from getTimeSlots API. ${httpResponse.statusCode} ${httpResponse.body}');
        return BaseModel()
          ..setException(ServerError.withError(error: DioError()));
      }
    } catch (error, stacktrace) {
      logger.e('Error from getTimeSlots API', error, stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: DioError()));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<Discount>> applyDiscount(
    String token,
    String code,
    int brandId,
    String orderType,
  ) async {
    Discount response;
    try {
      response = await apiClient.applyDiscount(
          'Bearer $token', code, brandId, orderType);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<DiscountResponse>> getDiscountCodes(
    String token,
    int brandId,
  ) async {
    DiscountResponse response;
    try {
      response = await apiClient.getDiscountCodes('Bearer $token', brandId);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<OrderResponse>> placeOrder(
    String token,
    OrderRequest orderRequest,
  ) async {
    OrderResponse response;
    try {
      response = await apiClient.placeOrder('Bearer $token', orderRequest);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<OrderListResponse>> getOrders(String token) async {
    OrderListResponse response;
    try {
      response = await apiClient.getOrders('Bearer $token');
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<OrderResponse>> getOrderDetails(
    String token,
    int orderId,
  ) async {
    OrderResponse response;
    try {
      response = await apiClient.getOrderDetails('Bearer $token', orderId);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<PromotionListResponse>> getMenuItems(
    int brandId,
    int offset,
    int category,
    int limit,
  ) async {
    PromotionListResponse response;

    String categoryStr = category != null ? category.toString() : '';

    try {
      response = await apiClient.getMenuItems(
        brandId,
        offset,
        categoryStr,
        limit,
      );
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<Item>> getMenuItem(int itemId) async {
    Item response;

    try {
      response = await apiClient.getMenuItem(itemId);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<FeesResponse>> getFees(int brandId) async {
    FeesResponse response;
    try {
      response = await apiClient.getFees(brandId);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<Location>> createLocation(
    String token,
    Location location,
  ) async {
    Location response;
    try {
      response = await apiClient.createLocation('Bearer $token', location);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<LocationResponse>> getLocations(String token) async {
    LocationResponse response;
    try {
      response = await apiClient.getLocations('Bearer $token');
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel> deleteLocation(String token, int id) async {
    try {
      await apiClient.deleteLocation('Bearer $token', id);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel();
  }

  Future<BaseModel<Location>> updateLocation(
    String token,
    int id,
    Location location,
  ) async {
    Location response;
    try {
      response = await apiClient.updateLocation('Bearer $token', id, location);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<FavoritesResponse>> getFavorites(String token) async {
    FavoritesResponse response;
    try {
      response = await apiClient.getFavorites('Bearer $token');
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<FavoriteItem>> getFavorite(
    String token,
    String id,
  ) async {
    FavoriteItem response;
    try {
      response = await apiClient.getFavoriteById('Bearer $token', id);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<FavoriteItem>> addFavorite(
    String token,
    AddFavoriteRequest favoriteItem,
  ) async {
    FavoriteItem response;
    try {
      response = await apiClient.addFavorite('Bearer $token', favoriteItem);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel> deleteFavorite(
    String token,
    String menuItemId,
  ) async {
    try {
      await apiClient.deleteFavorite('Bearer $token', menuItemId);
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel();
  }*/

  /*Future<BaseModel<ChatSignInModel>> signInMVP(String username, String password) async {
    ChatSignInModel response;
    try {
      dio = Dio();
      apiClient = ApiClient(dio, 'https://django-firebase-mvp.herokuapp.com');
      response = await apiClient.signInMVP(username, password);
    } catch (error) {
      print('ERRPRRRR: $error');
      return BaseModel()..setException(ServerError.withError(error: error as DioError));
    }
    return BaseModel()..data = response;
  }*/
}
