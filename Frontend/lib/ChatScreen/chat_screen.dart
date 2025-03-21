import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat/stream_chat.dart';

import 'chat_service.dart';

// Define the enum if it's not available in your current package
enum MessageSendingStatus { SENDING, SENT, DELIVERED, FAILED }

class ChatScreen extends StatefulWidget {
  final String channelId;
  final String? cropId;

  const ChatScreen({
    super.key,
    required this.channelId,
    this.cropId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatService _chatService;
  late Channel _channel;
  late Stream<List<Message>> _messageStream;
  bool _isLoading = true;
  String _chatTitle = 'Chat';
  String? _chatSubtitle;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Initialize ChatService with your Stream API key
      _chatService = ChatService('xqww9xknukff');

      // Auto-connect if not already connected
      if (!_chatService.isConnected()) {
        await _chatService.autoConnect();
      }

      // Get and initialize the channel
      _channel = _chatService.getChannel(widget.channelId);
      final channelState = await _channel.watch();

      // Set up the message stream
      _messageStream = _channel.state!.messagesStream;

      // Mark the channel as read
      _markChannelAsRead();

      // Get chat title from channel extraData or members
      _setChatTitle();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error initializing chat: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to set the chat title based on channel data
  void _setChatTitle() {
    try {
      // Try to get chat title from extraData
      final channelName = _channel.extraData['name'] as String?;
      if (channelName != null) {
        _chatTitle = channelName;
      } else {
        // If no name, check if it's a direct chat with another user
        final currentUserId = _channel.client.state.currentUser!.id;
        final members = _channel.state?.members ?? [];

        if (members.length == 2) {
          // Find the other member
          final otherMember = members.firstWhere(
            (member) => member.user?.id != currentUserId,
            orElse: () => members.first,
          );

          if (otherMember.user != null) {
            _chatTitle = otherMember.user!.name ?? 'Chat with seller';
            _chatSubtitle =
                otherMember.user!.extraData['role'] as String? ?? 'Seller';
          }
        }
      }

      // Get crop ID from channel extraData if available
      final cropId = _channel.extraData['crop_id'] as String? ?? widget.cropId;
      if (cropId != null) {
        _chatSubtitle = 'About Crop #$cropId';
      }
    } catch (e) {
      print("Error setting chat title: $e");
    }
  }

  void _markChannelAsRead() {
    _channel.markRead();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(widget.channelId, _messageController.text);
      _messageController.clear();
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/first_page_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/first_page_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _chatTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_chatSubtitle != null)
                            Text(
                              _chatSubtitle!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    StreamBuilder<int>(
                      stream: _channel.state!.unreadCountStream,
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        return unreadCount > 0
                            ? CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 12,
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _messageStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.reversed.toList();

                  // Schedule scroll to bottom after build
                  _scrollToBottom();

                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final currentUserId =
                          _channel.client.state.currentUser?.id;
                      return _MessageBubble(
                        message: message,
                        isMe: message.user?.id == currentUserId,
                        channel: _channel,
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Channel channel;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF4A4A7B) : Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text ?? '',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm')
                          .format(message.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: isMe ? Colors.white70 : Colors.black45,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    // Check if the message has been read by accessing the read state from the channel
    final readsCount = channel.state?.read
            .where((read) =>
                    read.user.id != message.user?.id && // Not the sender
                    read.lastRead.isAfter(message.createdAt ??
                        DateTime.now()) // Read after message was sent
                )
            .length ??
        0;

    // Check if the message is being handled properly
    if (readsCount > 0) {
      return const Icon(
        Icons.done_all,
        size: 12,
        color: Colors.blue,
      );
    }

    // Message is sent (using only the state property which is available)
    else if (message.state == MessageState.sent) {
      return const Icon(
        Icons.done,
        size: 12,
        color: Colors.white70,
      );
    }

    // Message is still sending or failed
    else {
      return const Icon(
        Icons.access_time,
        size: 12,
        color: Colors.white70,
      );
    }
  }
}
