// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// class MessageClientPage extends StatefulWidget {
//   final String clientId;
//   final String clientName;
//   final String clientImage;
//   final String serviceId;
//   final String serviceName;
//
//   const MessageClientPage({
//     Key? key,
//     required this.clientId,
//     required this.clientName,
//     required this.clientImage,
//     required this.serviceId,
//     required this.serviceName,
//   }) : super(key: key);
//
//   @override
//   _MessageClientPageState createState() => _MessageClientPageState();
// }
//
// class _MessageClientPageState extends State<MessageClientPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final ScrollController _scrollController = ScrollController();
//   late String _chatId;
//   late String _providerId;
//   bool _isLoading = true;
//   List<DocumentSnapshot> _messages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _initChat();
//   }
//
//   Future<void> _initChat() async {
//     try {
//       // Get current provider ID
//       final User? currentUser = _auth.currentUser;
//       if (currentUser == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('You need to be logged in to use chat')),
//         );
//         Navigator.pop(context);
//         return;
//       }
//
//       _providerId = currentUser.uid;
//
//       // Create a unique chat ID by combining client and provider IDs alphabetically
//       List<String> ids = [widget.clientId, _providerId];
//       ids.sort(); // Sort to ensure consistency
//       _chatId = ids.join('_');
//
//       // Check if chat already exists or create it
//       DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(_chatId).get();
//
//       if (!chatDoc.exists) {
//         // Create new chat
//         await _firestore.collection('chats').doc(_chatId).set({
//           'participants': [_providerId, widget.clientId],
//           'lastMessage': '',
//           'lastMessageTime': FieldValue.serverTimestamp(),
//           'serviceId': widget.serviceId,
//           'serviceName': widget.serviceName,
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//       }
//
//       setState(() {
//         _isLoading = false;
//       });
//
//       // Mark all unread messages as read when opening chat
//       _markMessagesAsRead();
//     } catch (e) {
//       print('Error initializing chat: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _markMessagesAsRead() async {
//     try {
//       // Find all unread messages sent to current provider
//       QuerySnapshot unreadMessages = await _firestore
//           .collection('chats')
//           .doc(_chatId)
//           .collection('messages')
//           .where('receiverId', isEqualTo: _providerId)
//           .where('isRead', isEqualTo: false)
//           .get();
//
//       // Update all messages to read in a batch
//       WriteBatch batch = _firestore.batch();
//       for (DocumentSnapshot doc in unreadMessages.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }
//
//       // Reset unread count for this provider
//       batch.update(
//           _firestore.collection('chats').doc(_chatId),
//           {'unreadCount_$_providerId': 0}
//       );
//
//       await batch.commit();
//     } catch (e) {
//       print('Error marking messages as read: $e');
//     }
//   }
//
//   void _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;
//
//     String messageText = _messageController.text.trim();
//     _messageController.clear();
//
//     try {
//       // Add message
//       await _firestore.collection('chats').doc(_chatId).collection('messages').add({
//         'text': messageText,
//         'senderId': _providerId,
//         'receiverId': widget.clientId,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isRead': false,
//       });
//
//       // Update chat with last message
//       await _firestore.collection('chats').doc(_chatId).update({
//         'lastMessage': messageText,
//         'lastMessageTime': FieldValue.serverTimestamp(),
//         // Increment unread count for the client
//         'unreadCount_${widget.clientId}': FieldValue.increment(1),
//       });
//
//       // Scroll to bottom after sending
//       _scrollToBottom();
//     } catch (e) {
//       print('Error sending message: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to send message. Please try again.')),
//       );
//     }
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       Future.delayed(Duration(milliseconds: 100), () {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor:  Color(0xff0F3966),
//         iconTheme: IconThemeData(color: Colors.white),
//         elevation: 1,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundImage: widget.clientImage.isNotEmpty
//                   ? NetworkImage(widget.clientImage)
//                   : null,
//               child: widget.clientImage.isEmpty
//                   ? Icon(Icons.person, color: Colors.blue[300])
//                   : null,
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.clientName,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.call, ),
//             onPressed: () {
//               // Implement call functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Call feature coming soon')),
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.more_vert, ),
//             onPressed: () {
//               _showOptionsMenu(context);
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('chats')
//                   .doc(_chatId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: false)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error loading messages'));
//                 }
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 _messages = snapshot.data!.docs;
//
//                 if (_messages.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.chat_bubble_outline,
//                           size: 80,
//                           color: Colors.grey[300],
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 16,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Send a message to start the conversation',
//                           style: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//
//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   itemCount: _messages.length,
//                   itemBuilder: (context, index) {
//                     final message = _messages[index].data() as Map<String, dynamic>;
//                     final isMe = message['senderId'] == _providerId;
//                     final timestamp = message['timestamp'] as Timestamp?;
//                     final time = timestamp != null
//                         ? DateFormat('hh:mm a').format(timestamp.toDate())
//                         : '';
//
//                     return _buildMessageBubble(message, isMe, time);
//                   },
//                 );
//               },
//             ),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, String time) {
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 4),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: isMe ? Colors.blueGrey[100] : Colors.blueGrey[100],
//           borderRadius: BorderRadius.circular(16).copyWith(
//             bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
//             bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               message['text'],
//               style: TextStyle(
//                 color: isMe ?  Colors.black87: Colors.black87,
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 2),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   time,
//                   style: TextStyle(
//                     color: isMe ?  Colors.grey[600]: Colors.grey[600],
//                     fontSize: 10,
//                   ),
//                 ),
//                 if (isMe) SizedBox(width: 4),
//                 if (isMe)
//                   Icon(
//                     message['isRead'] == true
//                         ? Icons.done_all
//                         : Icons.done,
//                     size: 14,
//                     color: Colors.grey[600],
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageInput() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: Icon(Icons.attach_file, color: Color(0xFF344D67)),
//             onPressed: () {
//               // Implement file attachment
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Attachment feature coming soon')),
//               );
//             },
//           ),
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//               maxLines: null,
//               textInputAction: TextInputAction.send,
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           SizedBox(width: 8),
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Color(0xff0F3966),
//             child: IconButton(
//               icon: Icon(Icons.send, color: Colors.white),
//               onPressed: _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showOptionsMenu(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//
//               ListTile(
//                 leading: Icon(Icons.report_problem, color: Colors.orange),
//                 title: Text('Report Client'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showReportDialog();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.block, color: Colors.red),
//                 title: Text('Block Client'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showBlockConfirmation();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.delete_outline, color: Colors.red),
//                 title: Text('Clear Chat History'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showClearChatConfirmation();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showReportDialog() {
//     final TextEditingController reportController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Report Client'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Please describe the issue you\'re experiencing with this client:'),
//             SizedBox(height: 16),
//             TextField(
//               controller: reportController,
//               decoration: InputDecoration(
//                 hintText: 'Describe the issue...',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Submit report
//               if (reportController.text.trim().isNotEmpty) {
//                 _firestore.collection('reports').add({
//                   'reporterId': _providerId,
//                   'reportedUserId': widget.clientId,
//                   'reason': reportController.text.trim(),
//                   'timestamp': FieldValue.serverTimestamp(),
//                   'chatId': _chatId,
//                 });
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Report submitted. Thank you for your feedback.')),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xff0F3966),
//             ),
//             child: Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showBlockConfirmation() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Block Client'),
//         content: Text('Are you sure you want to block this client? You won\'t receive messages from them anymore.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Block user
//               _firestore.collection('service provider').doc(_providerId).collection('blocked').doc(widget.clientId).set({
//                 'blockedAt': FieldValue.serverTimestamp(),
//               });
//               Navigator.pop(context);
//               Navigator.pop(context); // Go back to previous screen
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Client blocked successfully.')),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             child: Text('Block'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showClearChatConfirmation() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Clear Chat History'),
//         content: Text('Are you sure you want to clear the chat history? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               // Clear chat history
//               Navigator.pop(context);
//
//               // Show loading
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (context) => Center(child: CircularProgressIndicator()),
//               );
//
//               try {
//                 // Get all messages
//                 QuerySnapshot messages = await _firestore
//                     .collection('chats')
//                     .doc(_chatId)
//                     .collection('messages')
//                     .get();
//
//                 // Delete messages in batches of 500 (Firestore limit)
//                 const int batchSize = 500;
//                 List<List<DocumentSnapshot>> batches = [];
//
//                 for (int i = 0; i < messages.docs.length; i += batchSize) {
//                   int end = (i + batchSize < messages.docs.length)
//                       ? i + batchSize
//                       : messages.docs.length;
//                   batches.add(messages.docs.sublist(i, end));
//                 }
//
//                 for (var batch in batches) {
//                   WriteBatch writeBatch = _firestore.batch();
//                   for (var doc in batch) {
//                     writeBatch.delete(doc.reference);
//                   }
//                   await writeBatch.commit();
//                 }
//
//                 // Update chat document
//                 await _firestore.collection('chats').doc(_chatId).update({
//                   'lastMessage': '',
//                   'lastMessageTime': FieldValue.serverTimestamp(),
//                 });
//
//                 // Close loading dialog
//                 Navigator.pop(context);
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Chat history cleared successfully.')),
//                 );
//               } catch (e) {
//                 // Close loading dialog
//                 Navigator.pop(context);
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to clear chat history. Please try again.')),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             child: Text('Clear'),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import '../../../core/shared/services/image_service.dart';

