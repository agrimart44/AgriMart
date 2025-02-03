import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to send a message
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': _controller.text,
        'createdAt': Timestamp.now(),
        'userId': _auth.currentUser?.uid,  // Ensure messages are associated with the user
      });

      _controller.clear();  // Clear the text field after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/rukaass.jpg'), // Replace with real avatar URL
            ),
            SizedBox(width: 10),
            Text('Chat'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut();  // Sign out the user
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Display messages in a ListView
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,  // Show the most recent message at the bottom
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    bool isUserMessage = messages[index]['userId'] == _auth.currentUser?.uid;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isUserMessage) CircleAvatar(
                            backgroundImage: AssetImage('assets/images/avatart.jpg'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isUserMessage ? Colors.green : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  messages[index]['text'],
                                  style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  messages[index]['createdAt'].toDate().toString().substring(11, 16),
                                  style: TextStyle(
                                    color: isUserMessage ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUserMessage) CircleAvatar(
                            backgroundImage: AssetImage('assets/images/avatart.jpg'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Type a message...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
