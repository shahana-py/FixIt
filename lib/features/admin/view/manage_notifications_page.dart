



import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the notification model and service
import '../models/notification_model.dart';

class ManageNotificationsPage extends StatefulWidget {
  const ManageNotificationsPage({Key? key}) : super(key: key);

  @override
  _ManageNotificationsPageState createState() => _ManageNotificationsPageState();
}

class _ManageNotificationsPageState extends State<ManageNotificationsPage> {
  // Form controllers
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  // Notification service
  final NotificationService _notificationService = NotificationService();

  // Selected recipient type
  NotificationRecipientType _selectedRecipientType = NotificationRecipientType.all;

  // List of recipient type options
  final List<NotificationRecipientType> _recipientTypes = [
    NotificationRecipientType.all,
    NotificationRecipientType.user,
    NotificationRecipientType.serviceProvider,
  ];

  // Selected specific user (optional)
  String? _selectedUserId;
  String? _selectedUserDisplayName;
  bool _sendToSpecificUser = false;

  // Send notification method
  Future<void> _sendNotification() async {
    // Validate inputs
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_sendToSpecificUser && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user')),
      );
      return;
    }

    try {
      // Get current admin user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Send notification with or without specific recipientId
      await _notificationService.sendNotification(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        recipientType: _selectedRecipientType,
        recipientId: _sendToSpecificUser ? _selectedUserId : null,
        sentBy: currentUser.uid,
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      // Clear form and show success message
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedUserId = null;
        _selectedUserDisplayName = null;
        _sendToSpecificUser = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: _sendToSpecificUser
              ? Text('Notification sent to ${_selectedUserDisplayName ?? "selected user"}')
              : Text('Notification sent to ${_selectedRecipientType.name} users'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to select a specific user
  Future<void> _selectUser() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get users from Firestore based on selected type
      final String collectionPath = 'users';
      String roleFilter = '';

      if (_selectedRecipientType == NotificationRecipientType.user) {
        roleFilter = 'user';
      } else if (_selectedRecipientType == NotificationRecipientType.serviceProvider) {
        roleFilter = 'serviceProvider';
      }

      // Query Firestore for users
      QuerySnapshot querySnapshot;
      if (roleFilter.isNotEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection(collectionPath)
            .where('role', isEqualTo: roleFilter)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection(collectionPath)
            .get();
      }

      // Hide loading indicator
      Navigator.of(context).pop();

      // Check if we got any users
      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No ${roleFilter.isNotEmpty ? roleFilter : ""} users found'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show user selection dialog
      final users = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final email = data['email'] ?? 'No email';
        final name = data['displayName'] ?? data['fullName'] ?? email;
        return {
          'id': doc.id,
          'displayName': name,
        };
      }).toList();

      // Sort users by display name
      users.sort((a, b) => (a['displayName'] as String).compareTo(b['displayName'] as String));

      final selectedUser = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select User'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['displayName'] as String),
                  onTap: () => Navigator.of(context).pop(user),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );

      if (selectedUser != null) {
        setState(() {
          _selectedUserId = selectedUser['id'] as String;
          _selectedUserDisplayName = selectedUser['displayName'] as String;
        });
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Manage Notifications"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notification Title Input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            // Notification Message Input
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Notification Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Recipient Type Dropdown
            DropdownButtonFormField<NotificationRecipientType>(
              decoration: const InputDecoration(
                labelText: 'Send Notification To',
                border: OutlineInputBorder(),
              ),
              value: _selectedRecipientType,
              items: _recipientTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRecipientType = value!;
                  // Reset specific user selection when recipient type changes
                  _selectedUserId = null;
                  _selectedUserDisplayName = null;
                  _sendToSpecificUser = false;
                });
              },
            ),

            const SizedBox(height: 24),

            // Send Notification Button
            ElevatedButton(
              onPressed: _sendNotification,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xff0F3966)
              ),
              child: const Text(
                'Send Notification',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Divider(),
            ),

            // Notification History Section
            const SizedBox(height: 24),
            const Text(
              'Notification History',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F3966)
              ),
            ),
            SizedBox(height: 20),
            _buildNotificationHistory(),
          ],
        ),
      ),
    );
  }

  // Build detailed notification history widget with improved error handling
  Widget _buildNotificationHistory() {
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getNotifications(),
      builder: (context, snapshot) {
        // Print connection state for debugging
        print("StreamBuilder connection state: ${snapshot.connectionState}");

        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (snapshot.hasError) {
          print("Error in stream: ${snapshot.error}");
          return Center(
            child: Text(
              'Error loading notifications: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        // Handle empty data
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Print data length for debugging
        print("Number of notifications: ${snapshot.data!.length}");

        if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No notifications sent yet',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sent Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = snapshot.data![index];
                  print("Rendering notification: ${notification.id} - ${notification.title}");
                  return _buildNotificationTile(notification);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Build individual notification tile with detailed information
  Widget _buildNotificationTile(NotificationModel notification) {
    // Get recipient description
    String recipientDesc = notification.recipientType.name.toUpperCase();
    if (notification.recipientId != null) {
      recipientDesc = 'Specific $recipientDesc (ID: ${notification.recipientId})';
    }

    return ExpansionTile(
      title: Text(
        notification.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        'Sent to: $recipientDesc',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteNotification(notification),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Message
              Text(
                notification.message,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Additional Details
              _buildNotificationDetails(notification),
            ],
          ),
        ),
      ],
    );
  }

  // Method to delete a notification
  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      // Confirm deletion with a dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Notification'),
          content: Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      // If user confirms deletion
      if (confirmDelete == true) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Delete the notification from Firestore
        await _notificationService.deleteNotification(notification.id);

        // Hide loading indicator
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build additional notification details
  Widget _buildNotificationDetails(NotificationModel notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sent Date
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87),
            children: [
              const TextSpan(
                text: 'Sent on: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: _formatDateTime(notification.createdAt.toDate()),
              ),
            ],
          ),
        ),

        // Sender Information (if available)
        if (notification.sentBy != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  const TextSpan(
                    text: 'Sent by: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: notification.sentBy ?? 'Unknown',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Helper method to format date and time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        'at ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    // Clean up controllers
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}



