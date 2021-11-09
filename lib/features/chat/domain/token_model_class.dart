class TokenModelClass{
  String? kind, idToken, refreshToken, expiresIn;
  bool? isNewUser;

  TokenModelClass.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    idToken = json['idToken'];
    refreshToken = json['refreshToken'];
    expiresIn = json['expiresIn'];
    isNewUser = json['isNewUser'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kind'] = kind;
    data['idToken'] = idToken;
    data['refreshToken'] = refreshToken;
    data['expiresIn'] = expiresIn;
    data['isNewUser'] = isNewUser;

    return data;
  }
}