
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:fixit/core/utils/custom_texts/main_text.dart';
// import 'package:fixit/features/user/view/service_providers_list.dart';
// import 'package:fixit/features/user/view/user_search_page.dart';
// import 'package:fixit/features/user/view/user_side_drawer.dart';
// import 'package:flutter/material.dart';
//
//
// import '../../../core/utils/custom_widgets/service_category_card.dart';
//
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   String _userName = 'User';
//   int _unreadNotifications = 0;
//   bool isFavorite = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserName();
//     _setupNotificationListener();
//   }
//
//   Future<void> _fetchUserName() async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       try {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser.uid)
//             .get();
//
//         if (userDoc.exists) {
//           setState(() {
//             // Directly use the name from Firestore, fallback to email if name is not available
//             _userName = userDoc['name'] ?? currentUser.email?.split('@').first ?? 'User';
//           });
//         }
//       } catch (e) {
//         print('Error fetching user name: $e');
//         // Fallback to using part of the email if Firestore fetch fails
//         setState(() {
//           _userName = currentUser.email?.split('@').first ?? 'User';
//         });
//       }
//     }
//   }
//
//
//   void _setupNotificationListener() {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//
//     FirebaseFirestore.instance
//         .collection('notifications')
//         .where('recipientType', isEqualTo: 'user')
//         .where('recipientId', isEqualTo: currentUser.uid)
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//       if (mounted) {
//         setState(() {
//           _unreadNotifications = snapshot.docs.length;
//         });
//       }
//     }, onError: (error) {
//       print('Error listening to notifications: $error');
//     });
//   }
//
//   Future<void> _markNotificationsAsRead() async {
//     try {
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) return;
//
//       QuerySnapshot unreadNotifications = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('recipientType', isEqualTo: 'user')
//           .where('recipientId', isEqualTo: currentUser.uid)
//           .where('isRead', isEqualTo: false)
//           .get();
//
//       WriteBatch batch = FirebaseFirestore.instance.batch();
//       for (var doc in unreadNotifications.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }
//       await batch.commit();
//
//       if (mounted) {
//         setState(() {
//           _unreadNotifications = 0;
//         });
//       }
//     } catch (e) {
//       print('Error marking notifications as read: $e');
//     }
//   }
//
//   void _openNotificationsPage() async {
//     await _markNotificationsAsRead();
//     await Navigator.pushNamed(context, '/usernotificationpage');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: UserSideDrawer(), // Add the side drawer
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         leading: Builder(
//           builder: (context) => Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: IconButton(
//                 onPressed: () => Scaffold.of(context).openDrawer(),
//                 icon: Icon(Icons.person, color: Colors.blue),
//               ),
//             ),
//           ),
//         ),
//         // title: AppBarTitle(text: _userName),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//
//           children: [
//             Text(textAlign: TextAlign.start,"Hello,",style: TextStyle(color: Colors.white,fontSize: 13,),),
//             AppBarTitle(text: _userName),
//
//           ],
//         ),
//         actions: [
//           Icon(Icons.bookmark, color: Colors.white, size: 24),
//           SizedBox(width: 10),
//
//           // Notifications with unread count
//           Stack(
//             children: [
//               IconButton(
//                 onPressed: _openNotificationsPage,
//                 icon: Icon(Icons.notifications, color: Colors.white, size: 24),
//               ),
//               if (_unreadNotifications > 0)
//                 Positioned(
//                   right: 6,
//                   top: 6,
//                   child: Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     constraints: BoxConstraints(
//                       minWidth: 20,
//                       minHeight: 20,
//                     ),
//                     child: Text(
//                       '$_unreadNotifications',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           SizedBox(width: 10),
//
//
//
//
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
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SearchPage()),
//                   );
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey, width: 1),
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.search, color: Colors.grey),
//                             SizedBox(width: 10),
//                             Text(
//                               "Search for Services",
//                               style: TextStyle(color: Colors.grey, fontSize: 18),
//                             ),
//                           ],
//                         ),
//                         Icon(Icons.keyboard_voice, color: Colors.grey),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Divider(color: Colors.black54),
//
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "Offers"),
//                   ],
//                 ),
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 15, bottom: 10),
//                   child: Row(
//                     children: [
//                       Card(
//                         elevation: 2,
//                         margin: EdgeInsets.only(right: 10), // spacing between cards
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image.asset(
//                             "assets/images/offer-banner1.png",
//                             width: 321,
//                             height: 208,
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       ),
//
//                       Card(
//                         elevation: 2,
//                         margin: EdgeInsets.only(right: 10), // spacing between cards
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image.asset(
//                             "assets/images/offer-banner2.png",
//                             width: 321,
//                             height: 208,
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       )
//
//
//                     ],
//                   ),
//                 ),
//               ),
//
//               Padding(
//                 padding: const EdgeInsets.only(top: 15),
//                 child: Divider(color: Colors.black54),
//               ),
//
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "Categories"),
//                     GestureDetector(
//                       onTap: (){
//                         Navigator.pushNamed(context, '/userviewservicespage');
//                       },
//                         child: SubText(text: "View All",color: Colors.blue,fontWeight: FontWeight.w500,))
//                   ],
//                 ),
//               ),
//               GridView.count(
//                 crossAxisCount: 3, // 3 items per row
//                 shrinkWrap: true, // Makes it take only the needed height
//                 physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 0.8, // Adjust based on card height/width
//                 children: [
//                   ServiceCard(
//                     imagePath: "assets/images/Plumbing.jpg",
//                     serviceName: "Plumbing Works",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ServiceProvidersPage(
//                             serviceCategory: "Plumbing",
//                             serviceCategoryId: "BloLb9o2Dp90OvgrHXpF",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ServiceCard(
//                     imagePath: "assets/images/electrical work.jpg",
//                     serviceName: "Electrical Works",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ServiceProvidersPage(
//                             serviceCategory: "Electrical",
//                             serviceCategoryId: "your_actual_id",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ServiceCard(
//                     imagePath: "assets/images/painting.jpeg",
//                     serviceName: "Painting Works",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ServiceProvidersPage(
//                             serviceCategory: "Painting",
//                             serviceCategoryId: "your_actual_id",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ServiceCard(
//                     imagePath: "assets/images/AC repair.jpg",
//                     serviceName: "AC Repair",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ServiceProvidersPage(
//                             serviceCategory: "AC Repair",
//                             serviceCategoryId: "your_actual_id",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ServiceCard(
//                     imagePath: "assets/images/cleaning.jpeg",
//                     serviceName: "Cleaning",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ServiceProvidersPage(
//                             serviceCategory: "Cleaning",
//                             serviceCategoryId: "your_actual_id",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ServiceCard(
//                     imagePath: "assets/images/car wash.jpeg",
//                     serviceName: "Car Wash",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ServiceProvidersPage(
//                             serviceCategory: "Car Wash",
//                             serviceCategoryId: "your_actual_id",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ServiceCard(
//                     imagePath: "assets/images/laundry.jpg",
//                     serviceName: "Laundry",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ServiceProvidersPage(
//                             serviceCategory: "Laundry",
//                             serviceCategoryId: "your_actual_id",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "Near on you"),
//                     SubText(text: "View All",color: Colors.blue,fontWeight: FontWeight.w500,)
//
//
//                 ],),
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     StatefulBuilder(
//                       builder: (context, setState) {
//                         return Card(
//                           elevation: 5,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: SizedBox(
//                             width: 300,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Stack(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                                       child: Image.asset(
//                                         'assets/images/Jhon_plumber5.jpeg',
//                                         width: 300,
//                                         height: 160,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 10,
//                                       right: 10,
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             isFavorite = !isFavorite;
//                                           });
//                                         },
//                                         child: CircleAvatar(
//                                           backgroundColor: Colors.white70,
//                                           child: Icon(
//                                             isFavorite ? Icons.favorite : Icons.favorite_border,
//                                             color: isFavorite ? Colors.red : Colors.grey,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Container(
//                                   width: 300,
//                                   height: 100,
//                                   decoration: const BoxDecoration(
//                                     borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
//                                     color: Colors.white,
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text("Jhon",
//                                                     style: TextStyle(
//                                                         color: Color(0xff0F3966),
//                                                         fontSize: 18,
//                                                         fontWeight: FontWeight.w700)),
//                                                 Text("Plumbing",
//                                                     style: TextStyle(color: Colors.black54)),
//                                               ],
//                                             ),
//                                             Row(
//                                               children: [
//                                                 Icon(Icons.star, color: Colors.amber, size: 16),
//                                                 SizedBox(width: 4),
//                                                 Text("4.9", style: TextStyle(color: Colors.black54)),
//                                                 Text("(200)", style: TextStyle(color: Colors.black54)),
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                         SizedBox(height: 5),
//                                         Row(
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text("₹500/hr", style: TextStyle(color: Colors.black87)),
//                                             Row(
//                                               children: [
//                                                 Icon(Icons.location_on, color: Colors.blue, size: 16),
//                                                 SizedBox(width: 3),
//                                                 Text("24 km", style: TextStyle(color: Colors.black54)),
//                                               ],
//                                             )
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "All Services"),
//                     SubText(text: "View All",color: Colors.blue,fontWeight: FontWeight.w500,)
//
//
//                   ],),
//               ),
//               GridView.builder(
//                 padding: EdgeInsets.all(10),
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: 6, // Update to your list length
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 10,
//                   crossAxisSpacing: 10,
//                   childAspectRatio: 0.7,
//                 ),
//                 itemBuilder: (context, index) {
//                   bool isFavorite = false;
//
//                   return StatefulBuilder(
//                     builder: (context, setState) {
//                       return Card(
//                         elevation: 3,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Column(
//                           children: [
//                             Stack(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                                   child: Image.asset(
//                                     "assets/images/Jhon_plumber5.jpeg", // Replace with actual image
//                                     height: 175,
//                                     width: double.infinity,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: 8,
//                                   right: 8,
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         isFavorite = !isFavorite;
//                                       });
//                                     },
//                                     child: CircleAvatar(
//                                       backgroundColor: Colors.white70,
//                                       radius: 16,
//                                       child: Icon(
//                                         isFavorite ? Icons.favorite : Icons.favorite_border,
//                                         color: isFavorite ? Colors.red : Colors.grey,
//                                         size: 18,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start
//                                         ,children: [
//                                           Text(
//                                             "John",
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               color: Color(0xff0F3966),
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                           SizedBox(height: 2),
//                                           Text("Plumbing", style: TextStyle(color: Colors.black54)),
//                                         ],
//                                       ),
//                                       Container(
//                                         padding: EdgeInsets.all(4),
//                                         width: 47,
//                                         height: 25,
//                                         decoration: BoxDecoration(
//                                           color: Colors.green[700],
//                                             borderRadius: BorderRadius.circular(20)),
//                                         child: Row(
//
//                                           children: [
//                                             Icon(Icons.star, color: Colors.white, size: 16),
//                                             SizedBox(width: 4),
//                                             Text("4.9", style: TextStyle(color: Colors.white, fontSize: 12)),
//                                           ],
//                                         ),
//                                       ),
//
//                                     ],
//                                   ),
//
//                                   SizedBox(height: 6),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//
//                                       Text("₹500/hr", style: TextStyle(color:Color(0xff0F3966),fontWeight: FontWeight.w600, fontSize: 13)),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               )
//
//
//
//
//
//
//
//
//
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:fixit/core/utils/custom_texts/main_text.dart';
// import 'package:fixit/features/user/view/service_providers_list.dart';
// import 'package:fixit/features/user/view/user_search_page.dart';
// import 'package:fixit/features/user/view/user_side_drawer.dart';
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
//   String _userName = 'User';
//   int _unreadNotifications = 0;
//   bool isFavorite = false;
//
//   // Lists to store data from Firestore
//   List<Map<String, dynamic>> _offers = [];
//   List<Map<String, dynamic>> _categories = [];
//   List<Map<String, dynamic>> _services = [];
//
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserName();
//     _setupNotificationListener();
//     _fetchOffers();
//     _fetchCategories();
//     _fetchServices();
//   }
//
//   Future<void> _fetchUserName() async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       try {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser.uid)
//             .get();
//
//         if (userDoc.exists) {
//           setState(() {
//             // Directly use the name from Firestore, fallback to email if name is not available
//             _userName = userDoc['name'] ??
//                 currentUser.email?.split('@').first ??
//                 'User';
//           });
//         }
//       } catch (e) {
//         print('Error fetching user name: $e');
//         // Fallback to using part of the email if Firestore fetch fails
//         setState(() {
//           _userName = currentUser.email?.split('@').first ?? 'User';
//         });
//       }
//     }
//   }
//
//   Future<void> _fetchOffers() async {
//     try {
//       QuerySnapshot offersSnapshot = await FirebaseFirestore.instance
//           .collection('offers')
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       List<Map<String, dynamic>> offers = [];
//       for (var doc in offersSnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         offers.add({
//           'id': doc.id,
//           'name': data['name'] ?? '',
//           'imageUrl': data['imageUrl'] ?? '',
//         });
//       }
//
//       setState(() {
//         _offers = offers;
//       });
//     } catch (e) {
//       print('Error fetching offers: $e');
//     }
//   }
//
//   Future<void> _fetchCategories() async {
//     try {
//       QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance
//           .collection('categories')
//           .orderBy('createdAt', descending: false)
//           .get();
//
//       List<Map<String, dynamic>> categories = [];
//       for (var doc in categoriesSnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         categories.add({
//           'id': doc.id,
//           'name': data['name'] ?? '',
//           'image': data['image'] ?? '',
//           'icon': data['icon'] ?? '',
//         });
//       }
//
//       setState(() {
//         _categories = categories;
//       });
//     } catch (e) {
//       print('Error fetching categories: $e');
//     }
//   }
//
//   Future<void> _fetchServices() async {
//     try {
//       QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
//           .collection('services')
//           .orderBy('created_at', descending: true)
//           .limit(6)
//           .get();
//
//       List<Map<String, dynamic>> services = [];
//       for (var doc in servicesSnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//         // Get provider details
//         DocumentSnapshot providerDoc = await FirebaseFirestore.instance
//             .collection('service provider')
//             .doc(data['provider_id'])
//             .get();
//
//         Map<String, dynamic> providerData = {};
//         if (providerDoc.exists) {
//           providerData = providerDoc.data() as Map<String, dynamic>;
//         }
//
//         services.add({
//           'id': doc.id,
//           'name': data['name'] ?? '',
//           'hourly_rate': data['hourly_rate'] ?? 0,
//           'rating': data['rating'] ?? 0,
//           'rating_count': data['rating_count'] ?? 0,
//           'work_sample': data['work_sample'] ?? '',
//           'work_samples': data['work_samples'] ?? [],
//           'provider_name': providerData['name'] ?? 'Unknown',
//           'provider_image': providerData['profileImage'] ?? '',
//         });
//       }
//
//       setState(() {
//         _services = services;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching services: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _setupNotificationListener() {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//
//     FirebaseFirestore.instance
//         .collection('notifications')
//         .where('recipientType', isEqualTo: 'user')
//         .where('recipientId', isEqualTo: currentUser.uid)
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//       if (mounted) {
//         setState(() {
//           _unreadNotifications = snapshot.docs.length;
//         });
//       }
//     }, onError: (error) {
//       print('Error listening to notifications: $error');
//     });
//   }
//
//   Future<void> _markNotificationsAsRead() async {
//     try {
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) return;
//
//       QuerySnapshot unreadNotifications = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('recipientType', isEqualTo: 'user')
//           .where('recipientId', isEqualTo: currentUser.uid)
//           .where('isRead', isEqualTo: false)
//           .get();
//
//       WriteBatch batch = FirebaseFirestore.instance.batch();
//       for (var doc in unreadNotifications.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }
//       await batch.commit();
//
//       if (mounted) {
//         setState(() {
//           _unreadNotifications = 0;
//         });
//       }
//     } catch (e) {
//       print('Error marking notifications as read: $e');
//     }
//   }
//
//   void _openNotificationsPage() async {
//     await _markNotificationsAsRead();
//     await Navigator.pushNamed(context, '/usernotificationpage');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: UserSideDrawer(), // Add the side drawer
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         leading: Builder(
//           builder: (context) => Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: IconButton(
//                 onPressed: () => Scaffold.of(context).openDrawer(),
//                 icon: Icon(Icons.person, color: Colors.blue),
//               ),
//             ),
//           ),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               textAlign: TextAlign.start,
//               "Hello,",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//               ),
//             ),
//             AppBarTitle(text: _userName),
//           ],
//         ),
//         actions: [
//           GestureDetector(onTap: (){
//             Navigator.pushNamed(context, '/userfavouritespage');
//           },child: Icon(Icons.favorite, color: Colors.white, size: 24)),
//           SizedBox(width: 10),
//
//           // Notifications with unread count
//           Stack(
//             children: [
//               IconButton(
//                 onPressed: _openNotificationsPage,
//                 icon: Icon(Icons.notifications, color: Colors.white, size: 24),
//               ),
//               if (_unreadNotifications > 0)
//                 Positioned(
//                   right: 6,
//                   top: 6,
//                   child: Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     constraints: BoxConstraints(
//                       minWidth: 20,
//                       minHeight: 20,
//                     ),
//                     child: Text(
//                       '$_unreadNotifications',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           SizedBox(width: 10),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Search Bar Section
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SearchPage()),
//                   );
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey, width: 1),
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.search, color: Colors.grey),
//                             SizedBox(width: 10),
//                             Text(
//                               "Search for Services",
//                               style: TextStyle(
//                                   color: Colors.grey, fontSize: 18),
//                             ),
//                           ],
//                         ),
//                         Icon(Icons.keyboard_voice, color: Colors.grey),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Divider(color: Colors.black54),
//
//               // Offers Section
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "Offers"),
//                   ],
//                 ),
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 15, bottom: 10),
//                   child: Row(
//                     children: _offers.isEmpty
//                         ? [
//                       // Fallback if no offers are available
//                       Card(
//                         elevation: 2,
//                         margin: EdgeInsets.only(right: 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image.asset(
//                             "assets/images/offer-banner1.png",
//                             width: 321,
//                             height: 208,
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       ),
//                     ]
//                         : _offers.map((offer) {
//                       return Card(
//                         elevation: 2,
//                         margin: EdgeInsets.only(right: 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image.network(
//                             offer['imageUrl'],
//                             width: 321,
//                             height: 208,
//                             fit: BoxFit.fill,
//                             // Fallback for network image loading failure
//                             errorBuilder:
//                                 (context, error, stackTrace) =>
//                                 Image.asset(
//                                   "assets/images/offer-banner1.png",
//                                   width: 321,
//                                   height: 208,
//                                   fit: BoxFit.fill,
//                                 ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//
//               Padding(
//                 padding: const EdgeInsets.only(top: 15),
//                 child: Divider(color: Colors.black54),
//               ),
//
//               // Categories Section
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "Categories"),
//                     GestureDetector(
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, '/userviewservicespage');
//                         },
//                         child: SubText(
//                           text: "View All",
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w500,
//                         ))
//                   ],
//                 ),
//               ),
//               GridView.count(
//                 crossAxisCount: 3,
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 0.8,
//                 children: _categories.isEmpty
//                     ? [
//                   // Fallback categories if no data available
//                   ServiceCard(
//                     imagePath: "assets/images/Plumbing.jpg",
//                     serviceName: "Plumbing Works",
//                     onTap: () {},
//                   ),
//                   ServiceCard(
//                     imagePath: "assets/images/electrical work.jpg",
//                     serviceName: "Electrical Works",
//                     onTap: () {},
//                   ),
//                   ServiceCard(
//                     imagePath: "assets/images/painting.jpeg",
//                     serviceName: "Painting Works",
//                     onTap: () {},
//                   ),
//                 ]
//                     : _categories.take(7).map((category) {
//                   return ServiceCard(
//                     networkImage: category['image'],
//                     serviceName: category['name'],
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               ServiceProvidersPage(
//                                 serviceCategory: category['name'],
//                                 serviceCategoryId: category['id'],
//                               ),
//                         ),
//                       );
//                     },
//                   );
//                 }).toList(),
//               ),
//
//               // Near on you Section
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "Near on you"),
//                     SubText(
//                       text: "View All",
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w500,
//                     )
//                   ],
//                 ),
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: _services.isEmpty
//                       ? [
//                     // Fallback service card if no data available
//                     _buildNearbyServiceProviderCard(
//                         name: "John",
//                         service: "Plumbing",
//                         imagePath:
//                         'assets/images/Jhon_plumber5.jpeg',
//                         rating: 4.9,
//                         ratingCount: 200,
//                         hourlyRate: 500,
//                         distance: "24 km")
//                   ]
//                       : _services.map((service) {
//                     return _buildNearbyServiceProviderCard(
//                         name: service['provider_name'],
//                         service: service['name'],
//                         networkImage: service['provider_image'],
//                         rating: service['rating'].toDouble(),
//                         ratingCount: service['rating_count'],
//                         hourlyRate: service['hourly_rate'],
//                         distance: "Nearby" // For demo purposes
//                     );
//                   }).toList(),
//                 ),
//               ),
//
//               // All Services Section
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SubText(text: "All Services"),
//                     SubText(
//                       text: "View All",
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w500,
//                     )
//                   ],
//                 ),
//               ),
//               GridView.builder(
//                 padding: EdgeInsets.all(10),
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: _services.isEmpty ? 6 : _services.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 10,
//                   crossAxisSpacing: 10,
//                   childAspectRatio: 0.7,
//                 ),
//                 itemBuilder: (context, index) {
//                   if (_services.isEmpty) {
//                     // Fallback service card if no data available
//                     return _buildServiceCard(
//                         name: "John",
//                         service: "Plumbing",
//                         imagePath: "assets/images/Jhon_plumber5.jpeg",
//                         rating: 4.9,
//                         hourlyRate: 500);
//                   } else {
//                     final service = _services[index];
//                     return _buildServiceCard(
//                         name: service['provider_name'],
//                         service: service['name'],
//                         networkImage: service['work_sample'],
//                         rating: service['rating'].toDouble(),
//                         hourlyRate: service['hourly_rate']);
//                   }
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Helper method to build nearby service provider card
//   Widget _buildNearbyServiceProviderCard(
//       {required String name,
//         required String service,
//         String? imagePath,
//         String? networkImage,
//         required double rating,
//         required int ratingCount,
//         required int hourlyRate,
//         required String distance}) {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         bool isFavorite = false;
//
//         return Card(
//           elevation: 5,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: SizedBox(
//             width: 300,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius:
//                       BorderRadius.vertical(top: Radius.circular(20)),
//                       child: networkImage != null && networkImage.isNotEmpty
//                           ? Image.network(
//                         networkImage,
//                         width: 300,
//                         height: 160,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             Image.asset(
//                               imagePath ?? 'assets/images/Jhon_plumber5.jpeg',
//                               width: 300,
//                               height: 160,
//                               fit: BoxFit.cover,
//                             ),
//                       )
//                           : Image.asset(
//                         imagePath ?? 'assets/images/Jhon_plumber5.jpeg',
//                         width: 300,
//                         height: 160,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             isFavorite = !isFavorite;
//                           });
//                         },
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white70,
//                           radius: 16,
//                           child: Icon(
//                             isFavorite ? Icons.favorite : Icons.favorite_border,
//                             color: isFavorite ? Colors.red : Colors.grey,
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 Container(
//                   width: 300,
//                   height: 100,
//                   decoration: const BoxDecoration(
//                     borderRadius:
//                     BorderRadius.vertical(bottom: Radius.circular(12)),
//                     color: Colors.white,
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(name,
//                                     style: TextStyle(
//                                         color: Color(0xff0F3966),
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w700)),
//                                 Text(service,
//                                     style: TextStyle(color: Colors.black54)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Icon(Icons.star, color: Colors.amber, size: 16),
//                                 SizedBox(width: 4),
//                                 Text("$rating",
//                                     style: TextStyle(color: Colors.black54)),
//                                 Text("($ratingCount)",
//                                     style: TextStyle(color: Colors.black54)),
//                               ],
//                             )
//                           ],
//                         ),
//                         SizedBox(height: 5),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("₹$hourlyRate/hr",
//                                 style: TextStyle(color: Colors.black87)),
//                             Row(
//                               children: [
//                                 Icon(Icons.location_on,
//                                     color: Colors.blue, size: 16),
//                                 SizedBox(width: 3),
//                                 Text(distance,
//                                     style: TextStyle(color: Colors.black54)),
//                               ],
//                             )
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Helper method to build service card for All Services section
//   Widget _buildServiceCard(
//       {required String name,
//         required String service,
//         String? imagePath,
//         String? networkImage,
//         required double rating,
//         required int hourlyRate}) {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         bool isFavorite = false;
//
//         return Card(
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             children: [
//               Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius:
//                     BorderRadius.vertical(top: Radius.circular(20)),
//                     child: networkImage != null && networkImage.isNotEmpty
//                         ? Image.network(
//                       networkImage,
//                       height: 175,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) =>
//                           Image.asset(
//                             imagePath ?? "assets/images/Jhon_plumber5.jpeg",
//                             height: 175,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                           ),
//                     )
//                         : Image.asset(
//                       imagePath ?? "assets/images/Jhon_plumber5.jpeg",
//                       height: 175,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isFavorite = !isFavorite;
//                         });
//                       },
//                       child: CircleAvatar(
//                         backgroundColor: Colors.white70,
//                         radius: 16,
//                         child: Icon(
//                           isFavorite ? Icons.favorite : Icons.favorite_border,
//                           color: isFavorite ? Colors.red : Colors.grey,
//                           size: 18,
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               name,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xff0F3966),
//                                 fontSize: 16,
//                               ),
//                             ),
//                             SizedBox(height: 2),
//                             Text(service,
//                                 style: TextStyle(color: Colors.black54)),
//                           ],
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(4),
//                           width: 47,
//                           height: 25,
//                           decoration: BoxDecoration(
//                               color: Colors.green[700],
//                               borderRadius: BorderRadius.circular(20)),
//                           child: Row(
//                             children: [
//                               Icon(Icons.star, color: Colors.white, size: 16),
//                               SizedBox(width: 4),
//                               Text("$rating",
//                                   style: TextStyle(
//                                       color: Colors.white, fontSize: 12)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 6),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("₹$hourlyRate/hr",
//                             style: TextStyle(
//                                 color: Color(0xff0F3966),
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/core/utils/custom_texts/main_text.dart';
import 'package:fixit/features/user/view/service_providers_list.dart';
import 'package:fixit/features/user/view/user_search_page.dart';
import 'package:fixit/features/user/view/user_side_drawer.dart';
import 'package:fixit/features/user/view/view_service_details_page.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/custom_widgets/service_category_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _unreadNotifications = 0;

  // Maps to track favorites by ID
  Map<String, bool> _favoriteServices = {};
  Map<String, bool> _favoriteProviders = {};

  // Lists to store data from Firestore
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _services = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _setupNotificationListener();
    _fetchOffers();
    _fetchCategories();
    _fetchServices();
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
            _userName = userDoc['name'] ??
                currentUser.email?.split('@').first ??
                'User';
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

  Future<void> _fetchOffers() async {
    try {
      QuerySnapshot offersSnapshot = await FirebaseFirestore.instance
          .collection('offers')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> offers = [];
      for (var doc in offersSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        offers.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
        });
      }

      setState(() {
        _offers = offers;
      });
    } catch (e) {
      print('Error fetching offers: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('createdAt', descending: false)
          .get();

      List<Map<String, dynamic>> categories = [];
      for (var doc in categoriesSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        categories.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'image': data['image'] ?? '',
          'icon': data['icon'] ?? '',
        });
      }

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _fetchServices() async {
    try {
      QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .orderBy('created_at', descending: true)
          .limit(6)
          .get();

      List<Map<String, dynamic>> services = [];
      for (var doc in servicesSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Get provider details
        DocumentSnapshot providerDoc = await FirebaseFirestore.instance
            .collection('service provider')
            .doc(data['provider_id'])
            .get();

        Map<String, dynamic> providerData = {};
        if (providerDoc.exists) {
          providerData = providerDoc.data() as Map<String, dynamic>;
        }

        services.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          // 'hourly_rate': data['hourly_rate'] ?? 0,
          // 'rating': data['rating'] ?? 0,
          // 'rating_count': data['rating_count'] ?? 0,
          'hourly_rate': _parseNumber(data['hourly_rate']),
          'rating': _parseNumber(data['rating']),
          'rating_count': _parseNumber(data['rating_count']),
          'work_sample': data['work_sample'] ?? '',
          'work_samples': data['work_samples'] ?? [],
          'provider_id': data['provider_id'] ?? '',  // Store provider ID
          'provider_name': providerData['name'] ?? 'Unknown',
          'provider_image': providerData['profileImage'] ?? '',
        });
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        _isLoading = false;
      });
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
  num _parseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      // Remove any currency symbols or commas
      final cleanedValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return num.tryParse(cleanedValue) ?? 0;
    }
    return 0;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textAlign: TextAlign.start,
              "Hello,",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            AppBarTitle(text: _userName),
          ],
        ),
        actions: [
          GestureDetector(onTap: (){
            Navigator.pushNamed(context, '/userfavouritespage');
          },child: Icon(Icons.favorite, color: Colors.white, size: 24)),
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
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search Bar Section
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 10),
                            Text(
                              "Search for Services",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 18),
                            ),
                          ],
                        ),
                        Icon(Icons.keyboard_voice, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(color: Colors.black54),

              // Offers Section
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubText(text: "Offers"),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Row(
                    children: _offers.isEmpty
                        ? [
                      // Fallback if no offers are available
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.only(right: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/images/offer-banner1.png",
                            width: 321,
                            height: 208,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ]
                        : _offers.map((offer) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(right: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            offer['imageUrl'],
                            width: 321,
                            height: 208,
                            fit: BoxFit.fill,
                            // Fallback for network image loading failure
                            errorBuilder:
                                (context, error, stackTrace) =>
                                Image.asset(
                                  "assets/images/offer-banner1.png",
                                  width: 321,
                                  height: 208,
                                  fit: BoxFit.fill,
                                ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Divider(color: Colors.black54),
              ),

              // Categories Section
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubText(text: "Categories"),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/userviewservicespage');
                        },
                        child: SubText(
                          text: "View All",
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ))
                  ],
                ),
              ),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
                children: _categories.isEmpty
                    ? [
                  // Fallback categories if no data available
                  ServiceCard(
                    imagePath: "assets/images/Plumbing.jpg",
                    serviceName: "Plumbing Works",
                    onTap: () {},
                  ),
                  ServiceCard(
                    imagePath: "assets/images/electrical work.jpg",
                    serviceName: "Electrical Works",
                    onTap: () {},
                  ),
                  ServiceCard(
                    imagePath: "assets/images/painting.jpeg",
                    serviceName: "Painting Works",
                    onTap: () {},
                  ),
                ]
                    : _categories.take(7).map((category) {
                  return ServiceCard(
                    networkImage: category['image'],
                    serviceName: category['name'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ServiceProvidersPage(
                                serviceCategory: category['name'],
                                serviceCategoryId: category['id'],
                              ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              // Near on you Section
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubText(text: "Near on you"),
                    SubText(
                      text: "View All",
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _services.isEmpty
                      ? [
                    // Fallback service card if no data available
                    _buildNearbyServiceProviderCard(
                        name: "John",
                        service: "Plumbing",
                        imagePath: 'assets/images/Jhon_plumber5.jpeg',
                        rating: 4.9,
                        ratingCount: 200,
                        hourlyRate: 500,
                        distance: "24 km",
                        providerId: "dummy_provider_id")
                  ]
                      : _services.map((service) {
                    return _buildNearbyServiceProviderCard(
                        name: service['provider_name'],
                        service: service['name'],
                        networkImage: service['provider_image'],
                        // rating: service['rating'].toDouble(),
                        // ratingCount: service['rating_count'],
                        // hourlyRate: service['hourly_rate'],
                        rating: service['rating'].toDouble(), // Ensure double
                        ratingCount: service['rating_count'].toInt(), // Ensure int
                        hourlyRate: service['hourly_rate'].toInt(), // Ensure int
                        distance: "Nearby", // For demo purposes
                        providerId: service['provider_id'] ?? '');
                  }).toList(),
                ),
              ),

              // All Services Section
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubText(text: "All Services"),
                    SubText(
                      text: "View All",
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    )
                  ],
                ),
              ),
              GridView.builder(
                padding: EdgeInsets.all(10),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _services.isEmpty ? 6 : _services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  if (_services.isEmpty) {
                    // Fallback service card if no data available
                    return _buildServiceCard(
                      name: "John",
                      service: "Plumbing",
                      imagePath: "assets/images/Jhon_plumber5.jpeg",
                      rating: 4.9,
                      hourlyRate: 500,
                      serviceId: "dummy_service_id",
                      // Add navigation to a dummy service page or show a message
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No service details available')),
                        );
                      },
                    );
                  } else {
                    final service = _services[index];
                    return _buildServiceCard(
                      name: service['provider_name'],
                      service: service['name'],
                      networkImage: service['work_sample'],
                      rating: service['rating'].toDouble(), // Ensure double
                      hourlyRate: service['hourly_rate'].toInt(), // Ensure int
                      serviceId: service['id'] ?? '',
                      // Add navigation to the service details page
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewServiceDetailsPage(
                              serviceId: service['id'] ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              )
              // GridView.builder(
              //   padding: EdgeInsets.all(10),
              //   shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              //   itemCount: _services.isEmpty ? 6 : _services.length,
              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 2,
              //     mainAxisSpacing: 10,
              //     crossAxisSpacing: 10,
              //     childAspectRatio: 0.7,
              //   ),
              //   itemBuilder: (context, index) {
              //     if (_services.isEmpty) {
              //       // Fallback service card if no data available
              //       return _buildServiceCard(
              //           name: "John",
              //           service: "Plumbing",
              //           imagePath: "assets/images/Jhon_plumber5.jpeg",
              //           rating: 4.9,
              //           hourlyRate: 500,
              //           serviceId: "dummy_service_id");
              //     } else {
              //       final service = _services[index];
              //       return _buildServiceCard(
              //           name: service['provider_name'],
              //           service: service['name'],
              //           networkImage: service['work_sample'],
              //           // rating: service['rating'].toDouble(),
              //           // hourlyRate: service['hourly_rate'],
              //           rating: service['rating'].toDouble(), // Ensure double
              //           hourlyRate: service['hourly_rate'].toInt(), // Ensure int
              //           serviceId: service['id'] ?? '');
              //     }
              //   },
              // )
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build nearby service provider card
  Widget _buildNearbyServiceProviderCard({
    required String name,
    required String service,
    String? imagePath,
    String? networkImage,
    // required double rating,
    // required int ratingCount,
    // required int hourlyRate,
    required num rating,  // Changed from double to num
    required num ratingCount,  // Changed from int to num
    required num hourlyRate,
    required String distance,
    required String providerId,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                  child: networkImage != null && networkImage.isNotEmpty
                      ? Image.network(
                    networkImage,
                    width: 300,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                          imagePath ?? 'assets/images/Jhon_plumber5.jpeg',
                          width: 300,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                  )
                      : Image.asset(
                    imagePath ?? 'assets/images/Jhon_plumber5.jpeg',
                    width: 300,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _favoriteProviders[providerId] = !(_favoriteProviders[providerId] ?? false);
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      radius: 16,
                      child: Icon(
                        (_favoriteProviders[providerId] ?? false) ? Icons.favorite : Icons.favorite_border,
                        color: (_favoriteProviders[providerId] ?? false) ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Container(
              width: 300,
              height: 100,
              decoration: const BoxDecoration(
                borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(12)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: TextStyle(
                                    color: Color(0xff0F3966),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                            Text(service,
                                style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text("${rating.toDouble()}",
                                style: TextStyle(color: Colors.black54)),
                            Text("(${ratingCount.toInt()})",
                                style: TextStyle(color: Colors.black54)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₹${hourlyRate.toInt()}/hr",
                            style: TextStyle(color: Colors.black87)),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.blue, size: 16),
                            SizedBox(width: 3),
                            Text(distance,
                                style: TextStyle(color: Colors.black54)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build service card for All Services section
  Widget _buildServiceCard({
    required String name,
    required String service,
    String? imagePath,
    String? networkImage,
    required num rating,
    required num hourlyRate,
    required String serviceId,
    // Add the onTap parameter
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      // Add onTap handler to the entire card
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                  child: networkImage != null && networkImage.isNotEmpty
                      ? Image.network(
                    networkImage,
                    height: 175,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                          imagePath ?? "assets/images/Jhon_plumber5.jpeg",
                          height: 175,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  )
                      : Image.asset(
                    imagePath ?? "assets/images/Jhon_plumber5.jpeg",
                    height: 175,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _favoriteServices[serviceId] = !(_favoriteServices[serviceId] ?? false);
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      radius: 16,
                      child: Icon(
                        (_favoriteServices[serviceId] ?? false) ? Icons.favorite : Icons.favorite_border,
                        color: (_favoriteServices[serviceId] ?? false) ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F3966),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(service,
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        width: 47,
                        height: 25,
                        decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text("${rating.toDouble()}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹${hourlyRate.toInt()}/hr",
                          style: TextStyle(
                              color: Color(0xff0F3966),
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Widget _buildServiceCard({
  //   required String name,
  //   required String service,
  //   String? imagePath,
  //   String? networkImage,
  //   // required double rating,
  //   // required int hourlyRate,
  //   required num rating,  // Changed from double to num
  //   required num hourlyRate,
  //   required String serviceId,
  // }) {
  //   return Card(
  //     elevation: 3,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Column(
  //       children: [
  //         Stack(
  //           children: [
  //             ClipRRect(
  //               borderRadius:
  //               BorderRadius.vertical(top: Radius.circular(20)),
  //               child: networkImage != null && networkImage.isNotEmpty
  //                   ? Image.network(
  //                 networkImage,
  //                 height: 175,
  //                 width: double.infinity,
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) =>
  //                     Image.asset(
  //                       imagePath ?? "assets/images/Jhon_plumber5.jpeg",
  //                       height: 175,
  //                       width: double.infinity,
  //                       fit: BoxFit.cover,
  //                     ),
  //               )
  //                   : Image.asset(
  //                 imagePath ?? "assets/images/Jhon_plumber5.jpeg",
  //                 height: 175,
  //                 width: double.infinity,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //             Positioned(
  //               top: 8,
  //               right: 8,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     _favoriteServices[serviceId] = !(_favoriteServices[serviceId] ?? false);
  //                   });
  //                 },
  //                 child: CircleAvatar(
  //                   backgroundColor: Colors.white70,
  //                   radius: 16,
  //                   child: Icon(
  //                     (_favoriteServices[serviceId] ?? false) ? Icons.favorite : Icons.favorite_border,
  //                     color: (_favoriteServices[serviceId] ?? false) ? Colors.red : Colors.grey,
  //                     size: 18,
  //                   ),
  //                 ),
  //               ),
  //             )
  //           ],
  //         ),
  //         Padding(
  //           padding:
  //           const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         name,
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           color: Color(0xff0F3966),
  //                           fontSize: 16,
  //                         ),
  //                       ),
  //                       SizedBox(height: 2),
  //                       Text(service,
  //                           style: TextStyle(color: Colors.black54)),
  //                     ],
  //                   ),
  //                   Container(
  //                     padding: EdgeInsets.all(4),
  //                     width: 47,
  //                     height: 25,
  //                     decoration: BoxDecoration(
  //                         color: Colors.green[700],
  //                         borderRadius: BorderRadius.circular(20)),
  //                     child: Row(
  //                       children: [
  //                         Icon(Icons.star, color: Colors.white, size: 16),
  //                         SizedBox(width: 4),
  //                         Text("${rating.toDouble()}",
  //                             style: TextStyle(
  //                                 color: Colors.white, fontSize: 12)),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 6),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text("₹${hourlyRate.toInt()}/hr",
  //                       style: TextStyle(
  //                           color: Color(0xff0F3966),
  //                           fontWeight: FontWeight.w600,
  //                           fontSize: 13)),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
