// To parse this JSON data, do
//
//     final noteModel = noteModelFromJson(jsonString);

import 'dart:convert';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
  String? noteId; // Changed to String for Firestore document ID
  String? userId; // User ID for associating notes with users
  String title;
  String content;
  String createdAt;
  String updatedAt;
  bool pinned;

  NoteModel({
    this.noteId,
    this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.pinned,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final pinnedFromJson = json["pinned"];
    var pinnedValue = pinnedFromJson;

    if (pinnedFromJson is int) {
      pinnedValue = pinnedFromJson == 1;
    } else if (pinnedFromJson is bool) {
      pinnedValue = pinnedFromJson;
    } else {
      pinnedValue = false;
    }

    return NoteModel(
      noteId: json["note_id"],
      userId: json["user_id"],
      title: json["title"] ?? '',
      content: json["content"] ?? '',
      createdAt: json["created_at"] ?? DateTime.now().toIso8601String(),
      updatedAt: json["updated_at"] ?? DateTime.now().toIso8601String(),
      pinned: pinnedValue,
    );
  }

  // For Firestore - doesn't convert pinned to int
  Map<String, dynamic> toJson() {
    return {
      "note_id": noteId,
      "user_id": userId,
      "title": title,
      "content": content,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "pinned": pinned,
    };
  }

  // For SQLite - converts pinned to int
  Map<String, dynamic> toJsonSQLite() {
    final pinnedConverted = pinned ? 1 : 0;

    return {
      "note_id": noteId,
      "user_id": userId,
      "title": title,
      "content": content,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "pinned": pinnedConverted,
    };
  }
}
