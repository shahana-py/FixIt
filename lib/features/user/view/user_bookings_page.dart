//
// import 'package:fixit/features/user/view/track_booking_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// import '../../../core/shared/services/image_service.dart';
// import '../../../core/utils/custom_texts/app_bar_text.dart';
// import '../../service_provider/models/booking_model.dart';
//
//
// class UserBookingsPage extends StatefulWidget {
//   const UserBookingsPage({Key? key}) : super(key: key);
//
//   @override
//   State<UserBookingsPage> createState() => _UserBookingsPageState();
// }
//
// class _UserBookingsPageState extends State<UserBookingsPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImageService _imageService = ImageService();
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _bookings = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchBookings();
//   }
//
//   Future<void> _fetchBookings() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final User? currentUser = _auth.currentUser;
//
//       if (currentUser == null) {
//         throw Exception('No user logged in');
//       }
//
//       // Fetch all bookings for the current user
//       final QuerySnapshot bookingSnapshot = await _firestore
//           .collection('bookings')
//           .where('user_id', isEqualTo: currentUser.uid)
//           .orderBy('booking_date', descending: true)
//           .get();
//
//       List<Map<String, dynamic>> bookingsList = [];
//
//       // Process each booking
//       for (var doc in bookingSnapshot.docs) {
//         final bookingData = doc.data() as Map<String, dynamic>;
//
//         // Fetch service details
//         final serviceDoc = await _firestore
//             .collection('services')
//             .doc(bookingData['service_id'])
//             .get();
//
//         // Fetch provider details
//         final providerDoc = await _firestore
//             .collection('service provider')
//             .doc(bookingData['provider_id'])
//             .get();
//
//         if (serviceDoc.exists && providerDoc.exists) {
//           final serviceData = serviceDoc.data() as Map<String, dynamic>;
//           final providerData = providerDoc.data() as Map<String, dynamic>;
//
//           bookingsList.add({
//             'id': doc.id,
//             'booking_date': bookingData['booking_date'],
//             'service_name': bookingData['service_name'],
//             'provider_name': bookingData['provider_name'],
//             'status': bookingData['status'],
//             'payment_status': bookingData['payment_status'],
//             'total_cost': bookingData['total_cost'],
//             'duration_hours': bookingData['duration_hours'],
//             'work_sample': serviceData['work_sample'],
//             'provider_profile': providerData['profileImage'],
//             'hourly_rate': bookingData['hourly_rate'],
//           });
//         }
//       }
//
//       setState(() {
//         _bookings = bookingsList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showErrorDialog('Error loading bookings: ${e.toString()}');
//     }
//   }
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper methods for image handling
//   Future<String> _getWorkSampleImage(String? imageUrl) async {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return await _imageService.suggestPlaceholderImage('Service');
//     }
//     return imageUrl;
//   }
//
//   Future<String> _getProviderProfileImage(String? imageUrl) async {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return await _imageService.suggestPlaceholderImage('Person');
//     }
//     return imageUrl;
//   }
//   void _trackOrder(String bookingId) async {
//     try {
//       // Find the booking with the matching ID
//       final bookingMap = _bookings.firstWhere((b) => b['id'] == bookingId, orElse: () => {});
//
//       if (bookingMap.isEmpty) {
//         _showErrorDialog('Booking details not found.');
//         return;
//       }
//
//       // Get the document from Firestore to create a proper BookingModel
//       final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
//
//       if (!bookingDoc.exists) {
//         _showErrorDialog('Booking details not found in database.');
//         return;
//       }
//
//       // Create a BookingModel from the Firestore document
//       final bookingModel = BookingModel.fromFirestore(bookingDoc);
//
//       // Navigate to the track booking page with the proper BookingModel
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TrackBookingPage(
//             booking: bookingModel,
//           ),
//         ),
//       );
//     } catch (e) {
//       _showErrorDialog('Error loading booking details: ${e.toString()}');
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         iconTheme: IconThemeData(color: Colors.white,size: 24),
//         leading: IconButton(
//           onPressed: (){
//             Navigator.pushNamedAndRemoveUntil(context, '/home', (Route route)=>false);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//
//         title: AppBarTitle(text: "My Bookings"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchBookings,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _bookings.isEmpty
//           ? _buildEmptyState()
//           : _buildBookingsList(),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.calendar_today_outlined,
//             size: 80,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No bookings found',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Your bookings will appear here',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.search),
//             label: const Text('Browse Services'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade800,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             onPressed: () {
//               // Navigate to browse services
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBookingsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _bookings.length,
//       itemBuilder: (context, index) {
//         final booking = _bookings[index];
//         final bookingDate = (booking['booking_date'] as Timestamp).toDate();
//         final formattedDate = DateFormat('dd MMM yyyy').format(bookingDate);
//         final formattedTime = DateFormat('hh:mm a').format(bookingDate);
//
//         // Determine status color
//         Color statusColor = Colors.grey;
//         switch (booking['status']) {
//           case 'confirmed':
//             statusColor = Colors.blue;
//             break;
//           case 'pending_payment':
//             statusColor = Colors.red.shade300;
//             break;
//           case 'completed':
//             statusColor = Colors.green;
//             break;
//           case 'cancelled':
//             statusColor = Colors.red;
//             break;
//         }
//
//         return Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with date and status
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Text(
//                           formattedDate,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Icon(Icons.access_time, size: 18, color: Colors.blue),
//                         const SizedBox(width: 4),
//                         Text(
//                           formattedTime,
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: statusColor),
//                       ),
//                       child: Text(
//                         booking['status'].toString().toUpperCase().replaceAll('_', ' '),
//                         style: TextStyle(
//                           color: statusColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Service details
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Work sample image
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: FutureBuilder<String>(
//                         future: _getWorkSampleImage(booking['work_sample']),
//                         builder: (context, snapshot) {
//                           final imageUrl = snapshot.data ?? booking['work_sample'] ?? '';
//
//                           if (imageUrl.isEmpty) {
//                             return Container(
//                               width: 80,
//                               height: 80,
//                               color: Colors.grey.shade200,
//                               child: const Icon(Icons.home_repair_service, color: Colors.grey),
//                             );
//                           }
//
//                           return Image.network(
//                             imageUrl,
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                             loadingBuilder: (context, child, loadingProgress) {
//                               if (loadingProgress == null) return child;
//                               return Container(
//                                 width: 80,
//                                 height: 80,
//                                 color: Colors.grey.shade200,
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress.cumulativeBytesLoaded /
//                                         loadingProgress.expectedTotalBytes!
//                                         : null,
//                                   ),
//                                 ),
//                               );
//                             },
//                             errorBuilder: (context, error, stackTrace) {
//                               return FutureBuilder<String>(
//                                 future: _imageService.suggestPlaceholderImage('Service'),
//                                 builder: (context, placeholderSnapshot) {
//                                   if (placeholderSnapshot.hasData) {
//                                     return Image.network(
//                                       placeholderSnapshot.data!,
//                                       width: 80,
//                                       height: 80,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, stackTrace) => Container(
//                                         width: 80,
//                                         height: 80,
//                                         color: Colors.grey.shade200,
//                                         child: const Icon(Icons.home_repair_service, color: Colors.grey),
//                                       ),
//                                     );
//                                   }
//                                   return Container(
//                                     width: 80,
//                                     height: 80,
//                                     color: Colors.grey.shade200,
//                                     child: const Icon(Icons.home_repair_service, color: Colors.grey),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//
//                     // Service information
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             booking['service_name'] ?? 'Unknown Service',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//
//                           // Provider details
//                           Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: FutureBuilder<String>(
//                                   future: _getProviderProfileImage(booking['provider_profile']),
//                                   builder: (context, snapshot) {
//                                     final imageUrl = snapshot.data ?? booking['provider_profile'] ?? '';
//
//                                     if (imageUrl.isEmpty) {
//                                       return Container(
//                                         width: 32,
//                                         height: 32,
//                                         color: Colors.grey.shade200,
//                                         child: const Icon(Icons.person, color: Colors.grey, size: 20),
//                                       );
//                                     }
//
//                                     return Image.network(
//                                       imageUrl,
//                                       width: 32,
//                                       height: 32,
//                                       fit: BoxFit.cover,
//                                       loadingBuilder: (context, child, loadingProgress) {
//                                         if (loadingProgress == null) return child;
//                                         return Container(
//                                           width: 32,
//                                           height: 32,
//                                           color: Colors.grey.shade200,
//                                           child: Center(
//                                             child: SizedBox(
//                                               width: 16,
//                                               height: 16,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 2,
//                                                 value: loadingProgress.expectedTotalBytes != null
//                                                     ? loadingProgress.cumulativeBytesLoaded /
//                                                     loadingProgress.expectedTotalBytes!
//                                                     : null,
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       errorBuilder: (context, error, stackTrace) {
//                                         return FutureBuilder<String>(
//                                           future: _imageService.suggestPlaceholderImage('Person'),
//                                           builder: (context, placeholderSnapshot) {
//                                             if (placeholderSnapshot.hasData) {
//                                               return Image.network(
//                                                 placeholderSnapshot.data!,
//                                                 width: 32,
//                                                 height: 32,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder: (context, error, stackTrace) => Container(
//                                                   width: 32,
//                                                   height: 32,
//                                                   color: Colors.grey.shade200,
//                                                   child: const Icon(Icons.person, color: Colors.grey, size: 20),
//                                                 ),
//                                               );
//                                             }
//                                             return Container(
//                                               width: 32,
//                                               height: 32,
//                                               color: Colors.grey.shade200,
//                                               child: const Icon(Icons.person, color: Colors.grey, size: 20),
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 booking['provider_name'] ?? 'Unknown Provider',
//                                 style: TextStyle(
//                                   color: Colors.grey.shade700,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 8),
//
//                           // Cost details
//                           Row(
//                             children: [
//                               const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '₹${booking['hourly_rate']}/hr · ${booking['duration_hours']} ${booking['duration_hours'] == 1 ? 'hour' : 'hours'}',
//                                 style: TextStyle(color: Colors.grey.shade700),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 '₹${booking['total_cost']}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 4),
//
//                           // Payment status
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: booking['payment_status'] == 'paid'
//                                   ? Colors.green.shade300
//                                   : Colors.red.shade300,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               booking['payment_status'].toString().toUpperCase(),
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: booking['payment_status'] == 'paid'
//                                     ? Colors.white70
//                                     : Colors.white70,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Actions
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//
//                     // Contact button - Optional
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.call,color: Colors.blue,),
//                       label: const Text('Contact'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue.shade50,
//                         foregroundColor: Colors.blue.shade800,
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       ),
//                       onPressed: () {
//                         // calling functionality
//                       },
//                     ),
//
//                     const SizedBox(width: 8),
//                     // Track order button
//                     TextButton.icon(
//                       icon: const Icon(Icons.location_on,color: Colors.white70,),
//                       label: const Text('Track Order'),
//                       style: TextButton.styleFrom(
//                         foregroundColor: Colors.blue.shade50,
//                         backgroundColor: Colors.blue.shade800,
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       ),
//                       onPressed: () => _trackOrder(booking['id']),
//                     ),
//
//
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

// import 'package:fixit/features/user/view/track_booking_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../../core/shared/services/image_service.dart';
// import '../../../core/utils/custom_texts/app_bar_text.dart';
// import '../../service_provider/models/booking_model.dart';
//
// class UserBookingsPage extends StatefulWidget {
//   const UserBookingsPage({Key? key}) : super(key: key);
//
//   @override
//   State<UserBookingsPage> createState() => _UserBookingsPageState();
// }
//
// class _UserBookingsPageState extends State<UserBookingsPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImageService _imageService = ImageService();
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _bookings = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchBookings();
//   }
//
//   Future<void> _fetchBookings() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final User? currentUser = _auth.currentUser;
//
//       if (currentUser == null) {
//         throw Exception('No user logged in');
//       }
//
//       final QuerySnapshot bookingSnapshot = await _firestore
//           .collection('bookings')
//           .where('user_id', isEqualTo: currentUser.uid)
//           .orderBy('booking_date', descending: true)
//           .get();
//
//       List<Map<String, dynamic>> bookingsList = [];
//
//       for (var doc in bookingSnapshot.docs) {
//         final bookingData = doc.data() as Map<String, dynamic>;
//
//         // Only show completed or cancelled bookings in status bar
//         final status = bookingData['status'];
//         if (status != 'completed' && status != 'cancelled') {
//           bookingData['status'] = 'confirmed'; // Treat all others as confirmed
//         }
//
//         final serviceDoc = await _firestore
//             .collection('services')
//             .doc(bookingData['service_id'])
//             .get();
//
//         final providerDoc = await _firestore
//             .collection('service provider')
//             .doc(bookingData['provider_id'])
//             .get();
//
//         if (serviceDoc.exists && providerDoc.exists) {
//           final serviceData = serviceDoc.data() as Map<String, dynamic>;
//           final providerData = providerDoc.data() as Map<String, dynamic>;
//
//           bookingsList.add({
//             'id': doc.id,
//             'booking_date': bookingData['booking_date'],
//             'service_name': bookingData['service_name'],
//             'service_id': bookingData['service_id'],
//             'provider_name': bookingData['provider_name'],
//             'provider_id': bookingData['provider_id'],
//             'provider_phone': providerData['phone'] ?? providerData['phoneNumber'] ?? '',
//             'status': bookingData['status'],
//             'payment_status': bookingData['payment_status'],
//             'total_cost': bookingData['total_cost'],
//             'duration_hours': bookingData['duration_hours'],
//             'work_sample': serviceData['work_sample'],
//             'provider_profile': providerData['profileImage'],
//             'hourly_rate': bookingData['hourly_rate'],
//           });
//         }
//       }
//
//       setState(() {
//         _bookings = bookingsList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showErrorDialog('Error loading bookings: ${e.toString()}');
//     }
//   }
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<String> _getWorkSampleImage(String? imageUrl) async {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return await _imageService.suggestPlaceholderImage('Service');
//     }
//     return imageUrl;
//   }
//
//   Future<String> _getProviderProfileImage(String? imageUrl) async {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return await _imageService.suggestPlaceholderImage('Person');
//     }
//     return imageUrl;
//   }
//
//   Future<void> _makePhoneCall(String phoneNumber) async {
//     // Clean the phone number - remove any non-digit characters
//     final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
//
//     if (cleanedNumber.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Invalid phone number'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     // Create the Uri with the tel scheme
//     final Uri launchUri = Uri(
//       scheme: 'tel',
//       path: cleanedNumber,
//     );
//
//     try {
//       // Check if we can launch the URL and then launch it
//       if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
//         throw 'Could not launch phone dialer';
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error making call: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _trackOrder(String bookingId) async {
//     try {
//       final bookingMap = _bookings.firstWhere((b) => b['id'] == bookingId, orElse: () => {});
//
//       if (bookingMap.isEmpty) {
//         _showErrorDialog('Booking details not found.');
//         return;
//       }
//
//       final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
//
//       if (!bookingDoc.exists) {
//         _showErrorDialog('Booking details not found in database.');
//         return;
//       }
//
//       final bookingModel = BookingModel.fromFirestore(bookingDoc);
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TrackBookingPage(booking: bookingModel),
//         ),
//       );
//     } catch (e) {
//       _showErrorDialog('Error loading booking details: ${e.toString()}');
//     }
//   }
//
//   void _showRatingBottomSheet(String bookingId, String providerId, String serviceId) {
//     int rating = 0;
//     final TextEditingController feedbackController = TextEditingController();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext bottomSheetContext) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Handle bar for bottom sheet
//                       Center(
//                         child: Container(
//                           width: 40,
//                           height: 5,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Title
//                       const Text(
//                         'Rate Your Experience',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//
//                       const Text(
//                         'How would you rate this service?',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Rating stars
//                       Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: List.generate(5, (index) {
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   rating = index + 1;
//                                 });
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                                 child: Icon(
//                                   index < rating ? Icons.star : Icons.star_border,
//                                   color: Colors.amber,
//                                   size: 40,
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//
//                       // Feedback text field
//                       TextField(
//                         controller: feedbackController,
//                         decoration: InputDecoration(
//                           labelText: 'Share your feedback (optional)',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.all(16),
//                         ),
//                         maxLines: 4,
//                       ),
//                       const SizedBox(height: 30),
//
//                       // Submit button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             if (rating == 0) {
//                               ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Please select a rating'),
//                                 ),
//                               );
//                               return;
//                             }
//
//                             try {
//                               final user = _auth.currentUser;
//                               if (user == null) return;
//
//                               // Show loading indicator
//                               showDialog(
//                                 context: bottomSheetContext,
//                                 barrierDismissible: false,
//                                 builder: (context) => const Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               );
//
//                               // Create the rating document
//                               await _firestore.collection('ratings').add({
//                                 'booking_id': bookingId,
//                                 'provider_id': providerId,
//                                 'service_id': serviceId,
//                                 'user_id': user.uid,
//                                 'rating': rating,
//                                 'feedback': feedbackController.text,
//                                 'created_at': FieldValue.serverTimestamp(),
//                               });
//
//                               // Close loading indicator
//                               Navigator.pop(bottomSheetContext);
//
//                               // Close bottom sheet
//                               Navigator.pop(bottomSheetContext);
//
//                               // Show success message
//                               ScaffoldMessenger.of(this.context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Thank you for your feedback!'),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//                             } catch (e) {
//                               // Close loading indicator if showing
//                               Navigator.pop(bottomSheetContext);
//                               _showErrorDialog('Error submitting rating: ${e.toString()}');
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade800,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: const Text(
//                             'Submit Rating',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//
//                       // Cancel button
//                       SizedBox(
//                         width: double.infinity,
//                         child: TextButton(
//                           onPressed: () => Navigator.pop(bottomSheetContext),
//                           child: Text(
//                             'Cancel',
//                             style: TextStyle(
//                               color: Colors.grey.shade700,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         iconTheme: IconThemeData(color: Colors.white, size: 24),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushNamedAndRemoveUntil(context, '/home', (Route route) => false);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//         title: AppBarTitle(text: "My Bookings"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchBookings,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _bookings.isEmpty
//           ? _buildEmptyState()
//           : _buildBookingsList(),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.calendar_today_outlined,
//             size: 80,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No bookings found',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Your bookings will appear here',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.search),
//             label: const Text('Browse Services'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade800,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             onPressed: () {
//               // Navigate to browse services
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBookingsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _bookings.length,
//       itemBuilder: (context, index) {
//         final booking = _bookings[index];
//         final bookingDate = (booking['booking_date'] as Timestamp).toDate();
//         final formattedDate = DateFormat('dd MMM yyyy').format(bookingDate);
//         final formattedTime = DateFormat('hh:mm a').format(bookingDate);
//
//         // Determine status color
//         Color statusColor = Colors.grey;
//         switch (booking['status']) {
//           case 'completed':
//             statusColor = Colors.green;
//             break;
//           case 'cancelled':
//             statusColor = Colors.red;
//             break;
//           default: // For all other statuses
//             statusColor = Colors.blue;
//         }
//
//         return Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with date and status
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Text(
//                           formattedDate,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Icon(Icons.access_time, size: 18, color: Colors.blue),
//                         const SizedBox(width: 4),
//                         Text(
//                           formattedTime,
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: statusColor),
//                       ),
//                       child: Text(
//                         booking['status'].toString().toUpperCase().replaceAll('_', ' '),
//                         style: TextStyle(
//                           color: statusColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Service details
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Work sample image
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: FutureBuilder<String>(
//                         future: _getWorkSampleImage(booking['work_sample']),
//                         builder: (context, snapshot) {
//                           final imageUrl = snapshot.data ?? booking['work_sample'] ?? '';
//
//                           if (imageUrl.isEmpty) {
//                             return Container(
//                               width: 80,
//                               height: 80,
//                               color: Colors.grey.shade200,
//                               child: const Icon(Icons.home_repair_service, color: Colors.grey),
//                             );
//                           }
//
//                           return Image.network(
//                             imageUrl,
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                             loadingBuilder: (context, child, loadingProgress) {
//                               if (loadingProgress == null) return child;
//                               return Container(
//                                 width: 80,
//                                 height: 80,
//                                 color: Colors.grey.shade200,
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress.cumulativeBytesLoaded /
//                                         loadingProgress.expectedTotalBytes!
//                                         : null,
//                                   ),
//                                 ),
//                               );
//                             },
//                             errorBuilder: (context, error, stackTrace) {
//                               return FutureBuilder<String>(
//                                 future: _imageService.suggestPlaceholderImage('Service'),
//                                 builder: (context, placeholderSnapshot) {
//                                   if (placeholderSnapshot.hasData) {
//                                     return Image.network(
//                                       placeholderSnapshot.data!,
//                                       width: 80,
//                                       height: 80,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, stackTrace) => Container(
//                                         width: 80,
//                                         height: 80,
//                                         color: Colors.grey.shade200,
//                                         child: const Icon(Icons.home_repair_service, color: Colors.grey),
//                                       ),
//                                     );
//                                   }
//                                   return Container(
//                                     width: 80,
//                                     height: 80,
//                                     color: Colors.grey.shade200,
//                                     child: const Icon(Icons.home_repair_service, color: Colors.grey),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//
//                     // Service information
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             booking['service_name'] ?? 'Unknown Service',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//
//                           // Provider details
//                           Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: FutureBuilder<String>(
//                                   future: _getProviderProfileImage(booking['provider_profile']),
//                                   builder: (context, snapshot) {
//                                     final imageUrl = snapshot.data ?? booking['provider_profile'] ?? '';
//
//                                     if (imageUrl.isEmpty) {
//                                       return Container(
//                                         width: 32,
//                                         height: 32,
//                                         color: Colors.grey.shade200,
//                                         child: const Icon(Icons.person, color: Colors.grey, size: 20),
//                                       );
//                                     }
//
//                                     return Image.network(
//                                       imageUrl,
//                                       width: 32,
//                                       height: 32,
//                                       fit: BoxFit.cover,
//                                       loadingBuilder: (context, child, loadingProgress) {
//                                         if (loadingProgress == null) return child;
//                                         return Container(
//                                           width: 32,
//                                           height: 32,
//                                           color: Colors.grey.shade200,
//                                           child: Center(
//                                             child: SizedBox(
//                                               width: 16,
//                                               height: 16,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 2,
//                                                 value: loadingProgress.expectedTotalBytes != null
//                                                     ? loadingProgress.cumulativeBytesLoaded /
//                                                     loadingProgress.expectedTotalBytes!
//                                                     : null,
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       errorBuilder: (context, error, stackTrace) {
//                                         return FutureBuilder<String>(
//                                           future: _imageService.suggestPlaceholderImage('Person'),
//                                           builder: (context, placeholderSnapshot) {
//                                             if (placeholderSnapshot.hasData) {
//                                               return Image.network(
//                                                 placeholderSnapshot.data!,
//                                                 width: 32,
//                                                 height: 32,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder: (context, error, stackTrace) => Container(
//                                                   width: 32,
//                                                   height: 32,
//                                                   color: Colors.grey.shade200,
//                                                   child: const Icon(Icons.person, color: Colors.grey, size: 20),
//                                                 ),
//                                               );
//                                             }
//                                             return Container(
//                                               width: 32,
//                                               height: 32,
//                                               color: Colors.grey.shade200,
//                                               child: const Icon(Icons.person, color: Colors.grey, size: 20),
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 booking['provider_name'] ?? 'Unknown Provider',
//                                 style: TextStyle(
//                                   color: Colors.grey.shade700,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 8),
//
//                           // Cost details
//                           Row(
//                             children: [
//                               const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '₹${booking['hourly_rate']}/hr · ${booking['duration_hours']} ${booking['duration_hours'] == 1 ? 'hour' : 'hours'}',
//                                 style: TextStyle(color: Colors.grey.shade700),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 '₹${booking['total_cost']}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 4),
//
//                           // Payment status
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: booking['payment_status'] == 'paid'
//                                   ? Colors.green.shade300
//                                   : Colors.red.shade300,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               booking['payment_status'].toString().toUpperCase(),
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: booking['payment_status'] == 'paid'
//                                     ? Colors.white70
//                                     : Colors.white70,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Actions
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Contact button - Only show for non-completed services
//                     if (booking['status'] != 'completed')
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.call, color: Colors.blue),
//                         label: const Text('Contact'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue.shade50,
//                           foregroundColor: Colors.blue.shade800,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         ),
//                         onPressed: () => _makePhoneCall(booking['provider_phone']),
//                       ),
//
//                     if (booking['status'] != 'completed' && booking['status'] != 'cancelled')
//                       const SizedBox(width: 8),
//
//                     // For completed services: View Details/Track Order button and Rate button
//                     if (booking['status'] == 'completed') ...[
//
//                       TextButton.icon(
//                         icon: const Icon(Icons.star, color: Colors.white70),
//                         label: const Text('Rate Us'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.white70,
//                           backgroundColor: Color(0xffFABB02),
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         ),
//                         onPressed: () => _showRatingBottomSheet(
//                           booking['id'],
//                           booking['provider_id'],
//                           booking['service_id'],
//                         ),
//                       ),
//
//                       const SizedBox(width: 8),
//                       TextButton.icon(
//                         icon: const Icon(Icons.location_on, color: Colors.white70),
//                         label: const Text('View Details'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.blue.shade50,
//                           backgroundColor: Colors.blue.shade800,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         ),
//                         onPressed: () => _trackOrder(booking['id']),
//                       ),
//
//                     ]
//                     // For all other statuses: Track Order button
//                     else if (booking['status'] != 'cancelled') ...[
//                       TextButton.icon(
//                         icon: const Icon(Icons.location_on, color: Colors.white70),
//                         label: const Text('Track Order'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.blue.shade50,
//                           backgroundColor: Colors.blue.shade800,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         ),
//                         onPressed: () => _trackOrder(booking['id']),
//                       ),
//                     ],
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




//
// import 'package:fixit/features/user/view/track_booking_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../../core/shared/services/image_service.dart';
// import '../../../core/utils/custom_texts/app_bar_text.dart';
// import '../../service_provider/models/booking_model.dart';
//
// class UserBookingsPage extends StatefulWidget {
//   const UserBookingsPage({Key? key}) : super(key: key);
//
//   @override
//   State<UserBookingsPage> createState() => _UserBookingsPageState();
// }
//
// class _UserBookingsPageState extends State<UserBookingsPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImageService _imageService = ImageService();
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _bookings = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchBookings();
//   }
//   String _currentStatus(Map<String, dynamic> booking) {
//     final status = booking['status']?.toString().toLowerCase() ?? '';
//
//     // Normalize the status for display
//     if (status == 'declined') {
//       return 'declined';
//     } else if (status == 'cancelled') {
//       return 'cancelled';
//     } else if (status == 'completed') {
//       return 'completed';
//     }
//     // All other statuses are considered active/confirmed
//     return 'confirmed';
//   }
//
//   String? _refundStatus(Map<String, dynamic> booking) {
//     final refundStatus = booking['refund_status']?.toString().toLowerCase();
//     return refundStatus == 'processed' ? 'processed' : null;
//   }
//
//   bool _isActiveBooking(Map<String, dynamic> booking) {
//     final status = _currentStatus(booking);
//     return status != 'completed' && status != 'cancelled' && status != 'declined';
//   }
//
//   bool _isCompletedWithoutRating(Map<String, dynamic> booking) {
//     return _currentStatus(booking) == 'completed' && booking['user_rating'] == null;
//   }
//
//   Future<void> _fetchBookings() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final User? currentUser = _auth.currentUser;
//
//       if (currentUser == null) {
//         throw Exception('No user logged in');
//       }
//
//       final QuerySnapshot bookingSnapshot = await _firestore
//           .collection('bookings')
//           .where('user_id', isEqualTo: currentUser.uid)
//           .orderBy('booking_date', descending: true)
//           .get();
//
//       List<Map<String, dynamic>> activeBookings = [];
//       List<Map<String, dynamic>> completedNotRatedBookings = [];
//       List<Map<String, dynamic>> completedAndRatedBookings = [];
//
//       for (var doc in bookingSnapshot.docs) {
//         final bookingData = doc.data() as Map<String, dynamic>;
//
//         // Only show completed or cancelled bookings in status bar
//         final status = bookingData['status'];
//         if (status != 'completed' && status != 'cancelled') {
//           bookingData['status'] = 'confirmed'; // Treat all others as confirmed
//         }
//
//         final serviceDoc = await _firestore
//             .collection('services')
//             .doc(bookingData['service_id'])
//             .get();
//
//         final providerDoc = await _firestore
//             .collection('service provider')
//             .doc(bookingData['provider_id'])
//             .get();
//
//         // Check if user has already rated this booking
//         final QuerySnapshot ratingSnapshot = await _firestore
//             .collection('ratings')
//             .where('booking_id', isEqualTo: doc.id)
//             .where('user_id', isEqualTo: currentUser.uid)
//             .limit(1)
//             .get();
//
//         Map<String, dynamic>? userRating;
//         if (ratingSnapshot.docs.isNotEmpty) {
//           userRating = ratingSnapshot.docs.first.data() as Map<String, dynamic>;
//         }
//
//         if (serviceDoc.exists && providerDoc.exists) {
//           final serviceData = serviceDoc.data() as Map<String, dynamic>;
//           final providerData = providerDoc.data() as Map<String, dynamic>;
//
//           final bookingItem = {
//             'id': doc.id,
//             'booking_date': bookingData['booking_date'],
//             'service_name': bookingData['service_name'],
//             'service_id': bookingData['service_id'],
//             'provider_name': bookingData['provider_name'],
//             'provider_id': bookingData['provider_id'],
//             'provider_phone':
//             providerData['phone'] ?? providerData['phoneNumber'] ?? '',
//             'status': bookingData['status'],
//             'payment_status': bookingData['payment_status'],
//             'total_cost': bookingData['total_cost'],
//             'duration_hours': bookingData['duration_hours'],
//             'work_sample': serviceData['work_sample'],
//             'provider_profile': providerData['profileImage'],
//             'hourly_rate': bookingData['hourly_rate'],
//             'user_rating': userRating != null ? userRating['rating'] : null,
//             'user_feedback': userRating != null ? userRating['feedback'] : null,
//           };
//
//           // Categorize the booking
//           if (bookingData['status'] != 'completed' &&
//               bookingData['status'] != 'cancelled') {
//             activeBookings.add(bookingItem);
//           } else if (bookingData['status'] == 'completed' &&
//               userRating == null) {
//             completedNotRatedBookings.add(bookingItem);
//           } else {
//             completedAndRatedBookings.add(bookingItem);
//           }
//         }
//       }
//
//       // Combine all lists in the desired order
//       setState(() {
//         _bookings = [
//           ...activeBookings,
//           ...completedNotRatedBookings,
//           ...completedAndRatedBookings,
//         ];
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showErrorDialog('Error loading bookings: ${e.toString()}');
//     }
//   }
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<String> _getWorkSampleImage(String? imageUrl) async {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return await _imageService.suggestPlaceholderImage('Service');
//     }
//     return imageUrl;
//   }
//
//   Future<String> _getProviderProfileImage(String? imageUrl) async {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return await _imageService.suggestPlaceholderImage('Person');
//     }
//     return imageUrl;
//   }
//
//   Future<void> _makePhoneCall(String phoneNumber) async {
//     // Clean the phone number - remove any non-digit characters
//     final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
//
//     if (cleanedNumber.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Invalid phone number'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     // Create the Uri with the tel scheme
//     final Uri launchUri = Uri(
//       scheme: 'tel',
//       path: cleanedNumber,
//     );
//
//     try {
//       // Check if we can launch the URL and then launch it
//       if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
//         throw 'Could not launch phone dialer';
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error making call: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _trackOrder(String bookingId) async {
//     try {
//       final bookingMap =
//           _bookings.firstWhere((b) => b['id'] == bookingId, orElse: () => {});
//
//       if (bookingMap.isEmpty) {
//         _showErrorDialog('Booking details not found.');
//         return;
//       }
//
//       final bookingDoc =
//           await _firestore.collection('bookings').doc(bookingId).get();
//
//       if (!bookingDoc.exists) {
//         _showErrorDialog('Booking details not found in database.');
//         return;
//       }
//
//       final bookingModel = BookingModel.fromFirestore(bookingDoc);
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TrackBookingPage(booking: bookingModel),
//         ),
//       );
//     } catch (e) {
//       _showErrorDialog('Error loading booking details: ${e.toString()}');
//     }
//   }
//
//   // Send notification to service provider about the new rating
//   Future<void> _sendRatingNotification(
//       String providerId, String serviceName, int rating) async {
//     try {
//       // Create notification document
//       await _firestore.collection('notifications').add({
//         'provider_id': providerId,
//         'title': 'You got $rating ${rating == 1 ? 'star' : 'stars'} ${rating >= 2.5 ? '🎉' : '😔'}',
//         'message':
//             'A customer rated your service "$serviceName" with $rating ${rating == 1 ? 'star' : 'stars'}!',
//         'timestamp': FieldValue.serverTimestamp(),
//         'is_read': false,
//         'type': 'rating',
//       });
//     } catch (e) {
//       print('Error sending notification: ${e.toString()}');
//       // We don't want to show an error to the user if notification fails
//       // This is a background operation that shouldn't affect the user experience
//     }
//   }
//
//   void _showRatingBottomSheet(String bookingId, String providerId,
//       String serviceId, String serviceName) {
//     int rating = 0;
//     final TextEditingController feedbackController = TextEditingController();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext bottomSheetContext) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Handle bar for bottom sheet
//                       Center(
//                         child: Container(
//                           width: 40,
//                           height: 5,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Title
//                       const Text(
//                         'Rate Your Experience',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//
//                       const Text(
//                         'How would you rate this service?',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Rating stars
//                       Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: List.generate(5, (index) {
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   rating = index + 1;
//                                 });
//                               },
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 8),
//                                 child: Icon(
//                                   index < rating
//                                       ? Icons.star
//                                       : Icons.star_border,
//                                   color: Colors.amber,
//                                   size: 40,
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//
//                       // Feedback text field
//                       TextField(
//                         controller: feedbackController,
//                         decoration: InputDecoration(
//                           labelText: 'Share your feedback (optional)',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(
//                                 color: Colors.blue.shade800, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.all(16),
//                         ),
//                         maxLines: 4,
//                       ),
//                       const SizedBox(height: 30),
//
//                       // Submit button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             if (rating == 0) {
//                               ScaffoldMessenger.of(bottomSheetContext)
//                                   .showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Please select a rating'),
//                                 ),
//                               );
//                               return;
//                             }
//
//                             try {
//                               final user = _auth.currentUser;
//                               if (user == null) return;
//
//                               // Show loading indicator
//                               showDialog(
//                                 context: bottomSheetContext,
//                                 barrierDismissible: false,
//                                 builder: (context) => const Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               );
//
//                               // Create the rating document
//                               await _firestore.collection('ratings').add({
//                                 'booking_id': bookingId,
//                                 'provider_id': providerId,
//                                 'service_id': serviceId,
//                                 'user_id': user.uid,
//                                 'rating': rating,
//                                 'feedback': feedbackController.text,
//                                 'created_at': FieldValue.serverTimestamp(),
//                               });
//
//                               // Send notification to service provider
//                               await _sendRatingNotification(
//                                   providerId, serviceName, rating);
//
//                               // Close loading indicator
//                               Navigator.pop(bottomSheetContext);
//
//                               // Close bottom sheet
//                               Navigator.pop(bottomSheetContext);
//
//                               // Refresh the bookings to update the UI
//                               _fetchBookings();
//
//                               // Show success message
//                               ScaffoldMessenger.of(this.context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Thank you for your feedback!'),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//                             } catch (e) {
//                               // Close loading indicator if showing
//                               Navigator.pop(bottomSheetContext);
//                               _showErrorDialog(
//                                   'Error submitting rating: ${e.toString()}');
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade800,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: const Text(
//                             'Submit Rating',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//
//                       // Cancel button
//                       SizedBox(
//                         width: double.infinity,
//                         child: TextButton(
//                           onPressed: () => Navigator.pop(bottomSheetContext),
//                           child: Text(
//                             'Cancel',
//                             style: TextStyle(
//                               color: Colors.grey.shade700,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Widget to display user rating
//   Widget _buildUserRatingWidget(dynamic rating, String? feedback) {
//     // Convert the rating to an int (it might be coming from Firestore as a double)
//     final intRating = rating is double ? rating.toInt() : (rating as int);
//
//     return InkWell(
//       onTap: () {
//         // Show feedback if available
//         if (feedback != null && feedback.isNotEmpty) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Your Review'),
//               content: Text(feedback),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Close'),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.amber.shade100,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.amber.shade400),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Your Rating: ',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Row(
//               children: List.generate(5, (index) {
//                 return Icon(
//                   index < intRating ? Icons.star : Icons.star_border,
//                   color: Colors.amber,
//                   size: 16,
//                 );
//               }),
//             ),
//             if (feedback != null && feedback.isNotEmpty)
//               const Icon(
//                 Icons.chat_bubble_outline,
//                 size: 14,
//                 color: Colors.grey,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         iconTheme: IconThemeData(color: Colors.white, size: 24),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, '/home', (Route route) => false);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//         title: AppBarTitle(text: "My Bookings"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchBookings,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _bookings.isEmpty
//               ? _buildEmptyState()
//               : _buildBookingsList(),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.calendar_today_outlined,
//             size: 80,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No bookings found',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Your bookings will appear here',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.search,color: Colors.white,),
//             label: const Text('Browse Services',style: TextStyle(color: Colors.white),),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade800,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(context, '/userviewservicespage', (Route route) => false);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBookingsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _bookings.length,
//       itemBuilder: (context, index) {
//         final booking = _bookings[index];
//         final bookingDate = (booking['booking_date'] as Timestamp).toDate();
//         final formattedDate = DateFormat('dd MMM yyyy').format(bookingDate);
//         final formattedTime = DateFormat('hh:mm a').format(bookingDate);
//
//         // // Determine status color
//         // Color statusColor = Colors.grey;
//         // switch (booking['status']) {
//         //   case 'completed':
//         //     statusColor = Colors.green;
//         //     break;
//         //   case 'cancelled':
//         //   case 'declined':
//         //     statusColor = Colors.red;
//         //     break;
//         //   default: // For all other statuses
//         //     statusColor = Colors.blue;
//         // }
//         Color _getStatusColor(String status) {
//           switch (status) {
//             case 'completed':
//               return Colors.green;
//             case 'cancelled':
//             case 'declined':
//               return Colors.red;
//             default: // For all other statuses (confirmed)
//               return Colors.blue;
//           }
//         }
//
//         return Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           elevation: 2,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with date and status
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.calendar_today,
//                             size: 18, color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Text(
//                           formattedDate,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Icon(Icons.access_time,
//                             size: 18, color: Colors.blue),
//                         const SizedBox(width: 4),
//                         Text(
//                           formattedTime,
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     // Status display
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: _getStatusColor(_currentStatus(booking)).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: _getStatusColor(_currentStatus(booking))),
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             _currentStatus(booking).toUpperCase(),
//                             style: TextStyle(
//                               color: _getStatusColor(_currentStatus(booking)),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                           if (_refundStatus(booking) == 'processed')
//                             Padding(
//                               padding: const EdgeInsets.only(top: 4),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green.shade100,
//                                   borderRadius: BorderRadius.circular(16),
//                                   border: Border.all(color: Colors.green),
//                                 ),
//                                 child: Text(
//                                   'REFUNDED',
//                                   style: TextStyle(
//                                     color: Colors.green.shade800,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     // Container(
//                     //   padding: const EdgeInsets.symmetric(
//                     //       horizontal: 8, vertical: 4),
//                     //   decoration: BoxDecoration(
//                     //     color: statusColor.withOpacity(0.1),
//                     //     borderRadius: BorderRadius.circular(16),
//                     //     border: Border.all(color: statusColor),
//                     //   ),
//                     //   child: Text(
//                     //     booking['status']
//                     //         .toString()
//                     //         .toUpperCase()
//                     //         .replaceAll('_', ' '),
//                     //     style: TextStyle(
//                     //       color: statusColor,
//                     //       fontWeight: FontWeight.bold,
//                     //       fontSize: 12,
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//
//               // Service details
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Work sample image
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: FutureBuilder<String>(
//                         future: _getWorkSampleImage(booking['work_sample']),
//                         builder: (context, snapshot) {
//                           final imageUrl =
//                               snapshot.data ?? booking['work_sample'] ?? '';
//
//                           if (imageUrl.isEmpty) {
//                             return Container(
//                               width: 80,
//                               height: 80,
//                               color: Colors.grey.shade200,
//                               child: const Icon(Icons.home_repair_service,
//                                   color: Colors.grey),
//                             );
//                           }
//
//                           return Image.network(
//                             imageUrl,
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                             loadingBuilder: (context, child, loadingProgress) {
//                               if (loadingProgress == null) return child;
//                               return Container(
//                                 width: 80,
//                                 height: 80,
//                                 color: Colors.grey.shade200,
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes !=
//                                             null
//                                         ? loadingProgress
//                                                 .cumulativeBytesLoaded /
//                                             loadingProgress.expectedTotalBytes!
//                                         : null,
//                                   ),
//                                 ),
//                               );
//                             },
//                             errorBuilder: (context, error, stackTrace) {
//                               return FutureBuilder<String>(
//                                 future: _imageService
//                                     .suggestPlaceholderImage('Service'),
//                                 builder: (context, placeholderSnapshot) {
//                                   if (placeholderSnapshot.hasData) {
//                                     return Image.network(
//                                       placeholderSnapshot.data!,
//                                       width: 80,
//                                       height: 80,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               Container(
//                                         width: 80,
//                                         height: 80,
//                                         color: Colors.grey.shade200,
//                                         child: const Icon(
//                                             Icons.home_repair_service,
//                                             color: Colors.grey),
//                                       ),
//                                     );
//                                   }
//                                   return Container(
//                                     width: 80,
//                                     height: 80,
//                                     color: Colors.grey.shade200,
//                                     child: const Icon(Icons.home_repair_service,
//                                         color: Colors.grey),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//
//                     // Service information
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             booking['service_name'] ?? 'Unknown Service',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//
//                           // Provider details
//                           Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: FutureBuilder<String>(
//                                   future: _getProviderProfileImage(
//                                       booking['provider_profile']),
//                                   builder: (context, snapshot) {
//                                     final imageUrl = snapshot.data ??
//                                         booking['provider_profile'] ??
//                                         '';
//
//                                     if (imageUrl.isEmpty) {
//                                       return Container(
//                                         width: 32,
//                                         height: 32,
//                                         color: Colors.grey.shade200,
//                                         child: const Icon(Icons.person,
//                                             color: Colors.grey, size: 20),
//                                       );
//                                     }
//
//                                     return Image.network(
//                                       imageUrl,
//                                       width: 32,
//                                       height: 32,
//                                       fit: BoxFit.cover,
//                                       loadingBuilder:
//                                           (context, child, loadingProgress) {
//                                         if (loadingProgress == null)
//                                           return child;
//                                         return Container(
//                                           width: 32,
//                                           height: 32,
//                                           color: Colors.grey.shade200,
//                                           child: Center(
//                                             child: SizedBox(
//                                               width: 16,
//                                               height: 16,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 2,
//                                                 value: loadingProgress
//                                                             .expectedTotalBytes !=
//                                                         null
//                                                     ? loadingProgress
//                                                             .cumulativeBytesLoaded /
//                                                         loadingProgress
//                                                             .expectedTotalBytes!
//                                                     : null,
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                         return FutureBuilder<String>(
//                                           future: _imageService
//                                               .suggestPlaceholderImage(
//                                                   'Person'),
//                                           builder:
//                                               (context, placeholderSnapshot) {
//                                             if (placeholderSnapshot.hasData) {
//                                               return Image.network(
//                                                 placeholderSnapshot.data!,
//                                                 width: 32,
//                                                 height: 32,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder: (context, error,
//                                                         stackTrace) =>
//                                                     Container(
//                                                   width: 32,
//                                                   height: 32,
//                                                   color: Colors.grey.shade200,
//                                                   child: const Icon(
//                                                       Icons.person,
//                                                       color: Colors.grey,
//                                                       size: 20),
//                                                 ),
//                                               );
//                                             }
//                                             return Container(
//                                               width: 32,
//                                               height: 32,
//                                               color: Colors.grey.shade200,
//                                               child: const Icon(Icons.person,
//                                                   color: Colors.grey, size: 20),
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 booking['provider_name'] ?? 'Unknown Provider',
//                                 style: TextStyle(
//                                   color: Colors.grey.shade700,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 8),
//
//                           // Cost details
//                           Row(
//                             children: [
//                               const Icon(Icons.payments_outlined,
//                                   size: 16, color: Colors.grey),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '₹${booking['hourly_rate']}/hr · ${booking['duration_hours']} ${booking['duration_hours'] == 1 ? 'hour' : 'hours'}',
//                                 style: TextStyle(color: Colors.grey.shade700),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 '₹${booking['total_cost']}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 4),
//
//                           // Payment status
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: booking['payment_status'] == 'paid'
//                                   ? Colors.green.shade300
//                                   : Colors.red.shade300,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               booking['payment_status'] == 'paid'
//                                   ? 'PAID'
//                                   : 'UNPAID',
//                               style: TextStyle(
//                                 color: booking['payment_status'] == 'paid'
//                                     ? Colors.green.shade900
//                                     : Colors.red.shade900,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ),
//
//                           // User rating display (if available)
//                           if (booking['user_rating'] != null)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: _buildUserRatingWidget(
//                                 booking['user_rating'],
//                                 booking['user_feedback'],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
// // Actions section - Replace existing Padding widget containing buttons
// //               Padding(
// //                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.end,
// //                   children: [
// //                     // CASE 1: Active bookings (not completed or cancelled)
// //                     if (booking['status'] != 'completed' &&
// //                         booking['status'] != 'cancelled') ...[
// //                       // Contact button
// //                       ElevatedButton.icon(
// //                         icon: const Icon(Icons.call, color: Colors.blue),
// //                         label: const Text('Contact'),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.blue.shade50,
// //                           foregroundColor: Colors.blue.shade800,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 16, vertical: 8),
// //                         ),
// //                         onPressed: () =>
// //                             _makePhoneCall(booking['provider_phone']),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       // Track Order button
// //                       TextButton.icon(
// //                         icon: const Icon(Icons.location_on,
// //                             color: Colors.white70),
// //                         label: const Text('Track Order'),
// //                         style: TextButton.styleFrom(
// //                           foregroundColor: Colors.blue.shade50,
// //                           backgroundColor: Colors.blue.shade800,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 16, vertical: 8),
// //                         ),
// //                         onPressed: () => _trackOrder(booking['id']),
// //                       ),
// //                     ]
// //                     // CASE 2: Completed bookings without rating
// //                     else if (booking['status'] == 'completed' &&
// //                         booking['user_rating'] == null) ...[
// //                       TextButton.icon(
// //                         icon:  Icon(Icons.star, color: Colors.white),
// //                         label: const Text('Rate Us'),
// //                         style: TextButton.styleFrom(
// //                           foregroundColor: Colors.white,
// //                           backgroundColor: Color(0xffFABB02),
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 16, vertical: 8),
// //                         ),
// //                         onPressed: () => _showRatingBottomSheet(
// //                           booking['id'],
// //                           booking['provider_id'],
// //                           booking['service_id'],
// //                           booking['service_name'],
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       TextButton.icon(
// //                         icon:
// //                             const Icon(Icons.visibility, color: Colors.white70),
// //                         label: const Text('View Details'),
// //                         style: TextButton.styleFrom(
// //                           foregroundColor: Colors.blue.shade50,
// //                           backgroundColor: Colors.blue.shade800,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 16, vertical: 8),
// //                         ),
// //                         onPressed: () => _trackOrder(booking['id']),
// //                       ),
// //                     ]
// //                     // CASE 3: Completed or cancelled bookings with rating
// //                     else if ((booking['status'] == 'completed' ||
// //                             booking['status'] == 'cancelled'|| booking['status'] == 'declined') &&
// //                         booking['user_rating'] != null) ...[
// //                       TextButton.icon(
// //                         icon:
// //                             const Icon(Icons.visibility, color: Colors.white70),
// //                         label: const Text('View Details'),
// //                         style: TextButton.styleFrom(
// //                           foregroundColor: Colors.blue.shade50,
// //                           backgroundColor: Colors.blue.shade800,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 16, vertical: 8),
// //                         ),
// //                         onPressed: () => _trackOrder(booking['id']),
// //                       ),
// //                     ]
// //                     // CASE 4: Cancelled bookings without rating
// //                     else if ((booking['status'] == 'cancelled' || booking['status'] == 'declined') &&
// //                         booking['user_rating'] == null) ...[
// //                       TextButton.icon(
// //                         icon:
// //                             const Icon(Icons.visibility, color: Colors.white70),
// //                         label: const Text('View Details'),
// //                         style: TextButton.styleFrom(
// //                           foregroundColor: Colors.blue.shade50,
// //                           backgroundColor: Colors.blue.shade800,
// //                           padding: const EdgeInsets.symmetric(
// //                               horizontal: 16, vertical: 8),
// //                         ),
// //                         onPressed: () => _trackOrder(booking['id']),
// //                       ),
// //                     ],
// //                   ],
// //                 ),
// //               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (_isActiveBooking(booking)) ...[
//                       // Contact button
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.call, color: Colors.blue),
//                         label: const Text('Contact'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue.shade50,
//                           foregroundColor: Colors.blue.shade800,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         ),
//                         onPressed: () => _makePhoneCall(booking['provider_phone']),
//                       ),
//                       const SizedBox(width: 8),
//                       // Track Order button
//                       TextButton.icon(
//                         icon: const Icon(Icons.location_on, color: Colors.white70),
//                         label: const Text('Track Order'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.blue.shade50,
//                           backgroundColor: Colors.blue.shade800,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         ),
//                         onPressed: () => _trackOrder(booking['id']),
//                       ),
//                     ]
//                     else if (_isCompletedWithoutRating(booking)) ...[
//                       TextButton.icon(
//                         icon: Icon(Icons.star, color: Colors.white),
//                         label: const Text('Rate Us'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           backgroundColor: Color(0xffFABB02),
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         ),
//                         onPressed: () => _showRatingBottomSheet(
//                           booking['id'],
//                           booking['provider_id'],
//                           booking['service_id'],
//                           booking['service_name'],
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       TextButton.icon(
//                         icon: const Icon(Icons.visibility, color: Colors.white70),
//                         label: const Text('View Details'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.blue.shade50,
//                           backgroundColor: Colors.blue.shade800,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         ),
//                         onPressed: () => _trackOrder(booking['id']),
//                       ),
//                     ]
//                     else ...[
//                         // For all other cases (completed with rating, cancelled, declined)
//                         TextButton.icon(
//                           icon: const Icon(Icons.visibility, color: Colors.white70),
//                           label: const Text('View Details'),
//                           style: TextButton.styleFrom(
//                             foregroundColor: Colors.blue.shade50,
//                             backgroundColor: Colors.blue.shade800,
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           ),
//                           onPressed: () => _trackOrder(booking['id']),
//                         ),
//                       ],
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

import 'package:fixit/features/user/view/track_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/shared/services/image_service.dart';
import '../../../core/utils/custom_texts/app_bar_text.dart';
import '../../service_provider/models/booking_model.dart';

class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({Key? key}) : super(key: key);

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  String _currentStatus(Map<String, dynamic> booking) {
    final status = booking['status']?.toString().toLowerCase() ?? '';

    if (status == 'declined') {
      return 'declined';
    } else if (status == 'cancelled') {
      return 'cancelled';
    } else if (status == 'completed') {
      return 'completed';
    }
    return 'confirmed';
  }

  String? _refundStatus(Map<String, dynamic> booking) {
    final refundStatus = booking['refund_status']?.toString().toLowerCase();
    return refundStatus == 'processed' ? 'processed' : null;
  }

  bool _isActiveBooking(Map<String, dynamic> booking) {
    final status = _currentStatus(booking);
    return status != 'completed' && status != 'cancelled' && status != 'declined';
  }

  bool _isCompletedWithoutRating(Map<String, dynamic> booking) {
    return _currentStatus(booking) == 'completed' && booking['user_rating'] == null;
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final QuerySnapshot bookingSnapshot = await _firestore
          .collection('bookings')
          .where('user_id', isEqualTo: currentUser.uid)
          .orderBy('booking_date', descending: true)
          .get();

      List<Map<String, dynamic>> activeBookings = [];
      List<Map<String, dynamic>> completedNotRatedBookings = [];
      List<Map<String, dynamic>> completedAndRatedBookings = [];

      for (var doc in bookingSnapshot.docs) {
        final bookingData = doc.data() as Map<String, dynamic>;

        final serviceDoc = await _firestore
            .collection('services')
            .doc(bookingData['service_id'])
            .get();

        final providerDoc = await _firestore
            .collection('service provider')
            .doc(bookingData['provider_id'])
            .get();

        final QuerySnapshot ratingSnapshot = await _firestore
            .collection('ratings')
            .where('booking_id', isEqualTo: doc.id)
            .where('user_id', isEqualTo: currentUser.uid)
            .limit(1)
            .get();

        Map<String, dynamic>? userRating;
        if (ratingSnapshot.docs.isNotEmpty) {
          userRating = ratingSnapshot.docs.first.data() as Map<String, dynamic>;
        }

        if (serviceDoc.exists && providerDoc.exists) {
          final serviceData = serviceDoc.data() as Map<String, dynamic>;
          final providerData = providerDoc.data() as Map<String, dynamic>;

          final bookingItem = {
            'id': doc.id,
            'booking_date': bookingData['booking_date'],
            'service_name': bookingData['service_name'],
            'service_id': bookingData['service_id'],
            'provider_name': bookingData['provider_name'],
            'provider_id': bookingData['provider_id'],
            'provider_phone': providerData['phone'] ?? providerData['phoneNumber'] ?? '',
            'status': bookingData['status'],
            'payment_status': bookingData['payment_status'],
            'total_cost': bookingData['total_cost'],
            'duration_hours': bookingData['duration_hours'],
            'work_sample': serviceData['work_sample'],
            'provider_profile': providerData['profileImage'],
            'hourly_rate': bookingData['hourly_rate'],
            'user_rating': userRating != null ? userRating['rating'] : null,
            'user_feedback': userRating != null ? userRating['feedback'] : null,
            'refund_status': bookingData['refund_status'],
          };

          final originalStatus = bookingData['status']?.toString().toLowerCase() ?? '';
          if (originalStatus != 'completed' && originalStatus != 'cancelled' && originalStatus != 'declined') {
            activeBookings.add(bookingItem);
          } else if (originalStatus == 'completed' && userRating == null) {
            completedNotRatedBookings.add(bookingItem);
          } else {
            completedAndRatedBookings.add(bookingItem);
          }
        }
      }

      setState(() {
        _bookings = [
          ...activeBookings,
          ...completedNotRatedBookings,
          ...completedAndRatedBookings,
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading bookings: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String> _getWorkSampleImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return await _imageService.suggestPlaceholderImage('Service');
    }
    return imageUrl;
  }

  Future<String> _getProviderProfileImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return await _imageService.suggestPlaceholderImage('Person');
    }
    return imageUrl;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleanedNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: cleanedNumber);

    try {
      if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch phone dialer';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error making call: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _trackOrder(String bookingId) async {
    try {
      final bookingMap = _bookings.firstWhere((b) => b['id'] == bookingId, orElse: () => {});

      if (bookingMap.isEmpty) {
        _showErrorDialog('Booking details not found.');
        return;
      }

      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();

      if (!bookingDoc.exists) {
        _showErrorDialog('Booking details not found in database.');
        return;
      }

      final bookingModel = BookingModel.fromFirestore(bookingDoc);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrackBookingPage(booking: bookingModel),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error loading booking details: ${e.toString()}');
    }
  }

  Future<void> _sendRatingNotification(
      String providerId, String serviceName, int rating) async {
    try {
      await _firestore.collection('notifications').add({
        'provider_id': providerId,
        'title': 'You got $rating ${rating == 1 ? 'star' : 'stars'} ${rating >= 2.5 ? '🎉' : '😔'}',
        'message': 'A customer rated your service "$serviceName" with $rating ${rating == 1 ? 'star' : 'stars'}!',
        'timestamp': FieldValue.serverTimestamp(),
        'is_read': false,
        'type': 'rating',
      });
    } catch (e) {
      print('Error sending notification: ${e.toString()}');
    }
  }

  void _showRatingBottomSheet(String bookingId, String providerId,
      String serviceId, String serviceName) {
    int rating = 0;
    final TextEditingController feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Rate Your Experience',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'How would you rate this service?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  rating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  index < rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 40,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: feedbackController,
                        decoration: InputDecoration(
                          labelText: 'Share your feedback (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.blue.shade800, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (rating == 0) {
                              ScaffoldMessenger.of(bottomSheetContext)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a rating'),
                                ),
                              );
                              return;
                            }

                            try {
                              final user = _auth.currentUser;
                              if (user == null) return;

                              showDialog(
                                context: bottomSheetContext,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              await _firestore.collection('ratings').add({
                                'booking_id': bookingId,
                                'provider_id': providerId,
                                'service_id': serviceId,
                                'user_id': user.uid,
                                'rating': rating,
                                'feedback': feedbackController.text,
                                'created_at': FieldValue.serverTimestamp(),
                              });

                              await _sendRatingNotification(
                                  providerId, serviceName, rating);

                              Navigator.pop(bottomSheetContext);
                              Navigator.pop(bottomSheetContext);
                              _fetchBookings();

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Thank you for your feedback!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              Navigator.pop(bottomSheetContext);
                              _showErrorDialog(
                                  'Error submitting rating: ${e.toString()}');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Submit Rating',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserRatingWidget(dynamic rating, String? feedback) {
    final intRating = rating is double ? rating.toInt() : (rating as int);

    return InkWell(
      onTap: () {
        if (feedback != null && feedback.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Your Review'),
              content: Text(feedback),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your Rating: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < intRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            if (feedback != null && feedback.isNotEmpty)
              const Icon(
                Icons.chat_bubble_outline,
                size: 14,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'declined':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0F3966),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (Route route) => false);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const AppBarTitle(text: "My Bookings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? _buildEmptyState()
          : _buildBookingsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your bookings will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text('Browse Services', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/userviewservicespage', (Route route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        final bookingDate = (booking['booking_date'] as Timestamp).toDate();
        final formattedDate = DateFormat('dd MMM yyyy').format(bookingDate);
        final formattedTime = DateFormat('hh:mm a').format(bookingDate);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 18, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_currentStatus(booking)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _getStatusColor(_currentStatus(booking))),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentStatus(booking).toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(_currentStatus(booking)),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (_refundStatus(booking) == 'processed')
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  'REFUNDED',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FutureBuilder<String>(
                        future: _getWorkSampleImage(booking['work_sample']),
                        builder: (context, snapshot) {
                          final imageUrl = snapshot.data ?? booking['work_sample'] ?? '';

                          if (imageUrl.isEmpty) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.home_repair_service, color: Colors.grey),
                            );
                          }

                          return Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return FutureBuilder<String>(
                                future: _imageService.suggestPlaceholderImage('Service'),
                                builder: (context, placeholderSnapshot) {
                                  if (placeholderSnapshot.hasData) {
                                    return Image.network(
                                      placeholderSnapshot.data!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                                Icons.home_repair_service,
                                                color: Colors.grey),
                                          ),
                                    );
                                  }
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.home_repair_service,
                                        color: Colors.grey),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['service_name'] ?? 'Unknown Service',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: FutureBuilder<String>(
                                  future: _getProviderProfileImage(booking['provider_profile']),
                                  builder: (context, snapshot) {
                                    final imageUrl = snapshot.data ?? booking['provider_profile'] ?? '';

                                    if (imageUrl.isEmpty) {
                                      return Container(
                                        width: 32,
                                        height: 32,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.person,
                                            color: Colors.grey, size: 20),
                                      );
                                    }

                                    return Image.network(
                                      imageUrl,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: 32,
                                          height: 32,
                                          color: Colors.grey.shade200,
                                          child: Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return FutureBuilder<String>(
                                          future: _imageService.suggestPlaceholderImage('Person'),
                                          builder: (context, placeholderSnapshot) {
                                            if (placeholderSnapshot.hasData) {
                                              return Image.network(
                                                placeholderSnapshot.data!,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      color: Colors.grey.shade200,
                                                      child: const Icon(
                                                          Icons.person,
                                                          color: Colors.grey,
                                                          size: 20),
                                                    ),
                                              );
                                            }
                                            return Container(
                                              width: 32,
                                              height: 32,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.person,
                                                  color: Colors.grey, size: 20),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                booking['provider_name'] ?? 'Unknown Provider',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '₹${booking['hourly_rate']}/hr · ${booking['duration_hours']} ${booking['duration_hours'] == 1 ? 'hour' : 'hours'}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${booking['total_cost']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: booking['payment_status'] == 'paid'
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking['payment_status'] == 'paid' ? 'PAID' : 'UNPAID',
                              style: TextStyle(
                                color: booking['payment_status'] == 'paid'
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          if (booking['user_rating'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _buildUserRatingWidget(
                                booking['user_rating'],
                                booking['user_feedback'],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isActiveBooking(booking)) ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.call, color: Colors.blue),
                        label: const Text('Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () => _makePhoneCall(booking['provider_phone']),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.location_on, color: Colors.white70),
                        label: const Text('Track Order'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade50,
                          backgroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () => _trackOrder(booking['id']),
                      ),
                    ]
                    else if (_isCompletedWithoutRating(booking)) ...[
                      TextButton.icon(
                        icon: Icon(Icons.star, color: Colors.white),
                        label: const Text('Rate Us'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xffFABB02),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () => _showRatingBottomSheet(
                          booking['id'],
                          booking['provider_id'],
                          booking['service_id'],
                          booking['service_name'],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.visibility, color: Colors.white70),
                        label: const Text('View Details'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade50,
                          backgroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () => _trackOrder(booking['id']),
                      ),
                    ]
                    else ...[
                        TextButton.icon(
                          icon: const Icon(Icons.visibility, color: Colors.white70),
                          label: const Text('View Details'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade50,
                            backgroundColor: Colors.blue.shade800,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () => _trackOrder(booking['id']),
                        ),
                      ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}