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
//   final String? recipientId;
//   final Timestamp createdAt;
//   final String? sentBy;// Admin who sent the notification
//   final bool? isRead;
//
//   NotificationModel({
//     required this.id,
//     required this.title,
//     required this.message,
//     required this.recipientType,
//     this.recipientId,
//     required this.createdAt,
//     this.sentBy,
//     this.isRead,
//   });
//
//   // Convert to Firestore document
//   Map<String, dynamic> toMap() {
//     return {
//       // Removing id from the document data since Firestore uses document ID separately
//       'title': title,
//       'message': message,
//       'recipientType': recipientType.toString().split('.').last,
//       'recipientId': recipientId,
//       'createdAt': createdAt,
//       'sentBy': sentBy,
//       'isRead': isRead ?? false,
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
//               (e) => e.toString().split('.').last == map['recipientType'],
//           orElse: () => NotificationRecipientType.all // Default value if not found
//       ),
//       recipientId: map['recipientId'],
//       createdAt: map['createdAt'] as Timestamp,
//       sentBy: map['sentBy'],
//       isRead: map['isRead'] ?? false,
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
//     // Create a new document reference with auto-generated ID
//     final docRef = notificationsCollection.doc();
//
//     final notification = NotificationModel(
//       id: docRef.id, // Use the auto-generated document ID
//       title: title,
//       message: message,
//       recipientType: recipientType,
//       createdAt: Timestamp.now(),
//       sentBy: senderInfo,
//       isRead: false,
//     );
//
//     // Save the notification data to the document
//     await docRef.set(notification.toMap());
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
//   // Fetch notifications with debug logging
//   Stream<List<NotificationModel>> getNotifications() {
//     return notificationsCollection
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       print("Notifications snapshot: ${snapshot.docs.length} documents"); // Debug log
//       return snapshot.docs
//           .map((doc) {
//         print("Document ID: ${doc.id}, Data: ${doc.data()}"); // Debug log
//         return NotificationModel.fromMap(
//             doc.data() as Map<String, dynamic>,
//             doc.id
//         );
//       })
//           .toList();
//     });
//   }
//
//   // Delete a notification by its ID
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



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';


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
  final String? recipientId;
  final Timestamp createdAt;
  final String? sentBy;// Admin who sent the notification
  final bool? isRead;
  final String type;// Added type field to track notification type (e.g., rating, payment, etc.)
  final String? providerId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.recipientType,
    this.recipientId,
    required this.createdAt,
    this.sentBy,
    this.isRead,
    this.type = '', // Default to empty string if not provided
    this.providerId,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      // Removing id from the document data since Firestore uses document ID separately
      'title': title,
      'message': message,
      'recipientType': recipientType.toString().split('.').last,
      'recipientId': recipientId,
      'createdAt': createdAt,
      'sentBy': sentBy,
      'isRead': isRead ?? false,
      'type': type, // Include type in map
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
      recipientId: map['recipientId'],
      createdAt: map['createdAt'] as Timestamp,
      sentBy: map['sentBy'],
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? '', // Extract type from map
    );
  }
}

// Firestore Service for Notifications
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
//     String type = '', // Added type parameter with default value
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
//     // Create a new document reference with auto-generated ID
//     final docRef = notificationsCollection.doc();
//
//     final notification = NotificationModel(
//       id: docRef.id, // Use the auto-generated document ID
//       title: title,
//       message: message,
//       recipientType: recipientType,
//       createdAt: Timestamp.now(),
//       sentBy: senderInfo,
//       isRead: false,
//       type: type, // Pass type to model
//     );
//
//     // Save the notification data to the document
//     await docRef.set(notification.toMap());
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
//   // Fetch notifications with debug logging
//   Stream<List<NotificationModel>> getNotifications() {
//     return notificationsCollection
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       print("Notifications snapshot: ${snapshot.docs.length} documents"); // Debug log
//       return snapshot.docs
//           .map((doc) {
//         print("Document ID: ${doc.id}, Data: ${doc.data()}"); // Debug log
//         return NotificationModel.fromMap(
//             doc.data() as Map<String, dynamic>,
//             doc.id
//         );
//       })
//           .toList();
//     });
//   }
//
//   // Delete a notification by its ID
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


