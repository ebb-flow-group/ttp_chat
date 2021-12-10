import 'dart:convert';


UserFirebaseTokenModel userFirebaseTokenModelFromJson(String str) =>
    UserFirebaseTokenModel.fromJson(json.decode(str));

String userFirebaseTokenModelToJson(UserFirebaseTokenModel data) => json.encode(data.toJson());

class UserFirebaseTokenModel {
  UserFirebaseTokenModel({
    this.firebaseToken,
  });

  String? firebaseToken;

  factory UserFirebaseTokenModel.fromJson(Map<String, dynamic> json) => UserFirebaseTokenModel(
      firebaseToken: json["firebase_token"] ?? null,
  );

  Map<String, dynamic> toJson() => {
  "firebase_token": firebaseToken ?? null,
};
}