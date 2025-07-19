
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;

import '../../../core/shared/services/image_service.dart';

class MessageClientPage extends StatefulWidget {
  final String clientId;
  final String clientName;
  final String clientImage;
  final String serviceId;
  final String serviceName;
  final String? clientPhone;

  const MessageClientPage({
    Key? key,
    required this.clientId,
    required this.clientName,
    required this.clientImage,
    required this.serviceId,
    required this.serviceName,
    this.clientPhone,
  }) : super(key: key);

  @override
  _MessageClientPageState createState() => _MessageClientPageState();
}

class _MessageClientPageState extends State<MessageClientPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final ImageService _imageService = ImageService();

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
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You need to be logged in to use chat')),
        );
        Navigator.pop(context);
        return;
      }

      _providerId = currentUser.uid;

      List<String> ids = [widget.clientId, _providerId];
      ids.sort();
      _chatId = ids.join('_');

      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(_chatId).get();

      if (!chatDoc.exists) {
        await _firestore.collection('chats').doc(_chatId).set({
          'participants': [_providerId, widget.clientId],
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'serviceId': widget.serviceId,
          'serviceName': widget.serviceName,
          'createdAt': FieldValue.serverTimestamp(),
          'hiddenForProviders': [],
        });
      } else {
        if (!(chatDoc.data() as Map<String, dynamic>).containsKey('hiddenForProviders')) {
          await _firestore.collection('chats').doc(_chatId).update({
            'hiddenForProviders': [],
          });
        }
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
  Future<bool> _checkImageUrl(String url) async {
    if (url.isEmpty) return false;

    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('URL check error: $e');
      return false;
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: _providerId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

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

    if (messageText.isEmpty && imageUrl == null) return;

    _messageController.clear();
    setState(() {
      _imageFile = null;
      _imageUrl = null;
      _isAttachingImage = false;
    });

    try {
      Map<String, dynamic> messageData = {
        'senderId': _providerId,
        'receiverId': widget.clientId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      if (messageText.isNotEmpty) {
        messageData['text'] = messageText;
      }

      if (imageUrl != null) {
        messageData['imageUrl'] = imageUrl;
        messageData['type'] = 'image';
      } else {
        messageData['type'] = 'text';
      }

      await _firestore.collection('chats').doc(_chatId).collection('messages').add(messageData);

      Map<String, dynamic> chatUpdate = {
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount_${widget.clientId}': FieldValue.increment(1),
      };

      if (imageUrl != null && messageText.isEmpty) {
        chatUpdate['lastMessage'] = '📷 Image';
      } else if (imageUrl != null) {
        chatUpdate['lastMessage'] = '$messageText 📷';
      } else {
        chatUpdate['lastMessage'] = messageText;
      }

      await _firestore.collection('chats').doc(_chatId).update(chatUpdate);

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
      String? imageUrl = await _imageService.uploadImageWorking(_imageFile!, _chatId);

      if (imageUrl != null) {
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

  Future<void> _makePhoneCall(String clientPhone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: clientPhone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch phone dialer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Group messages by date
  Map<String, List<DocumentSnapshot>> _groupMessagesByDate(List<DocumentSnapshot> messages) {
    Map<String, List<DocumentSnapshot>> groupedMessages = {};

    for (var message in messages) {
      final data = message.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp?;

      if (timestamp != null) {
        final date = timestamp.toDate();
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (!groupedMessages.containsKey(dateKey)) {
          groupedMessages[dateKey] = [];
        }
        groupedMessages[dateKey]!.add(message);
      }
    }

    return groupedMessages;
  }

  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
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
            FutureBuilder<String?>(
              future: _getClientProfileImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }

                final imageUrl = snapshot.data;
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Text(
                    widget.clientName.isNotEmpty ? widget.clientName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                );
              },
            ),
            SizedBox(width: 5),
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
          if (widget.clientPhone != null)
            IconButton(
              icon: Icon(Icons.call),
              onPressed: () => _callClient(),
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

                return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('chats').doc(_chatId).snapshots(),
                  builder: (context, chatSnapshot) {
                    if (!chatSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<String> hiddenMessages = [];

                    if (chatSnapshot.data!.exists) {
                      Map<String, dynamic> chatData = chatSnapshot.data!.data() as Map<String, dynamic>;
                      if (chatData.containsKey('hiddenForProviders') &&
                          chatData['hiddenForProviders'] is List) {
                        hiddenMessages = List<String>.from(chatData['hiddenForProviders']);
                      }
                    }

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

                    // Group messages by date
                    Map<String, List<DocumentSnapshot>> groupedMessages = _groupMessagesByDate(visibleMessages);
                    List<String> sortedDates = groupedMessages.keys.toList()..sort();

                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, dateIndex) {
                        String dateKey = sortedDates[dateIndex];
                        List<DocumentSnapshot> messagesForDate = groupedMessages[dateKey]!;

                        return Column(
                          children: [
                            // Date header
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 16),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatDateHeader(dateKey),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Messages for this date
                            ...messagesForDate.map((message) {
                              final messageData = message.data() as Map<String, dynamic>;
                              final isMe = messageData['senderId'] == _providerId;
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

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
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

  Future<String?> _getClientProfileImage() async {
    if (widget.clientImage.isNotEmpty) {
      return widget.clientImage;
    }

    try {
      final doc = await _firestore.collection('users').doc(widget.clientId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['profileImageUrl'] as String?;
      }
    } catch (e) {
      print('Error fetching client profile image: $e');
    }

    return null;
  }

  Future<void> _callClient() async {
    if (widget.clientPhone == null || widget.clientPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client phone number not available')),
      );
      return;
    }

    try {
      bool? callResult = await FlutterPhoneDirectCaller.callNumber(widget.clientPhone!);

      if (callResult != true) {
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
        SnackBar(content: Text('Could not make the call. Please try again.')),
      );
    }
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
              _firestore.collection('service provider').doc(_providerId).collection('blocked').doc(widget.clientId).set({
                'blockedAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              Navigator.pop(context);
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

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator()),
              );

              try {
                QuerySnapshot messages = await _firestore
                    .collection('chats')
                    .doc(_chatId)
                    .collection('messages')
                    .get();

                DocumentSnapshot chatDoc = await _firestore
                    .collection('chats')
                    .doc(_chatId)
                    .get();

                List<String> hiddenMessages = [];
                if (chatDoc.exists) {
                  Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;
                  if (chatData.containsKey('hiddenForProviders') &&
                      chatData['hiddenForProviders'] is List) {
                    hiddenMessages = List<String>.from(chatData['hiddenForProviders']);
                  }
                }

                messages.docs.forEach((doc) {
                  if (!hiddenMessages.contains(doc.id)) {
                    hiddenMessages.add(doc.id);
                  }
                });

                await _firestore.collection('chats').doc(_chatId).update({
                  'hiddenForProviders': hiddenMessages,
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat history cleared successfully (only for you).')),
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