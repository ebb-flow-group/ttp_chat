import 'dart:convert';

ErrorMessage errorMessageFromJson(String str) => ErrorMessage.fromJson(json.decode(str));

String errorMessageToJson(ErrorMessage data) => json.encode(data.toJson());

class ErrorMessage {
  ErrorMessage({
    this.detail,
    this.code,
    this.messages,
    this.username,
    this.email,
  });

  String? detail;
  String? code;
  List<Message>? messages;
  List<String>? username;
  List<String>? email;

  factory ErrorMessage.fromJson(Map<String, dynamic> json) => ErrorMessage(
        detail: json["detail"],
        code: json["code"],
        messages:
            json["messages"] == null ? null : List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
        username: json["username"] == null ? null : List<String>.from(json["username"].map((x) => x)),
        email: json["email"] == null ? null : List<String>.from(json["email"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "detail": detail,
        "code": code,
        "messages": messages == null ? null : List<dynamic>.from(messages!.map((x) => x.toJson())),
        "username": username == null ? null : List<dynamic>.from(username!.map((x) => x)),
        "email": email == null ? null : List<dynamic>.from(email!.map((x) => x)),
      };
}

class Message {
  Message({
    this.tokenClass,
    this.tokenType,
    this.message,
  });

  String? tokenClass;
  String? tokenType;
  String? message;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        tokenClass: json["token_class"],
        tokenType: json["token_type"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "token_class": tokenClass,
        "token_type": tokenType,
        "message": message,
      };
}
