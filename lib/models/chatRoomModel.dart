import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  String? chatroomId;
  String? lastMessage;
  Timestamp? lastMessageTimestamp;
  List<String>? participants;
  int? unreadCountOfUser1;
  int? unreadCountOfUser2;
  Timestamp? user1LastSeen;
  Timestamp? user2LastSeen;
  String? user1Name;
  String? user2Name;

  ChatRoom({
    this.chatroomId,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.participants,
    this.unreadCountOfUser1,
    this.unreadCountOfUser2,
    this.user1LastSeen,
    this.user2LastSeen,
    this.user1Name,
    this.user2Name
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {

    Timestamp parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp;
      } else if (timestamp is String && timestamp.isNotEmpty) {
        return Timestamp.fromDate(DateTime.parse(timestamp));
      }
      return Timestamp.now();
    }
    return ChatRoom(
      chatroomId: json["chatroomId"] ??"",
      lastMessage: json["lastMessage"]??"",
      lastMessageTimestamp: parseTimestamp(json["lastMessageTimestamp"]),
      participants:  (json["participants"] != null && json["participants"] is List)? List<String>.from(json["participants"] as List<dynamic>):['',''],
      unreadCountOfUser1: json["unreadCountOfUser1"] ??0,
      unreadCountOfUser2: json["unreadCountOfUser2"] ??0,
      user1LastSeen:parseTimestamp(json["user1LastSeen"]),
      user2LastSeen: parseTimestamp(json['user2LastSeen']),
      user1Name: json['user1Name']??"",
      user2Name: json['user2Name']??""
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chatroomId": chatroomId,
      "lastMessage": lastMessage,
      "lastMessageTimestamp": lastMessageTimestamp,
      "participants": participants,
      "unreadCountOfUser1": unreadCountOfUser1,
      "unreadCountOfUser2": unreadCountOfUser2,
      "user1LastSeen": user1LastSeen,
      "user2LastSeen": user2LastSeen,
      'user1Name':user1Name,
      'user2Name':user2Name
    };
  }
}
