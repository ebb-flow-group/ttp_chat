class ChatSignInModel
{
  String? refresh, access, customFirebaseToken;
  List<BrandCustomTokens> brandCustomFirebaseTokens = [];

  ChatSignInModel({this.refresh, this.access, this.customFirebaseToken});

  ChatSignInModel.fromJson(Map<String, dynamic> json) {
    refresh = json['refresh'];
    access = json['access'];
    customFirebaseToken = json['custom_firebase_token'];
    // getFBUser(json['custom_firebase_token']); // This function gives IdToken and Refresh Token
    brandCustomFirebaseTokens = json["brand_custom_firebase_tokens"] == null
    ? []
    : List<BrandCustomTokens>.from(json["brand_custom_firebase_tokens"].map((x) => BrandCustomTokens.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['refresh'] = refresh;
    data['access'] = access;
    data['custom_firebase_token'] = customFirebaseToken;
    data['brand_custom_firebase_tokens'] = brandCustomFirebaseTokens;

    return data;
  }
}

class BrandCustomTokens
{
  String? firebaseUuid, brandName, firebaseToken;

  BrandCustomTokens({
    this.firebaseUuid,
    this.brandName,
    this.firebaseToken,
  });

  BrandCustomTokens.fromJson(Map<String, dynamic> json) {
    firebaseUuid = json['firebase_uuid'];
    brandName = json['brand_name'];
    firebaseToken = json['firebase_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firebase_uuid'] = firebaseUuid;
    data['brand_name'] = brandName;
    data['firebase_token'] = firebaseToken;

    return data;
  }
}