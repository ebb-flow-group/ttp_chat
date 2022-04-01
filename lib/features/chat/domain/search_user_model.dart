// ignore_for_file: prefer_collection_literals

class SearchUserModel {
  List<Brands>? brands;
  List<Users>? users;

  SearchUserModel({this.brands = const [], this.users = const []});

  SearchUserModel.fromJson(Map<String, dynamic> json) {
    if (json['brands'] != null) {
      brands = [];
      json['brands'].forEach((v) {
        brands!.add(Brands.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = [];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (brands != null) {
      data['brands'] = brands!.map((v) => v.toJson()).toList();
    }
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Brands {
  int? id;
  String? name;
  String? username;
  String? logo;

  Brands({this.id, this.name, this.username});

  Brands.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    logo = json['logo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['logo'] = logo;
    return data;
  }
}

class Users {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? avatar;
  String? phoneNumber;

  Users({this.id, this.firstName, this.lastName, this.email, this.phoneNumber});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['avatar'] = avatar;
    return data;
  }
}
