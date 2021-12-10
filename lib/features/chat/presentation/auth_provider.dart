import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/models/auth_data.dart';
import 'package:ttp_chat/models/base_model.dart';
import 'package:ttp_chat/network/api_service.dart';
import 'package:ttp_chat/services/shared_preference_service.dart';

import '../../../global.dart';

enum AuthStatus {
  NotLoggedIn,
  LoggedIn,
}

class AuthProvider with ChangeNotifier {
  static const AuthStatus INIT_STATUS = AuthStatus.NotLoggedIn;

  final SharedPrefService? _sharedPrefService = GetIt.I<SharedPrefService>();

  AuthStatus _status = INIT_STATUS;
  AuthData? _authData;

  AuthProvider() {
    /*String? savedAppEnv = _sharedPrefService!.getAppEnv();
    _sharedPrefService!.setAppEnv(BASE_URL);

    if (savedAppEnv != BASE_URL) {
      // Mismatched app env. can lead to invalid state of AuthProvider. So sign out user.
      logger.w('App env changed from $savedAppEnv to $BASE_URL');
      signOut();
    } else {
      // App env. matches last session. Use the saved AuthData.
      AuthData? d = _sharedPrefService!.getAuthData();
      _updateAuthData(d);
    }*/
  }

  Future<String?> refreshAccessToken() async {
    logger.i('Refreshing access token');

    /*BaseModel<RefreshTokenResponse> res =
    await GetIt.I<ApiService>().refreshToken(_authData!.refresh);

    if (res.getException != null) {
      logger.w('Issue in refreshing token.');
      _updateAuthData(null);
      notifyListeners();
      return null;
    }

    print('');

    // Update access token expiration
    int tokenExpireTimestampInMillis = DateTime.now()
        .add(Duration(seconds: res.data!.accessTokenExpiry!))
        .millisecondsSinceEpoch;
    _sharedPrefService!.setAuthTokenExpireAt(tokenExpireTimestampInMillis);

    // Update refresh token
    AuthData newAuthData = AuthData(
      access: res.data!.access,
      refresh: _authData!.refresh,
      accessTokenExpiry: res.data!.accessTokenExpiry,
    );
    await _updateAuthData(newAuthData);

    notifyListeners();

    return _authData!.access;*/
  }

  bool shouldUpdateAccessToken() {
    int accessTokenExpireAt = _sharedPrefService!.getAuthTokenExpireAt();

    // Cushion Duration -> better to refresh token a little earlier
    const Duration CUSHION_DURATION = const Duration(seconds: 10);

    return DateTime.now()
        .subtract(CUSHION_DURATION)
        .isAfter(DateTime.fromMillisecondsSinceEpoch(accessTokenExpireAt));
  }
}
