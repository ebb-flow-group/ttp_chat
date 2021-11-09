
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttp_chat/utils/shared_pref_constant.dart';

/// Use this class to CRUD data to Shared Preference
class SharedPrefService {
  final SharedPreferences _sharedPref;

  SharedPrefService._(this._sharedPref);

  static Future<SharedPrefService> getInstance() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return SharedPrefService._(sharedPref);
  }

  bool? getIsFirstTime() {
    return _sharedPref.getBool(SharedPrefKeys.IS_FIRST_TIME);
  }

  Future<bool> setIsFirstTime(bool value) {
    return _sharedPref.setBool(SharedPrefKeys.IS_FIRST_TIME, value);
  }

  /*AuthData getAuthData() {
    String data = _sharedPref.getString(SharedPrefKeys.AUTH)!;

    if (data != null) {
      try {
        Map<String, dynamic> map = json.decode(data);
        if (map == null) return AuthData();
        return AuthData.fromJson(map);
      } catch (e, s) {
        Logger().e('Error parsing AuthData from SharedPref', e, s);
        return AuthData();
      }
    }

    return AuthData();
  }

  // TODO: Don't store sensitive data in Shared Pref. Use flutter_secure_storage instead
  Future<bool> setAuthData(AuthData value) {
    return _sharedPref.setString(
      SharedPrefKeys.AUTH,
      json.encode(value.toJson()),
    );
  }*/

  int getAuthTokenExpireAt() {
    return _sharedPref.getInt(SharedPrefKeys.AUTH_TOKEN_EXPIRE_AT)!;
  }

  Future<bool> setAuthTokenExpireAt(int timeInMs) {
    return _sharedPref.setInt(SharedPrefKeys.AUTH_TOKEN_EXPIRE_AT, timeInMs);
  }

 /*

  SavedCart getSavedCart() {
    String data = _sharedPref.getString(SharedPrefKeys.CART_ITEMS);

    if (data != null) {
      try {
        Map map = json.decode(data);
        if (map == null) return null;
        return SavedCart.fromJson(map);
      } catch (e, s) {
        logger.e('Error parsing SavedCart from SharedPref', e, s);
        return null;
      }
    }

    return null;
  }

  Future<bool> setSavedCart(SavedCart cart) {
    return _sharedPref.setString(
      SharedPrefKeys.CART_ITEMS,
      json.encode(cart.toJson()),
    );
  }*/
}
