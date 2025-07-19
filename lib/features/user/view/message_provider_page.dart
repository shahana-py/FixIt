

import 'dart:io';
import 'package:fixit/features/user/view/view_service_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/shared/services/image_service.dart';

class ChatPage extends StatefulWidget {
  final String providerId;
  final String providerName;
  final String providerImage;
  final String serviceId;
  final String serviceName;
  final String providerPhone;

  const ChatPage({
    Key? key,
    required this.providerId,
    required this.providerName,
    required this.providerImage,
    required this.serviceId,
    required this.serviceName,
    required this.providerPhone,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final ImageService _imageService = ImageService();
  late String _chatId;
  late String _userId;
  bool _isLoading = true;
  List<DocumentSnapshot> _messages = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You need to be logged in to use chat')),
        );
        Navigator.pop(context);
        return;
      }

      _userId = currentUser.uid;

      List<String> ids = [_userId, widget.providerId];
      ids.sort();
      _chatId = ids.join('_');

      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(_chatId).get();

      if (!chatDoc.exists) {
        await _firestore.collection('chats').doc(_chatId).set({
          'participants': [_userId, widget.providerId],
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'serviceId': widget.serviceId,
          'serviceName': widget.serviceName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      DocumentSnapshot userChatMetaDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('chatMetadata')
          .doc(_chatId)
          .get();

      if (!userChatMetaDoc.exists) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('chatMetadata')
            .doc(_chatId)
            .set({
          'isHidden': false,
          'lastClearedTimestamp': null,
        });
      }

      setState(() {
        _isLoading = false;
      });

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
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: _userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    String messageText = _messageController.text.trim();

    if (messageText.isEmpty && imageUrl == null) return;
    _messageController.clear();

    try {
      Map<String, dynamic> messageData = {
        'senderId': _userId,
        'receiverId': widget.providerId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      if (messageText.isNotEmpty) {
        messageData['text'] = messageText;
      }

      if (imageUrl != null) {
        messageData['imageUrl'] = imageUrl;
      }

      await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add(messageData);

      String lastMessagePreview = messageText.isNotEmpty ? messageText : '📷 Image';

      await _firestore.collection('chats').doc(_chatId).update({
        'lastMessage': lastMessagePreview,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount_${widget.providerId}': FieldValue.increment(1),
      });

      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message. Please try again.')),
      );
    }
  }




  Future<void> _handleImageUpload() async {
    try {
      File? imageFile = await _imageService.showImagePickerDialog(context);

      if (imageFile != null) {
        setState(() {
          _isUploading = true;
        });

        String? imageUrl = await _imageService.uploadImageWorking(
            imageFile,
            'chat_${_chatId}'
        );

        if (imageUrl != null) {
          _sendMessage(imageUrl: imageUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image. Please try again.')),
          );
        }

        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      print('Error handling image upload: $e');
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while uploading the image.')),
      );
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

  // Helper method to group messages by date
  // Map<String, List<DocumentSnapshot>> _groupMessagesByDate(List<DocumentSnapshot> messages) {
  //   Map<String, List<DocumentSnapshot>> groupedMessages = {};
  //
  //   for (var message in messages) {
  //     final messageData = message.data() as Map<String, dynamic>;
  //     final timestamp = messageData['timestamp'] as Timestamp?;
  //
  //     if (timestamp != null) {
  //       DateTime date = timestamp.toDate();
  //       String dateKey = DateFormat('yyyy-MM-dd').format(date);
  //
  //       if (!groupedMessages.containsKey(dateKey)) {
  //         groupedMessages[dateKey] = [];
  //       }
  //       groupedMessages[dateKey]!.add(message);
  //     } else {
  //       // Handle messages without timestamp (shouldn't happen in normal cases)
  //       const String noDateKey = 'No Date';
  //       if (!groupedMessages.containsKey(noDateKey)) {
  //         groupedMessages[noDateKey] = [];
  //       }
  //       groupedMessages[noDateKey]!.add(message);
  //     }
  //   }
  //
  //   return groupedMessages;
  // }


  // Helper method to group messages by date
  Map<String, List<DocumentSnapshot>> _groupMessagesByDate(List<DocumentSnapshot> messages) {
    Map<String, List<DocumentSnapshot>> groupedMessages = {};

    for (var message in messages) {
      final messageData = message.data() as Map<String, dynamic>;
      final timestamp = messageData['timestamp'] as Timestamp?;
      String dateKey;

      if (timestamp != null) {
        try {
          DateTime date = timestamp.toDate();
          dateKey = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          dateKey = 'No Date';
        }
      } else {
        dateKey = 'No Date';
      }

      if (!groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey] = [];
      }
      groupedMessages[dateKey]!.add(message);
    }

    return groupedMessages;
  }

  // Helper method to format date header
  // String _formatDateHeader(String dateKey) {
  //   DateTime now = DateTime.now();
  //   DateTime today = DateTime(now.year, now.month, now.day);
  //   DateTime date = DateTime.parse(dateKey);
  //
  //   if (date == today) {
  //     return 'Today';
  //   } else if (date == today.subtract(Duration(days: 1))) {
  //     return 'Yesterday';
  //   } else {
  //     return DateFormat('MMMM d, yyyy').format(date);
  //   }
  // }

  // Helper method to format date header
  String _formatDateHeader(String dateKey) {
    if (dateKey == 'No Date') {
      return '';
    }

    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime date = DateTime.parse(dateKey);

      if (date == today) {
        return 'Today';
      } else if (date == today.subtract(Duration(days: 1))) {
        return 'Yesterday';
      } else {
        return DateFormat('MMMM d, yyyy').format(date);
      }
    } catch (e) {
      print('Error formatting date: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff0F3966),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.providerImage.isNotEmpty
                  ? NetworkImage(widget.providerImage)
                  : null,
              child: widget.providerImage.isEmpty
                  ? Text(
                widget.providerName.isNotEmpty
                    ? widget.providerName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.providerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
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
            icon: Icon(Icons.call, color: Colors.white),
            onPressed: () => _callProvider(),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
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
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_userId)
                  .collection('chatMetadata')
                  .doc(_chatId)
                  .snapshots(),
              builder: (context, metadataSnapshot) {
                if (metadataSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final metadata = metadataSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                final Timestamp? lastClearedTimestamp = metadata['lastClearedTimestamp'];

                return StreamBuilder<QuerySnapshot>(
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

                    List<DocumentSnapshot> allMessages = snapshot.data!.docs;
                    List<DocumentSnapshot> visibleMessages = lastClearedTimestamp == null
                        ? allMessages
                        : allMessages.where((doc) {
                      final messageData = doc.data() as Map<String, dynamic>;
                      final messageTimestamp = messageData['timestamp'] as Timestamp?;
                      if (messageTimestamp == null) return true;
                      return messageTimestamp.compareTo(lastClearedTimestamp) > 0;
                    }).toList();

                    _messages = visibleMessages;

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

                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                    // Group messages by date
                    Map<String, List<DocumentSnapshot>> groupedMessages = _groupMessagesByDate(_messages);
                    List<String> sortedDates = groupedMessages.keys.toList()..sort();

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        String dateKey = sortedDates[index];
                        List<DocumentSnapshot> dateMessages = groupedMessages[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Date header
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatDateHeader(dateKey),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            // Messages for this date
                            ...dateMessages.map((message) {
                              final messageData = message.data() as Map<String, dynamic>;
                              final isMe = messageData['senderId'] == _userId;
                              final timestamp = messageData['timestamp'] as Timestamp?;
                              final time = timestamp != null
                                  ? DateFormat('hh:mm a').format(timestamp.toDate())
                                  : '';

                              return _buildMessageBubble(messageData, isMe, time);
                            }).toList(),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[100],
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Uploading image...', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, String time) {
    final hasImage = message['imageUrl'] != null;
    final hasText = message['text'] != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: hasImage ? 8 : 10
        ),
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
            if (hasText)
              Text(
                message['text'],
                style: TextStyle(
                  color: isMe ? Colors.black87 : Colors.black87,
                  fontSize: 16,
                ),
              ),
            if (hasText && hasImage) SizedBox(height: 8),
            if (hasImage)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.black,
                          iconTheme: IconThemeData(color: Colors.white),
                          elevation: 0,
                        ),
                        body: Center(
                          child: InteractiveViewer(
                            panEnabled: true,
                            boundaryMargin: EdgeInsets.all(20),
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              message['imageUrl'],
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    message['imageUrl'],
                    width: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 200,
                        height: 150,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 150,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),
            SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.grey[600] : Colors.grey[600],
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


  Future<void> _callProvider() async {
    if (widget.providerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Provider phone number not available')),
      );
      return;
    }

    try {
      bool? callResult = await FlutterPhoneDirectCaller.callNumber(widget.providerPhone);

      if (callResult != true) {
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: widget.providerPhone,
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
        SnackBar(content: Text('Could not make the call. Please try again.')),
      );
    }
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
            onPressed: _handleImageUpload,
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
              onPressed: () => _sendMessage(),
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
                leading: Icon(Icons.person, color: Color(0xFF344D67)),
                title: Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewServiceDetailsPage(
                        serviceId: widget.serviceId,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.report_problem, color: Colors.orange),
                title: Text('Report Provider'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text('Block Provider'),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockConfirmation();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
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
        title: Text('Report Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please describe the issue you\'re experiencing with this provider:'),
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
              if (reportController.text.trim().isNotEmpty) {
                _firestore.collection('reports').add({
                  'reporterId': _userId,
                  'reportedUserId': widget.providerId,
                  'reason': reportController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                  'chatId': _chatId,
                  'reportedUserRole': 'provider',
                  'serviceId': widget.serviceId,
                  'serviceName': widget.serviceName,
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
        title: Text('Block Provider'),
        content: Text('Are you sure you want to block this provider? You won\'t receive messages from them anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _firestore.collection('users').doc(_userId).collection('blocked').doc(widget.providerId).set({
                'blockedAt': FieldValue.serverTimestamp(),
                'providerName': widget.providerName,
                'providerImage': widget.providerImage,
                'serviceId': widget.serviceId,
                'serviceName': widget.serviceName,
              });
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Provider blocked successfully.')),
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
        content: Text(
            'This will clear the chat history from your view, but the provider will still see the messages. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator()),
              );

              try {
                await _firestore
                    .collection('users')
                    .doc(_userId)
                    .collection('chatMetadata')
                    .doc(_chatId)
                    .update({
                  'lastClearedTimestamp': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat history cleared from your view successfully.')),
                );
              } catch (e) {
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