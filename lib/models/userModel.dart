
import 'dart:convert';


class UserModel {
  String? name;
  bool? isOnline;
  String? id;
  String? email;

  UserModel({
     this.name,
     this.isOnline,
     this.id,
     this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json["name"]??"",
    isOnline: json["isOnline"]??false,
    id: json["id"]??"",
    email: json["email"]??"",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "isOnline": isOnline,
    "id": id,
    "email": email,
  };
}
