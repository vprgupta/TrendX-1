class ChatMessage {
  final String id;
  final String text;
  final String senderName;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    required this.isMe,
    required this.timestamp,
  });
}
