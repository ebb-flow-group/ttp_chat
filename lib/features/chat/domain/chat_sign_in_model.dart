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
    this.userData,
    this.brandFirebaseTokenList
  });

  String? refresh;
  String? access;
  String? firebaseToken;
  int? accessTokenExpiry;
  UserData? userData;
  List<BrandChatFirebaseTokenResponse>? brandFirebaseTokenList;

  factory ChatSignInModel.fromJson(Map<String, dynamic> json) => ChatSignInModel(
    refresh: json["refresh"] ?? null,
    access: json["access"] ?? null,
    firebaseToken: json["firebase_token"] ?? null,
    accessTokenExpiry: json["access_token_expiry"] ?? null,
    userData: json["user_data"] == null
        ? null
        : UserData.fromJson(json["user_data"]),
    brandFirebaseTokenList: json["brand_firebase_tokens"] == null
        ? []
        : List<BrandChatFirebaseTokenResponse>.from(
        json["brand_firebase_tokens"].map((x) => BrandChatFirebaseTokenResponse.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "refresh": refresh ?? null,
    "access": access ?? null,
    "firebase_token": firebaseToken ?? null,
    "access_token_expiry": accessTokenExpiry ?? null,
    "user_data": userData == null ? null : userData!.toJson(),
    "brand_firebase_tokens": brandFirebaseTokenList == null
        ? []
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

class UserData {
  UserData({
    this.id,
    this.phoneNumber,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.usernameSet,
    this.passwordSet,
  });

  final int? id;
  final String? phoneNumber;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool? usernameSet;
  final bool? passwordSet;

  UserData copyWith({
    int? id,
    String? phoneNumber,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    bool? usernameSet,
    bool? passwordSet,
  }) {
    return UserData(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      usernameSet: usernameSet ?? this.usernameSet,
      passwordSet: passwordSet ?? this.passwordSet,
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"] ?? null,
    phoneNumber: json["phone_number"] ?? null,
    username: json["username"] ?? null,
    firstName: json["first_name"] ?? null,
    lastName: json["last_name"] ?? null,
    email: json["email"] ?? null,
    usernameSet: json["username_set"] ?? null,
    passwordSet: json["password_set"] ?? null,
  );

  Map<String, dynamic> toJson() => {
    "id": id ?? null,
    "phone_number": phoneNumber ?? null,
    "username": username ?? null,
    "first_name": firstName ?? null,
    "last_name": lastName ?? null,
    "email": email ?? null,
    "username_set": usernameSet ?? null,
    "password_set": passwordSet ?? null,
  };
}



