// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ChatMessage {
//   final String id;
//   final String text;
//   final String senderId;
//   final String receiverId;
//   final Timestamp timestamp;
//   final bool isRead;
//
//   ChatMessage({
//     required this.id,
//     required this.text,
//     required this.senderId,
//     required this.receiverId,
//     required this.timestamp,
//     required this.isRead,
//   });
//
//   factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//     return ChatMessage(
//       id: doc.id,
//       text: data['text'] ?? '',
//       senderId: data['senderId'] ?? '',
//       receiverId: data['receiverId'] ?? '',
//       timestamp: data['timestamp'] ?? Timestamp.now(),
//       isRead: data['isRead'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'text': text,
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'timestamp': timestamp,
//       'isRead': isRead,
//     };
//   }
// }
//
// class Chat {
//   final String id;
//   final List<String> participants;
//   final String lastMessage;
//   final Timestamp lastMessageTime;
//   final String serviceId;
//   final String serviceName;
//   final Timestamp createdAt;
//   final int unreadCount; // For the current user
//
//   Chat({
//     required this.id,
//     required this.participants,
//     required this.lastMessage,
//     required this.lastMessageTime,
//     required this.serviceId,
//     required this.serviceName,
//     required this.createdAt,
//     this.unreadCount = 0,
//   });
//
//   factory Chat.fromFirestore(DocumentSnapshot doc, {String? currentUserId}) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//     return Chat(
//       id: doc.id,
//       participants: List<String>.from(data['participants'] ?? []),
//       lastMessage: data['lastMessage'] ?? '',
//       lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
//       serviceId: data['serviceId'] ?? '',
//       serviceName: data['serviceName'] ?? '',
//       createdAt: data['createdAt'] ?? Timestamp.now(),
//       unreadCount: data['unreadCount_$currentUserId'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'participants': participants,
//       'lastMessage': lastMessage,
//       'lastMessageTime': lastMessageTime,
//       'serviceId': serviceId,
//       'serviceName': serviceName,
//       'createdAt': createdAt,
//     };
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ChatMessage {
//   final String id;
//   final String text;
//   final String senderId;
//   final String receiverId;
//   final Timestamp timestamp;
//   final bool isRead;
//
//   ChatMessage({
//     required this.id,
//     required this.text,
//     required this.senderId,
//     required this.receiverId,
//     required this.timestamp,
//     required this.isRead,
//   });
//
//   factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//     return ChatMessage(
//       id: doc.id,
//       text: data['text'] ?? '',
//       senderId: data['senderId'] ?? '',
//       receiverId: data['receiverId'] ?? '',
//       timestamp: data['timestamp'] ?? Timestamp.now(),
//       isRead: data['isRead'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'text': text,
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'timestamp': timestamp,
//       'isRead': isRead,
//     };
//   }
// }
//
// class Chat {
//   final String id;
//   final List<String> participants;
//   final String lastMessage;
//   final Timestamp lastMessageTime;
//   final String serviceId;
//   final String serviceName;
//   final Timestamp createdAt;
//   final int unreadCount; // For the current user
//
//   Chat({
//     required this.id,
//     required this.participants,
//     required this.lastMessage,
//     required this.lastMessageTime,
//     required this.serviceId,
//     required this.serviceName,
//     required this.createdAt,
//     this.unreadCount = 0,
//   });
//
//   factory Chat.fromFirestore(DocumentSnapshot doc, {String? currentUserId}) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//     // Handle participants safely
//     List<String> participantsList = [];
//     if (data['participants'] != null) {
//       participantsList = List<String>.from(data['participants']);
//     }
//
//     return Chat(
//       id: doc.id,
//       participants: participantsList,
//       lastMessage: data['lastMessage'] ?? '',
//       lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
//       serviceId: data['serviceId'] ?? '',
//       serviceName: data['serviceName'] ?? '',
//       createdAt: data['createdAt'] ?? Timestamp.now(),
//       unreadCount: currentUserId != null ? (data['unreadCount_$currentUserId'] ?? 0) : 0,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'participants': participants,
//       'lastMessage': lastMessage,
//       'lastMessageTime': lastMessageTime,
//       'serviceId': serviceId,
//       'serviceName': serviceName,
//       'createdAt': createdAt,
//     };
//   }
// }



// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Chat {
//   final String id;
//   final List<String> participants;
//   final String otherUserId; // The ID of the other user (not the current user)
//   final String lastMessage;
//   final Timestamp lastMessageTime;
//   final int unreadCount;
//   final String serviceId;
//   final String serviceName;
//
//   Chat({
//     required this.id,
//     required this.participants,
//     required this.otherUserId,
//     required this.lastMessage,
//     required this.lastMessageTime,
//     required this.unreadCount,
//     required this.serviceId,
//     required this.serviceName,
//   });
//
//   factory Chat.fromFirestore(DocumentSnapshot doc, {required String currentUserId}) {
//     final data = doc.data() as Map<String, dynamic>;
//
//     // Get participants list
//     List<String> participantsList = [];
//     if (data['participants'] != null) {
//       participantsList = List<String>.from(data['participants']);
//     }
//
//     // Get the other participant's ID (not the current user)
//     final otherUser = participantsList.firstWhere(
//           (id) => id != currentUserId,
//       orElse: () => '',
//     );
//
//     // Get unread count specifically for the current user
//     final unreadCountField = 'unreadCount_$currentUserId';
//     final unreadCount = data[unreadCountField] ?? 0;
//
//     return Chat(
//       id: doc.id,
//       participants: participantsList,
//       otherUserId: otherUser,
//       lastMessage: data['lastMessage'] ?? '',
//       lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
//       unreadCount: unreadCount,
//       serviceId: data['serviceId'] ?? '',
//       serviceName: data['serviceName'] ?? '',
//     );
//   }
// }
//
// class ChatMessage {
//   final String id;
//   final String senderId;
//   final String receiverId;
//   final String text;
//   final Timestamp timestamp;
//   final bool isRead;
//
//   ChatMessage({
//     this.id = '',
//     required this.senderId,
//     required this.receiverId,
//     required this.text,
//     required this.timestamp,
//     this.isRead = false,
//   });
//
//   factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//
//     return ChatMessage(
//       id: doc.id,
//       senderId: data['senderId'] ?? '',
//       receiverId: data['receiverId'] ?? '',
//       text: data['text'] ?? '',
//       timestamp: data['timestamp'] ?? Timestamp.now(),
//       isRead: data['isRead'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'text': text,
//       'timestamp': timestamp,
//       'isRead': isRead,
//     };
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants;
  final String otherUserId; // The ID of the other user (not the current user)
  final String lastMessage;
  final Timestamp lastMessageTime;
  final int unreadCount;
  final String serviceId;
  final String serviceName;

  Chat({
    required this.id,
    required this.participants,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.serviceId,
    required this.serviceName,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc, {required String currentUserId}) {
    final data = doc.data() as Map<String, dynamic>;

    // Get participants list
    List<String> participantsList = [];
    if (data['participants'] != null) {
      participantsList = List<String>.from(data['participants']);
    }

    // Get the other participant's ID (not the current user)
    final otherUser = participantsList.firstWhere(
          (id) => id != currentUserId,
      orElse: () => '',
    );

    // Get unread count specifically for the current user
    final unreadCountField = 'unreadCount_$currentUserId';
    final unreadCount = data[unreadCountField] ?? 0;

    return Chat(
      id: doc.id,
      participants: participantsList,
      otherUserId: otherUser,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
      unreadCount: unreadCount,
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;
  final bool isRead;

  ChatMessage({
    this.id = '',
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
