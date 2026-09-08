class ChatMessage {
  final String id;
  final String requestId;
  final String senderId;
  final String text;
  final bool isQuickMessage;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.text,
    required this.isQuickMessage,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        requestId: json['requestId'] as String,
        senderId: json['senderId'] as String,
        text: json['text'] as String,
        isQuickMessage: json['isQuickMessage'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
