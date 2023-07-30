class ChatModel {
  bool isSeen;
  String receiverId;
  String senderId;
  String text;
  DateTime timestamp;
  String image;
  DateTime updatedAt;

  ChatModel({
    required this.isSeen,
    required this.receiverId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.image,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'isSeen': isSeen,
      'receiverId': receiverId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'updatedAt':updatedAt.toIso8601String(),
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      isSeen: json['isSeen'],
      receiverId: json['receiverId'],
      senderId: json['senderId'],
      text: json['text'],
      timestamp: json['timestamp'].toDate(),
        updatedAt:json['updatedAt'].toDate(),
      image: json['image']
    );
  }
}