class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Flutter Local Notifications Plugin setup
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Initialize notification services
  Future<void> initialize(BuildContext context) async {
    // Request notification permissions
    await _requestNotificationPermissions();

    // Configure local notifications
    await _configureLocalNotifications();

    // Configure Firebase Messaging
    await _configureFirebaseMessaging(context);

    // Subscribe to notification topics based on user role
    await _subscribeToTopics();
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Configure local notifications
  Future<void> _configureLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Initialization settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleNotificationTap(response);
      },
    );
  }

  // Configure Firebase Cloud Messaging
  Future<void> _configureFirebaseMessaging(BuildContext context) async {
    // Get the token for this device
    String? token = await _firebaseMessaging.getToken();

    // Save the token to Firestore for the current user
    if (token != null && _auth.currentUser != null) {
      await _saveDeviceToken(token);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: message.data['id'] ?? '',
      );
    });

    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate to appropriate screen based on notification
      _handleNotificationTap(
        NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: message.data['id'],
        ),
      );
    });
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background messages
    print('Handling a background message: ${message.messageId}');
  }

  // Save device token to Firestore
  Future<void> _saveDeviceToken(String token) async {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'deviceTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': Timestamp.now(),
      });
    }
  }

  // Subscribe to topics based on user role
  Future<void> _subscribeToTopics() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Get user role from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userRole = userDoc.data()?['role'] ?? '';

      // Subscribe to different topics based on role
      if (userRole == 'user') {
        await _firebaseMessaging.subscribeToTopic('user_notifications');
      } else if (userRole == 'serviceProvider') {
        await _firebaseMessaging.subscribeToTopic('provider_notifications');
      }

      // Subscribe all users to general notifications
      await _firebaseMessaging.subscribeToTopic('all_notifications');
    }
  }

  // Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String payload = '',
  }) async {
    // Android notification details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'notification_channel_id',
      'App Notifications',
      channelDescription: 'Channel for app notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    // Notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show notification
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    // Navigate to appropriate screen based on notification payload
    if (response.payload != null && response.payload!.isNotEmpty) {
      // You can implement navigation to specific screens based on payload
      print('Notification tapped with payload: ${response.payload}');

      // Example: Navigate to notification details screen
      // Navigator.pushNamed(context, '/notification_details', arguments: response.payload);
    }
  }

  // Collection reference - keep your existing implementation
  CollectionReference get notificationsCollection =>
      _firestore.collection('notifications');

  // Send a new notification - enhanced version of your existing method
  Future<void> sendNotification({
    required String title,
    required String message,
    required NotificationRecipientType recipientType,
    String? recipientId,
    String? sentBy,
    String type = '',
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
      id: docRef.id,
      title: title,
      message: message,
      recipientType: recipientType,
      recipientId: recipientId, // Add specific recipient ID if targeting a specific user
      createdAt: Timestamp.now(),
      sentBy: senderInfo,
      isRead: false,
      type: type,
    );

    // Save the notification data to Firestore
    await docRef.set(notification.toMap());

    // Handle sending push notifications based on recipient type
    if (recipientType == NotificationRecipientType.all) {
      // Send to all users via topic messaging
      await _sendPushNotificationToTopic('all_notifications', title, message, docRef.id);
    } else if (recipientType == NotificationRecipientType.user) {
      // Send to all regular users
      await _sendPushNotificationToTopic('user_notifications', title, message, docRef.id);
    } else if (recipientType == NotificationRecipientType.serviceProvider) {
      // Send to all service providers
      await _sendPushNotificationToTopic('provider_notifications', title, message, docRef.id);
    }

    // If there's a specific recipientId, send directly to that user
    if (recipientId != null) {
      await _sendPushNotificationToUser(recipientId, title, message, docRef.id);
    }
  }

  // Send push notification to a topic
  Future<void> _sendPushNotificationToTopic(
      String topic,
      String title,
      String message,
      String notificationId
      ) async {
    // This would typically be handled by your backend
    // For demo purposes, we're showing the implementation concept

    // In a real application, you would have a Cloud Function or backend API endpoint
    // that sends FCM messages to topics

    // Example Cloud Function (implement in your Firebase project):
    /*
    exports.sendTopicNotification = functions.https.onCall(async (data, context) => {
      // Check if request is authorized
      if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
      }

      const topic = data.topic;
      const title = data.title;
      const body = data.body;
      const notificationId = data.notificationId;

      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          id: notificationId,
        },
        topic: topic,
      };

      // Send message
      return admin.messaging().send(message);
    });
    */
  }

  // Send push notification to a specific user
  Future<void> _sendPushNotificationToUser(
      String userId,
      String title,
      String message,
      String notificationId
      ) async {
    try {
      // Get user's device tokens from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final deviceTokens = userDoc.data()?['deviceTokens'] ?? [];

      if (deviceTokens.isNotEmpty) {
        // This would typically be handled by your backend
        // For local testing/development, you can show a local notification

        // Show local notification if the recipient is the current user
        if (userId == _auth.currentUser?.uid) {
          await _showLocalNotification(
            title: title,
            body: message,
            payload: notificationId,
          );
        }

        // In a real application, you would have a Cloud Function or backend API
        // that sends FCM messages to specific device tokens
      }
    } catch (e) {
      print('Error sending push notification to user: $e');
    }
  }

  // Keep your existing methods
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



  // Fetch notifications - keep your existing implementation
  Stream<List<NotificationModel>> getNotifications() {
    return notificationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print("Notifications snapshot: ${snapshot.docs.length} documents");
      return snapshot.docs
          .map((doc) {
        print("Document ID: ${doc.id}, Data: ${doc.data()}");
        return NotificationModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id
        );
      })
          .toList();
    });
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await notificationsCollection.doc(notificationId).update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return notificationsCollection
        .where('isRead', isEqualTo: false)
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete notification - keep your existing implementation
  Future<void> deleteNotification(String notificationId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<NotificationModel>> getUserNotifications2(String userId, String userRole) {
    return notificationsCollection
        .where(Filter.or(
        Filter('recipientId', isEqualTo: userId),
        Filter.and(
            Filter('recipientId', isNull: true),
            Filter('recipientType', isEqualTo: userRole)
        ),
        Filter.and(
            Filter('recipientId', isNull: true),
            Filter('recipientType', isEqualTo: 'all')
        )
    ))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print("User notifications snapshot: ${snapshot.docs.length} documents");
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id
      ))
          .toList();
    });
  }
}