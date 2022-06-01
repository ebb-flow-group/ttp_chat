import 'dart:convert';

BrandFirebaseTokenModel brandFirebaseTokenModelFromJson(String str) =>
    BrandFirebaseTokenModel.fromJson(json.decode(str));

String brandFirebaseTokenModelToJson(BrandFirebaseTokenModel data) => json.encode(data.toJson());

class BrandFirebaseTokenModel {
  BrandFirebaseTokenModel({this.brandFirebaseTokenList});

  List<BrandFirebaseTokenData>? brandFirebaseTokenList;

  factory BrandFirebaseTokenModel.fromJson(Map<String, dynamic> json) => BrandFirebaseTokenModel(
        brandFirebaseTokenList: json["brand_firebase_tokens"] == null
            ? []
            : List<BrandFirebaseTokenData>.from(
                json["brand_firebase_tokens"].map((x) => BrandFirebaseTokenData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "brand_firebase_tokens":
            brandFirebaseTokenList == null ? [] : List<dynamic>.from(brandFirebaseTokenList!.map((x) => x.toJson())),
      };
}

BrandFirebaseTokenData brandFirebaseTokenDataFromJson(String str) => BrandFirebaseTokenData.fromJson(json.decode(str));

String brandFirebaseTokenDataToJson(BrandFirebaseTokenData data) => json.encode(data.toJson());

class BrandFirebaseTokenData {
  BrandFirebaseTokenData({
    required this.brandId,
    required this.firebaseToken,
    this.brandName,
    this.brandUsername,
  });

  String? brandName;
  String? brandUsername;
  String? firebaseToken;
  int brandId;

  factory BrandFirebaseTokenData.fromJson(Map<String, dynamic> json) => BrandFirebaseTokenData(
        brandName: json["brand_name"],
        firebaseToken: json["firebase_token"],
        brandId: json["brand_id"],
        brandUsername: json["brand_username"],
      );

  Map<String, dynamic> toJson() => {
        "brand_name": brandName,
        "firebase_token": firebaseToken,
        "brand_id": brandId,
        "brand_username": brandUsername,
      };
}
