
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';
import 'message_provider_page.dart';


class UserMessagesPage extends StatefulWidget {
  const UserMessagesPage({Key? key}) : super(key: key);

  @override
  _UserMessagesPageState createState() => _UserMessagesPageState();
}

class _UserMessagesPageState extends State<UserMessagesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;
  bool _isLoading = true;
  late ChatRepository _chatRepository;

  @override
  void initState() {
    super.initState();
    _chatRepository = ChatRepository();
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      // Get current user ID
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to see messages')),
        );
        Navigator.pop(context);
        return;
      }

      _userId = currentUser.uid;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Format timestamp to a readable format
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      // Today, show time only
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      // Within the last week, show day name
      return DateFormat('EEEE').format(timestamp);
    } else {
      // Older messages, show date
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Messages"),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Chat>>(
        stream: _chatRepository.getChatsForUser(_userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error fetching chats: ${snapshot.error}');
            return Center(child: Text('Error loading chats: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data ?? [];

          // Filter chats to only include those with at least one message
          final activeChats = chats.where((chat) => chat.lastMessage.isNotEmpty).toList();

          if (activeChats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When you message service providers, they\'ll appear here',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: activeChats.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Colors.grey,
              indent: 10,
              endIndent: 10,
            ),
            itemBuilder: (context, index) {
              final chat = activeChats[index];
              final time = _formatTimestamp(chat.lastMessageTime.toDate());

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('service provider').doc(chat.otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text('Loading...'),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  final username = userData?['name'] ?? 'Service Provider';
                  final profileImage = userData?['profileImage'] ?? '';
                  final providerPhone = userData?['phone'] ?? '';

                  return InkWell(
                    onTap: () async {
                      // Mark messages as read when chat is opened
                      await _chatRepository.markMessagesAsRead(chat.id, _userId);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            providerId: chat.otherUserId,
                            providerName: username,
                            providerImage: profileImage,
                            serviceId: chat.serviceId,
                            serviceName: chat.serviceName,
                            providerPhone: providerPhone,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : null,
                            child: profileImage.isEmpty
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        username,
                                        style: TextStyle(
                                          fontWeight:FontWeight.bold,

                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  chat.serviceName,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chat.lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: chat.unreadCount > 0
                                              ? Colors.green
                                              : Colors.grey[700],
                                          fontWeight: chat.unreadCount > 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (chat.unreadCount > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          chat.unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}