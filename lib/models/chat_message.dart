class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime dateTime;
  final bool isRead;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.dateTime,
    this.isRead = false,
    this.imageUrl,
  });

  ChatMessage copyWith({
    bool? isRead,
  }) {
    return ChatMessage(
      id: this.id,
      sessionId: this.sessionId,
      senderId: this.senderId,
      senderName: this.senderName,
      text: this.text,
      dateTime: this.dateTime,
      isRead: isRead ?? this.isRead,
      imageUrl: this.imageUrl,
    );
  }
}
