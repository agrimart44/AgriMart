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
