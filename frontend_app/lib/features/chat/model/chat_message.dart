class ChatMessage {
  final String id;
  final String trendId;
  final String text;
  final String senderName;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.trendId,
    required this.text,
    required this.senderName,
    required this.timestamp,
    required this.isMe, // This remains frontend-only to control UI
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserName) {
    return ChatMessage(
      id: json['_id'] ?? DateTime.now().toString(),
      trendId: json['trendId'] ?? '',
      text: json['text'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      isMe: json['senderName'] == currentUserName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trendId': trendId,
      'text': text,
      'senderName': senderName,
    };
  }
}
