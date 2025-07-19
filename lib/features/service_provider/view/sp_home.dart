


import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/features/service_provider/view/provider_home_page.dart';
import 'package:fixit/features/service_provider/view/provider_jobs_page.dart';
import 'package:fixit/features/service_provider/view/provider_messages_page.dart';
import 'package:fixit/features/service_provider/view/provider_profile_page.dart';
import 'package:fixit/features/service_provider/view/provider_services.dart';
import 'package:fixit/features/service_provider/view/view_all_tools.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderHome extends StatefulWidget {
  const ProviderHome({super.key});

  @override
  State<ProviderHome> createState() => _ProviderHomeState();
}

class _ProviderHomeState extends State<ProviderHome> {
  int _selectedIndex = 0;
  int _unreadMessageCount = 0;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  String? _currentUserId;

  List<Widget> _widgetOptions = [
    ServiceProviderHomePage(),
    // ProviderServicesPage(),
    ViewAllToolsPage(),
    ProviderJobsPage(),
    ProviderMessagesPage(),
    ProviderProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
      _setupMessageListener();
    }
  }

  void _setupMessageListener() {
    if (_currentUserId == null) return;

    // Cancel any existing subscription to avoid multiple listeners
    _messagesSubscription?.cancel();

    // Listen to all chats where the provider is a participant
    _messagesSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      int totalUnread = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Use the correct field name for unread count
        final unreadField = 'unreadCount_$_currentUserId';

        if (data.containsKey(unreadField)) {
          totalUnread += (data[unreadField] as num).toInt();
        }
      }

      if (mounted) {
        setState(() {
          _unreadMessageCount = totalUnread;
        });
      }
    });
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Widget _buildMessageIconWithBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.message_rounded),
        if (_unreadMessageCount > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _unreadMessageCount > 9 ? '9+' : _unreadMessageCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xff0F3966),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white30,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
              // Reset unread count when messages tab is selected
              if (index == 3) {
                // Don't reset the count here, let the messages page handle it
                // when it marks messages as read
              }
            });
          },
          items: [
            const BottomNavigationBarItem(
              backgroundColor: Color(0xff0F3966),
              icon: Icon(Icons.home),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              backgroundColor: Color(0xff0F3966),
              icon: Icon(Icons.construction),
              label: "Tools",
            ),
            const BottomNavigationBarItem(
              backgroundColor: Color(0xff0F3966),
              icon: Icon(Icons.today_outlined),
              label: "Jobs",
            ),
            BottomNavigationBarItem(
              backgroundColor: const Color(0xff0F3966),
              icon: _buildMessageIconWithBadge(),
              label: "Messages",
            ),
            const BottomNavigationBarItem(
              backgroundColor: Color(0xff0F3966),
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}