// Import your ImageService


class MessageClientPage extends StatefulWidget {
  final String clientId;
  final String clientName;
  final String clientImage;
  final String serviceId;
  final String serviceName;
  final String? clientPhone; // Added client phone parameter

  const MessageClientPage({
    Key? key,
    required this.clientId,
    required this.clientName,
    required this.clientImage,
    required this.serviceId,
    required this.serviceName,
    this.clientPhone, // Optional parameter for client's phone number
  }) : super(key: key);

  @override
  _MessageClientPageState createState() => _MessageClientPageState();
}

class _MessageClientPageState extends State<MessageClientPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final ImageService _imageService = ImageService(); // Initialize image service

  late String _chatId;
  late String _providerId;
  bool _isLoading = true;
  bool _isAttachingImage = false;
  List<DocumentSnapshot> _messages = [];
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      // Get current provider ID
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You need to be logged in to use chat')),
        );
        Navigator.pop(context);
        return;
      }

      _providerId = currentUser.uid;

      // Create a unique chat ID by combining client and provider IDs alphabetically
      List<String> ids = [widget.clientId, _providerId];
      ids.sort(); // Sort to ensure consistency
      _chatId = ids.join('_');

      // Check if chat already exists or create it
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(_chatId).get();

      if (!chatDoc.exists) {
        // Create new chat
        await _firestore.collection('chats').doc(_chatId).set({
          'participants': [_providerId, widget.clientId],
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'serviceId': widget.serviceId,
          'serviceName': widget.serviceName,
          'createdAt': FieldValue.serverTimestamp(),
          'hiddenForProviders': [], // Initialize list for tracking provider-hidden messages
        });
      } else {
        // Make sure the 'hiddenForProviders' field exists
        if (!(chatDoc.data() as Map<String, dynamic>).containsKey('hiddenForProviders')) {
          await _firestore.collection('chats').doc(_chatId).update({
            'hiddenForProviders': [],
          });
        }
      }

      setState(() {
        _isLoading = false;
      });

      // Mark all unread messages as read when opening chat
      _markMessagesAsRead();
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      // Find all unread messages sent to current provider
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: _providerId)
          .where('isRead', isEqualTo: false)
          .get();

      // Update all messages to read in a batch
      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Reset unread count for this provider
      batch.update(
          _firestore.collection('chats').doc(_chatId),
          {'unreadCount_$_providerId': 0}
      );

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _sendMessage({String? imageUrl}) async {
    String messageText = _messageController.text.trim();

    // Check if there's text or image to send
    if (messageText.isEmpty && imageUrl == null) return;

    _messageController.clear();
    setState(() {
      _imageFile = null;
      _imageUrl = null;
      _isAttachingImage = false;
    });

    try {
      // Prepare message data
      Map<String, dynamic> messageData = {
        'senderId': _providerId,
        'receiverId': widget.clientId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      // Add text if provided
      if (messageText.isNotEmpty) {
        messageData['text'] = messageText;
      }

      // Add image URL if provided
      if (imageUrl != null) {
        messageData['imageUrl'] = imageUrl;
        messageData['type'] = 'image';
      } else {
        messageData['type'] = 'text';
      }

      // Add message to Firestore
      await _firestore.collection('chats').doc(_chatId).collection('messages').add(messageData);

      // Update chat with last message
      Map<String, dynamic> chatUpdate = {
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount_${widget.clientId}': FieldValue.increment(1),
      };

      // Set the last message preview
      if (imageUrl != null && messageText.isEmpty) {
        chatUpdate['lastMessage'] = '📷 Image';
      } else if (imageUrl != null) {
        chatUpdate['lastMessage'] = '$messageText 📷';
      } else {
        chatUpdate['lastMessage'] = messageText;
      }

      await _firestore.collection('chats').doc(_chatId).update(chatUpdate);

      // Scroll to bottom after sending
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message. Please try again.')),
      );
    }
  }

  Future<void> _sendImageMessage() async {
    if (_imageFile == null) return;

    setState(() {
      _isAttachingImage = true;
    });

    try {
      // Upload the image
      String? imageUrl = await _imageService.uploadImageWorking(_imageFile!, _chatId);

      if (imageUrl != null) {
        // Send the message with the image URL
        _sendMessage(imageUrl: imageUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
        setState(() {
          _isAttachingImage = false;
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image. Please try again.')),
      );
      setState(() {
        _isAttachingImage = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Method to call the client's phone number
  Future<void> _callClient() async {
    if (widget.clientPhone == null || widget.clientPhone!.isEmpty) {
      // If phone number not available, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client phone number not available')),
      );
      return;
    }

    try {
      // Try to make a direct call using the plugin
      bool? callResult = await FlutterPhoneDirectCaller.callNumber(widget.clientPhone!);

      // Check if the call was successful
      if (callResult != true) {
        // If direct call fails, try launching the dialer
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: widget.clientPhone,
        );
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        } else {
          throw 'Could not launch $launchUri';
        }
      }
    } catch (e) {
      print('Error making phone call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make the call. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.clientImage.isNotEmpty
                  ? NetworkImage(widget.clientImage)
                  : null,
              child: widget.clientImage.isEmpty
                  ? Icon(Icons.person, color: Colors.blue[300])
                  : null,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clientName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: _callClient,
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                _messages = snapshot.data!.docs;

                if (_messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Send a message to start the conversation',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Check for hidden messages for this provider
                return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('chats').doc(_chatId).snapshots(),
                  builder: (context, chatSnapshot) {
                    if (!chatSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<String> hiddenMessages = [];

                    // Get hidden messages for this provider
                    if (chatSnapshot.data!.exists) {
                      Map<String, dynamic> chatData = chatSnapshot.data!.data() as Map<String, dynamic>;
                      if (chatData.containsKey('hiddenForProviders') &&
                          chatData['hiddenForProviders'] is List) {
                        hiddenMessages = List<String>.from(chatData['hiddenForProviders']);
                      }
                    }

                    // Filter out hidden messages
                    List<DocumentSnapshot> visibleMessages = _messages.where((message) {
                      return !hiddenMessages.contains(message.id);
                    }).toList();

                    if (visibleMessages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No messages to display',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: visibleMessages.length,
                      itemBuilder: (context, index) {
                        final message = visibleMessages[index].data() as Map<String, dynamic>;
                        final isMe = message['senderId'] == _providerId;
                        final timestamp = message['timestamp'] as Timestamp?;
                        final time = timestamp != null
                            ? DateFormat('hh:mm a').format(timestamp.toDate())
                            : '';

                        return _buildMessageBubble(message, isMe, time);
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (_isAttachingImage)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _imageFile!,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _imageFile = null;
                            _isAttachingImage = false;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Color(0xff0F3966)),
                        onPressed: _sendImageMessage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, String time) {
    // Get message type
    String type = message['type'] ?? 'text';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueGrey[100] : Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
            bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Show message content based on type
            if (type == 'image')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message['imageUrl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                  if (message['text'] != null && message['text'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        message['text'],
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),

            if (type != 'image' && message['text'] != null)
              Text(
                message['text'],
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),

            SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
                if (isMe) SizedBox(width: 4),
                if (isMe)
                  Icon(
                    message['isRead'] == true
                        ? Icons.done_all
                        : Icons.done,
                    size: 14,
                    color: message['isRead'] == true
                    ? Colors.green
                    : Colors.grey[600]

                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Color(0xFF344D67)),
            onPressed: () async {
              // Show image picker
              final File? pickedImage = await _imageService.showImagePickerDialog(context);
              if (pickedImage != null) {
                setState(() {
                  _imageFile = pickedImage;
                  _isAttachingImage = true;
                });
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xff0F3966),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () => _imageFile != null ? _sendImageMessage() : _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.report_problem, color: Colors.orange),
                title: Text('Report Client'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text('Block Client'),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockConfirmation();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Clear Chat History'),
                onTap: () {
                  Navigator.pop(context);
                  _showClearChatConfirmation();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog() {
    final TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please describe the issue you\'re experiencing with this client:'),
            SizedBox(height: 16),
            TextField(
              controller: reportController,
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Submit report
              if (reportController.text.trim().isNotEmpty) {
                _firestore.collection('reports').add({
                  'reporterId': _providerId,
                  'reportedUserId': widget.clientId,
                  'reason': reportController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                  'chatId': _chatId,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report submitted. Thank you for your feedback.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0F3966),
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block Client'),
        content: Text('Are you sure you want to block this client? You won\'t receive messages from them anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Block user
              _firestore.collection('service provider').doc(_providerId).collection('blocked').doc(widget.clientId).set({
                'blockedAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Client blocked successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showClearChatConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat History'),
        content: Text('This will clear the chat history only for you. The client will still see all messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator()),
              );

              try {
                // Get all message IDs
                QuerySnapshot messages = await _firestore
                    .collection('chats')
                    .doc(_chatId)
                    .collection('messages')
                    .get();

                // Get current chat document
                DocumentSnapshot chatDoc = await _firestore
                    .collection('chats')
                    .doc(_chatId)
                    .get();

                // Get or initialize the hidden messages array
                List<String> hiddenMessages = [];
                if (chatDoc.exists) {
                  Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;
                  if (chatData.containsKey('hiddenForProviders') &&
                      chatData['hiddenForProviders'] is List) {
                    hiddenMessages = List<String>.from(chatData['hiddenForProviders']);
                  }
                }

                // Add all message IDs to hidden list
                messages.docs.forEach((doc) {
                  if (!hiddenMessages.contains(doc.id)) {
                    hiddenMessages.add(doc.id);
                  }
                });

                // Update the chat document with hidden messages
                await _firestore.collection('chats').doc(_chatId).update({
                  'hiddenForProviders': hiddenMessages,
                });

                // Close loading dialog
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat history cleared successfully (only for you).')),
                );
              } catch (e) {
                // Close loading dialog
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to clear chat history. Please try again.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
}