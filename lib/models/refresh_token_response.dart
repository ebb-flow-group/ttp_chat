class RefreshTokenResponse {
  String? access;
  int? accessTokenExpiry;

  RefreshTokenResponse({this.access, this.accessTokenExpiry});

  RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    access = json['access'];
    accessTokenExpiry = json['access_token_expiry'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access'] = access;
    data['access_token_expiry'] = accessTokenExpiry;
    return data;
  }
}
