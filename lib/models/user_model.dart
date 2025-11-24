// To parse this JSON data, do
//
//     final userNote = userNoteFromJson(jsonString);

import 'dart:convert';

UserModel userNoteFromJson(String str) => UserModel.fromJson(json.decode(str));

String userNoteToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String userId;
  String userName;
  String userEmail;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json["user_id"],
    userName: json["user_name"],
    userEmail: json["user_email"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "user_name": userName,
    "user_email": userEmail,
  };
}