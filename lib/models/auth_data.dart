import '../features/chat/domain/brand_firebase_token_model.dart';

class AuthData {
  String? refresh;
  String? access;
  String? firebaseToken;
  int? accessTokenExpiry;
  List<BrandFirebaseTokenModel>? brandFirebaseTokenList;

  AuthData(
      {this.refresh,
      this.access,
      this.firebaseToken,
      this.accessTokenExpiry,
      this.brandFirebaseTokenList});

  AuthData.fromJson(Map<String, dynamic> json) {
    refresh = json['refresh'];
    access = json['access'];
    firebaseToken = json['firebase_token'];
    accessTokenExpiry = json['access_token_expiry'];
    brandFirebaseTokenList = json["brand_firebase_tokens"] == null
        ? []
        : List<BrandFirebaseTokenModel>.from(json["brand_firebase_tokens"]
            .map((x) => BrandFirebaseTokenModel.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refresh'] = refresh;
    data['access'] = access;
    data['firebase_token'] = firebaseToken;
    data['access_token_expiry'] = accessTokenExpiry;
    data['brand_firebase_tokens'] = brandFirebaseTokenList == null
        ? []
        : List<dynamic>.from(brandFirebaseTokenList!.map((x) => x.toJson()));
    return data;
  }
}
