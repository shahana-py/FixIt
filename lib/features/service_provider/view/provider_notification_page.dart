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
//   // Method to show notification details in a dialog
//   void _showNotificationDialog(NotificationModel notification) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             notification.title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Color(0xff0F3966),
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 notification.message,
//                 style: TextStyle(
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     _formatDateTime(notification.createdAt.toDate()),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   _buildNotificationBadge(notification),
//                 ],
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//
//               child: const Text('Close',style: TextStyle(color: Color(0xff0F3966)),),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
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
//   // Build notifications list with onTap to show dialog
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
//               child: ListTile(
//                 onTap: () => _showNotificationDialog(notification),
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
//         Icons.notifications,
//         color: Colors.white,
//       ),
//     );
//   }
//
//   // Get icon based on recipient type
//   // IconData _getNotificationIcon(NotificationRecipientType recipientType) {
//   //   switch (recipientType) {
//   //     case NotificationRecipientType.serviceProvider:
//   //       return Icons.build;
//   //     case NotificationRecipientType.user:
//   //       return Icons.person;
//   //     default:
//   //       return Icons.notifications;
//   //   }
//   // }
//
//   // Get color based on recipient type
//   Color _getNotificationColor(NotificationRecipientType recipientType) {
//     switch (recipientType) {
//       case NotificationRecipientType.serviceProvider:
//         return Colors.orange;
//       case NotificationRecipientType.user:
//         return Colors.blue;
//       default:
//         return Colors.lightGreen;
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
//   // Track hidden notifications locally (not deleted from Firestore)
//   final Set<String> _hiddenNotificationIds = {};
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the stream in initState to ensure it's set up correctly
//     _notificationsStream = _getAllNotifications();
//   }
//
//   // Method to show notification details in a dialog
//   void _showNotificationDialog(NotificationModel notification) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             notification.title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Color(0xff0F3966),
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 notification.message,
//                 style: TextStyle(
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 _formatDateTime(notification.createdAt.toDate()),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Close', style: TextStyle(color: Color(0xff0F3966))),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Hide', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 _hideNotification(notification.id);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
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
//             // No notifications or all hidden
//             List<NotificationModel> visibleNotifications = [];
//             if (snapshot.hasData) {
//               visibleNotifications = snapshot.data!.where(
//                       (notification) => !_hiddenNotificationIds.contains(notification.id)
//               ).toList();
//             }
//
//             if (visibleNotifications.isEmpty) {
//               return _buildNoNotificationsView();
//             }
//
//             // Display notifications
//             return _buildNotificationsList(visibleNotifications);
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
//   // Build notifications list with onTap to show dialog
//   Widget _buildNotificationsList(List<NotificationModel> notifications) {
//     return ListView.separated(
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: notifications.length,
//       separatorBuilder: (context, index) => Padding(
//         padding: const EdgeInsets.only(right: 20,left: 20),
//         child: const Divider(height: 1, thickness: 1),
//       ),
//       itemBuilder: (context, index) {
//         final notification = notifications[index];
//         return InkWell(
//           onTap: () => _showNotificationDialog(notification),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Row(
//               children: [
//                 _buildNotificationIcon(notification),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         notification.title,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xff0F3966),
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         notification.message,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatDateTime(notification.createdAt.toDate()),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.grey),
//                   onPressed: () => _hideNotification(notification.id),
//                   tooltip: 'Hide',
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Build notification icon based on type
//   Widget _buildNotificationIcon(NotificationModel notification) {
//     IconData iconData;
//     Color iconColor;
//
//     // Determine icon and color based on notification type
//     if (notification.type == "rating") {
//       iconData = Icons.star;
//       iconColor = Colors.amber;
//     } else if (notification.type == "payment") {
//       iconData = Icons.payment;
//       iconColor = Colors.green;
//     }else if (notification.type == "complaint_resolved") {
//       iconData = Icons.feedback;
//       iconColor = Colors.red;
//     } else {
//       iconData = Icons.notifications;
//       iconColor = const Color(0xff0F3966);
//     }
//
//     return CircleAvatar(
//       backgroundColor: iconColor.withOpacity(0.1),
//       child: Icon(
//         iconData,
//         color: iconColor,
//       ),
//     );
//   }
//
//   // Get color based on notification type
//   Color _getNotificationColor(String type) {
//     switch (type) {
//       case "rating":
//         return Colors.amber;
//       case "payment":
//         return Colors.green;
//       default:
//         return const Color(0xff0F3966);
//     }
//   }
//
//   // Custom stream to fetch all notifications for the current service provider
//   Stream<List<NotificationModel>> _getAllNotifications() {
//     final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
//
//     return FirebaseFirestore.instance
//         .collection('notifications')
//         .where(Filter.or(
//       // Admin notifications for all service providers
//         Filter('recipientType', isEqualTo: NotificationRecipientType.serviceProvider.toString().split('.').last),
//         // Admin notifications for everyone
//         Filter('recipientType', isEqualTo: NotificationRecipientType.all.toString().split('.').last),
//         // Rating notifications (specific to this provider)
//         Filter.and(
//             Filter('type', isEqualTo: 'rating'),
//             Filter('provider_id', isEqualTo: currentUserId)
//         ),
//         // Payment notifications (specific to this provider)
//         Filter.and(
//             Filter('type', isEqualTo: 'payment'),
//             Filter('provider_id', isEqualTo: currentUserId)
//         ),
//         Filter.and(
//             Filter('type', isEqualTo: 'complaint_resolved'),
//             Filter('provider_id', isEqualTo: currentUserId)
//         )
//     ))
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         // Convert Firestore document to NotificationModel
//         Map<String, dynamic> data = doc.data();
//
//         // Debug print to see the actual structure of documents
//         print('Document ID: ${doc.id}, Data: $data');
//
//         // Handle special cases for rating and payment notifications
//         if (data['type'] == 'rating' || data['type'] == 'payment' || data['type'] == 'complaint_resolved') {
//           // For these notifications, fields are named differently
//           return NotificationModel(
//             id: doc.id,
//             title: data['title'] ?? '',
//             message: data['message'] ?? '',
//             // Use timestamp if it exists, otherwise use createdAt or default to now
//             createdAt: data['timestamp'] ?? data['createdAt'] ?? Timestamp.now(),
//             // Since these are provider-specific, use serviceProvider as recipientType
//             recipientType: NotificationRecipientType.serviceProvider,
//             // Store provider_id as recipientId for consistency
//             recipientId: data['provider_id'],
//             type: data['type'] ?? '',
//             isRead: data['is_read'] ?? false,
//           );
//         }
//
//         // For standard admin notifications
//         return NotificationModel(
//           id: doc.id,
//           title: data['title'] ?? '',
//           message: data['message'] ?? '',
//           createdAt: data['createdAt'] ?? Timestamp.now(),
//           recipientType: _parseRecipientType(data['recipientType']),
//           recipientId: data['recipientId'],
//           sentBy: data['sentBy'],
//           isRead: data['isRead'] ?? false,
//           type: data['type'] ?? '',
//         );
//       }).toList();
//     }).handleError((error) {
//       print('Error fetching notifications: $error');
//       return <NotificationModel>[];
//     });
//   }
//
//   // Helper method to parse recipient type
//   NotificationRecipientType _parseRecipientType(String? type) {
//     if (type == null) return NotificationRecipientType.all;
//
//     try {
//       return NotificationRecipientType.values.firstWhere(
//               (e) => e.toString().split('.').last == type,
//           orElse: () => NotificationRecipientType.all
//       );
//     } catch (e) {
//       return NotificationRecipientType.all;
//     }
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
//   // Method to hide a notification locally (doesn't delete from Firestore)
//   void _hideNotification(String notificationId) {
//     setState(() {
//       _hiddenNotificationIds.add(notificationId);
//     });
//
//     // Show a snackbar to let the user know
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Notification hidden'),
//         duration: const Duration(seconds: 2),
//         action: SnackBarAction(
//           label: 'Undo',
//           onPressed: () {
//             setState(() {
//               _hiddenNotificationIds.remove(notificationId);
//             });
//           },
//         ),
//       ),
//     );
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
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
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
//   // Track hidden notifications locally (not deleted from Firestore)
//   final Set<String> _hiddenNotificationIds = {};
//   // Current user ID to associate with hidden notifications
//   String? _currentUserId;
//
//   @override
//   void initState() {
//     super.initState();
//     // Get current user ID
//     _currentUserId = FirebaseAuth.instance.currentUser?.uid;
//     // Load hidden notification IDs from SharedPreferences
//     _loadHiddenNotifications();
//     // Initialize the stream in initState to ensure it's set up correctly
//     _notificationsStream = _getAllNotifications();
//   }
//
//   // Load hidden notifications from SharedPreferences
//   Future<void> _loadHiddenNotifications() async {
//     try {
//       if (_currentUserId == null) return;
//
//       final prefs = await SharedPreferences.getInstance();
//       final hiddenNotificationsJson = prefs.getString('hidden_notifications_$_currentUserId');
//
//       if (hiddenNotificationsJson != null) {
//         final List<dynamic> hiddenList = jsonDecode(hiddenNotificationsJson);
//         setState(() {
//           _hiddenNotificationIds.addAll(hiddenList.map((id) => id.toString()));
//         });
//         print('Loaded ${_hiddenNotificationIds.length} hidden notifications');
//       }
//     } catch (e) {
//       print('Error loading hidden notifications: $e');
//     }
//   }
//
//   // Save hidden notifications to SharedPreferences
//   Future<void> _saveHiddenNotifications() async {
//     try {
//       if (_currentUserId == null) return;
//
//       final prefs = await SharedPreferences.getInstance();
//       final hiddenNotificationsJson = jsonEncode(_hiddenNotificationIds.toList());
//       await prefs.setString('hidden_notifications_$_currentUserId', hiddenNotificationsJson);
//       print('Saved ${_hiddenNotificationIds.length} hidden notifications');
//     } catch (e) {
//       print('Error saving hidden notifications: $e');
//     }
//   }
//
//   // Method to show notification details in a dialog
//   void _showNotificationDialog(NotificationModel notification) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             notification.title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Color(0xff0F3966),
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 notification.message,
//                 style: TextStyle(
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 _formatDateTime(notification.createdAt.toDate()),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Close', style: TextStyle(color: Color(0xff0F3966))),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Hide', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 _hideNotification(notification.id);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
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
//           // Clear all button
//           if (!_isLoading && _hiddenNotificationIds.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete_sweep, color: Colors.white),
//               onPressed: _clearAllHiddenNotifications,
//               tooltip: 'Reset Hidden Notifications',
//             ),
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
//             // No notifications or all hidden
//             List<NotificationModel> visibleNotifications = [];
//             if (snapshot.hasData) {
//               visibleNotifications = snapshot.data!.where(
//                       (notification) => !_hiddenNotificationIds.contains(notification.id)
//               ).toList();
//             }
//
//             if (visibleNotifications.isEmpty) {
//               return _buildNoNotificationsView();
//             }
//
//             // Display notifications
//             return _buildNotificationsList(visibleNotifications);
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
//   // Build notifications list with onTap to show dialog
//   Widget _buildNotificationsList(List<NotificationModel> notifications) {
//     return ListView.separated(
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: notifications.length,
//       separatorBuilder: (context, index) => Padding(
//         padding: const EdgeInsets.only(right: 20,left: 20),
//         child: const Divider(height: 1, thickness: 1),
//       ),
//       itemBuilder: (context, index) {
//         final notification = notifications[index];
//         return InkWell(
//           onTap: () => _showNotificationDialog(notification),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Row(
//               children: [
//                 _buildNotificationIcon(notification),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         notification.title,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xff0F3966),
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         notification.message,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatDateTime(notification.createdAt.toDate()),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.grey),
//                   onPressed: () => _hideNotification(notification.id),
//                   tooltip: 'Hide',
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Build notification icon based on type
//   Widget _buildNotificationIcon(NotificationModel notification) {
//     IconData iconData;
//     Color iconColor;
//
//     // Determine icon and color based on notification type
//     if (notification.type == "rating") {
//       iconData = Icons.star;
//       iconColor = Colors.amber;
//     } else if (notification.type == "payment") {
//       iconData = Icons.payment;
//       iconColor = Colors.green;
//     } else if (notification.type == "booking") {
//       iconData = Icons.home_repair_service;
//       iconColor = Colors.cyan;
//     }
//     else if (notification.type == "complaint_resolved") {
//       iconData = Icons.feedback;
//       iconColor = Colors.red;
//     } else {
//       iconData = Icons.notifications;
//       iconColor = const Color(0xff0F3966);
//     }
//
//     return CircleAvatar(
//       radius: 25,
//       backgroundColor: iconColor.withOpacity(0.1),
//       child: Icon(
//         iconData,
//         color: iconColor,
//         size: 25,
//       ),
//     );
//   }
//
//   // Get color based on notification type
//   Color _getNotificationColor(String type) {
//     switch (type) {
//       case "rating":
//         return Colors.amber;
//       case "payment":
//         return Colors.green;
//       case "complaint_resolved":
//         return Colors.red;
//       default:
//         return const Color(0xff0F3966);
//     }
//   }
//
//   // Custom stream to fetch all notifications for the current service provider
//   Stream<List<NotificationModel>> _getAllNotifications() {
//     final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     print('Fetching notifications for user: $currentUserId');
//
//     return FirebaseFirestore.instance
//         .collection('notifications')
//         .where(Filter.or(
//       // Admin notifications for all service providers
//         Filter('recipientType', isEqualTo: NotificationRecipientType.serviceProvider.toString().split('.').last),
//         Filter('recipientType', isEqualTo: "service provider"), // Add this line for the format in your document
//
//         // Admin notifications for everyone
//         Filter('recipientType', isEqualTo: NotificationRecipientType.all.toString().split('.').last),
//
//         // Notifications for specific provider
//         Filter('recipientUid', isEqualTo: currentUserId),
//
//         // For backwards compatibility with older notifications
//         Filter('provider_id', isEqualTo: currentUserId)
//     ))
//         .snapshots()
//         .map((snapshot) {
//       print('Retrieved ${snapshot.docs.length} notifications'); // Debug log
//
//       return snapshot.docs.map((doc) {
//         Map<String, dynamic> data = doc.data();
//
//         // Debug print to see the actual structure of documents
//         print('Document ID: ${doc.id}, Type: ${data['type']}, Data: $data');
//
//         // Create a notification model from the document
//         return NotificationModel(
//           id: doc.id,
//           title: data['title'] ?? '',
//           message: data['message'] ?? '',
//           // Use timestamp if it exists, otherwise use createdAt or default to now
//           createdAt: data['timestamp'] ?? data['createdAt'] ?? Timestamp.now(),
//           recipientType: _parseRecipientType(data['recipientType']),
//           recipientId: data['recipientId'] ?? data['recipientUid'] ?? data['provider_id'],
//           sentBy: data['sentBy'] ?? data['senderName'],
//           isRead: data['isRead'] ?? data['is_read'] ?? false,
//           type: data['type'] ?? '',
//         );
//       }).toList();
//     })
//         .handleError((error) {
//       print('Error fetching notifications: $error');
//       return <NotificationModel>[];
//     });
//   }
//
//
//
//
//
//
//
//   // Helper method to parse recipient type
//   NotificationRecipientType _parseRecipientType(String? type) {
//     if (type == null) return NotificationRecipientType.all;
//
//     // Handle "service provider" with space
//     if (type.toLowerCase() == "service provider") {
//       return NotificationRecipientType.serviceProvider;
//     }
//
//     try {
//       return NotificationRecipientType.values.firstWhere(
//               (e) => e.toString().split('.').last.toLowerCase() == type.toLowerCase(),
//           orElse: () => NotificationRecipientType.all
//       );
//     } catch (e) {
//       return NotificationRecipientType.all;
//     }
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
//       // Make sure we have the latest hidden notifications
//       await _loadHiddenNotifications();
//
//       // Recreate the stream to force a refresh
//       _notificationsStream = _getAllNotifications();
//
//       // Simulate a delay to show loading indicator
//       await Future.delayed(const Duration(seconds: 1));
//     } catch (e) {
//       print('Refresh error: $e');
//       // Optionally show a snackbar or toast to the user
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to refresh: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Method to hide a notification and persist the state
//   Future<void> _hideNotification(String notificationId) async {
//     setState(() {
//       _hiddenNotificationIds.add(notificationId);
//     });
//
//     // Persist hidden notifications to SharedPreferences
//     await _saveHiddenNotifications();
//
//     // Show a snackbar to let the user know
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Notification hidden'),
//         duration: const Duration(seconds: 2),
//         action: SnackBarAction(
//           label: 'Undo',
//           onPressed: () async {
//             setState(() {
//               _hiddenNotificationIds.remove(notificationId);
//             });
//             // Update the persisted hidden notifications
//             await _saveHiddenNotifications();
//           },
//         ),
//       ),
//     );
//   }
//
//   // Helper method to format date and time
//   String _formatDateTime(DateTime dateTime) {
//     return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
//   }
//
//   // Method to clear all hidden notifications
//   Future<void> _clearAllHiddenNotifications() async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Reset Hidden Notifications'),
//         content: const Text('This will show all previously hidden notifications again. Continue?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop();
//               setState(() {
//                 _hiddenNotificationIds.clear();
//               });
//               await _saveHiddenNotifications();
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('All hidden notifications have been reset'),
//                 ),
//               );
//
//               // Refresh the list
//               _refreshNotifications();
//             },
//             child: const Text('Reset', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // Make sure all changes are saved when the page is closed
//     _saveHiddenNotifications();
//     super.dispose();
//   }
// }



