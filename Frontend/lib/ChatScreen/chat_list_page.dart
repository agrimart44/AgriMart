import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/ChatScreen/chat_screen.dart';
import 'package:namer_app/ChatScreen/chat_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<Chat>> _chatListFuture; // To hold the dynamic list of chats
  late ChatService _chatService;

  @override
  void initState() {
    super.initState();

    // Initialize ChatService with your Stream API key
    _chatService = ChatService('xqww9xknukff'); // Replace with your actual API key

    // Fetch chats when the page loads
    _chatListFuture = _chatService.fetchChatsFromStream();
  }

  @override
  Widget build(BuildContext context) {
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
            // Custom App Bar
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Chats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Chat List
            Expanded(
              child: FutureBuilder<List<Chat>>(
                future: _chatListFuture, // Fetch chats using the future
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _chatListFuture = _chatService.fetchChatsFromStream(); // Retry fetching chats
                              });
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No chats available.'));
                  } else {
                    final chatList = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: chatList.length,
                      itemBuilder: (context, index) {
                        final chat = chatList[index];
                        return ChatListItem(chat: chat);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final Chat chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white.withOpacity(0.8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Link to the Chat Screen
              builder: (context) => ChatScreen(channelId: chat.id), // Pass the channel ID dynamically
            ),
          );
        },
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          backgroundImage: chat.profileImage.isNotEmpty
              ? NetworkImage(chat.profileImage)
              : AssetImage('lib/assets/default_avatar.png') as ImageProvider,
        ),
        title: Text(
          chat.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          chat.lastMessage,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('HH:mm').format(chat.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
