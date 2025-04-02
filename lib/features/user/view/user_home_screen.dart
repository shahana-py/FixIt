// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:fixit/core/utils/custom_texts/main_text.dart';
// import 'package:flutter/material.dart';
//
// import '../../../core/utils/custom_widgets/service_category_card.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         leading:Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: CircleAvatar(
//             backgroundColor: Colors.white,
//             child: IconButton(onPressed: (){}, icon: Icon(Icons.person,color: Colors.blue,)),
//           ),
//         ) ,
//         title: AppBarTitle(text: "name"),
//         actions: [
//           Icon(Icons.bookmark,color: Colors.white,size: 24,),
//           SizedBox(width: 10),
//           // Icon(Icons.notifications,color: Colors.white,size: 24,),
//           IconButton(onPressed: (){
//             Navigator.pushNamed(context,'/usernotificationpage');
//           }, icon: Icon(Icons.notifications,color: Colors.white,size: 24,)),
//           SizedBox(width: 10),
//           Icon(Icons.search,color: Colors.white,size: 24,),
//           SizedBox(width: 10),
//           IconButton(onPressed: (){
//             FirebaseAuth.instance.signOut();
//             Navigator.pushNamedAndRemoveUntil(context, '/login', (Route route)=>false);
//           }, icon: Icon(Icons.logout,color: Colors.white,size: 24)),
//           SizedBox(width: 10),
//
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SubText(text: "Offers"),
//
//
//                 ],
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 15,bottom: 10),
//                   child: Row(
//                     children: [
//                       Container(
//                         height: 208,
//                         width: 321,
//                         margin: EdgeInsets.only(right: 10),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           // color: Colors.blue
//                           image: DecorationImage(image: AssetImage("assets/images/offer-banner1.png"),fit: BoxFit.fill)
//                         ),
//                       ),
//                       Container(
//                         height: 208,
//                         width: 321,
//                         margin: EdgeInsets.only(right: 10),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                             // color: Colors.blue
//                           image: DecorationImage(image: AssetImage("assets/images/offer-banner2.png"),fit: BoxFit.fill)
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ),
//
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 15),
//                 child: Divider(color: Colors.black54,),
//               ),
//               MainText(text: "our services"),
//               Divider(color: Colors.black54,),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "Maintenance Services"),
//                     // SubText(text: "View all",color: Color(0xff007AFF),),
//
//                   ],
//                 ),
//               ),
//
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ServiceCard(
//                       imagePath: "assets/images/Plumbing.jpg",
//                       serviceName: "Plumbing Works",
//                     ),
//                     ServiceCard(
//                       imagePath: "assets/images/electrical work.jpg",
//                       serviceName: "Electrical Works",
//                     ),
//                     ServiceCard(
//                       imagePath: "assets/images/painting.jpeg",
//                       serviceName: "Painting Works",
//                     ),
//                     ServiceCard(
//                       imagePath: "assets/images/AC repair.jpg",
//                       serviceName: "AC Repair",
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "Cleaning Services"),
//                     // SubText(text: "View all",color: Color(0xff007AFF),),
//
//                   ],
//                 ),
//               ),
//
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ServiceCard(
//                       imagePath: "assets/images/cleaning.jpeg",
//                       serviceName: "Cleaning",
//                     ),
//                     ServiceCard(
//                       imagePath: "assets/images/car wash.jpeg",
//                       serviceName: "Car Wash",
//                     ),
//                     ServiceCard(
//                       imagePath: "assets/images/laundry.jpg",
//                       serviceName: "Laundry",
//                     ),
//
//                   ],
//                 ),
//               ),
//               // Padding(
//               //   padding: const EdgeInsets.only(top: 10),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //     children: [
//               //       SubText(text: "Gardening Services"),
//               //       // SubText(text: "View all",color: Color(0xff007AFF),),
//               //
//               //     ],
//               //   ),
//               // ),
//               //
//               // SingleChildScrollView(
//               //   scrollDirection: Axis.horizontal,
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.start,
//               //     crossAxisAlignment: CrossAxisAlignment.start,
//               //     children: [
//               //       ServiceCard(
//               //         imagePath: "assets/images/mens grooming.png",
//               //         serviceName: "Men's Grooming",
//               //       ),
//               //       ServiceCard(
//               //         imagePath: "assets/images/womens grooming.jpg",
//               //         serviceName: "Women's Grooming",
//               //       ),
//               //
//               //     ],
//               //   ),
//               // ),
//
//             ],
//
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
// // import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// // import 'package:fixit/core/utils/custom_texts/main_text.dart';
// // import 'package:flutter/material.dart';
// // import 'dart:async';
// //
// // import '../../../core/utils/custom_widgets/service_category_card.dart';
// //
// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({super.key});
// //
// //   @override
// //   State<HomeScreen> createState() => _HomeScreenState();
// // }
// //
// // class _HomeScreenState extends State<HomeScreen> {
// //   int _unreadNotifications = 0;
// //   late StreamSubscription _notificationSubscription;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _setupNotificationListener();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _notificationSubscription.cancel();
// //     super.dispose();
// //   }
// //
// //   void _setupNotificationListener() {
// //     User? currentUser = FirebaseAuth.instance.currentUser;
// //     if (currentUser == null) return;
// //
// //     _notificationSubscription = FirebaseFirestore.instance
// //         .collection('notifications')
// //         .where('recipientType', isEqualTo: 'user')
// //         .where('isRead', isEqualTo: false)
// //         .snapshots()
// //         .listen((snapshot) {
// //       if (mounted) {
// //         setState(() {
// //           _unreadNotifications = snapshot.docs.length;
// //         });
// //       }
// //     }, onError: (error) {
// //       print('Error listening to notifications: $error');
// //     });
// //   }
// //
// //   Future<void> _markNotificationsAsRead() async {
// //     try {
// //       User? currentUser = FirebaseAuth.instance.currentUser;
// //       if (currentUser == null) return;
// //
// //       QuerySnapshot unreadNotifications = await FirebaseFirestore.instance
// //           .collection('notifications')
// //           .where('recipientType', isEqualTo: 'user')
// //           .where('isRead', isEqualTo: false)
// //           .get();
// //
// //       WriteBatch batch = FirebaseFirestore.instance.batch();
// //       for (var doc in unreadNotifications.docs) {
// //         batch.update(doc.reference, {'isRead': true});
// //       }
// //       await batch.commit();
// //
// //       if (mounted) {
// //         setState(() {
// //           _unreadNotifications = 0;
// //         });
// //       }
// //     } catch (e) {
// //       print('Error marking notifications as read: $e');
// //     }
// //   }
// //
// //   void _openNotificationsPage() async {
// //     await _markNotificationsAsRead(); // Mark as read before navigating
// //
// //     await Navigator.pushNamed(context, '/usernotificationpage');
// //
// //     // After returning, refresh notification count
// //     if (mounted) {
// //       setState(() {
// //         _unreadNotifications = 0;
// //       });
// //     }
// //   }
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Color(0xff0F3966),
// //         leading: Padding(
// //           padding: const EdgeInsets.all(8.0),
// //           child: Image(
// //             image: AssetImage("assets/images/splash_logo.png"),
// //             width: 30,
// //             height: 30,
// //           ),
// //         ),
// //         title: AppBarTitle(text: "FixIt"),
// //         actions: [
// //           Icon(Icons.bookmark, color: Colors.white, size: 24,),
// //           SizedBox(width: 10),
// //
// //           Stack(
// //             children: [
// //               IconButton(
// //                   onPressed: _openNotificationsPage,
// //                   icon: Icon(Icons.notifications, color: Colors.white, size: 24,)
// //               ),
// //               if (_unreadNotifications > 0)
// //                 Positioned(
// //                   right: 6,
// //                   top: 6,
// //                   child: Container(
// //                     padding: EdgeInsets.all(4),
// //                     decoration: BoxDecoration(
// //                       color: Colors.red,
// //                       shape: BoxShape.circle,
// //                     ),
// //                     constraints: BoxConstraints(
// //                       minWidth: 20,
// //                       minHeight: 20,
// //                     ),
// //                     child: Text(
// //                       '$_unreadNotifications',
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                       textAlign: TextAlign.center,
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           SizedBox(width: 10),
// //
// //           Icon(Icons.search, color: Colors.white, size: 24,),
// //           SizedBox(width: 10),
// //
// //           IconButton(
// //               onPressed: () {
// //                 FirebaseAuth.instance.signOut();
// //                 Navigator.pushNamedAndRemoveUntil(context, '/login', (Route route) => false);
// //               },
// //               icon: Icon(Icons.logout, color: Colors.white, size: 24)
// //           ),
// //           SizedBox(width: 10),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(10.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               SubText(text: "Offers"),
// //               SingleChildScrollView(
// //                 scrollDirection: Axis.horizontal,
// //                 child: Row(
// //                   children: [
// //                     Image.asset("assets/images/offer-banner1.png", height: 208, width: 321),
// //                     Image.asset("assets/images/offer-banner2.png", height: 208, width: 321),
// //                   ],
// //                 ),
// //               ),
// //               Divider(color: Colors.black54),
// //               MainText(text: "Our Services"),
// //               Divider(color: Colors.black54),
// //               SubText(text: "Maintenance Services"),
// //               SingleChildScrollView(
// //                 scrollDirection: Axis.horizontal,
// //                 child: Row(
// //                   children: [
// //                     ServiceCard(imagePath: "assets/images/Plumbing.jpg", serviceName: "Plumbing Works"),
// //                     ServiceCard(imagePath: "assets/images/electrical work.jpg", serviceName: "Electrical Works"),
// //                     ServiceCard(imagePath: "assets/images/painting.jpeg", serviceName: "Painting Works"),
// //                     ServiceCard(imagePath: "assets/images/AC repair.jpg", serviceName: "AC Repair"),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/core/utils/custom_texts/main_text.dart';
import 'package:fixit/features/user/view/user_side_drawer.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/custom_widgets/service_category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _setupNotificationListener();
  }

  Future<void> _fetchUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            // Directly use the name from Firestore, fallback to email if name is not available
            _userName = userDoc['name'] ?? currentUser.email?.split('@').first ?? 'User';
          });
        }
      } catch (e) {
        print('Error fetching user name: $e');
        // Fallback to using part of the email if Firestore fetch fails
        setState(() {
          _userName = currentUser.email?.split('@').first ?? 'User';
        });
      }
    }
  }

  void _setupNotificationListener() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientType', isEqualTo: 'user')
        .where('recipientId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _unreadNotifications = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      print('Error listening to notifications: $error');
    });
  }

  Future<void> _markNotificationsAsRead() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      QuerySnapshot unreadNotifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientType', isEqualTo: 'user')
          .where('recipientId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      if (mounted) {
        setState(() {
          _unreadNotifications = 0;
        });
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  void _openNotificationsPage() async {
    await _markNotificationsAsRead();
    await Navigator.pushNamed(context, '/usernotificationpage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: UserSideDrawer(), // Add the side drawer
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.person, color: Colors.blue),
              ),
            ),
          ),
        ),
        title: AppBarTitle(text: _userName),
        actions: [
          Icon(Icons.bookmark, color: Colors.white, size: 24),
          SizedBox(width: 10),

          // Notifications with unread count
          Stack(
            children: [
              IconButton(
                onPressed: _openNotificationsPage,
                icon: Icon(Icons.notifications, color: Colors.white, size: 24),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 10),

          Icon(Icons.search, color: Colors.white, size: 24),
          SizedBox(width: 10),

          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (Route route) => false);
            },
            icon: Icon(Icons.logout, color: Colors.white, size: 24),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SubText(text: "Offers"),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        height: 208,
                        width: 321,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage("assets/images/offer-banner1.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Container(
                        height: 208,
                        width: 321,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage("assets/images/offer-banner2.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Divider(color: Colors.black54),
              ),

              MainText(text: "our services"),

              Divider(color: Colors.black54),

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubText(text: "Maintenance Services"),
                  ],
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServiceCard(
                      imagePath: "assets/images/Plumbing.jpg",
                      serviceName: "Plumbing Works",
                    ),
                    ServiceCard(
                      imagePath: "assets/images/electrical work.jpg",
                      serviceName: "Electrical Works",
                    ),
                    ServiceCard(
                      imagePath: "assets/images/painting.jpeg",
                      serviceName: "Painting Works",
                    ),
                    ServiceCard(
                      imagePath: "assets/images/AC repair.jpg",
                      serviceName: "AC Repair",
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubText(text: "Cleaning Services"),
                  ],
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServiceCard(
                      imagePath: "assets/images/cleaning.jpeg",
                      serviceName: "Cleaning",
                    ),
                    ServiceCard(
                      imagePath: "assets/images/car wash.jpeg",
                      serviceName: "Car Wash",
                    ),
                    ServiceCard(
                      imagePath: "assets/images/laundry.jpg",
                      serviceName: "Laundry",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
