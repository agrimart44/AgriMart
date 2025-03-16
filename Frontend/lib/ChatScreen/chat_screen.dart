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