import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    if (notification.type == "rating") {
      iconData = Icons.star;
      iconColor = Colors.amber;
    } else if (notification.type == "payment") {
      iconData = Icons.payment;
      iconColor = Colors.green;
    } else if (notification.type == "booking") {
      iconData = Icons.home_repair_service;
      iconColor = Colors.cyan;
    }
    else if (notification.type == "complaint_resolved") {
      iconData = Icons.feedback;
      iconColor = Colors.red;
    }else if (notification.type == "order_update") {
      iconData = Icons.shopping_cart_rounded;
      iconColor = Colors.pinkAccent;
    }else if (notification.type == "refund_notification") {
      iconData = Icons.check_circle_sharp;
      iconColor = Colors.lightGreen;
    }
    else {
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
      case "rating":
        return Colors.amber;
      case "payment":
        return Colors.green;
      case "complaint_resolved":
        return Colors.red;
      default:
        return const Color(0xff0F3966);
    }
  }

  // Modified stream to fetch relevant notifications for the current service provider
  Stream<List<NotificationModel>> _getAllNotifications() {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print('Fetching notifications for provider: $currentUserId');

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
        if (data['type'] == 'rating' || data['type'] == 'booking' || data['type'] == 'order_update' || data['type'] == 'refund_notification'|| data['type'] == 'complaint_resolved') {
          // For provider-specific notifications, check if it's meant for this provider
          isRelevantForThisProvider =
              (data['provider_id'] == currentUserId) ||
                  (data['recipientId'] == currentUserId) ||
                  (data['recipientUid'] == currentUserId);
        } else {
          // For general notifications, check recipient type
          String recipientType = (data['recipientType'] ?? '').toString().toLowerCase();

          // Check if it's for all service providers or for everyone
          isRelevantForThisProvider =
              recipientType == 'serviceprovider' ||
                  recipientType == 'service provider' ||
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
            recipientId: data['recipientId'] ?? data['recipientUid'] ?? data['provider_id'] ?? '',
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

    // Handle "service provider" with space
    if (type.toLowerCase() == "service provider") {
      return NotificationRecipientType.serviceProvider;
    }

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