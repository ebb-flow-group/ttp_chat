import 'dart:convert';


BrandFirebaseTokenModel brandFirebaseTokenModelFromJson(String str) =>
    BrandFirebaseTokenModel.fromJson(json.decode(str));

String brandFirebaseTokenModelToJson(BrandFirebaseTokenModel data) => json.encode(data.toJson());

class BrandFirebaseTokenModel {
  BrandFirebaseTokenModel({
    this.brandFirebaseTokenList
  });

  List<BrandFirebaseTokenData>? brandFirebaseTokenList;

  factory BrandFirebaseTokenModel.fromJson(Map<String, dynamic> json) => BrandFirebaseTokenModel(
      brandFirebaseTokenList: json["brand_firebase_tokens"] == null
      ? []
      : List<BrandFirebaseTokenData>.from(
  json["brand_firebase_tokens"].map((x) => BrandFirebaseTokenData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
  "brand_firebase_tokens": brandFirebaseTokenList == null
  ? []
      : List<dynamic>.from(brandFirebaseTokenList!.map((x) => x.toJson())),
};
}

BrandFirebaseTokenData brandFirebaseTokenDataFromJson(String str) =>
    BrandFirebaseTokenData.fromJson(json.decode(str));

String brandFirebaseTokenDataToJson(BrandFirebaseTokenData data) => json.encode(data.toJson());

class BrandFirebaseTokenData {
  BrandFirebaseTokenData({
    this.brandName,
    this.firebaseToken,
  });

  String? brandName;
  String? firebaseToken;

  factory BrandFirebaseTokenData.fromJson(Map<String, dynamic> json) => BrandFirebaseTokenData(
    brandName: json["brand_name"] ?? null,
    firebaseToken: json["firebase_token"] ?? null,
  );

  Map<String, dynamic> toJson() => {
    "brand_name": brandName ?? null,
    "firebase_token": firebaseToken ?? null,
  };
}