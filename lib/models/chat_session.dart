class ChatSession {
  final String id;
  final List<String> memberIds;
  final String lastMessageText;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCountByUserId;

  ChatSession({
    required this.id,
    required this.memberIds,
    this.lastMessageText = '',
    required this.lastMessageTime,
    this.unreadCountByUserId = const {},
  });

  ChatSession copyWith({
    String? lastMessageText,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCountByUserId,
  }) {
    return ChatSession(
      id: this.id,
      memberIds: this.memberIds,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCountByUserId: unreadCountByUserId ?? this.unreadCountByUserId,
    );
  }
}
