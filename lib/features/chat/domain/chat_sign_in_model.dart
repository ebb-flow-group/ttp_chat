import 'dart:convert';


ChatSignInModel chatSignInModelFromJson(String str) =>
    ChatSignInModel.fromJson(json.decode(str));

String chatSignInModelToJson(ChatSignInModel data) => json.encode(data.toJson());

class ChatSignInModel {
  ChatSignInModel({
    this.refresh,
    this.access,
    this.firebaseToken,
    this.accessTokenExpiry,
    this.brandFirebaseTokenList
  });

  String? refresh;
  String? access;
  String? firebaseToken;
  int? accessTokenExpiry;
  List<BrandChatFirebaseTokenResponse>? brandFirebaseTokenList;

  factory ChatSignInModel.fromJson(Map<String, dynamic> json) => ChatSignInModel(
    refresh: json["refresh"] ?? null,
    access: json["access"] ?? null,
    firebaseToken: json["firebase_token"] ?? null,
    accessTokenExpiry: json["access_token_expiry"] ?? null,
    brandFirebaseTokenList: json["brand_firebase_tokens"] == null
        ? null
        : List<BrandChatFirebaseTokenResponse>.from(
        json["results"].map((x) => BrandChatFirebaseTokenResponse.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "refresh": refresh ?? null,
    "access": access ?? null,
    "firebase_token": firebaseToken ?? null,
    "access_token_expiry":
    accessTokenExpiry ?? null,
    "brand_firebase_tokens": brandFirebaseTokenList == null
        ? null
        : List<dynamic>.from(brandFirebaseTokenList!.map((x) => x.toJson())),
  };
}


BrandChatFirebaseTokenResponse brandChatFirebaseTokenResponseFromJson(String str) =>
    BrandChatFirebaseTokenResponse.fromJson(json.decode(str));

String brandChatFirebaseTokenResponseToJson(BrandChatFirebaseTokenResponse data) => json.encode(data.toJson());

class BrandChatFirebaseTokenResponse {
  BrandChatFirebaseTokenResponse({
    this.brandName,
    this.firebaseToken,
  });

  String? brandName;
  String? firebaseToken;

  factory BrandChatFirebaseTokenResponse.fromJson(Map<String, dynamic> json) => BrandChatFirebaseTokenResponse(
    brandName: json["brand_name"] ?? null,
    firebaseToken: json["firebase_token"] ?? null,
  );

  Map<String, dynamic> toJson() => {
    "brand_name": brandName ?? null,
    "firebase_token": firebaseToken ?? null,
  };
}



