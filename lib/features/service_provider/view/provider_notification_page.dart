//
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// // Import the notification model
// import '../../admin/models/notification_model.dart';
//
// class ServiceProviderNotificationPage extends StatefulWidget {
//   const ServiceProviderNotificationPage({Key? key}) : super(key: key);
//
//   @override
//   _ServiceProviderNotificationPageState createState() => _ServiceProviderNotificationPageState();
// }
//
// class _ServiceProviderNotificationPageState extends State<ServiceProviderNotificationPage> {
//   final NotificationService _notificationService = NotificationService();
//   late Stream<List<NotificationModel>> _notificationsStream;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the stream in initState to ensure it's set up correctly
//     _notificationsStream = _getAllNotifications();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xff0F3966),
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: AppBarTitle(text: "Notifications"),
//         actions: [
//           // Refresh button in the app bar
//           if (!_isLoading)
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.white),
//               onPressed: _refreshNotifications,
//               tooltip: 'Refresh Notifications',
//             ),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               child: SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refreshNotifications,
//         child: StreamBuilder<List<NotificationModel>>(
//           stream: _notificationsStream,
//           builder: (context, snapshot) {
//             // Error state
//             if (snapshot.hasError) {
//               return _buildErrorView();
//             }
//
//             // Loading state
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             // No notifications
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return _buildNoNotificationsView();
//             }
//
//             // Display notifications
//             return _buildNotificationsList(snapshot.data!);
//           },
//         ),
//       ),
//     );
//   }
//
//   // Build error view
//   Widget _buildErrorView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.error_outline,
//             size: 100,
//             color: Colors.red,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "Error loading notifications",
//             style: TextStyle(
//               color: Colors.red,
//               fontSize: 18,
//             ),
//           ),
//           TextButton(
//             onPressed: _refreshNotifications,
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Build no notifications view
//   Widget _buildNoNotificationsView() {
//     return RefreshIndicator(
//       onRefresh: _refreshNotifications,
//       child: ListView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         children: [
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 100),
//                 const Icon(
//                   Icons.notifications_off,
//                   size: 100,
//                   color: Colors.grey,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "No notifications available",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: _refreshNotifications,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Refresh'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xff0F3966),
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Build notifications list with improved styling
//   Widget _buildNotificationsList(List<NotificationModel> notifications) {
//     return ListView.builder(
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         final notification = notifications[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           child: Dismissible(
//             key: Key(notification.id),
//             background: _buildDismissBackground(),
//             direction: DismissDirection.endToStart,
//             onDismissed: (direction) {
//               _deleteNotification(notification.id);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.2),
//                     spreadRadius: 1,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(12),
//                 leading: _buildNotificationIcon(notification),
//                 title: Text(
//                   notification.title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xff0F3966),
//                   ),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 6),
//                     Text(
//                       notification.message,
//                       style: TextStyle(
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _formatDateTime(notification.createdAt.toDate()),
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     _buildNotificationBadge(notification),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Build notification icon based on recipient type
//   Widget _buildNotificationIcon(NotificationModel notification) {
//     return CircleAvatar(
//       backgroundColor: _getNotificationColor(notification.recipientType),
//       child: Icon(
//         _getNotificationIcon(notification.recipientType),
//         color: Colors.white,
//       ),
//     );
//   }
//
//   // Get icon based on recipient type
//   IconData _getNotificationIcon(NotificationRecipientType recipientType) {
//     switch (recipientType) {
//       case NotificationRecipientType.serviceProvider:
//         return Icons.build;
//       case NotificationRecipientType.user:
//         return Icons.person;
//       default:
//         return Icons.notifications;
//     }
//   }
//
//   // Get color based on recipient type
//   Color _getNotificationColor(NotificationRecipientType recipientType) {
//     switch (recipientType) {
//       case NotificationRecipientType.serviceProvider:
//         return Colors.orange;
//       case NotificationRecipientType.user:
//         return Colors.blue;
//       default:
//         return const Color(0xff0F3966);
//     }
//   }
//
//   // Build notification type badge
//   Widget _buildNotificationBadge(NotificationModel notification) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _getNotificationColor(notification.recipientType).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         notification.recipientType.toString().split('.').last.toUpperCase(),
//         style: TextStyle(
//           fontSize: 10,
//           color: _getNotificationColor(notification.recipientType),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   // Build dismiss background
//   Widget _buildDismissBackground() {
//     return Container(
//       color: Colors.red,
//       alignment: Alignment.centerRight,
//       padding: const EdgeInsets.only(right: 20),
//       child: const Icon(
//         Icons.delete,
//         color: Colors.white,
//       ),
//     );
//   }
//
//   // Custom stream to fetch all notifications for service provider and user
//   Stream<List<NotificationModel>> _getAllNotifications() {
//     return FirebaseFirestore.instance
//         .collection('notifications')
//         .where('recipientType', whereIn: [
//       NotificationRecipientType.serviceProvider.toString().split('.').last,
//       NotificationRecipientType.all.toString().split('.').last,
//     ])
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => NotificationModel.fromMap(
//           doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     }).handleError((error) {
//       print('Error fetching notifications: $error');
//       return <NotificationModel>[];
//     });
//   }
//
//   // Method to refresh notifications manually
//   Future<void> _refreshNotifications() async {
//     if (_isLoading) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Recreate the stream to force a refresh
//       _notificationsStream = _getAllNotifications();
//
//       // Simulate a delay to show loading indicator
//       await Future.delayed(const Duration(seconds: 1));
//     } catch (e) {
//       print('Refresh error: $e');
//       // Optionally show a snackbar or toast to the user
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Optional method to delete a specific notification
//   Future<void> _deleteNotification(String notificationId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(notificationId)
//           .delete();
//     } catch (e) {
//       print('Error deleting notification: $e');
//       // Optionally show a snackbar or toast to the user
//     }
//   }
//
//   // Helper method to format date and time
//   String _formatDateTime(DateTime dateTime) {
//     return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
//   }
// }
//
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// // Import the notification model
// import '../../admin/models/notification_model.dart';
//
// class ServiceProviderNotificationPage extends StatefulWidget {
//   const ServiceProviderNotificationPage({Key? key}) : super(key: key);
//
//   @override
//   _ServiceProviderNotificationPageState createState() => _ServiceProviderNotificationPageState();
// }
//
// class _ServiceProviderNotificationPageState extends State<ServiceProviderNotificationPage> {
//   final NotificationService _notificationService = NotificationService();
//   late Stream<List<NotificationModel>> _notificationsStream;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the stream in initState to ensure it's set up correctly
//     _notificationsStream = _getAllNotifications();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xff0F3966),
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: AppBarTitle(text: "Notifications"),
//         actions: [
//           // Refresh button in the app bar
//           if (!_isLoading)
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.white),
//               onPressed: _refreshNotifications,
//               tooltip: 'Refresh Notifications',
//             ),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               child: SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refreshNotifications,
//         child: StreamBuilder<List<NotificationModel>>(
//           stream: _notificationsStream,
//           builder: (context, snapshot) {
//             // Error state
//             if (snapshot.hasError) {
//               return _buildErrorView();
//             }
//
//             // Loading state
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             // No notifications
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return _buildNoNotificationsView();
//             }
//
//             // Display notifications
//             return _buildNotificationsList(snapshot.data!);
//           },
//         ),
//       ),
//     );
//   }
//
//   // Build error view
//   Widget _buildErrorView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.error_outline,
//             size: 100,
//             color: Colors.red,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "Error loading notifications",
//             style: TextStyle(
//               color: Colors.red,
//               fontSize: 18,
//             ),
//           ),
//           TextButton(
//             onPressed: _refreshNotifications,
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Build no notifications view
//   Widget _buildNoNotificationsView() {
//     return RefreshIndicator(
//       onRefresh: _refreshNotifications,
//       child: ListView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         children: [
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 100),
//                 const Icon(
//                   Icons.notifications_off,
//                   size: 100,
//                   color: Colors.grey,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "No notifications available",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: _refreshNotifications,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Refresh'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xff0F3966),
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Build notifications list with ExpansionTile
//   Widget _buildNotificationsList(List<NotificationModel> notifications) {
//     return ListView.builder(
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         final notification = notifications[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           child: Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Dismissible(
//               key: Key(notification.id),
//               background: _buildDismissBackground(),
//               direction: DismissDirection.endToStart,
//               onDismissed: (direction) {
//                 _deleteNotification(notification.id);
//               },
//               child: ExpansionTile(
//                 leading: _buildNotificationIcon(notification),
//                 title: Text(
//                   notification.title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xff0F3966),
//                   ),
//                 ),
//                 subtitle: Text(
//                   _formatDateTime(notification.createdAt.toDate()),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 trailing: _buildNotificationBadge(notification),
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Text(
//                       notification.message,
//                       style: TextStyle(
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Build notification icon based on recipient type
//   Widget _buildNotificationIcon(NotificationModel notification) {
//     return CircleAvatar(
//       backgroundColor: _getNotificationColor(notification.recipientType),
//       child: Icon(
//         _getNotificationIcon(notification.recipientType),
//         color: Colors.white,
//       ),
//     );
//   }
//
//   // Get icon based on recipient type
//   IconData _getNotificationIcon(NotificationRecipientType recipientType) {
//     switch (recipientType) {
//       case NotificationRecipientType.serviceProvider:
//         return Icons.build;
//       case NotificationRecipientType.user:
//         return Icons.person;
//       default:
//         return Icons.notifications;
//     }
//   }
//
//   // Get color based on recipient type
//   Color _getNotificationColor(NotificationRecipientType recipientType) {
//     switch (recipientType) {
//       case NotificationRecipientType.serviceProvider:
//         return Colors.orange;
//       case NotificationRecipientType.user:
//         return Colors.blue;
//       default:
//         return const Color(0xff0F3966);
//     }
//   }
//
//   // Build notification type badge
//   Widget _buildNotificationBadge(NotificationModel notification) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _getNotificationColor(notification.recipientType).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         notification.recipientType.toString().split('.').last.toUpperCase(),
//         style: TextStyle(
//           fontSize: 10,
//           color: _getNotificationColor(notification.recipientType),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   // Build dismiss background
//   Widget _buildDismissBackground() {
//     return Container(
//       color: Colors.red,
//       alignment: Alignment.centerRight,
//       padding: const EdgeInsets.only(right: 20),
//       child: const Icon(
//         Icons.delete,
//         color: Colors.white,
//       ),
//     );
//   }
//
//   // Custom stream to fetch all notifications for service provider and user
//   Stream<List<NotificationModel>> _getAllNotifications() {
//     return FirebaseFirestore.instance
//         .collection('notifications')
//         .where('recipientType', whereIn: [
//       NotificationRecipientType.serviceProvider.toString().split('.').last,
//       NotificationRecipientType.user.toString().split('.').last,
//     ])
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => NotificationModel.fromMap(
//           doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     }).handleError((error) {
//       print('Error fetching notifications: $error');
//       return <NotificationModel>[];
//     });
//   }
//
//   // Method to refresh notifications manually
//   Future<void> _refreshNotifications() async {
//     if (_isLoading) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Recreate the stream to force a refresh
//       _notificationsStream = _getAllNotifications();
//
//       // Simulate a delay to show loading indicator
//       await Future.delayed(const Duration(seconds: 1));
//     } catch (e) {
//       print('Refresh error: $e');
//       // Optionally show a snackbar or toast to the user
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Optional method to delete a specific notification
//   Future<void> _deleteNotification(String notificationId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(notificationId)
//           .delete();
//     } catch (e) {
//       print('Error deleting notification: $e');
//       // Optionally show a snackbar or toast to the user
//     }
//   }
//
//   // Helper method to format date and time
//   String _formatDateTime(DateTime dateTime) {
//     return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
//   }
// }



import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Import the notification model
import '../../admin/models/notification_model.dart';

class ServiceProviderNotificationPage extends StatefulWidget {
  const ServiceProviderNotificationPage({Key? key}) : super(key: key);

  @override
  _ServiceProviderNotificationPageState createState() => _ServiceProviderNotificationPageState();
}

class _ServiceProviderNotificationPageState extends State<ServiceProviderNotificationPage> {
  final NotificationService _notificationService = NotificationService();
  late Stream<List<NotificationModel>> _notificationsStream;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the stream in initState to ensure it's set up correctly
    _notificationsStream = _getAllNotifications();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateTime(notification.createdAt.toDate()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  _buildNotificationBadge(notification),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(

              child: const Text('Close',style: TextStyle(color: Color(0xff0F3966)),),
              onPressed: () {
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

            // No notifications
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildNoNotificationsView();
            }

            // Display notifications
            return _buildNotificationsList(snapshot.data!);
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
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Dismissible(
              key: Key(notification.id),
              background: _buildDismissBackground(),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _deleteNotification(notification.id);
              },
              child: ListTile(
                onTap: () => _showNotificationDialog(notification),
                leading: _buildNotificationIcon(notification),
                title: Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F3966),
                  ),
                ),
                subtitle: Text(
                  _formatDateTime(notification.createdAt.toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: _buildNotificationBadge(notification),
              ),
            ),
          ),
        );
      },
    );
  }

  // Build notification icon based on recipient type
  Widget _buildNotificationIcon(NotificationModel notification) {
    return CircleAvatar(
      backgroundColor: _getNotificationColor(notification.recipientType),
      child: Icon(
        Icons.notifications,
        color: Colors.white,
      ),
    );
  }

  // Get icon based on recipient type
  // IconData _getNotificationIcon(NotificationRecipientType recipientType) {
  //   switch (recipientType) {
  //     case NotificationRecipientType.serviceProvider:
  //       return Icons.build;
  //     case NotificationRecipientType.user:
  //       return Icons.person;
  //     default:
  //       return Icons.notifications;
  //   }
  // }

  // Get color based on recipient type
  Color _getNotificationColor(NotificationRecipientType recipientType) {
    switch (recipientType) {
      case NotificationRecipientType.serviceProvider:
        return Colors.orange;
      case NotificationRecipientType.user:
        return Colors.blue;
      default:
        return Colors.lightGreen;
    }
  }

  // Build notification type badge
  Widget _buildNotificationBadge(NotificationModel notification) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getNotificationColor(notification.recipientType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        notification.recipientType.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: _getNotificationColor(notification.recipientType),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Build dismiss background
  Widget _buildDismissBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  // Custom stream to fetch all notifications for service provider and user
  Stream<List<NotificationModel>> _getAllNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientType', whereIn: [
      NotificationRecipientType.serviceProvider.toString().split('.').last,
      NotificationRecipientType.all.toString().split('.').last,
    ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    }).handleError((error) {
      print('Error fetching notifications: $error');
      return <NotificationModel>[];
    });
  }

  // Method to refresh notifications manually
  Future<void> _refreshNotifications() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Recreate the stream to force a refresh
      _notificationsStream = _getAllNotifications();

      // Simulate a delay to show loading indicator
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print('Refresh error: $e');
      // Optionally show a snackbar or toast to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Optional method to delete a specific notification
  Future<void> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
      // Optionally show a snackbar or toast to the user
    }
  }

  // Helper method to format date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}