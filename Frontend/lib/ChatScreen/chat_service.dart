import 'package:flutter/material.dart';
import 'package:namer_app/ChatScreen/chat_screen.dart';
import 'package:namer_app/buyer_view_page/crop.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final StreamChatClient _client;
  static const String _userIdKey = 'stream_user_id';
  static const String _userTokenKey = 'stream_user_token';

  // Initialize the client with a dynamic API Key
  ChatService(String apiKey)
      : _client = StreamChatClient(
          apiKey,
          logLevel: Level.INFO,
        );

  // Check if user is connected
  bool isConnected() {
    return _client.state.currentUser != null;
  }

  // Save user credentials for auto-reconnect
  Future<void> _saveUserCredentials(String userId, String userToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userTokenKey, userToken);
  }

  // Get saved user credentials
  Future<Map<String, String?>> _getSavedUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'userToken': prefs.getString(_userTokenKey),
    };
  }

  // Method to connect the user with Stream using the JWT token
  Future<void> connectUser(String userId, String userToken) async {
    try {
      // Don't reconnect if already connected with same user
      if (_client.state.currentUser?.id == userId) {
        print("User already connected");
        return;
      }

      final user = User(id: userId);
      await _client.connectUser(
        user,
        userToken, // The JWT token
      );
      await _saveUserCredentials(userId, userToken);
      print("User connected to Stream successfully!");
    } catch (e) {
      print("Error connecting user to Stream: $e");
      throw Exception("Failed to connect user: $e");
    }
  }

  // Method to auto-connect with saved credentials
  Future<bool> autoConnect() async {
    try {
      final credentials = await _getSavedUserCredentials();
      final userId = credentials['userId'];
      final userToken = credentials['userToken'];

      if (userId != null && userToken != null) {
        await connectUser(userId, userToken);
        return true;
      }
      return false;
    } catch (e) {
      print("Auto-connect failed: $e");
      return false;
    }
  }

  // Method to disconnect the user
  Future<void> disconnectUser() async {
    try {
      await _client.disconnectUser();
      print("User disconnected from Stream");
    } catch (e) {
      print("Error disconnecting user from Stream: $e");
      throw Exception("Failed to disconnect user: $e");
    }
  }

  // Method to get or create a channel
  Channel getChannel(String channelId) {
    return _client.channel(
      'messaging', // Channel type (can be 'messaging', 'livestream', etc.)
      id: channelId, // Channel ID
    );
  }

  // Method to initialize a channel
  Future<ChannelState> initializeChannel(String channelId) async {
    final channel = getChannel(channelId);
    return await channel.watch(); // Initialize and watch the channel
  }

  // Example of sending a message
  Future<SendMessageResponse> sendMessage(
      String channelId, String messageText) async {
    try {
      // Ensure user is connected first
      if (!isConnected()) {
        await autoConnect();
        if (!isConnected()) {
          throw Exception("Cannot send message: User not connected");
        }
      }

      final channel = getChannel(channelId);
      // Ensure channel is initialized
      await channel.watch();

      final message = Message(
        text: messageText,
      );
      final response = await channel.sendMessage(message);
      print("Message sent!");
      return response;
    } catch (e) {
      print("Error sending message: $e");
      throw Exception("Failed to send message: $e");
    }
  }

  // Fetch the list of chats (channels) from Stream
