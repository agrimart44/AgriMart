import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:namer_app/ChatScreen/chat_service.dart';
import 'package:stream_chat/stream_chat.dart';

// Define the enum if it's not available in your current package
enum MessageSendingStatus { SENDING, SENT, DELIVERED, FAILED }

class ChatScreen extends StatefulWidget {
  final String channelId;
  final String?
      cropId; // Optional parameter to identify the crop being discussed

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