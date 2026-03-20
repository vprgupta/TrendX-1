import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/ui/glass_container.dart';
import '../../../../core/services/socket_service.dart';
import '../model/chat_message.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  final String trendTitle;
  final String trendPlatform;
  final String trendId;

  const ChatScreen({
    super.key, 
    required this.trendTitle,
    required this.trendPlatform,
    required this.trendId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService();
  
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late String _currentUserName;

  @override
  void initState() {
    super.initState();
    _currentUserName = "User${Random().nextInt(9000) + 1000}"; // Anonymous User
    
    // Wire up Socket
    _socketService.addChatListener(_onReceiveMessage);
    _socketService.addHistoryListener(_onReceiveHistory);
    _socketService.addTypingListener(_onTypingStatus);

    _socketService.connect();
    _socketService.joinChat(widget.trendId, _currentUserName);
  }

  @override
  void dispose() {
    _socketService.leaveChat(widget.trendId);
    _socketService.removeChatListener(_onReceiveMessage);
    _socketService.removeHistoryListener(_onReceiveHistory);
    _socketService.removeTypingListener(_onTypingStatus);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onReceiveMessage(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        _messages.add(ChatMessage.fromJson(data, _currentUserName));
      });
      _scrollToBottom();
    }
  }

  void _onReceiveHistory(List<dynamic> historyData) {
    if (mounted) {
      setState(() {
        _messages.clear();
        for (var item in historyData) {
          _messages.add(ChatMessage.fromJson(item, _currentUserName));
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animate: false);
      });
    }
  }

  void _onTypingStatus(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        // Exclude ourselves from the typing list
        List<dynamic> users = data['users'] ?? [];
        users.removeWhere((u) => u == _currentUserName);
        _isTyping = users.isNotEmpty;
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _socketService.sendMessage(widget.trendId, text, _currentUserName);
    _socketService.stopTyping(widget.trendId, _currentUserName);
    
    setState(() {
      // Optimistic update
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        trendId: widget.trendId,
        text: text,
        senderName: _currentUserName,
        timestamp: DateTime.now(),
        isMe: true,
      ));
      _controller.clear();
    });

    _scrollToBottom();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
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
            const Icon(Icons.auto_awesome, color: Colors.purple),
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
        ).animate().fade().slideY(begin: 0.2),
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
            Text(widget.trendPlatform, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
            Text(widget.trendTitle, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showAISummary,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.withOpacity(0.5)),
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
          image: DecorationImage(
            image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), // Subtle pattern background
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.surface.withOpacity(0.05), BlendMode.dstATop),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final showTail = index == _messages.length - 1 || _messages[index + 1].senderName != msg.senderName;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: showTail ? 16.0 : 4.0),
                      child: Row(
                        mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!msg.isMe) ...[
                            if (showTail)
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.primaries[msg.senderName.hashCode % Colors.primaries.length],
                                child: Text(msg.senderName[msg.senderName.length - 1].toUpperCase(), 
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            else
                              const SizedBox(width: 28),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: msg.isMe 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: (!msg.isMe && showTail) ? Radius.zero : const Radius.circular(20),
                                  bottomRight: (msg.isMe && showTail) ? Radius.zero : const Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!msg.isMe && showTail)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        msg.senderName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.primaries[msg.senderName.hashCode % Colors.primaries.length],
                                        ),
                                      ),
                                    ),
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.3,
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
                    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOutQuad);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typing indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 48, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      "Someone is typing",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 4),
                    const SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
              ).animate().fade(),

            // Input Field
            GlassContainer(
              blur: 15,
              opacity: 0.85,
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: 5,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                _socketService.startTyping(widget.trendId, _currentUserName);
                              } else {
                                _socketService.stopTyping(widget.trendId, _currentUserName);
                              }
                            },
                            onSubmitted: (_) => _sendMessage(),
                            decoration: const InputDecoration(
                              hintText: "Join the discussion...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        ),
                        child: IconButton(
                          onPressed: _sendMessage,
                          icon: Icon(Icons.send_rounded, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .shimmer(duration: 2.seconds, color: Colors.white24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
