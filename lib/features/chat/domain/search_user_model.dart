// ignore_for_file: prefer_collection_literals

class SearchUserModel {
  final int count;
  final List<Users> users;

  SearchUserModel({this.count = 0, this.users = const []});

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      count: json['count'] ?? 0,
      users: ((json['results'] ?? []) as List<dynamic>).map((e) => Users.fromJson(e)).toList(),
    );
  }
}

enum UserType {
  user,
  brand,
}

class Users {
  int? id;
  String? uid;
  String? firstName;
  String? lastName;
  String? imgUrl;
  UserType? type;

  Users({this.id, this.uid, this.firstName, this.lastName, this.imgUrl, this.type});

  Users.fromJson(Map<String, dynamic> json) {
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
