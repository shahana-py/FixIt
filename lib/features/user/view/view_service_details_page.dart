//
// import 'package:fixit/features/user/view/service_booking_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'message_provider_page.dart';
//
//
//
// class ViewServiceDetailsPage extends StatefulWidget {
//   final String serviceId;
//
//   const ViewServiceDetailsPage({Key? key, required this.serviceId}) : super(key: key);
//
//   @override
//   _ViewServiceDetailsPageState createState() => _ViewServiceDetailsPageState();
// }
//
// class _ViewServiceDetailsPageState extends State<ViewServiceDetailsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? serviceData;
//   Map<String, dynamic>? providerData;
//   bool isLoading = true;
//   int currentImageIndex = 0;
//   final pageController = PageController();
//   bool showFullDescription = false;
//   List<String> serviceImages = [];
//
//   Map<String, bool> _favoriteProviders = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchServiceDetails();
//   }
//
//   Future<void> _fetchServiceDetails() async {
//     try {
//       // Fetch service details
//       DocumentSnapshot serviceDoc =
//       await _firestore.collection('services').doc(widget.serviceId).get();
//
//       if (serviceDoc.exists) {
//         serviceData = serviceDoc.data() as Map<String, dynamic>;
//
//         // Initialize service images array
//         serviceImages = [];
//
//         // Add work sample if exists
//         if (serviceData!.containsKey('work_sample') &&
//             serviceData!['work_sample'] != null &&
//             serviceData!['work_sample'].toString().isNotEmpty) {
//           serviceImages.add(serviceData!['work_sample']);
//         }
//
//         // Add additional work samples if they exist
//         if (serviceData!.containsKey('additional_work_samples') &&
//             serviceData!['additional_work_samples'] is List &&
//             (serviceData!['additional_work_samples'] as List).isNotEmpty) {
//           for (var image in serviceData!['additional_work_samples']) {
//             if (image != null && image.toString().isNotEmpty) {
//               serviceImages.add(image);
//             }
//           }
//         }
//
//         // If no images at all, add a placeholder
//         if (serviceImages.isEmpty) {
//           serviceImages.add('https://via.placeholder.com/400?text=No+Images');
//         }
//
//         // Fetch provider details
//         if (serviceData!.containsKey('provider_id')) {
//           DocumentSnapshot providerDoc = await _firestore
//               .collection('service provider')
//               .doc(serviceData!['provider_id'])
//               .get();
//
//           if (providerDoc.exists) {
//             providerData = providerDoc.data() as Map<String, dynamic>;
//           }
//         }
//       }
//     } catch (e) {
//       print('Error fetching service details: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Widget _buildInfoSection(String title, List<dynamic> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 24),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF344D67),
//           ),
//         ),
//         SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: items.map((item) {
//             return Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Color(0xff0F3966).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Color(0xff0F3966).withOpacity(0.3)),
//               ),
//               child: Text(
//                 item.toString(),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF344D67),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   void _navigateToChat() {
//     if (serviceData != null && providerData != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChatPage(
//             providerId: serviceData!['provider_id'],
//             providerName: providerData!['name'] ?? 'Service Provider',
//             providerImage: providerData!['profileImage'] ?? '',
//             serviceId: widget.serviceId,
//             serviceName: serviceData!['name'] ?? 'Service',
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Cannot open chat at this moment')),
//       );
//     }
//   }
//
//   // Navigate to the booking page
//   void _navigateToBooking() {
//     if (serviceData != null && providerData != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BookingPage(
//             serviceId: widget.serviceId,
//             serviceData: serviceData!,
//             providerData: providerData!,
//             serviceImages: serviceImages,
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Cannot book service at this moment')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Calculate average rating
//     double avgRating = 0.0;
//     int ratingCount = 0;
//     if (serviceData != null) {
//       final rating = (serviceData!['rating'] as num?)?.toDouble() ?? 0.0;
//       ratingCount = (serviceData!['rating_count'] as num?)?.toInt() ?? 0;
//       avgRating = ratingCount > 0 ? (rating / ratingCount) : 0.0;
//     }
//
//     String providerName = providerData?['name'] ?? 'Service Provider';
//     String serviceName = serviceData?['name'] ?? 'Service';
//     String experience = serviceData?['experience']?.toString() ?? '0';
//
//     // Get available areas and days
//     List<dynamic> availableAreas = serviceData?['available_areas'] ?? [];
//     List<dynamic> availableDays = serviceData?['available_days'] ?? [];
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : serviceData == null
//           ? Center(child: Text('Service not found'))
//           : Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Image slider with back and more buttons
//                   Stack(
//                     children: [
//                       Container(
//                         height: MediaQuery.of(context).size.height * 0.4,
//                         child: PageView.builder(
//                           controller: pageController,
//                           onPageChanged: (index) {
//                             setState(() {
//                               currentImageIndex = index;
//                             });
//                           },
//                           itemCount: serviceImages.length,
//                           itemBuilder: (context, index) {
//                             return Image.network(
//                               serviceImages[index],
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey[300],
//                                   child: Center(
//                                     child: Icon(
//                                       Icons.image_not_supported,
//                                       size: 50,
//                                       color: Colors.grey[500],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                       // Navigation buttons
//                       Positioned(
//                         top: MediaQuery.of(context).padding.top + 8,
//                         left: 16,
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white,
//                           radius: 22,
//                           child: IconButton(
//                             icon: Icon(Icons.arrow_back_ios_new, size: 18),
//                             onPressed: () => Navigator.pop(context),
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: 8,
//                         right: 8,
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _favoriteProviders[providerId] = !(_favoriteProviders[providerId] ?? false);
//                             });
//                           },
//                           child: CircleAvatar(
//                             backgroundColor: Colors.white70,
//                             radius: 16,
//                             child: Icon(
//                               (_favoriteProviders[providerId] ?? false) ? Icons.favorite : Icons.favorite_border,
//                               color: (_favoriteProviders[providerId] ?? false) ? Colors.red : Colors.grey,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       )
//                       // Page indicator dots - only show if more than one image
//                       if (serviceImages.length > 1)
//                         Positioned(
//                           bottom: 16,
//                           left: 0,
//                           right: 0,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(
//                               serviceImages.length,
//                                   (index) => Container(
//                                 width: 8,
//                                 height: 8,
//                                 margin: EdgeInsets.symmetric(horizontal: 4),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: currentImageIndex == index
//                                       ? Colors.white
//                                       : Colors.white.withOpacity(0.5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       // Service provider profile picture
//                       Positioned(
//                         bottom: 20,
//                         right: 24,
//                         child: Container(
//                           height: 90,
//                           width: 90,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.white,
//                               width: 2,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 5,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: providerData != null &&
//                                 providerData!.containsKey('profileImage') &&
//                                 providerData!['profileImage'] != null
//                                 ? Image.network(
//                               providerData!['profileImage'],
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey[200],
//                                   child: Icon(Icons.person, size: 30, color: Colors.grey[400]),
//                                 );
//                               },
//                             )
//                                 : Container(
//                               color: Colors.grey[200],
//                               child: Icon(Icons.person, size: 30, color: Colors.grey[400]),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   // Profile info
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 providerName,
//                                 style: TextStyle(
//                                   fontSize: 26,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF344D67),
//                                 ),
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Icon(Icons.star, color: Colors.amber, size: 18),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   avgRating.toStringAsFixed(1),
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   ' (${ratingCount})',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '$serviceName • ${experience} year Experience',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//
//                         SizedBox(height: 24),
//                         Text(
//                           'About me',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF344D67),
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           serviceData!['description'] ??
//                               'I\'m $providerName, a dedicated $serviceName with $experience years of hands-on experience. I specialize in everything from routine maintenance to complex installations and repairs.',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[700],
//                           ),
//                           maxLines: showFullDescription ? null : 3,
//                           overflow: showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               showFullDescription = !showFullDescription;
//                             });
//                           },
//                           child: Text(
//                             showFullDescription ? 'Show less' : 'Read more...',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ),
//
//                         // Available Areas Section
//                         if (availableAreas.isNotEmpty)
//                           _buildInfoSection('Available Areas', availableAreas),
//
//                         // Available Days Section
//                         if (availableDays.isNotEmpty)
//                           _buildInfoSection('Available Days', availableDays),
//
//                         SizedBox(height: 24),
//
//                         // Reviews section
//                         Text(
//                           'Review',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF344D67),
//                           ),
//                         ),
//                         SizedBox(height: 8),
//
//                         // Stars
//                         Row(
//                           children: List.generate(5, (index) {
//                             return Icon(
//                               Icons.star,
//                               color: Colors.amber,
//                               size: 20,
//                             );
//                           }),
//                         ),
//                         SizedBox(height: 8),
//
//                         // Review text
//                         Container(
//                           padding: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[100],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '"$providerName is a true professional. ${providerName.split(' ')[0]} quickly diagnosed the issue and fixed it with ease. Impressive expertise and dedication to the work. Good job!"',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               SizedBox(height: 12),
//                               Align(
//                                 alignment: Alignment.bottomRight,
//                                 child: Text(
//                                   'Alex T',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[800],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Bottom hire section
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '₹${serviceData!['hourly_rate'] ?? '0'}/Hr',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     OutlinedButton.icon(
//                       onPressed: _navigateToChat,
//                       icon: Icon(Icons.message, size: 16, color: Color(0xff0F3966)),
//                       label: Text('Message', style: TextStyle(color: Color(0xff0F3966), fontWeight: FontWeight.bold, fontSize: 16)),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Color(0xff0F3966),
//                         side: BorderSide(color: Color(0xff0F3966)),
//                         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: _navigateToBooking, // Updated to use the new navigation method
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xff0F3966),
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                       ),
//                       child: Text(
//                         'Book Now',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fixit/features/user/view/service_booking_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'message_provider_page.dart';
//
// class ViewServiceDetailsPage extends StatefulWidget {
//   final String serviceId;
//
//   const ViewServiceDetailsPage({Key? key, required this.serviceId})
//       : super(key: key);
//
//   @override
//   _ViewServiceDetailsPageState createState() => _ViewServiceDetailsPageState();
// }
//
// class _ViewServiceDetailsPageState extends State<ViewServiceDetailsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? serviceData;
//   Map<String, dynamic>? providerData;
//   bool isLoading = true;
//   int currentImageIndex = 0;
//   final PageController pageController = PageController();
//   bool showFullDescription = false;
//   List<String> serviceImages = [];
//   bool isProviderFavorite = false;
//   String? providerId;
//   Set<String> _favoriteServiceIds = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchServiceDetails();
//     _fetchUserFavorites();
//   }
//
//   Future<void> _fetchServiceDetails() async {
//     try {
//       DocumentSnapshot serviceDoc =
//       await _firestore.collection('services').doc(widget.serviceId).get();
//
//       if (serviceDoc.exists) {
//         serviceData = serviceDoc.data() as Map<String, dynamic>;
//
//         if (serviceData!.containsKey('provider_id')) {
//           providerId = serviceData!['provider_id'];
//           isProviderFavorite = _favoriteServiceIds.contains(widget.serviceId);
//         }
//
//         serviceImages = [];
//
//         if (serviceData!.containsKey('work_sample') &&
//             serviceData!['work_sample'] != null &&
//             serviceData!['work_sample'].toString().isNotEmpty) {
//           serviceImages.add(serviceData!['work_sample']);
//         }
//
//         if (serviceData!.containsKey('additional_work_samples') &&
//             serviceData!['additional_work_samples'] is List &&
//             (serviceData!['additional_work_samples'] as List).isNotEmpty) {
//           for (var image in serviceData!['additional_work_samples']) {
//             if (image != null && image.toString().isNotEmpty) {
//               serviceImages.add(image);
//             }
//           }
//         }
//
//         if (serviceImages.isEmpty) {
//           serviceImages.add('https://via.placeholder.com/400?text=No+Images');
//         }
//
//         if (providerId != null) {
//           DocumentSnapshot providerDoc = await _firestore
//               .collection('service provider')
//               .doc(providerId)
//               .get();
//
//           if (providerDoc.exists) {
//             providerData = providerDoc.data() as Map<String, dynamic>;
//           }
//         }
//       }
//     } catch (e) {
//       print('Error fetching service details: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _fetchUserFavorites() async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//
//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();
//
//       if (userDoc.exists && userDoc.data() != null) {
//         var userData = userDoc.data() as Map<String, dynamic>;
//         if (userData.containsKey('favorites') &&
//             userData['favorites'] is List) {
//           setState(() {
//             _favoriteServiceIds =
//             Set<String>.from(userData['favorites'] as List);
//             isProviderFavorite = _favoriteServiceIds.contains(widget.serviceId);
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching user favorites: $e');
//     }
//   }
//
//   Future<void> _toggleFavorite() async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//
//     try {
//       bool isCurrentlyFavorite = _favoriteServiceIds.contains(widget.serviceId);
//       Set<String> newFavorites = Set<String>.from(_favoriteServiceIds);
//
//       if (isCurrentlyFavorite) {
//         newFavorites.remove(widget.serviceId);
//       } else {
//         newFavorites.add(widget.serviceId);
//       }
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .update({'favorites': newFavorites.toList()});
//
//       setState(() {
//         _favoriteServiceIds = newFavorites;
//         isProviderFavorite = !isCurrentlyFavorite;
//       });
//     } catch (e) {
//       print('Error toggling favorite: $e');
//     }
//   }
//
//   Widget _buildInfoSection(String title, List<dynamic> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 24),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF344D67),
//           ),
//         ),
//         SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: items.map((item) {
//             return Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Color(0xff0F3966).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Color(0xff0F3966).withOpacity(0.3)),
//               ),
//               child: Text(
//                 item.toString(),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF344D67),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   void _navigateToChat() {
//     if (serviceData != null && providerData != null && providerId != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChatPage(
//             providerId: providerId!,
//             providerName: providerData!['name'] ?? 'Service Provider',
//             providerImage: providerData!['profileImage'] ?? '',
//             serviceId: widget.serviceId,
//             serviceName: serviceData!['name'] ?? 'Service',
//             providerPhone:  providerData!['phone'] ?? '',
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Cannot open chat at this moment')),
//       );
//     }
//   }
//
//   void _navigateToBooking() {
//     if (serviceData != null && providerData != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BookingPage(
//             serviceId: widget.serviceId,
//             serviceData: serviceData!,
//             providerData: providerData!,
//             serviceImages: serviceImages,
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Cannot book service at this moment')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double avgRating = 0.0;
//     int ratingCount = 0;
//     if (serviceData != null) {
//       final rating = (serviceData!['rating'] as num?)?.toDouble() ?? 0.0;
//       ratingCount = (serviceData!['rating_count'] as num?)?.toInt() ?? 0;
//       avgRating = ratingCount > 0 ? (rating / ratingCount) : 0.0;
//     }
//
//     String providerName = providerData?['name'] ?? 'Service Provider';
//     String serviceName = serviceData?['name'] ?? 'Service';
//     String experience = serviceData?['experience']?.toString() ?? '0';
//     bool isVerified = providerData?['isApproved'] ?? false;
//
//     List<dynamic> availableAreas = serviceData?['available_areas'] ?? [];
//     List<dynamic> availableDays = serviceData?['available_days'] ?? [];
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : serviceData == null
//           ? Center(child: Text('Service not found'))
//           : Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Stack(
//                     children: [
//                       Container(
//                         height:
//                         MediaQuery.of(context).size.height * 0.4,
//                         child: PageView.builder(
//                           controller: pageController,
//                           onPageChanged: (index) {
//                             setState(() {
//                               currentImageIndex = index;
//                             });
//                           },
//                           itemCount: serviceImages.length,
//                           itemBuilder: (context, index) {
//                             return Image.network(
//                               serviceImages[index],
//                               fit: BoxFit.cover,
//                               errorBuilder:
//                                   (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey[300],
//                                   child: Center(
//                                     child: Icon(
//                                       Icons.image_not_supported,
//                                       size: 50,
//                                       color: Colors.grey[500],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                       Positioned(
//                         top: MediaQuery.of(context).padding.top + 8,
//                         left: 16,
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white,
//                           radius: 22,
//                           child: IconButton(
//                             icon: Icon(Icons.arrow_back_ios_new,
//                                 size: 18),
//                             onPressed: () =>
//                                 Navigator.pop(context, true),
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: MediaQuery.of(context).padding.top + 8,
//                         right: 16,
//                         child: GestureDetector(
//                           onTap: _toggleFavorite,
//                           child: CircleAvatar(
//                             backgroundColor: Colors.white70,
//                             radius: 22,
//                             child: Icon(
//                               isProviderFavorite
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: isProviderFavorite
//                                   ? Colors.red
//                                   : Colors.grey,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       ),
//                       if (serviceImages.length > 1)
//                         Positioned(
//                           bottom: 16,
//                           left: 0,
//                           right: 0,
//                           child: Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.center,
//                             children: List.generate(
//                               serviceImages.length,
//                                   (index) => Container(
//                                 width: 8,
//                                 height: 8,
//                                 margin: EdgeInsets.symmetric(
//                                     horizontal: 4),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: currentImageIndex == index
//                                       ? Colors.white
//                                       : Colors.white.withOpacity(0.5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       Positioned(
//                         bottom: 20,
//                         right: 24,
//                         child: Container(
//                           height: 90,
//                           width: 90,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.white,
//                               width: 2,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 5,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: providerData != null &&
//                                 providerData!.containsKey(
//                                     'profileImage') &&
//                                 providerData!['profileImage'] !=
//                                     null
//                                 ? Image.network(
//                               providerData!['profileImage'],
//                               fit: BoxFit.cover,
//                               errorBuilder:
//                                   (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey[200],
//                                   child: Icon(Icons.person,
//                                       size: 30,
//                                       color: Colors.grey[400]),
//                                 );
//                               },
//                             )
//                                 : Container(
//                               color: Colors.grey[200],
//                               child: Icon(Icons.person,
//                                   size: 30,
//                                   color: Colors.grey[400]),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment:
//                           MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Row(
//                                 children: [
//                                   Flexible(
//                                     child: Text(
//                                       providerName,
//                                       style: TextStyle(
//                                         fontSize: 26,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF344D67),
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   if (isVerified)
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 4.0),
//                                       child: Icon(
//                                         Icons.verified,
//                                         color: Colors.blue,
//                                         size: 20,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Icon(Icons.star,
//                                     color: Colors.amber, size: 18),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   avgRating.toStringAsFixed(1),
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   ' ($ratingCount)',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '$serviceName • $experience year Experience',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         SizedBox(height: 24),
//                         Text(
//                           'About me',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF344D67),
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           serviceData!['description'] ??
//                               'I\'m $providerName, a dedicated $serviceName with $experience years of hands-on experience. I specialize in everything from routine maintenance to complex installations and repairs.',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[700],
//                           ),
//                           maxLines: showFullDescription ? null : 3,
//                           overflow: showFullDescription
//                               ? TextOverflow.visible
//                               : TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               showFullDescription =
//                               !showFullDescription;
//                             });
//                           },
//                           child: Text(
//                             showFullDescription
//                                 ? 'Show less'
//                                 : 'Read more...',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ),
//                         if (availableAreas.isNotEmpty)
//                           _buildInfoSection(
//                               'Available Areas', availableAreas),
//                         if (availableDays.isNotEmpty)
//                           _buildInfoSection(
//                               'Available Days', availableDays),
//                         SizedBox(height: 24),
//                         Text(
//                           'Reviews',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF344D67),
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Container(
//                           padding: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[100],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 22,
//                                     backgroundColor: Colors.blue,
//                                     child: Icon(
//                                       Icons.person,
//                                       color: Colors.white60,
//                                       size: 23,
//                                     ),
//                                   ),
//                                   SizedBox(width: 15),
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Alex T',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.grey[800],
//                                         ),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Row(
//                                         children:
//                                         List.generate(5, (index) {
//                                           return Icon(
//                                             Icons.star,
//                                             color: Colors.amber,
//                                             size: 15,
//                                           );
//                                         }),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                               SizedBox(height: 10),
//                               Text(
//                                 '"$providerName is a true professional. ${providerName.split(' ')[0]} quickly diagnosed the issue and fixed it with ease. Impressive expertise and dedication to the work. Good job!"',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding:
//             EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '₹${serviceData!['hourly_rate'] ?? '0'}/Hr',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     OutlinedButton.icon(
//                       onPressed: _navigateToChat,
//                       icon: Icon(Icons.message,
//                           size: 16, color: Color(0xff0F3966)),
//                       label: Text('Message',
//                           style: TextStyle(
//                               color: Color(0xff0F3966),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16)),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Color(0xff0F3966),
//                         side: BorderSide(color: Color(0xff0F3966)),
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: _navigateToBooking,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xff0F3966),
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                       ),
//                       child: Text(
//                         'Book Now',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//
// import 'dart:async';
// import 'dart:math';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fixit/features/user/view/service_booking_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'message_provider_page.dart';
//
// class ViewServiceDetailsPage extends StatefulWidget {
//   final String serviceId;
//
//   const ViewServiceDetailsPage({Key? key, required this.serviceId})
//       : super(key: key);
//
//   @override
//   _ViewServiceDetailsPageState createState() => _ViewServiceDetailsPageState();
// }
//
// class _ViewServiceDetailsPageState extends State<ViewServiceDetailsPage> with SingleTickerProviderStateMixin {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? serviceData;
//   Map<String, dynamic>? providerData;
//   bool isLoading = true;
//   int currentImageIndex = 0;
//   final PageController pageController = PageController();
//   bool showFullDescription = false;
//   List<String> serviceImages = [];
//   bool isProviderFavorite = false;
//   String? providerId;
//   Set<String> _favoriteServiceIds = {};
//   List<Map<String, dynamic>> reviewsList = [];
//   int currentReviewIndex = 0;
//   bool showReviewFront = true;
//   Timer? _reviewTimer;
//   bool _isAnimatingReviewCard = false;
//
//   // Animation controller for card flip
//   late AnimationController _flipController;
//   late Animation<double> _flipAnimation;
//   PageController _reviewPageController = PageController(viewportFraction: 0.85);
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize animation controller
//     _flipController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 800),
//     );
//     _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
//     );
//
//     // Add animation status listener to track when animation completes
//     _flipController.addStatusListener(_animationStatusListener);
//
//
//
//     _fetchServiceDetails();
//     _fetchUserFavorites();
//   }
//
//   void _animationStatusListener(AnimationStatus status) {
//     if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
//       setState(() {
//         _isAnimatingReviewCard = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _reviewTimer?.cancel();
//     _flipController.removeStatusListener(_animationStatusListener);
//     _flipController.dispose();
//     _reviewPageController.dispose();
//     pageController.dispose();
//     super.dispose();
//   }
//
//   // Future<void> _fetchServiceDetails() async {
//   //   try {
//   //     DocumentSnapshot serviceDoc =
//   //     await _firestore.collection('services').doc(widget.serviceId).get();
//   //
//   //     if (serviceDoc.exists) {
//   //       serviceData = serviceDoc.data() as Map<String, dynamic>;
//   //
//   //       if (serviceData!.containsKey('provider_id')) {
//   //         providerId = serviceData!['provider_id'];
//   //         isProviderFavorite = _favoriteServiceIds.contains(widget.serviceId);
//   //
//   //         // Fetch reviews for this service and provider
//   //         await _fetchReviews();
//   //       }
//   //
//   //       serviceImages = [];
//   //
//   //       if (serviceData!.containsKey('work_sample') &&
//   //           serviceData!['work_sample'] != null &&
//   //           serviceData!['work_sample'].toString().isNotEmpty) {
//   //         serviceImages.add(serviceData!['work_sample']);
//   //       }
//   //
//   //       if (serviceData!.containsKey('additional_work_samples') &&
//   //           serviceData!['additional_work_samples'] is List &&
//   //           (serviceData!['additional_work_samples'] as List).isNotEmpty) {
//   //         for (var image in serviceData!['additional_work_samples']) {
//   //           if (image != null && image.toString().isNotEmpty) {
//   //             serviceImages.add(image);
//   //           }
//   //         }
//   //       }
//   //
//   //       if (serviceImages.isEmpty) {
//   //         serviceImages.add('https://via.placeholder.com/400?text=No+Images');
//   //       }
//   //
//   //       if (providerId != null) {
//   //         DocumentSnapshot providerDoc = await _firestore
//   //             .collection('service provider')
//   //             .doc(providerId)
//   //             .get();
//   //
//   //         if (providerDoc.exists) {
//   //           providerData = providerDoc.data() as Map<String, dynamic>;
//   //         }
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print('Error fetching service details: $e');
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         isLoading = false;
//   //       });
//   //     }
//   //   }
//   // }
//
//   Future<void> _fetchServiceDetails() async {
//     try {
//       DocumentSnapshot serviceDoc =
//       await _firestore.collection('services').doc(widget.serviceId).get();
//
//       if (serviceDoc.exists) {
//         serviceData = serviceDoc.data() as Map<String, dynamic>;
//
//         if (serviceData!.containsKey('provider_id')) {
//           providerId = serviceData!['provider_id'];
//           isProviderFavorite = _favoriteServiceIds.contains(widget.serviceId);
//
//           // Fetch reviews for this service and provider
//           await _fetchReviews();
//         }
//
//         // Reset the service images array
//         serviceImages = [];
//
//         // Check for work_samples array first (multiple images)
//         if (serviceData!.containsKey('work_samples') &&
//             serviceData!['work_samples'] is List &&
//             (serviceData!['work_samples'] as List).isNotEmpty) {
//
//           for (var image in serviceData!['work_samples']) {
//             if (image != null && image.toString().isNotEmpty) {
//               serviceImages.add(image.toString());
//             }
//           }
//         }
//         // If no work_samples array, check for single work_sample
//         else if (serviceData!.containsKey('work_sample') &&
//             serviceData!['work_sample'] != null &&
//             serviceData!['work_sample'].toString().isNotEmpty) {
//
//           serviceImages.add(serviceData!['work_sample'].toString());
//         }
//
//         // If we still have no images, add a placeholder
//         if (serviceImages.isEmpty) {
//           serviceImages.add('https://via.placeholder.com/400?text=No+Images');
//         }
//
//         if (providerId != null) {
//           DocumentSnapshot providerDoc = await _firestore
//               .collection('service provider')
//               .doc(providerId)
//               .get();
//
//           if (providerDoc.exists) {
//             providerData = providerDoc.data() as Map<String, dynamic>;
//           }
//         }
//       }
//     } catch (e) {
//       print('Error fetching service details: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//   Future<void> _fetchReviews() async {
//     try {
//       if (providerId == null || widget.serviceId.isEmpty) return;
//
//       // Query ratings collection for this service
//       QuerySnapshot ratingsSnapshot = await _firestore
//           .collection('ratings')
//           .where('service_id', isEqualTo: widget.serviceId)
//           .where('provider_id', isEqualTo: providerId)
//           .get();
//
//       if (ratingsSnapshot.docs.isNotEmpty) {
//         List<Map<String, dynamic>> reviews = [];
//         double totalRating = 0;
//
//         for (var doc in ratingsSnapshot.docs) {
//           Map<String, dynamic> ratingData = doc.data() as Map<String, dynamic>;
//           String userId = ratingData['user_id'] ?? '';
//           int rating = (ratingData['rating'] as num?)?.toInt() ?? 0;
//           totalRating += rating;
//
//           if (userId.isNotEmpty) {
//             // Fetch user data for this review
//             DocumentSnapshot userDoc = await _firestore
//                 .collection('users')
//                 .doc(userId)
//                 .get();
//
//             if (userDoc.exists) {
//               Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//
//               reviews.add({
//                 'rating': rating,
//                 'feedback': ratingData['feedback'] ?? '',
//                 'userName': userData['name'] ?? 'User',
//                 'userImage': userData['profileImageUrl'] ?? '',
//                 'created_at': ratingData['created_at']
//               });
//             }
//           }
//         }
//
//         if (mounted) {
//           setState(() {
//             reviewsList = reviews;
//
//             // Start the timer to rotate reviews only if there are reviews
//             if (reviewsList.length > 1) {
//               _startReviewRotation();
//             }
//
//             // Update service data with actual average rating
//             if (serviceData != null && reviews.isNotEmpty) {
//               serviceData!['rating_count'] = reviews.length;
//               serviceData!['rating'] = totalRating; // Store total for average calculation
//             }
//           });
//         }
//       } else if (mounted) {
//         // If no reviews found, set reviewsList to empty list
//         setState(() {
//           reviewsList = [];
//         });
//       }
//     } catch (e) {
//       print('Error fetching reviews: $e');
//       if (mounted) {
//         setState(() {
//           reviewsList = [];
//         });
//       }
//     }
//   }
//
//
//
//   void _startReviewRotation() {
//     // Cancel any existing timer
//     _reviewTimer?.cancel();
//
//     // Start a new timer that rotates through reviews every 8 seconds (increased from 5)
//     _reviewTimer = Timer.periodic(Duration(seconds: 8), (timer) {
//       if (mounted && !_isAnimatingReviewCard) {
//         _rotateToNextReview();
//       }
//     });
//   }
//
//   void _rotateToNextReview() {
//     if (_isAnimatingReviewCard) return;
//
//     setState(() {
//       _isAnimatingReviewCard = true;
//     });
//
//     // First show the front of the current card if it's showing the back
//     if (_flipAnimation.value > 0) {
//       _flipController.reverse().then((_) {
//         // Wait a moment before changing to the next review
//         Future.delayed(Duration(milliseconds: 300), () {
//           if (!mounted) return;
//
//           setState(() {
//             currentReviewIndex = (currentReviewIndex + 1) % reviewsList.length;
//           });
//
//           // Animate to next page in PageView
//           if (reviewsList.length > 1) {
//             _reviewPageController.animateToPage(
//               currentReviewIndex,
//               duration: Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//             );
//           }
//         });
//       });
//     } else {
//       // If already showing front, just change to next review
//       setState(() {
//         currentReviewIndex = (currentReviewIndex + 1) % reviewsList.length;
//       });
//
//       // Animate to next page in PageView
//       if (reviewsList.length > 1) {
//         _reviewPageController.animateToPage(
//           currentReviewIndex,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       }
//     }
//   }
//
//   void _flipCard() {
//     if (_flipController.isAnimating || _isAnimatingReviewCard) return;
//
//     setState(() {
//       _isAnimatingReviewCard = true;
//     });
//
//     if (_flipController.status == AnimationStatus.dismissed) {
//       _flipController.forward();
//     } else {
//       _flipController.reverse();
//     }
//   }
//
//   Future<void> _fetchUserFavorites() async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//
//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();
//
//       if (userDoc.exists && userDoc.data() != null) {
//         var userData = userDoc.data() as Map<String, dynamic>;
//         if (userData.containsKey('favorites') &&
//             userData['favorites'] is List) {
//           setState(() {
//             _favoriteServiceIds =
//             Set<String>.from(userData['favorites'] as List);
//             isProviderFavorite = _favoriteServiceIds.contains(widget.serviceId);
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching user favorites: $e');
//     }
//   }
//
//   Future<void> _toggleFavorite() async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//
//     try {
//       bool isCurrentlyFavorite = _favoriteServiceIds.contains(widget.serviceId);
//       Set<String> newFavorites = Set<String>.from(_favoriteServiceIds);
//
//       if (isCurrentlyFavorite) {
//         newFavorites.remove(widget.serviceId);
//       } else {
//         newFavorites.add(widget.serviceId);
//       }
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .update({'favorites': newFavorites.toList()});
//
//       setState(() {
//         _favoriteServiceIds = newFavorites;
//         isProviderFavorite = !isCurrentlyFavorite;
//       });
//     } catch (e) {
//       print('Error toggling favorite: $e');
//     }
//   }
//
//   Widget _buildInfoSection(String title, List<dynamic> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 24),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF344D67),
//           ),
//         ),
//         SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: items.map((item) {
//             return Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Color(0xff0F3966).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Color(0xff0F3966).withOpacity(0.3)),
//               ),
//               child: Text(
//                 item.toString(),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF344D67),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildReviewCarousel() {
//     if (reviewsList.isEmpty) {
//       return Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child: Text(
//             'No reviews yet',
//             style: TextStyle(color: Colors.grey[700]),
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       height: 220,
//       child: PageView.builder(
//         controller: _reviewPageController,
//         itemCount: reviewsList.length,
//         onPageChanged: (index) {
//           // Reset the flip animation when page changes manually
//           if (_flipController.value > 0) {
//             _flipController.reset();
//           }
//
//           setState(() {
//             currentReviewIndex = index;
//             _isAnimatingReviewCard = false;
//           });
//
//           // Reset the timer when user manually changes page
//           if (_reviewTimer != null) {
//             _reviewTimer!.cancel();
//             _startReviewRotation();
//           }
//         },
//         itemBuilder: (context, index) {
//           return AnimatedBuilder(
//             animation: _flipAnimation,
//             builder: (context, child) {
//               final isCurrentCard = index == currentReviewIndex;
//
//               // Only apply flip animation to current card
//               if (!isCurrentCard) {
//                 return _buildReviewCard(index, 0);
//               }
//
//               return _buildReviewCard(index, _flipAnimation.value);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildReviewCard(int index, double flipValue) {
//     Map<String, dynamic> review = reviewsList[index];
//     int rating = (review['rating'] as num).toInt();
//     String feedback = review['feedback'] ?? '';
//     String userName = review['userName'] ?? 'User';
//     String userImage = review['userImage'] ?? '';
//
//     // Determine if we're showing front or back based on animation value
//     bool showingBack = flipValue >= 0.5;
//
//     // Calculate the rotation angle for 3D effect
//     final angle = flipValue * pi;
//
//     return GestureDetector(
//       onTap: index == currentReviewIndex ? _flipCard : null,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//         child: Transform(
//           alignment: Alignment.center,
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, 0.001) // Perspective
//             ..rotateY(angle),
//           child: Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Container(
//
//
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Color(0xffedf3fb),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: showingBack
//                   ? Transform(
//                   alignment: Alignment.center,
//                   transform: Matrix4.identity()..rotateY(pi),
//                   child: _buildReviewBackContent(feedback, rating)
//               )
//                   : _buildReviewFrontContent(userImage, userName, rating),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildReviewFrontContent(String userImage, String userName, int rating) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CircleAvatar(
//           radius: 40,
//           backgroundColor: Colors.blue.shade100,
//           backgroundImage: userImage.isNotEmpty ? NetworkImage(userImage) : null,
//           child: userImage.isEmpty ? Icon(Icons.person, size: 40, color: Colors.blue) : null,
//         ),
//         SizedBox(height: 16),
//         // Fix overflow with Flexible widget
//         Flexible(
//           child: Text(
//             userName,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xff0F3966),
//             ),
//             textAlign: TextAlign.center,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//           ),
//         ),
//         SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(5, (index) {
//             return Icon(
//               index < rating ? Icons.star : Icons.star_border,
//               color: Colors.amber,
//               size: 20,
//             );
//           }),
//         ),
//         SizedBox(height: 10),
//         Text(
//           'Tap to see review',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.blue[800],
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildReviewBackContent(String feedback, int rating) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(5, (index) {
//             return Icon(
//               index < rating ? Icons.star : Icons.star_border,
//               color: Colors.amber,
//               size: 20,
//             );
//           }),
//         ),
//         SizedBox(height: 16),
//         Expanded(
//           child: SingleChildScrollView(
//             child: Text(
//               feedback,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontStyle: FontStyle.italic,
//                 color: Color(0xff0F3966),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Text(
//           'Tap to see reviewer',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.blue[800],
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _navigateToChat() {
//     if (serviceData != null && providerData != null && providerId != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChatPage(
//             providerId: providerId!,
//             providerName: providerData!['name'] ?? 'Service Provider',
//             providerImage: providerData!['profileImage'] ?? '',
//             serviceId: widget.serviceId,
//             serviceName: serviceData!['name'] ?? 'Service',
//             providerPhone:  providerData!['phone'] ?? '',
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Cannot open chat at this moment')),
//       );
//     }
//   }
//
//   void _navigateToBooking() {
//     if (serviceData != null && providerData != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BookingPage(
//             serviceId: widget.serviceId,
//             serviceData: serviceData!,
//             providerData: providerData!,
//             serviceImages: serviceImages,
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Cannot book service at this moment')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Calculate average rating
//     double avgRating = 0.0;
//     int ratingCount = 0;
//     if (serviceData != null) {
//       final rating = (serviceData!['rating'] as num?)?.toDouble() ?? 0.0;
//       ratingCount = (serviceData!['rating_count'] as num?)?.toInt() ?? 0;
//       avgRating = ratingCount > 0 ? (rating / ratingCount) : 0.0;
//     }
//
//     String providerName = providerData?['name'] ?? 'Service Provider';
//     String serviceName = serviceData?['name'] ?? 'Service';
//     String experience = serviceData?['experience']?.toString() ?? '0';
//     // String status = providerData?['status']?.toString() ?? '0';
//     bool isApproved = providerData?['isApproved'] ?? false;
//
//
//     List<dynamic> availableAreas = serviceData?['available_areas'] ?? [];
//     List<dynamic> availableDays = serviceData?['available_days'] ?? [];
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : serviceData == null
//           ? Center(child: Text('Service not found'))
//           : Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Stack(
//                   //   children: [
//                   //     Container(
//                   //       height:
//                   //       MediaQuery.of(context).size.height * 0.4,
//                   //       child: PageView.builder(
//                   //         controller: pageController,
//                   //         onPageChanged: (index) {
//                   //           setState(() {
//                   //             currentImageIndex = index;
//                   //           });
//                   //         },
//                   //         itemCount: serviceImages.length,
//                   //         itemBuilder: (context, index) {
//                   //           return Image.network(
//                   //             serviceImages[index],
//                   //             fit: BoxFit.cover,
//                   //             errorBuilder:
//                   //                 (context, error, stackTrace) {
//                   //               return Container(
//                   //                 color: Colors.grey[300],
//                   //                 child: Center(
//                   //                   child: Icon(
//                   //                     Icons.image_not_supported,
//                   //                     size: 50,
//                   //                     color: Colors.grey[500],
//                   //                   ),
//                   //                 ),
//                   //               );
//                   //             },
//                   //           );
//                   //         },
//                   //       ),
//                   //     ),
//                   //     Positioned(
//                   //       top: MediaQuery.of(context).padding.top + 8,
//                   //       left: 16,
//                   //       child: CircleAvatar(
//                   //         backgroundColor: Colors.white,
//                   //         radius: 22,
//                   //         child: IconButton(
//                   //           icon: Icon(Icons.arrow_back_ios_new,
//                   //               size: 18),
//                   //           onPressed: () =>
//                   //               Navigator.pop(context, true),
//                   //           color: Colors.black,
//                   //         ),
//                   //       ),
//                   //     ),
//                   //     Positioned(
//                   //       top: MediaQuery.of(context).padding.top + 8,
//                   //       right: 16,
//                   //       child: GestureDetector(
//                   //         onTap: _toggleFavorite,
//                   //         child: CircleAvatar(
//                   //           backgroundColor: Colors.white70,
//                   //           radius: 22,
//                   //           child: Icon(
//                   //             isProviderFavorite
//                   //                 ? Icons.favorite
//                   //                 : Icons.favorite_border,
//                   //             color: isProviderFavorite
//                   //                 ? Colors.red
//                   //                 : Colors.grey,
//                   //             size: 18,
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     ),
//                   //     if (serviceImages.length > 1)
//                   //       Positioned(
//                   //         bottom: 16,
//                   //         left: 0,
//                   //         right: 0,
//                   //         child: Row(
//                   //           mainAxisAlignment:
//                   //           MainAxisAlignment.center,
//                   //           children: List.generate(
//                   //             serviceImages.length,
//                   //                 (index) => Container(
//                   //               width: 8,
//                   //               height: 8,
//                   //               margin: EdgeInsets.symmetric(
//                   //                   horizontal: 4),
//                   //               decoration: BoxDecoration(
//                   //                 shape: BoxShape.circle,
//                   //                 color: currentImageIndex == index
//                   //                     ? Colors.white
//                   //                     : Colors.white.withOpacity(0.5),
//                   //               ),
//                   //             ),
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     Positioned(
//                   //       bottom: 20,
//                   //       right: 24,
//                   //       child: Container(
//                   //         height: 90,
//                   //         width: 90,
//                   //         decoration: BoxDecoration(
//                   //           borderRadius: BorderRadius.circular(12),
//                   //           border: Border.all(
//                   //             color: Colors.white,
//                   //             width: 2,
//                   //           ),
//                   //           boxShadow: [
//                   //             BoxShadow(
//                   //               color: Colors.black.withOpacity(0.1),
//                   //               spreadRadius: 1,
//                   //               blurRadius: 5,
//                   //               offset: Offset(0, 3),
//                   //             ),
//                   //           ],
//                   //         ),
//                   //         child: ClipRRect(
//                   //           borderRadius: BorderRadius.circular(10),
//                   //           child: providerData != null &&
//                   //               providerData!.containsKey(
//                   //                   'profileImage') &&
//                   //               providerData!['profileImage'] !=
//                   //                   null
//                   //               ? Image.network(
//                   //             providerData!['profileImage'],
//                   //             fit: BoxFit.cover,
//                   //             errorBuilder:
//                   //                 (context, error, stackTrace) {
//                   //               return Container(
//                   //                 color: Colors.grey[200],
//                   //                 child: Icon(Icons.person,
//                   //                     size: 30,
//                   //                     color: Colors.grey[400]),
//                   //               );
//                   //             },
//                   //           )
//                   //               : Container(
//                   //             color: Colors.grey[200],
//                   //             child: Icon(Icons.person,
//                   //                 size: 30,
//                   //                 color: Colors.grey[400]),
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//
//                   // Replace the Stack in the build method with this updated version
//                   Stack(
//                     children: [
//                       Container(
//                         height: MediaQuery.of(context).size.height * 0.4,
//                         child: PageView.builder(
//                           controller: pageController,
//                           onPageChanged: (index) {
//                             setState(() {
//                               currentImageIndex = index;
//                             });
//                           },
//                           itemCount: serviceImages.length,
//                           itemBuilder: (context, index) {
//                             return Image.network(
//                               serviceImages[index],
//                               fit: BoxFit.cover,
//                               loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                 if (loadingProgress == null) {
//                                   return child;
//                                 }
//                                 return Center(
//                                   child: CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                         : null,
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey[300],
//                                   child: Center(
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Icon(
//                                           Icons.image_not_supported,
//                                           size: 50,
//                                           color: Colors.grey[500],
//                                         ),
//                                         SizedBox(height: 10),
//                                         Text("Image load failed", style: TextStyle(color: Colors.grey[700])),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                       Positioned(
//                         top: MediaQuery.of(context).padding.top + 8,
//                         left: 16,
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white,
//                           radius: 22,
//                           child: IconButton(
//                             icon: Icon(Icons.arrow_back_ios_new, size: 18),
//                             onPressed: () => Navigator.pop(context, true),
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: MediaQuery.of(context).padding.top + 8,
//                         right: 16,
//                         child: GestureDetector(
//                           onTap: _toggleFavorite,
//                           child: CircleAvatar(
//                             backgroundColor: Colors.white70,
//                             radius: 22,
//                             child: Icon(
//                               isProviderFavorite
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: isProviderFavorite
//                                   ? Colors.red
//                                   : Colors.grey,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       ),
//                       // Only show indicators if there are multiple images
//                       if (serviceImages.length > 1)
//                         Positioned(
//                           bottom: 16,
//                           left: 0,
//                           right: 0,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(
//                               serviceImages.length,
//                                   (index) => Container(
//                                 width: 8,
//                                 height: 8,
//                                 margin: EdgeInsets.symmetric(horizontal: 4),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: currentImageIndex == index
//                                       ? Colors.white
//                                       : Colors.white.withOpacity(0.5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       Positioned(
//                         bottom: 20,
//                         right: 24,
//                         child: Container(
//                           height: 90,
//                           width: 90,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.white,
//                               width: 2,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 5,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: providerData != null &&
//                                 providerData!.containsKey('profileImage') &&
//                                 providerData!['profileImage'] != null
//                                 ? Image.network(
//                               providerData!['profileImage'],
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey[200],
//                                   child: Icon(Icons.person,
//                                       size: 30,
//                                       color: Colors.grey[400]),
//                                 );
//                               },
//                             )
//                                 : Container(
//                               color: Colors.grey[200],
//                               child: Icon(Icons.person,
//                                   size: 30,
//                                   color: Colors.grey[400]),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment:
//                           MainAxisAlignment.spaceBetween,
//                           children: [
//
//                             Expanded(
//                               child: Row(
//                                 children: [
//                                   Flexible(
//                                     child: Text(
//                                       providerName,
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF344D67),
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   if (isApproved)
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 4.0),
//                                       child: Icon(
//                                         Icons.verified,
//                                         color: Colors.blue,
//                                         size: 20,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Icon(Icons.star,
//                                     color: Colors.amber, size: 18),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   avgRating.toStringAsFixed(1),
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   ' ($ratingCount)',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '$serviceName • $experience year Experience',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         SizedBox(height: 24),
//                         Text(
//                           'About me',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF344D67),
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           serviceData!['description'] ??
//                               'I\'m $providerName, a dedicated $serviceName with $experience years of hands-on experience. I specialize in everything from routine maintenance to complex installations and repairs.',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[700],
//                           ),
//                           maxLines: showFullDescription ? null : 3,
//                           overflow: showFullDescription
//                               ? TextOverflow.visible
//                               : TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               showFullDescription =
//                               !showFullDescription;
//                             });
//                           },
//                           child: Text(
//                             showFullDescription
//                                 ? 'Show less'
//                                 : 'Read more...',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ),
//                         if (availableAreas.isNotEmpty)
//                           _buildInfoSection(
//                               'Available Areas', availableAreas),
//                         if (availableDays.isNotEmpty)
//                           _buildInfoSection(
//                               'Available Days', availableDays),
//                         SizedBox(height: 24),
//                         Text(
//                           'Reviews',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF344D67),
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         // Updated review carousel
//                         _buildReviewCarousel(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding:
//             EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '₹${serviceData!['hourly_rate'] ?? '0'}/Hr',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     OutlinedButton.icon(
//                       onPressed: _navigateToChat,
//                       icon: Icon(Icons.message,
//                           size: 16, color: Color(0xff0F3966)),
//                       label: Text('Message',
//                           style: TextStyle(
//                               color: Color(0xff0F3966),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16)),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Color(0xff0F3966),
//                         side: BorderSide(color: Color(0xff0F3966)),
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: _navigateToBooking,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xff0F3966),
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                       ),
//                       child: Text(
//                         'Book Now',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }}

