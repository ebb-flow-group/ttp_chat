// ignore_for_file: prefer_collection_literals

class SearchUserModel {
  final int count;
  final List<SearchUser> users;

  SearchUserModel({this.count = 0, this.users = const []});

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      count: json['count'] ?? 0,
      users: ((json['results'] ?? []) as List<dynamic>).map((e) => SearchUser.fromJson(e)).toList(),
    );
  }
}

enum UserType {
  user,
  brand,
}

class SearchUser {
  int? id;
  String? uid;
  String? firstName;
  String? lastName;
  String? imgUrl;
  UserType? type;

  SearchUser({this.id, this.uid, this.firstName, this.lastName, this.imgUrl, this.type});

  String get fullName {
    String name = "${firstName ?? ""} ${lastName ?? ""}".trim();
    return name.isEmpty ? "Guest" : name;
  }

  SearchUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['firebase_uuid'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    imgUrl = json['image_url'];
    type = json['type'] == 'user' ? UserType.user : UserType.brand;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['firebase_uuid'] = uid;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['image_url'] = imgUrl;
    data['type'] = type;
    return data;
  }
}
