import 'package:flutter/material.dart';
import '../../../../core/ui/glass_container.dart';
import '../model/chat_message.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  final String trendTitle;
  final String trendPlatform;

  const ChatScreen({
    super.key, 
    required this.trendTitle,
    required this.trendPlatform,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMockMessages();
  }

  void _loadMockMessages() {
    final List<String> mockComments = [
      "This is totally wild! 🤯",
      "I noticed this trending yesterday too.",
      "Does anyone have more context on why this happened?",
      "Typical ${widget.trendPlatform} moment lol",
      "I actually sort of agree with the main point.",
      "Who else is here from the notification? 🙋‍♂️",
    ];

    final random = Random();
    for (int i = 0; i < 5; i++) {
      _messages.add(ChatMessage(
        id: DateTime.now().subtract(Duration(minutes: (5-i)*10)).toString(),
        text: mockComments[random.nextInt(mockComments.length)],
        senderName: "User${random.nextInt(1000)}",
        isMe: false,
        timestamp: DateTime.now().subtract(Duration(minutes: (5-i)*10)),
      ));
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: _controller.text,
      senderName: "You",
      isMe: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
      _controller.clear();
      _isTyping = true; // Simulate others typing
    });

    _scrollToBottom();

    // Simulate reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            id: DateTime.now().toString(),
            text: "Totally! That's a good point.",
            senderName: "TrendWatcher",
            isMe: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAISummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            const SizedBox(width: 8),
            const Text("AI Mood Summary"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Discussion Analysis:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              "People are generally excited and curious about this trend. There is high engagement with a mix of surprise and agreement. Key sentiment is Positive (85%).",
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(value: 0.85, color: Colors.green, backgroundColor: Colors.grey),
            const SizedBox(height: 4),
            const Text("Positivity Score", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trendPlatform, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
            Text("Trend Chat", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showAISummary,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                  SizedBox(width: 4),
                  Text("AI Summary", style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!msg.isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.primaries[msg.senderName.hashCode % Colors.primaries.length],
                              child: Text(msg.senderName[0], style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: msg.isMe 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: msg.isMe ? const Radius.circular(20) : Radius.zero,
                                  bottomRight: msg.isMe ? Radius.zero : const Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!msg.isMe)
                                    Text(
                                      msg.senderName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                      ),
                                    ),
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: msg.isMe 
                                          ? Theme.of(context).colorScheme.onPrimary 
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Typing indicator
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 40, bottom: 8),
                  child: Text(
                    "Someone is typing...",
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),

              // Input Field
              GlassContainer(
                blur: 10,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Join the discussion...",
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _sendMessage,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(Icons.send, size: 18, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
