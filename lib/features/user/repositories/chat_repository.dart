// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/chat_message_model.dart';
//
// class ChatRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Get chats where the user has sent at least one message
//   Stream<List<Chat>> getChatsForUser(String userId) {
//     return _firestore
//         .collection('chats')
//         .where('participants', arrayContains: userId)
//         .orderBy('lastMessageTime', descending: true)
//         .snapshots()
//         .asyncMap((snapshot) async {
//       final chats = <Chat>[];
//
//       for (final doc in snapshot.docs) {
//         final chat = Chat.fromFirestore(doc, currentUserId: userId);
//
//         // Check if the user has sent any messages in this chat
//         final hasSentMessages = await _hasUserSentMessages(chat.id, userId);
//
//         if (hasSentMessages) {
//           chats.add(chat);
//         }
//       }
//
//       return chats;
//     });
//   }
//
//   // Helper method to check if user has sent any messages in a chat
//   Future<bool> _hasUserSentMessages(String chatId, String userId) async {
//     final querySnapshot = await _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .where('senderId', isEqualTo: userId)
//         .limit(1)
//         .get();
//
//     return querySnapshot.docs.isNotEmpty;
//   }
//
//   // Get messages for a specific chat
//   Stream<List<ChatMessage>> getMessages(String chatId) {
//     return _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => ChatMessage.fromFirestore(doc))
//           .toList();
//     });
//   }
//
//   // Send a new message
//   Future<void> sendMessage(String chatId, ChatMessage message) async {
//     // Add message to the messages subcollection
//     await _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add(message.toMap());
//
//     // Update the chat document with the latest message info
//     await _firestore.collection('chats').doc(chatId).update({
//       'lastMessage': message.text,
//       'lastMessageTime': message.timestamp,
//       // Increment unread count for the receiver
//       'unreadCount_${message.receiverId}': FieldValue.increment(1),
//     });
//   }
//
//   // Mark all messages as read for a specific chat
//   Future<void> markMessagesAsRead(String chatId, String userId) async {
//     // Get all unread messages for this user
//     final unreadMessages = await _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .where('receiverId', isEqualTo: userId)
//         .where('isRead', isEqualTo: false)
//         .get();
//
//     // Create a batch to update all messages
//     final batch = _firestore.batch();
//
//     for (var doc in unreadMessages.docs) {
//       batch.update(doc.reference, {'isRead': true});
//     }
//
//     // Reset unread count for this user
//     batch.update(
//         _firestore.collection('chats').doc(chatId),
//         {'unreadCount_$userId': 0}
//     );
//
//     // Commit the batch
//     await batch.commit();
//   }
//
//   // Create a new chat if it doesn't exist
//   Future<String> getOrCreateChat({
//     required String userId,
//     required String providerId,
//     required String serviceId,
//     required String serviceName,
//   }) async {
//     // Check if chat already exists between these users for this service
//     final query = await _firestore
//         .collection('chats')
//         .where('participants', arrayContains: userId)
//         .where('serviceId', isEqualTo: serviceId)
//         .get();
//
//     // If chat exists, return its ID
//     if (query.docs.isNotEmpty) {
//       for (final doc in query.docs) {
//         final participants = List<String>.from(doc['participants']);
//         if (participants.contains(providerId)) {
//           return doc.id;
//         }
//       }
//     }
//
//     // Create new chat
//     final newChatRef = await _firestore.collection('chats').add({
//       'participants': [userId, providerId],
//       'lastMessage': '',
//       'lastMessageTime': FieldValue.serverTimestamp(),
//       'unreadCount_$userId': 0,
//       'unreadCount_$providerId': 0,
//       'serviceId': serviceId,
//       'serviceName': serviceName,
//     });
//
//     return newChatRef.id;
//   }
// }


