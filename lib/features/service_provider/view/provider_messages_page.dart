
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// import '../../../core/shared/services/image_service.dart';
// import '../../user/models/chat_message_model.dart';
// import '../../user/repositories/chat_repository.dart';
// import 'chat_with_client.dart';
//
//
// class ProviderMessagesPage extends StatefulWidget {
//   const ProviderMessagesPage({Key? key}) : super(key: key);
//
//   @override
//   _ProviderMessagesPageState createState() => _ProviderMessagesPageState();
// }
//
// class _ProviderMessagesPageState extends State<ProviderMessagesPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late String _providerId;
//   bool _isLoading = true;
//   late ChatRepository _chatRepository;
//   final ImageService _imageService = ImageService();
//
//   @override
//   void initState() {
//     super.initState();
//     _chatRepository = ChatRepository();
//     _initProvider();
//   }
//
//   Future<void> _initProvider() async {
//     try {
//       final User? currentUser = _auth.currentUser;
//       if (currentUser == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('You need to be logged in to see messages')),
//         );
//         Navigator.pop(context);
//         return;
//       }
//
//       _providerId = currentUser.uid;
//       setState(() => _isLoading = false);
//     } catch (e) {
//       print('Error initializing provider: $e');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   String _formatTimestamp(Timestamp timestamp) {
//     final DateTime messageTime = timestamp.toDate();
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final messageDate = DateTime(messageTime.year, messageTime.month, messageTime.day);
//
//     if (messageDate == today) {
//       return DateFormat('h:mm a').format(messageTime);
//     } else if (messageDate == yesterday) {
//       return 'Yesterday';
//     } else if (now.difference(messageTime).inDays < 7) {
//       return DateFormat('EEEE').format(messageTime);
//     } else {
//       return DateFormat('MMM d').format(messageTime);
//     }
//   }
//
//   Widget _buildProfileAvatar(String? profileImageUrl, String username) {
//     // Generate consistent color based on username
//     final colors = [
//       Colors.blue,
//       Colors.red,
//       Colors.green,
//       Colors.indigoAccent,
//       Colors.orange,
//       Colors.teal
//     ];
//     final color = colors[username.length % colors.length];
//     final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
//
//     if (profileImageUrl == null || profileImageUrl.isEmpty) {
//       return CircleAvatar(
//         radius: 28,
//         backgroundColor: color,
//         child: Text(
//           initial,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }
//
//     return CircleAvatar(
//       radius: 28,
//       backgroundImage: NetworkImage(profileImageUrl),
//       // Remove the child widget completely when there's a profile image
//     );
//   }
//
//   Widget _buildUnreadCountBadge(int unreadCount) {
//     return Container(
//       padding: const EdgeInsets.all(5),
//       decoration: const BoxDecoration(
//         color: Colors.green,
//         shape: BoxShape.circle,
//       ),
//       child: Text(
//         unreadCount.toString(),
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.chat_bubble_outline,
//             size: 80,
//             color: Colors.grey[300],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No messages yet',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               'When clients message you about your services, they\'ll appear here',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey[500],
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChatItem(Chat chat, String username, String? profileImageUrl, String clientPhone) {
//     final time = _formatTimestamp(chat.lastMessageTime);
//     final hasUnread = chat.unreadCount > 0;
//
//     return InkWell(
//       onTap: () async {
//         await _chatRepository.markMessagesAsRead(chat.id, _providerId);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MessageClientPage(
//               clientId: chat.otherUserId,
//               clientName: username,
//               clientImage: profileImageUrl ?? '',
//               serviceId: chat.serviceId,
//               serviceName: chat.serviceName,
//               clientPhone: clientPhone,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         decoration: BoxDecoration(
//           color: hasUnread ? Colors.green.withOpacity(0.05) : null,
//           border: Border(
//             bottom: BorderSide(
//               color: Colors.grey[200]!,
//               width: 0.5,
//             ),
//           ),
//         ),
//         child: Row(
//           children: [
//             _buildProfileAvatar(profileImageUrl, username),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           username,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Text(
//                         time,
//                         style: TextStyle(
//                           color: Colors.grey[500],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           chat.lastMessage,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: hasUnread ? Colors.green[700] : Colors.grey[700],
//                             fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                       if (hasUnread) ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: const BoxDecoration(
//                             color: Colors.green,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             chat.unreadCount.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xff0F3966),
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const AppBarTitle(text: "Messages"),
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pushNamed(context, '/serviceProviderHome'),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : StreamBuilder<List<Chat>>(
//         stream: _chatRepository.getChatsForUser(_providerId),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Error loading messages\n${snapshot.error}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final chats = snapshot.data ?? [];
//           if (chats.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.chat_bubble_outline,
//                     size: 80,
//                     color: Colors.grey[300],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No messages yet',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 40),
//                     child: Text(
//                       'When clients message you about your services, they\'ll appear here',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey[500],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.separated(
//             itemCount: chats.length,
//             separatorBuilder: (context, index) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(chat.otherUserId)
//                     .get(),
//                 builder: (context, userSnapshot) {
//                   if (!userSnapshot.hasData) {
//                     return const ListTile(
//                       leading: CircleAvatar(child: Icon(Icons.person)),
//                       title: Text('Loading...'),
//                     );
//                   }
//
//                   final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
//                   final username = userData?['name'] ?? 'Client';
//                   final profileImageUrl = userData?['profileImageUrl'] as String?;
//                   final clientPhone = userData?['phone'] ?? '';
//
//                   return _buildChatItem(chat, username, profileImageUrl, clientPhone);
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/shared/services/image_service.dart';
import '../../user/models/chat_message_model.dart';
import '../../user/repositories/chat_repository.dart';
import 'chat_with_client.dart';

class ProviderMessagesPage extends StatefulWidget {
  const ProviderMessagesPage({Key? key}) : super(key: key);

  @override
  _ProviderMessagesPageState createState() => _ProviderMessagesPageState();
}

class _ProviderMessagesPageState extends State<ProviderMessagesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _providerId;
  bool _isLoading = true;
  late ChatRepository _chatRepository;
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _chatRepository = ChatRepository();
    _initProvider();
  }

  Future<void> _initProvider() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to see messages')),
        );
        Navigator.pop(context);
        return;
      }

      _providerId = currentUser.uid;
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing provider: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime messageTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(messageTime.year, messageTime.month, messageTime.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(messageTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageTime).inDays < 7) {
      return DateFormat('EEEE').format(messageTime);
    } else {
      return DateFormat('MMM d').format(messageTime);
    }
  }

  Widget _buildProfileAvatar(String? profileImageUrl, String username) {
    // Generate consistent color based on username
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.indigoAccent,
      Colors.orange,
      Colors.teal
    ];
    final color = colors[username.length % colors.length];
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundImage: NetworkImage(profileImageUrl),
      // Remove the child widget completely when there's a profile image
    );
  }



  Widget _buildUnreadCountBadge(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: Text(
        unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'When clients message you about your services, they\'ll appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Chat chat, String username, String? profileImageUrl, String clientPhone) {
    final time = _formatTimestamp(chat.lastMessageTime);
    final hasUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: () async {
        await _chatRepository.markMessagesAsRead(chat.id, _providerId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageClientPage(
              clientId: chat.otherUserId,
              clientName: username,
              clientImage: profileImageUrl ?? '',
              serviceId: chat.serviceId,
              serviceName: chat.serviceName,
              clientPhone: clientPhone,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: hasUnread ? Colors.green.withOpacity(0.05) : null,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildProfileAvatar(profileImageUrl, username),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasUnread ? Colors.green[700] : Colors.grey[700],
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        _buildUnreadCountBadge(chat.unreadCount),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0F3966),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const AppBarTitle(text: "Messages"),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/serviceProviderHome'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Chat>>(
        stream: _chatRepository.getChatsForUser(_providerId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading messages\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Divider(height: 1),
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(chat.otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      leading: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: CircleAvatar(
                          radius: 20, // Match your default avatar size
                          backgroundColor: Colors.white,
                        ),
                      ),
                      title: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 10, // Match your text height
                          width: 100,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 10, // Match your text height
                          width: 100,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  final username = userData?['name'] ?? 'Client';
                  final profileImageUrl = userData?['profileImageUrl'] as String?;
                  final clientPhone = userData?['phone'] ?? '';

                  return _buildChatItem(chat, username, profileImageUrl, clientPhone);
                },
              );
            },
          );
        },
      ),
    );
  }
}
