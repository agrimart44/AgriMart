import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/ChatScreen/chat_screen.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: dummyChats.length,
                itemBuilder: (context, index) {
                  final chat = dummyChats[index];
                  return ChatListItem(chat: chat);
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
              //Link to the Chat Screen
              builder: (context) => const ChatScreen(),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          backgroundImage: AssetImage(chat.profileImage),
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

// Dummy Data Model
class Chat {
  final String name;
  final String lastMessage;
  final String profileImage;
  final DateTime timestamp;
  final int unreadCount;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.profileImage,
    required this.timestamp,
    this.unreadCount = 0,
  });
}

// Dummy Data
final List<Chat> dummyChats = [
  Chat(
    name: 'Silva',
    lastMessage: 'Hello, how are you?',
    profileImage: 'lib/assets/rukaass.jpg',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    unreadCount: 2,
  ),
  Chat(
    name: 'Danutha',
    lastMessage: 'Can we meet tomorrow?',
    profileImage: 'lib/assets/rukaass.jpg',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Chat(
    name: 'Sahan',
    lastMessage: 'I sent you the details.',
    profileImage: 'lib/assets/rukaass.jpg',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 1,
  ),
  Chat(
    name: 'Gokul',
    lastMessage: 'Thanks for the help!',
    profileImage: 'lib/assets/rukaass.jpg',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
  ),
];