//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/chat_message_model.dart';
//
// class ChatRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Modified method - show all chats where the user is a participant
//   Stream<List<Chat>> getChatsForUser(String userId) {
//     return _firestore
//         .collection('chats')
//         .where('participants', arrayContains: userId)
//         .orderBy('lastMessageTime', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       // Convert each document to a Chat object
//       return snapshot.docs
//           .map((doc) => Chat.fromFirestore(doc, currentUserId: userId))
//           .toList();
//     });
//   }
//
//   // Get messages for a specific chat
//   Stream<List<ChatMessage>> getMessages(String chatId) {
//     return _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => ChatMessage.fromFirestore(doc))
//           .toList();
//     });
//   }
//
//   // Send a new message
//   Future<void> sendMessage(String chatId, ChatMessage message) async {
//     // Add message to the messages subcollection
//     await _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add(message.toMap());
//
//     // Update the chat document with the latest message info
//     await _firestore.collection('chats').doc(chatId).update({
//       'lastMessage': message.text,
//       'lastMessageTime': message.timestamp,
//       // Increment unread count for the receiver
//       'unreadCount_${message.receiverId}': FieldValue.increment(1),
//     });
//   }
//
//   // Mark all messages as read for a specific chat
//   Future<void> markMessagesAsRead(String chatId, String userId) async {
//     // Get all unread messages for this user
//     final unreadMessages = await _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .where('receiverId', isEqualTo: userId)
//         .where('isRead', isEqualTo: false)
//         .get();
//
//     // Create a batch to update all messages
//     final batch = _firestore.batch();
//
//     for (var doc in unreadMessages.docs) {
//       batch.update(doc.reference, {'isRead': true});
//     }
//
//     // Reset unread count for this user
//     batch.update(
//         _firestore.collection('chats').doc(chatId),
//         {'unreadCount_$userId': 0}
//     );
//
//     // Commit the batch
//     await batch.commit();
//   }
//
//   // Create a new chat if it doesn't exist
//   Future<String> getOrCreateChat({
//     required String userId,
//     required String providerId,
//     required String serviceId,
//     required String serviceName,
//   }) async {
//     // Check if chat already exists between these users for this service
//     final query = await _firestore
//         .collection('chats')
//         .where('participants', arrayContains: userId)
//         .where('serviceId', isEqualTo: serviceId)
//         .get();
//
//     // If chat exists, return its ID
//     if (query.docs.isNotEmpty) {
//       for (final doc in query.docs) {
//         final participants = List<String>.from(doc['participants']);
//         if (participants.contains(providerId)) {
//           return doc.id;
//         }
//       }
//     }
//
//     // Create new chat
//     final newChatRef = await _firestore.collection('chats').add({
//       'participants': [userId, providerId],
//       'lastMessage': '',
//       'lastMessageTime': FieldValue.serverTimestamp(),
//       'unreadCount_$userId': 0,
//       'unreadCount_$providerId': 0,
//       'serviceId': serviceId,
//       'serviceName': serviceName,
//     });
//
//     return newChatRef.id;
//   }
// }





import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Modified method - show all chats where the user is a participant
  Stream<List<Chat>> getChatsForUser(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      // Convert each document to a Chat object
      return snapshot.docs
          .map((doc) => Chat.fromFirestore(doc, currentUserId: userId))
          .toList();
    });
  }

  // Get messages for a specific chat
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  // Send a new message
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    // Add message to the messages subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Update the chat document with the latest message info
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
      // Increment unread count for the receiver
      'unreadCount_${message.receiverId}': FieldValue.increment(1),
    });
  }

  // Mark all messages as read for a specific chat
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Get all unread messages for this user
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Create a batch to update all messages
      final batch = _firestore.batch();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Reset unread count for this user
      batch.update(
          _firestore.collection('chats').doc(chatId),
          {'unreadCount_$userId': 0}
      );

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Create a new chat if it doesn't exist
  Future<String> getOrCreateChat({
    required String userId,
    required String providerId,
    required String serviceId,
    required String serviceName,
  }) async {
    // Check if chat already exists between these users for this service
    final query = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .where('serviceId', isEqualTo: serviceId)
        .get();

    // If chat exists, return its ID
    if (query.docs.isNotEmpty) {
      for (final doc in query.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(providerId)) {
          return doc.id;
        }
      }
    }

    // Create new chat
    final newChatRef = await _firestore.collection('chats').add({
      'participants': [userId, providerId],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount_$userId': 0,
      'unreadCount_$providerId': 0,
      'serviceId': serviceId,
      'serviceName': serviceName,
    });

    return newChatRef.id;
  }
}