// Update this method in your ChatService class
Future<List<Chat>> fetchChatsFromStream() async {
  List<Chat> chatList = [];

  try {
    // Check if user is connected
    if (!isConnected()) {
      final connected = await autoConnect();
      if (!connected) return [];
    }

    final currentUserId = _client.state.currentUser!.id;
    final filter = Filter.and([
      Filter.equal('type', 'messaging'),
      Filter.in_('members', [currentUserId])
    ]);

    final response = await _client.queryChannels(
      filter: filter,
      messageLimit: 1,
      memberLimit: 10,
      paginationParams: PaginationParams(limit: 20),
    ).first;

    for (var channel in response) {
      // Default values
      String chatName = 'Unknown';
      String imageUrl = '';
      
      // First check if it's a named channel
      if (channel.extraData.containsKey('name') && 
          channel.extraData['name'] != null && 
          channel.extraData['name'] is String) {
        chatName = channel.extraData['name'] as String;
      } else {
        // If not a named channel, assume it's a direct message
        final otherMembers = channel.state?.members.where(
          (member) => member.user?.id != currentUserId
        ).toList();
        
        if (otherMembers != null && otherMembers.isNotEmpty) {
          final otherUser = otherMembers.first.user;
          // Make sure we have a valid name
          if (otherUser != null && otherUser.name.isNotEmpty) {
            chatName = otherUser.name;
          } else if (otherUser != null) {
            // Fallback to a cleaner display name
            chatName = "User ${otherUser.id.substring(0, 8)}";
          }
          
          // Get profile image if available
          if (otherUser != null && otherUser.image != null && otherUser.image!.isNotEmpty) {
            imageUrl = otherUser.image!;
          }
        }
      }

      chatList.add(Chat(
        id: channel.id ?? '',
        name: chatName,
        lastMessage: channel.state?.lastMessage?.text ?? 'No messages',
        profileImage: imageUrl.isNotEmpty ? imageUrl : 'lib/assets/default_avatar.png',
        timestamp: channel.state?.lastMessage?.createdAt ?? DateTime.now(),
        unreadCount: channel.state?.unreadCount ?? 0,
      ));
    }
  } catch (e) {
    print("Error fetching chats from Stream: $e");
    throw Exception("Failed to fetch chats: $e");
  }

  return chatList;
}

  // Listen to real-time message updates
  Stream<List<Message>> listenForMessages(String channelId) {
    final channel = getChannel(channelId);

    // Start watching the channel if not already
    channel.watch().catchError((error) {
      print("Error watching channel: $error");
      return ChannelState(); // Return empty state instead of null
    });

    return channel.state!.messagesStream.map((event) => event);
  }

  // Listen to real-time channel updates
  Stream<List<Chat>> listenForChannelUpdates() {
    // Check connection and try to auto-connect in a non-blocking way
    if (!isConnected()) {
      autoConnect().then((success) {
        if (!success) {
          print("Failed to auto-connect for channel updates");
        }
      });
      return Stream.value([]);
    }

    final currentUserId = _client.state.currentUser!.id;
    final filter = Filter.and([
      Filter.equal('type', 'messaging'),
      Filter.in_('members',
          [currentUserId]) // Changed from Filter.contains to Filter.in_
    ]);

    return _client
        .queryChannels(
      filter: filter,
      messageLimit: 1,
      memberLimit: 10,
      paginationParams: PaginationParams(limit: 20),
    )
        .map((response) {
      List<Chat> chatList = [];
      for (var channel in response) {
        String chatName = channel.extraData['name'] as String? ?? 'Unknown';
        String imageUrl = '';
        final members = channel.state?.members;
        if (members != null && members.length == 2) {
          final otherMember = members.firstWhere(
            (member) => member.user?.id != currentUserId,
            orElse: () => members.first,
          );
          chatName =
              otherMember.user?.name ?? otherMember.user?.id ?? 'Unknown';
          imageUrl = otherMember.user?.image ?? '';
        }
        chatList.add(Chat(
          id: channel.id ?? '',
          name: chatName,
          lastMessage: channel.state?.lastMessage?.text ?? 'No messages',
          profileImage:
              imageUrl.isNotEmpty ? imageUrl : 'assets/default_avatar.png',
          timestamp: channel.state?.lastMessage?.createdAt ?? DateTime.now(),
          unreadCount: channel.state?.unreadCount ?? 0,
        ));
      }
      return chatList;
    });
  }

  // Add these methods to your existing ChatService class

// Method to create or join a chat with a seller based on crop
  Future<Channel> createOrJoinSellerChat(
      String cropId, String sellerId, String sellerName) async {
    try {
      // Ensure user is connected
      if (!isConnected()) {
        await autoConnect();
        if (!isConnected()) {
          throw Exception("Cannot create chat: User not connected");
        }
      }

      // Create a unique channel ID based on crop and seller IDs, ensuring it is under 64 characters
      final currentUserId = _client.state.currentUser!.id;

      // Create a shortened but unique channel ID to stay under 64 characters
      final shortCropId =
          cropId.length > 10 ? cropId.substring(cropId.length - 10) : cropId;
      final shortBuyerId = currentUserId.length > 10
          ? currentUserId.substring(0, 10)
          : currentUserId;
      final shortSellerId =
          sellerId.length > 10 ? sellerId.substring(0, 10) : sellerId;

      // Combine shortened IDs to create a unique channel ID
      String channelId = 'c_${shortCropId}_${shortBuyerId}_$shortSellerId';

      // Ensure the channel ID is under the 64 character limit
      if (channelId.length > 64) {
        channelId = channelId.substring(0, 64); // Truncate to 64 characters
      }

      // Log the channel ID length for debugging
      print('Channel ID: $channelId (length: ${channelId.length})');

      // Try to get an existing channel or create a new one
      final channel = _client.channel(
        'messaging',
        id: channelId,
        extraData: {
          'members': [currentUserId, sellerId],
          'crop_id': cropId,
          'name': 'Chat about $sellerName\'s crop'
        },
      );

      // Initialize the channel
      await channel.watch();

      // Send a regular user message to indicate the start of conversation if new
      if (channel.state?.messages.isEmpty ?? true) {
        await channel.sendMessage(
          Message(
            text:
                'Chat started about crop #$cropId', // This is a user message, not a system message
            user:
                User(id: currentUserId), // The current user sends this message
          ),
        );
      }

      return channel;
    } catch (e) {
      print("Error creating or joining seller chat: $e");
      throw Exception("Failed to create or join chat: $e");
    }
  }

// Method to navigate to the chat screen with a seller
  Future<void> openSellerChat(BuildContext context, Crop crop) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create or join the chat channel
      final channel = await createOrJoinSellerChat(
        crop.id,
        crop.sellerId,
        crop.farmerName,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(channelId: channel.id!),
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Chat Model (Class)
class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final String profileImage;
  final DateTime timestamp;
  final int unreadCount;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.profileImage,
    required this.timestamp,
    this.unreadCount = 0,
  });
}
