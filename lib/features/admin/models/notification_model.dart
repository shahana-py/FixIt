// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// // Enum for notification recipient types
// enum NotificationRecipientType {
//   all,
//   user,
//   serviceProvider
// }
//
// // Notification Model Class
// class NotificationModel {
//   final String id;
//   final String title;
//   final String message;
//   final NotificationRecipientType recipientType;
//   final Timestamp createdAt;
//   final String? sentBy;// Admin who sent the notification
//   final bool? isRead;
//
//   NotificationModel({
//     required this.id,
//     required this.title,
//     required this.message,
//     required this.recipientType,
//     required this.createdAt,
//     this.sentBy,
//     this.isRead,
//   });
//
//   // Convert to Firestore document
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'message': message,
//       'recipientType': recipientType.toString().split('.').last,
//       'createdAt': createdAt,
//       'sentBy': sentBy,
//       'isRead':false,
//
//     };
//   }
//
//   // Create from Firestore document
//   factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
//     return NotificationModel(
//       id: documentId,
//       title: map['title'] ?? '',
//       message: map['message'] ?? '',
//       recipientType: NotificationRecipientType.values.firstWhere(
//               (e) => e.toString().split('.').last == map['recipientType']
//       ),
//       createdAt: map['createdAt'] as Timestamp,
//       sentBy: map['sentBy'],
//       isRead: map['isRead'],
//     );
//   }
// }
//
// // Firestore Service for Notifications
// class NotificationService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // Collection reference
//   CollectionReference get notificationsCollection =>
//       _firestore.collection('notifications');
//
//   // Send a new notification
//   Future<void> sendNotification({
//     required String title,
//     required String message,
//     required NotificationRecipientType recipientType,
//     String? sentBy,
//   }) async {
//     // If sentBy is not provided, use current user
//     final currentUser = sentBy ?? _auth.currentUser?.uid;
//
//     if (currentUser == null) {
//       throw Exception('No user logged in');
//     }
//
//     // Get sender display info
//     String senderInfo = await _getSenderInfo(currentUser);
//
//     final notification = NotificationModel(
//       id: notificationsCollection.doc().id, // Auto-generate ID
//       title: title,
//       message: message,
//       recipientType: recipientType,
//       createdAt: Timestamp.now(),
//       sentBy: senderInfo,
//       isRead: false,
//     );
//
//     await notificationsCollection.doc(notification.id).set(
//         notification.toMap()
//     );
//   }
//
//   // Fetch sender information
//   Future<String> _getSenderInfo(String userId) async {
//     try {
//       // Try to get user from Firebase Authentication
//       final user = _auth.currentUser;
//       if (user != null) {
//         // Prefer display name, fall back to email
//         return user.displayName ?? user.email ?? user.uid;
//       }
//
//       // If no user in auth, try Firestore users collection
//       final userDoc = await _firestore.collection('users').doc(userId).get();
//       if (userDoc.exists) {
//         return userDoc.data()?['displayName'] ??
//             userDoc.data()?['email'] ??
//             userId;
//       }
//
//       return userId;
//     } catch (e) {
//       return userId;
//     }
//   }
//
//   // Fetch notifications (optional method)
//   Stream<List<NotificationModel>> getNotifications() {
//     return notificationsCollection
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => NotificationModel.fromMap(
//         doc.data() as Map<String, dynamic>, doc.id))
//         .toList());
//   }
//
// // Delete a notification by its ID
//   Future<void> deleteNotification(String notificationId) async {
//     try {
//       // Check if the user is authenticated
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) {
//         throw Exception('No user logged in');
//       }
//
//       // Delete the notification from Firestore
//       await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
//     } catch (e) {
//       // Rethrow the error to be handled by the caller
//       rethrow;
//     }
//   }
// }
//



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enum for notification recipient types
enum NotificationRecipientType {
  all,
  user,
  serviceProvider
}

// Notification Model Class
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationRecipientType recipientType;
  final Timestamp createdAt;
  final String? sentBy;// Admin who sent the notification
  final bool? isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.recipientType,
    required this.createdAt,
    this.sentBy,
    this.isRead,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      // Removing id from the document data since Firestore uses document ID separately
      'title': title,
      'message': message,
      'recipientType': recipientType.toString().split('.').last,
      'createdAt': createdAt,
      'sentBy': sentBy,
      'isRead': isRead ?? false,
    };
  }

  // Create from Firestore document
  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      recipientType: NotificationRecipientType.values.firstWhere(
              (e) => e.toString().split('.').last == map['recipientType'],
          orElse: () => NotificationRecipientType.all // Default value if not found
      ),
      createdAt: map['createdAt'] as Timestamp,
      sentBy: map['sentBy'],
      isRead: map['isRead'] ?? false,
    );
  }
}

// Firestore Service for Notifications
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get notificationsCollection =>
      _firestore.collection('notifications');

  // Send a new notification
  Future<void> sendNotification({
    required String title,
    required String message,
    required NotificationRecipientType recipientType,
    String? sentBy,
  }) async {
    // If sentBy is not provided, use current user
    final currentUser = sentBy ?? _auth.currentUser?.uid;

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    // Get sender display info
    String senderInfo = await _getSenderInfo(currentUser);

    // Create a new document reference with auto-generated ID
    final docRef = notificationsCollection.doc();

    final notification = NotificationModel(
      id: docRef.id, // Use the auto-generated document ID
      title: title,
      message: message,
      recipientType: recipientType,
      createdAt: Timestamp.now(),
      sentBy: senderInfo,
      isRead: false,
    );

    // Save the notification data to the document
    await docRef.set(notification.toMap());
  }

  // Fetch sender information
  Future<String> _getSenderInfo(String userId) async {
    try {
      // Try to get user from Firebase Authentication
      final user = _auth.currentUser;
      if (user != null) {
        // Prefer display name, fall back to email
        return user.displayName ?? user.email ?? user.uid;
      }

      // If no user in auth, try Firestore users collection
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['displayName'] ??
            userDoc.data()?['email'] ??
            userId;
      }

      return userId;
    } catch (e) {
      return userId;
    }
  }

  // Fetch notifications with debug logging
  Stream<List<NotificationModel>> getNotifications() {
    return notificationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print("Notifications snapshot: ${snapshot.docs.length} documents"); // Debug log
      return snapshot.docs
          .map((doc) {
        print("Document ID: ${doc.id}, Data: ${doc.data()}"); // Debug log
        return NotificationModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id
        );
      })
          .toList();
    });
  }

  // Delete a notification by its ID
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Check if the user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Delete the notification from Firestore
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      // Rethrow the error to be handled by the caller
      rethrow;
    }
  }
}