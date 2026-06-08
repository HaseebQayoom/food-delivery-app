class ChatMessageModel {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime sentAt;
  final List<String>? quickReplies; // only on bot messages

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.sentAt,
    this.quickReplies,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isFromUser: json['is_from_user'] as bool,
      sentAt: DateTime.parse(json['sent_at'] as String),
      quickReplies: (json['quick_replies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'is_from_user': isFromUser,
        'sent_at': sentAt.toIso8601String(),
        'quick_replies': quickReplies,
      };

  ChatMessageModel copyWith({
    String? id,
    String? text,
    bool? isFromUser,
    DateTime? sentAt,
    List<String>? quickReplies,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isFromUser: isFromUser ?? this.isFromUser,
      sentAt: sentAt ?? this.sentAt,
      quickReplies: quickReplies ?? this.quickReplies,
    );
  }
}
