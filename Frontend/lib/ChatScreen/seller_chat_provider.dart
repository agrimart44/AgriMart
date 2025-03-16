import 'package:flutter/material.dart';
import 'package:namer_app/ChatScreen/chat_service.dart';

class SellerChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  SellerChatProvider() : _chatService = ChatService('xqww9xknukff');
  
  ChatService get chatService => _chatService;
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    notifyListeners();
    
    try {
      // Try to auto-connect with saved credentials
      final connected = await _chatService.autoConnect();
      
      if (!connected) {
        // If auto-connect fails, we'll need manual login later
        print("Auto-connect failed. Manual login required.");
      }
      
      _isInitialized = true;
    } catch (e) {
      print("Error initializing chat service: $e");
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }