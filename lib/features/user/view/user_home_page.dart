// import 'package:fixit/features/user/view/user_account_page.dart';
// import 'package:fixit/features/user/view/user_bookings_page.dart';
// import 'package:fixit/features/user/view/user_home_screen.dart';
// import 'package:fixit/features/user/view/user_messages_page.dart';
// import 'package:fixit/features/user/view/view_services_page.dart';
// import 'package:flutter/material.dart';
//
// class UserHomePage extends StatefulWidget {
//   const UserHomePage({super.key});
//
//   @override
//   State<UserHomePage> createState() => _UserHomePageState();
// }
//
// class _UserHomePageState extends State<UserHomePage> {
//   int _selectedIndex=0;
//   List<Widget> _widgetOptions=[
//      HomeScreen(),
//      ViewServicesPage(),
//      UserBookingsPage(),
//      UserMessagesPage(),
//      UserAccountPage(),
//
//   ];
//   @override
//   Widget build(BuildContext context) {
//     final Size size=MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(25),
//
//         ),
//         child: BottomNavigationBar(
//             backgroundColor: Color(0xff0F3966),
//             selectedItemColor: Colors.white,
//             unselectedItemColor: Colors.white30,
//             // showSelectedLabels: false,
//             currentIndex: _selectedIndex,
//             onTap: (int index){
//               setState(() {
//                 _selectedIndex=index;
//               });
//             },
//
//             items:[
//               BottomNavigationBarItem(
//                 backgroundColor: Color(0xff0F3966),
//                   icon: Icon(Icons.home),
//                   label: "Home"
//               ),
//               BottomNavigationBarItem(
//                   backgroundColor: Color(0xff0F3966),
//                   icon: Icon(Icons.home_repair_service),
//                   label: "Services"
//               ),
//               BottomNavigationBarItem(
//                   backgroundColor: Color(0xff0F3966),
//                   icon: Icon(Icons.calendar_month),
//                   label: "Bookings"
//               ),
//               BottomNavigationBarItem(
//                   backgroundColor: Color(0xff0F3966),
//                   icon: Icon(Icons.message_rounded),
//                   label: "Messages"
//               ),
//
//               BottomNavigationBarItem(
//                   backgroundColor: Color(0xff0F3966),
//                   icon: Icon(Icons.person),
//                   label: "Account"
//               )
//             ]),
//       ),
//       body: _widgetOptions.elementAt(_selectedIndex),
//
//     );
//   }
// }

//
// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fixit/features/user/view/user_account_page.dart';
// import 'package:fixit/features/user/view/user_bookings_page.dart';
// import 'package:fixit/features/user/view/user_home_screen.dart';
// import 'package:fixit/features/user/view/user_messages_page.dart';
// import 'package:fixit/features/user/view/view_services_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class UserHomePage extends StatefulWidget {
//   const UserHomePage({super.key});
//
//   @override
//   State<UserHomePage> createState() => _UserHomePageState();
// }
//
// class _UserHomePageState extends State<UserHomePage> {
//   int _selectedIndex = 0;
//   int _unreadMessageCount = 0;
//   late StreamSubscription<QuerySnapshot> _messagesSubscription;
//   String? _currentUserId; // Set this from your auth system
//   StreamSubscription<DocumentSnapshot>? _userSubscription;
//
//   final List<Widget> _widgetOptions = [
//     HomeScreen(),
//     ViewServicesPage(),
//     UserBookingsPage(),
//     UserMessagesPage(),
//     UserAccountPage(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // Example: Replace with actual user ID from your auth
//     _getCurrentUser();
//     _setupMessageListener();
//   }
//
//   void _getCurrentUser() {
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       // Listen to the user document in Firestore
//       _userSubscription = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .snapshots()
//           .listen((userDoc) {
//         if (userDoc.exists) {
//           setState(() {
//             _currentUserId = user.uid;
//           });
//           _setupMessageListener();
//         }
//       });
//     }
//   }
//
//   void _setupMessageListener() {
//     if (_currentUserId == null) return;
//
//     // Cancel any existing subscription to avoid multiple listeners
//     _messagesSubscription.cancel();
//
//     _messagesSubscription = FirebaseFirestore.instance
//         .collection('chats')
//         .where('participants', arrayContains: _currentUserId)
//         .snapshots()
//         .listen((snapshot) {
//       int totalUnread = 0;
//
//       for (var doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         final unreadField = 'unreadCount_$_currentUserId';
//         if (data.containsKey(unreadField)) {
//           totalUnread += data[unreadField] as int;
//         }
//       }
//
//       if (mounted) {
//         setState(() {
//           _unreadMessageCount = totalUnread;
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _messagesSubscription.cancel();
//     _userSubscription?.cancel();
//     super.dispose();
//   }
//
//   Widget _buildMessageIconWithBadge() {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         const Icon(Icons.message_rounded),
//         if (_unreadMessageCount > 0)
//           Positioned(
//             right: -8,
//             top: -8,
//             child: Container(
//               constraints: const BoxConstraints(
//                 minWidth: 16,
//                 minHeight: 16,
//               ),
//               padding: const EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 _unreadMessageCount > 9 ? '9+' : _unreadMessageCount.toString(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(25),
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: const Color(0xff0F3966),
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white30,
//           currentIndex: _selectedIndex,
//           onTap: (int index) {
//             setState(() {
//               _selectedIndex = index;
//               if (index == 3) {
//                 _unreadMessageCount = 0;
//               }
//             });
//           },
//           items: [
//             const BottomNavigationBarItem(
//               backgroundColor: Color(0xff0F3966),
//               icon: Icon(Icons.home),
//               label: "Home",
//             ),
//             const BottomNavigationBarItem(
//               backgroundColor: Color(0xff0F3966),
//               icon: Icon(Icons.home_repair_service),
//               label: "Services",
//             ),
//             const BottomNavigationBarItem(
//               backgroundColor: Color(0xff0F3966),
//               icon: Icon(Icons.calendar_month),
//               label: "Bookings",
//             ),
//             BottomNavigationBarItem(
//               backgroundColor: const Color(0xff0F3966),
//               icon: _buildMessageIconWithBadge(),
//               label: "Messages",
//             ),
//             const BottomNavigationBarItem(
//               backgroundColor: Color(0xff0F3966),
//               icon: Icon(Icons.person),
//               label: "Account",
//             ),
//           ],
//         ),
//       ),
//       body: _widgetOptions.elementAt(_selectedIndex),
//     );
//   }
// }


import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/features/user/view/user_account_page.dart';
import 'package:fixit/features/user/view/user_bookings_page.dart';
import 'package:fixit/features/user/view/user_home_screen.dart';
import 'package:fixit/features/user/view/user_messages_page.dart';
import 'package:fixit/features/user/view/view_services_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  int _unreadMessageCount = 0;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  String? _currentUserId;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  final List<Widget> _widgetOptions = [
    HomeScreen(),
    ViewServicesPage(),
    UserBookingsPage(),
    UserMessagesPage(),
    UserAccountPage(),
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

    _messagesSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      int totalUnread = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
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
    _userSubscription?.cancel();
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
                _unreadMessageCount = 0;
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
              icon: Icon(Icons.home_repair_service),
              label: "Services",
            ),
            const BottomNavigationBarItem(
              backgroundColor: Color(0xff0F3966),
              icon: Icon(Icons.calendar_month),
              label: "Bookings",
            ),
            BottomNavigationBarItem(
              backgroundColor: const Color(0xff0F3966),
              icon: _buildMessageIconWithBadge(),
              label: "Messages",
            ),
            const BottomNavigationBarItem(
              backgroundColor: Color(0xff0F3966),
              icon: Icon(Icons.person),
              label: "Account",
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