import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/features/user/view/service_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_provider_page.dart';

class ViewServiceDetailsPage extends StatefulWidget {
  final String serviceId;

  const ViewServiceDetailsPage({Key? key, required this.serviceId})
      : super(key: key);

  @override
  _ViewServiceDetailsPageState createState() => _ViewServiceDetailsPageState();
}

class _ViewServiceDetailsPageState extends State<ViewServiceDetailsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? serviceData;
  Map<String, dynamic>? providerData;
  bool isLoading = true;
  int currentImageIndex = 0;
  final PageController pageController = PageController();
  bool showFullDescription = false;
  List<String> serviceImages = [];
  bool isProviderFavorite = false;
  String? providerId;
  Set<String> _favoriteServiceIds = {};
  List<Map<String, dynamic>> reviewsList = [];
  int currentReviewIndex = 0;
  bool showReviewFront = true;
  Timer? _reviewTimer;
  bool _isAnimatingReviewCard = false;

  // Animation controller for card flip
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  PageController _reviewPageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    // Add animation status listener to track when animation completes
    _flipController.addStatusListener(_animationStatusListener);

    _fetchServiceDetails();
    _fetchUserFavorites();
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      setState(() {
        _isAnimatingReviewCard = false;
      });
    }
  }

  @override
  void dispose() {
    _reviewTimer?.cancel();
    _flipController.removeStatusListener(_animationStatusListener);
    _flipController.dispose();
    _reviewPageController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchServiceDetails() async {
    try {
      DocumentSnapshot serviceDoc =
          await _firestore.collection('services').doc(widget.serviceId).get();

      if (serviceDoc.exists) {
        serviceData = serviceDoc.data() as Map<String, dynamic>;

        if (serviceData!.containsKey('provider_id')) {
          providerId = serviceData!['provider_id'];
          isProviderFavorite = _favoriteServiceIds.contains(widget.serviceId);

          // Fetch reviews for this service and provider
          await _fetchReviews();
        }

        // Reset the service images array
        serviceImages = [];

        // Check for work_samples array first (multiple images)
        if (serviceData!.containsKey('work_samples') &&
            serviceData!['work_samples'] is List &&
            (serviceData!['work_samples'] as List).isNotEmpty) {
          for (var image in serviceData!['work_samples']) {
            if (image != null && image.toString().isNotEmpty) {
              serviceImages.add(image.toString());
            }
          }
        }
        // If no work_samples array, check for single work_sample
        else if (serviceData!.containsKey('work_sample') &&
            serviceData!['work_sample'] != null &&
            serviceData!['work_sample'].toString().isNotEmpty) {
          serviceImages.add(serviceData!['work_sample'].toString());
        }

        // If we still have no images, add a placeholder
        if (serviceImages.isEmpty) {
          serviceImages.add('https://via.placeholder.com/400?text=No+Images');
        }

        if (providerId != null) {
          DocumentSnapshot providerDoc = await _firestore
              .collection('service provider')
              .doc(providerId)
              .get();

          if (providerDoc.exists) {
            providerData = providerDoc.data() as Map<String, dynamic>;
          }
        }
      }
    } catch (e) {
      print('Error fetching service details: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchReviews() async {
    try {
      if (providerId == null || widget.serviceId.isEmpty) return;

      // Query ratings collection for this service
      QuerySnapshot ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('service_id', isEqualTo: widget.serviceId)
          .where('provider_id', isEqualTo: providerId)
          .get();

      if (ratingsSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> reviews = [];
        double totalRating = 0;

        for (var doc in ratingsSnapshot.docs) {
          Map<String, dynamic> ratingData = doc.data() as Map<String, dynamic>;
          String userId = ratingData['user_id'] ?? '';
          int rating = (ratingData['rating'] as num?)?.toInt() ?? 0;
          totalRating += rating;

          if (userId.isNotEmpty) {
            // Fetch user data for this review
            DocumentSnapshot userDoc =
                await _firestore.collection('users').doc(userId).get();

            if (userDoc.exists) {
              Map<String, dynamic> userData =
                  userDoc.data() as Map<String, dynamic>;

              reviews.add({
                'rating': rating,
                'feedback': ratingData['feedback'] ?? '',
                'userName': userData['name'] ?? 'User',
                'userImage': userData['profileImageUrl'] ?? '',
                'created_at': ratingData['created_at']
              });
            }
          }
        }

        if (mounted) {
          setState(() {
            reviewsList = reviews;

            // Start the timer to rotate reviews only if there are reviews
            if (reviewsList.length > 1) {
              _startReviewRotation();
            }

            // Update service data with actual average rating
            if (serviceData != null && reviews.isNotEmpty) {
              serviceData!['rating_count'] = reviews.length;
              serviceData!['rating'] =
                  totalRating; // Store total for average calculation
            }
          });
        }
      } else if (mounted) {
        // If no reviews found, set reviewsList to empty list
        setState(() {
          reviewsList = [];
        });
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      if (mounted) {
        setState(() {
          reviewsList = [];
        });
      }
    }
  }

  void _startReviewRotation() {
    // Cancel any existing timer
    _reviewTimer?.cancel();

    // Start a new timer that rotates through reviews every 8 seconds (increased from 5)
    _reviewTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      if (mounted && !_isAnimatingReviewCard) {
        _rotateToNextReview();
      }
    });
  }

  void _rotateToNextReview() {
    if (_isAnimatingReviewCard) return;

    setState(() {
      _isAnimatingReviewCard = true;
    });

    // First show the front of the current card if it's showing the back
    if (_flipAnimation.value > 0) {
      _flipController.reverse().then((_) {
        // Wait a moment before changing to the next review
        Future.delayed(Duration(milliseconds: 300), () {
          if (!mounted) return;

          setState(() {
            currentReviewIndex = (currentReviewIndex + 1) % reviewsList.length;
          });

          // Animate to next page in PageView
          if (reviewsList.length > 1) {
            _reviewPageController.animateToPage(
              currentReviewIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      });
    } else {
      // If already showing front, just change to next review
      setState(() {
        currentReviewIndex = (currentReviewIndex + 1) % reviewsList.length;
      });

      // Animate to next page in PageView
      if (reviewsList.length > 1) {
        _reviewPageController.animateToPage(
          currentReviewIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _flipCard() {
    if (_flipController.isAnimating || _isAnimatingReviewCard) return;

    setState(() {
      _isAnimatingReviewCard = true;
    });

    if (_flipController.status == AnimationStatus.dismissed) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _fetchUserFavorites() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('favorites') &&
            userData['favorites'] is List) {
          setState(() {
            _favoriteServiceIds =
                Set<String>.from(userData['favorites'] as List);
            isProviderFavorite = _favoriteServiceIds.contains(widget.serviceId);
          });
        }
      }
    } catch (e) {
      print('Error fetching user favorites: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      bool isCurrentlyFavorite = _favoriteServiceIds.contains(widget.serviceId);
      Set<String> newFavorites = Set<String>.from(_favoriteServiceIds);

      if (isCurrentlyFavorite) {
        newFavorites.remove(widget.serviceId);
      } else {
        newFavorites.add(widget.serviceId);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'favorites': newFavorites.toList()});

      setState(() {
        _favoriteServiceIds = newFavorites;
        isProviderFavorite = !isCurrentlyFavorite;
      });
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Widget _buildInfoSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF344D67),
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xff0F3966).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xff0F3966).withOpacity(0.3)),
              ),
              child: Text(
                item.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF344D67),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewCarousel() {
    if (reviewsList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No reviews yet',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Container(
      height: 220,
      child: PageView.builder(
        controller: _reviewPageController,
        itemCount: reviewsList.length,
        onPageChanged: (index) {
          // Reset the flip animation when page changes manually
          if (_flipController.value > 0) {
            _flipController.reset();
          }

          setState(() {
            currentReviewIndex = index;
            _isAnimatingReviewCard = false;
          });

          // Reset the timer when user manually changes page
          if (_reviewTimer != null) {
            _reviewTimer!.cancel();
            _startReviewRotation();
          }
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final isCurrentCard = index == currentReviewIndex;

              // Only apply flip animation to current card
              if (!isCurrentCard) {
                return _buildReviewCard(index, 0);
              }

              return _buildReviewCard(index, _flipAnimation.value);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(int index, double flipValue) {
    Map<String, dynamic> review = reviewsList[index];
    int rating = (review['rating'] as num).toInt();
    String feedback = review['feedback'] ?? '';
    String userName = review['userName'] ?? 'User';
    String userImage = review['userImage'] ?? '';

    // Determine if we're showing front or back based on animation value
    bool showingBack = flipValue >= 0.5;

    // Calculate the rotation angle for 3D effect
    final angle = flipValue * pi;

    return GestureDetector(
      onTap: index == currentReviewIndex ? _flipCard : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xffedf3fb),
                borderRadius: BorderRadius.circular(12),
              ),
              child: showingBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildReviewBackContent(feedback, rating))
                  : _buildReviewFrontContent(userImage, userName, rating),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewFrontContent(
      String userImage, String userName, int rating) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue.shade100,
          backgroundImage:
              userImage.isNotEmpty ? NetworkImage(userImage) : null,
          child: userImage.isEmpty
              ? Icon(Icons.person, size: 40, color: Colors.blue)
              : null,
        ),
        SizedBox(height: 16),
        // Fix overflow with Flexible widget
        Flexible(
          child: Text(
            userName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0F3966),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
        SizedBox(height: 10),
        Text(
          'Tap to see review',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[800],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewBackContent(String feedback, int rating) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
        SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              feedback,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Color(0xff0F3966),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Tap to see reviewer',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[800],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _navigateToChat() {
    if (serviceData != null && providerData != null && providerId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            providerId: providerId!,
            providerName: providerData!['name'] ?? 'Service Provider',
            providerImage: providerData!['profileImage'] ?? '',
            serviceId: widget.serviceId,
            serviceName: serviceData!['name'] ?? 'Service',
            providerPhone: providerData!['phone'] ?? '',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open chat at this moment')),
      );
    }
  }

  void _navigateToBooking() {
    if (serviceData != null && providerData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingPage(
            serviceId: widget.serviceId,
            serviceData: serviceData!,
            providerData: providerData!,
            serviceImages: serviceImages,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot book service at this moment')),
      );
    }
  }

  void _showUnavailableServiceTooltip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'This service is currently unavailable. You can still message the provider for inquiries.'),
        backgroundColor: Color(0xff0F3966),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate average rating
    double avgRating = 0.0;
    int ratingCount = 0;
    if (serviceData != null) {
      final rating = (serviceData!['rating'] as num?)?.toDouble() ?? 0.0;
      ratingCount = (serviceData!['rating_count'] as num?)?.toInt() ?? 0;
      avgRating = ratingCount > 0 ? (rating / ratingCount) : 0.0;
    }

    String providerName = providerData?['name'] ?? 'Service Provider';
    String serviceName = serviceData?['name'] ?? 'Service';
    String experience = serviceData?['experience']?.toString() ?? '0';
    bool isApproved = providerData?['isApproved'] ?? false;
    bool isServiceActive = serviceData?['isActive'] ?? true;

    List<dynamic> availableAreas = serviceData?['available_areas'] ?? [];
    List<dynamic> availableDays = serviceData?['available_days'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966),))
          : serviceData == null
              ? Center(child: Text('Service not found'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Updated Stack with overlay for inactive service
                            Stack(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: PageView.builder(
                                    controller: pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        currentImageIndex = index;
                                      });
                                    },
                                    itemCount: serviceImages.length,
                                    itemBuilder: (context, index) {
                                      return Image.network(
                                        serviceImages[index],
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey[500],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text("Image load failed",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[700])),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                // Overlay for inactive service
                                if (!isServiceActive)
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    color: Colors.black.withOpacity(0.4),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [


                                          Text(
                                            'This service is Currently Unavailable',
                                            style: TextStyle(
                                              color: Colors.red[400],
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: MediaQuery.of(context).padding.top + 8,
                                  left: 16,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 22,
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back_ios_new,
                                          size: 18),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: MediaQuery.of(context).padding.top + 8,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: _toggleFavorite,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white70,
                                      radius: 22,
                                      child: Icon(
                                        isProviderFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isProviderFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                // Only show indicators if there are multiple images
                                if (serviceImages.length > 1)
                                  Positioned(
                                    bottom: 16,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        serviceImages.length,
                                        (index) => Container(
                                          width: 8,
                                          height: 8,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentImageIndex == index
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 20,
                                  right: 24,
                                  child: Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: providerData != null &&
                                              providerData!.containsKey(
                                                  'profileImage') &&
                                              providerData!['profileImage'] !=
                                                  null
                                          ? Image.network(
                                              providerData!['profileImage'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(Icons.person,
                                                      size: 30,
                                                      color: Colors.grey[400]),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: Icon(Icons.person,
                                                  size: 30,
                                                  color: Colors.grey[400]),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                providerName,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF344D67),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isApproved)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4.0),
                                                child: Icon(
                                                  Icons.verified,
                                                  color: Colors.blue,
                                                  size: 20,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.amber, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            avgRating.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            ' ($ratingCount)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '$serviceName • $experience year Experience',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),

                                    ],
                                  ),
                                  SizedBox(height: 16),



                                  // Service Description
                                  Text(
                                    'About this service',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF344D67),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  AnimatedCrossFade(
                                    duration: Duration(milliseconds: 300),
                                    crossFadeState: showFullDescription
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    firstChild: Text(
                                      serviceData!['description'] ??
                                          'No description available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    secondChild: Text(
                                      serviceData!['description'] ??
                                          'No description available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  if ((serviceData!['description'] ?? '')
                                          .length >
                                      150)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showFullDescription =
                                              !showFullDescription;
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          showFullDescription
                                              ? 'Show less'
                                              : 'Show more',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Available Areas
                                  if (availableAreas.isNotEmpty)
                                    _buildInfoSection(
                                        'Service Areas', availableAreas),

                                  // Available Days
                                  if (availableDays.isNotEmpty)
                                    _buildInfoSection(
                                        'Available Days', availableDays),

                                  // Reviews Section
                                  SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Customer Reviews',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF344D67),
                                        ),
                                      ),
                                      if (reviewsList.isNotEmpty)
                                        Text(
                                          '${reviewsList.length} review${reviewsList.length > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  _buildReviewCarousel(),

                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Action Buttons
                    Container(
            padding:
            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${serviceData!['hourly_rate'] ?? '0'}/Hr',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _navigateToChat,
                      icon: Icon(Icons.message,
                          size: 16, color: Color(0xff0F3966)),
                      label: Text('Message',
                          style: TextStyle(
                              color: Color(0xff0F3966),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xff0F3966),
                        side: BorderSide(color: Color(0xff0F3966)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: isServiceActive
                          ? _navigateToBooking
                          : _showUnavailableServiceTooltip,

                      label: Text(isServiceActive
                          ? 'Book Now'
                          : 'Unavailable',
                          style: TextStyle(

                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isServiceActive
                            ? Color(0xff0F3966)
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
                )
                    )

                ],
                ),
    );
  }
}
