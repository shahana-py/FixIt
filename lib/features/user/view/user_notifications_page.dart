

import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Import the notification model
import '../../admin/models/notification_model.dart';

class UserNotificationPage extends StatefulWidget {
  const UserNotificationPage({Key? key}) : super(key: key);

  @override
  _UserNotificationPageState createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> {
  final NotificationService _notificationService = NotificationService();
  late Stream<List<NotificationModel>> _notificationsStream;
  bool _isLoading = false;
  // Track hidden notifications locally (not deleted from Firestore)
  final Set<String> _hiddenNotificationIds = {};
  // Current user ID to associate with hidden notifications
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Get current user ID
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // Load hidden notification IDs from SharedPreferences
    _loadHiddenNotifications();
    // Initialize the stream in initState to ensure it's set up correctly
    _notificationsStream = _getAllNotifications();
  }

  // Load hidden notifications from SharedPreferences
  Future<void> _loadHiddenNotifications() async {
    try {
      if (_currentUserId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final hiddenNotificationsJson = prefs.getString('hidden_notifications_$_currentUserId');

      if (hiddenNotificationsJson != null) {
        final List<dynamic> hiddenList = jsonDecode(hiddenNotificationsJson);
        setState(() {
          _hiddenNotificationIds.addAll(hiddenList.map((id) => id.toString()));
        });
        print('Loaded ${_hiddenNotificationIds.length} hidden notifications');
      }
    } catch (e) {
      print('Error loading hidden notifications: $e');
    }
  }

  // Save hidden notifications to SharedPreferences
  Future<void> _saveHiddenNotifications() async {
    try {
      if (_currentUserId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final hiddenNotificationsJson = jsonEncode(_hiddenNotificationIds.toList());
      await prefs.setString('hidden_notifications_$_currentUserId', hiddenNotificationsJson);
      print('Saved ${_hiddenNotificationIds.length} hidden notifications');
    } catch (e) {
      print('Error saving hidden notifications: $e');
    }
  }

  // Method to show notification details in a dialog
  void _showNotificationDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            notification.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff0F3966),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _formatDateTime(notification.createdAt.toDate()),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close', style: TextStyle(color: Color(0xff0F3966))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hide', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _hideNotification(notification.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0F3966),
        iconTheme: const IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Notifications"),
        actions: [
          // Clear all button
          if (!_isLoading && _hiddenNotificationIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: _clearAllHiddenNotifications,
              tooltip: 'Reset Hidden Notifications',
            ),
          // Refresh button in the app bar
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshNotifications,
              tooltip: 'Refresh Notifications',
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: StreamBuilder<List<NotificationModel>>(
          stream: _notificationsStream,
          builder: (context, snapshot) {
            // Error state
            if (snapshot.hasError) {
              return _buildErrorView();
            }

            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // No notifications or all hidden
            List<NotificationModel> visibleNotifications = [];
            if (snapshot.hasData) {
              visibleNotifications = snapshot.data!.where(
                      (notification) => !_hiddenNotificationIds.contains(notification.id)
              ).toList();
            }

            if (visibleNotifications.isEmpty) {
              return _buildNoNotificationsView();
            }

            // Display notifications
            return _buildNotificationsList(visibleNotifications);
          },
        ),
      ),
    );
  }

  // Build error view
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            "Error loading notifications",
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
            ),
          ),
          TextButton(
            onPressed: _refreshNotifications,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Build no notifications view
  Widget _buildNoNotificationsView() {
    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const Icon(
                  Icons.notifications_off,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  "No notifications available",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refreshNotifications,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0F3966),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build notifications list with onTap to show dialog
  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    // Sort notifications by createdAt timestamp (newest first)
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(right: 20,left: 20),
        child: const Divider(height: 1, thickness: 1),
      ),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return InkWell(
          onTap: () => _showNotificationDialog(notification),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                _buildNotificationIcon(notification),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0F3966),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(notification.createdAt.toDate()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => _hideNotification(notification.id),
                  tooltip: 'Hide',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build notification icon based on type
  Widget _buildNotificationIcon(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    // Determine icon and color based on notification type
    if (notification.type == "booking_arrived" ) {
      iconData = Icons.location_on;
      iconColor = Colors.amber;
    } else if (notification.type == "booking_in_progress") {
      iconData = Icons.engineering;
      iconColor = Colors.blue;
    } else if (notification.type == "booking_completed") {
      iconData = Icons.check_circle_sharp;
      iconColor = Colors.green;
    }
    else if (notification.type == "booking_dispatched") {
      iconData = Icons.local_shipping;
      iconColor = Colors.pink;
    }else if (notification.type == "booking_rescheduled") {
      iconData = Icons.calendar_month;
      iconColor = Colors.orange;
    }else if (notification.type == "booking_confirmed") {
      iconData = Icons.thumb_up;
      iconColor = Colors.lightGreen;
    }
    else if (notification.type == "payment") {
      iconData = Icons.payment;
      iconColor = Colors.greenAccent;
    }else if (notification.type == "refund_processed") {
      iconData = Icons.attach_money;
      iconColor = Colors.teal;
    }
    else if (notification.type == "complaint_resolved") {
      iconData = Icons.feedback;
      iconColor = Colors.red;
    } else {
      iconData = Icons.notifications;
      iconColor = const Color(0xff0F3966);
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 25,
      ),
    );
  }

  // Get color based on notification type
  Color _getNotificationColor(String type) {
    switch (type) {

      case "payment":
        return Colors.green;
      case "complaint_resolved":
        return Colors.red;
      case "booking_arrived":
      case "booking_in_progress":
      case "booking_completed":
      case "booking_dispatched":
        return Colors.amber;
      default:
        return const Color(0xff0F3966);
    }
  }

  // Custom stream to fetch all notifications for the current user
  // Stream<List<NotificationModel>> _getAllNotifications() {
  //   final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  //   print('Fetching notifications for user: $currentUserId');
  //
  //   return FirebaseFirestore.instance
  //       .collection('notifications')
  //       .where(Filter.or(
  //     // Notifications for all users
  //       Filter('recipientType', isEqualTo: NotificationRecipientType.all.toString().split('.').last),
  //       // Notifications for specific user
  //       Filter('recipientUid', isEqualTo: currentUserId),
  //       // For backwards compatibility with older notifications
  //       Filter('user_id', isEqualTo: currentUserId)
  //   ))
  //       .orderBy('createdAt', descending: true) // Sort by createdAt timestamp in descending order (newest first)
  //       .snapshots()
  //       .map((snapshot) {
  //     print('Retrieved ${snapshot.docs.length} notifications'); // Debug log
  //
  //     return snapshot.docs.map((doc) {
  //       Map<String, dynamic> data = doc.data();
  //
  //       // Debug print to see the actual structure of documents
  //       print('Document ID: ${doc.id}, Type: ${data['type']}, Data: $data');
  //
  //       // Create a notification model from the document
  //       return NotificationModel(
  //         id: doc.id,
  //         title: data['title'] ?? '',
  //         message: data['message'] ?? '',
  //         // Use timestamp if it exists, otherwise use createdAt or default to now
  //         createdAt: data['timestamp'] ?? data['createdAt'] ?? Timestamp.now(),
  //         recipientType: _parseRecipientType(data['recipientType']),
  //         recipientId: data['recipientId'] ?? data['recipientUid'] ?? data['user_id'],
  //         sentBy: data['sentBy'] ?? data['senderName'],
  //         isRead: data['isRead'] ?? data['is_read'] ?? false,
  //         type: data['type'] ?? '',
  //       );
  //     }).toList();
  //   })
  //       .handleError((error) {
  //     print('Error fetching notifications: $error');
  //     return <NotificationModel>[];
  //   });
  // }

  // Stream<List<NotificationModel>> _getAllNotifications() {
  //   final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  //   print('Fetching notifications for user: $currentUserId');
  //
  //   return FirebaseFirestore.instance
  //       .collection('notifications')
  //       .where(Filter.or(
  //     // Notifications for all users
  //     Filter('recipientType', isEqualTo: 'all'),
  //     // Notifications for specific user
  //     Filter('recipientId', isEqualTo: currentUserId),
  //     // For backwards compatibility with older notifications
  //     Filter('user_id', isEqualTo: currentUserId),
  //     // For notifications with recipientType 'user' (as shown in your document)
  //     Filter('recipientType', isEqualTo: 'user'),
  //   ))
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //     print('Retrieved ${snapshot.docs.length} notifications');
  //
  //     return snapshot.docs.map((doc) {
  //       Map<String, dynamic> data = doc.data();
  //       print('Document ID: ${doc.id}, Type: ${data['type']}, Data: $data');
  //
  //       return NotificationModel(
  //         id: doc.id,
  //         title: data['title'] ?? '',
  //         message: data['message'] ?? '',
  //         createdAt: data['createdAt'] ?? Timestamp.now(),
  //         recipientType: _parseRecipientType(data['recipientType']),
  //         recipientId: data['recipientId'] ?? data['user_id'],
  //         sentBy: data['sentBy'] ?? '',
  //         isRead: data['isRead'] ?? false,
  //         type: data['type'] ?? '',
  //       );
  //     }).toList();
  //   }).handleError((error) {
  //     print('Error fetching notifications: $error');
  //     return <NotificationModel>[];
  //   });
  // }


  Stream<List<NotificationModel>> _getAllNotifications() {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print('Fetching notifications for user: $currentUserId');

    return FirebaseFirestore.instance
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
      print('Retrieved ${snapshot.docs.length} total notifications'); // Debug log

      List<NotificationModel> relevantNotifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();

        // Debug print to see the actual structure of documents
        print('Document ID: ${doc.id}, Type: ${data['type']}, Data: $data');

        // IMPORTANT: Check if this notification is relevant for the current service provider
        bool isRelevantForThisProvider = false;

        // First, determine if it's a provider-specific notification
        if (data['type'] == 'booking_dispatched' || data['type'] == 'booking_arrived' || data['type'] == 'booking_rescheduled' || data['type'] == 'booking_confirmed' ||data['type'] == 'booking_completed' || data['type'] == 'complaint_resolved') {
          // For provider-specific notifications, check if it's meant for this provider
          isRelevantForThisProvider =
              (data['user_id'] == currentUserId) ||
                  (data['recipientId'] == currentUserId) ||
                  (data['recipientUid'] == currentUserId);
        } else {
          // For general notifications, check recipient type
          String recipientType = (data['recipientType'] ?? '').toString().toLowerCase();

          // Check if it's for all service providers or for everyone
          isRelevantForThisProvider =
              recipientType == 'user' ||
                  recipientType == 'user' ||
                  recipientType == 'all';
        }

        // If the notification is relevant, add it to our list
        if (isRelevantForThisProvider) {
          // Parse recipient type properly
          NotificationRecipientType recipientType = _parseRecipientType(data['recipientType']);

          // Get timestamp from the appropriate field
          Timestamp timestamp = data['timestamp'] ??
              data['createdAt'] ??
              Timestamp.now();

          // Create notification model
          NotificationModel notification = NotificationModel(
            id: doc.id,
            title: data['title'] ?? '',
            message: data['message'] ?? '',
            createdAt: timestamp,
            recipientType: recipientType,
            recipientId: data['recipientId'] ?? data['recipientUid'] ?? data['user_id'] ?? '',
            sentBy: data['sentBy'] ?? data['senderName'] ?? '',
            isRead: data['isRead'] ?? data['is_read'] ?? false,
            type: data['type'] ?? '',
          );

          relevantNotifications.add(notification);
        }
      }

      // Sort notifications by timestamp (newest first)
      relevantNotifications.sort((a, b) =>
          b.createdAt.compareTo(a.createdAt));

      print('Filtered down to ${relevantNotifications.length} relevant notifications');
      return relevantNotifications;
    })
        .handleError((error) {
      print('Error fetching notifications: $error');
      return <NotificationModel>[];
    });
  }

  // Helper method to parse recipient type
  NotificationRecipientType _parseRecipientType(String? type) {
    if (type == null) return NotificationRecipientType.all;

    try {
      return NotificationRecipientType.values.firstWhere(
              (e) => e.toString().split('.').last.toLowerCase() == type.toLowerCase(),
          orElse: () => NotificationRecipientType.all
      );
    } catch (e) {
      return NotificationRecipientType.all;
    }
  }

  // Method to refresh notifications manually
  Future<void> _refreshNotifications() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Make sure we have the latest hidden notifications
      await _loadHiddenNotifications();

      // Recreate the stream to force a refresh
      _notificationsStream = _getAllNotifications();

      // Simulate a delay to show loading indicator
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print('Refresh error: $e');
      // Optionally show a snackbar or toast to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to hide a notification and persist the state
  Future<void> _hideNotification(String notificationId) async {
    setState(() {
      _hiddenNotificationIds.add(notificationId);
    });

    // Persist hidden notifications to SharedPreferences
    await _saveHiddenNotifications();

    // Show a snackbar to let the user know
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification hidden'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            setState(() {
              _hiddenNotificationIds.remove(notificationId);
            });
            // Update the persisted hidden notifications
            await _saveHiddenNotifications();
          },
        ),
      ),
    );
  }

  // Helper method to format date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Method to clear all hidden notifications
  Future<void> _clearAllHiddenNotifications() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Hidden Notifications'),
        content: const Text('This will show all previously hidden notifications again. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _hiddenNotificationIds.clear();
              });
              await _saveHiddenNotifications();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All hidden notifications have been reset'),
                ),
              );

              // Refresh the list
              _refreshNotifications();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Make sure all changes are saved when the page is closed
    _saveHiddenNotifications();
    super.dispose();
  }
}