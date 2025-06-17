//
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
//
// class ProviderJobsPage extends StatefulWidget {
//   const ProviderJobsPage({super.key});
//
//   @override
//   State<ProviderJobsPage> createState() => _ProviderJobsPageState();
// }
//
// class _ProviderJobsPageState extends State<ProviderJobsPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         iconTheme: IconThemeData(color: Colors.white,size: 24),
//         leading: IconButton(
//           onPressed: (){
//             Navigator.pushNamedAndRemoveUntil(context, '/serviceProviderHome', (Route route)=>false);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//
//         title: AppBarTitle(text: "My Jobs"),
//         actions: [
//           Icon(Icons.notifications,),
//           SizedBox(width: 10),
//           Icon(Icons.search,),
//           SizedBox(width: 10),
//
//         ],
//       ),
//       body: Text("Your Jobs"),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// import '../models/booking_model.dart';
// import '../services/booking_service.dart';
//
//
// class ProviderJobsPage extends StatefulWidget {
//   const ProviderJobsPage({Key? key}) : super(key: key);
//
//   @override
//   State<ProviderJobsPage> createState() => _ProviderJobsPageState();
// }
//
// class _ProviderJobsPageState extends State<ProviderJobsPage> {
//   String _selectedFilter = 'Active'; // Default filter
//   final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//   late BookingService _bookingService;
//
//   @override
//   void initState() {
//     super.initState();
//     _bookingService = BookingService();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text(
//           'My Jobs',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Filter tabs
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildFilterTab('Active'),
//                 _buildFilterTab('Job offers'),
//                 _buildFilterTab('Completed'),
//               ],
//             ),
//           ),
//
//           // Divider
//           const Divider(height: 1, thickness: 1),
//
//           // Bookings list
//           Expanded(
//             child: _buildBookingsList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterTab(String filterName) {
//     bool isSelected = _selectedFilter == filterName;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedFilter = filterName;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: isSelected ? Colors.red : Colors.transparent,
//               width: 2.0,
//             ),
//           ),
//         ),
//         child: Text(
//           filterName,
//           style: TextStyle(
//             color: isSelected ? Colors.red : Colors.blue[900],
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookingsList() {
//     return StreamBuilder<List<BookingModel>>(
//       stream: _bookingService.getProviderBookings(_selectedFilter),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (snapshot.hasError) {
//           // return Center(child: Text('Error: ${snapshot.error}'));
//           print('Error: ${snapshot.error}');
//         }
//
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//             child: Text(
//               'No ${_selectedFilter.toLowerCase()} bookings found',
//               style: const TextStyle(fontSize: 16),
//             ),
//           );
//         }
//
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             var booking = snapshot.data![index];
//             // Ensure we have user details
//             _bookingService.fetchUserDetailsForBooking(booking);
//             return _buildBookingCard(booking);
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildBookingCard(BookingModel booking) {
//     String serviceName = booking.serviceName;
//     String userName = booking.userName;
//     String location = booking.address;
//     bool isJobOffer = _selectedFilter == 'Job offers';
//
//     // Format date and time
//     String formattedDate = DateFormat('dd MMM, yyyy').format(booking.bookingDate);
//     String formattedTime = '${DateFormat('hh:mm a').format(booking.bookingDate)} - ${DateFormat('hh:mm a').format(booking.bookingDate.add(Duration(hours: booking.durationHours)))}';
//
//     // Get appropriate service icon
//     IconData serviceIcon = _getServiceIcon(serviceName);
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Service icon
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     serviceIcon,
//                     size: 30,
//                     color: Colors.blue[900],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//
//                 // Service details
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         serviceName,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[900],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
//                           const SizedBox(width: 4),
//                           Text(
//                             formattedDate,
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
//                           const SizedBox(width: 4),
//                           Text(
//                             formattedTime,
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Status indicator for new offers
//                 if (isJobOffer)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       'New offer',
//                       style: TextStyle(
//                         color: Colors.blue[900],
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             // User details
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // User avatar
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: Colors.grey[300],
//                   child: Text(
//                     userName.isNotEmpty ? userName[0].toUpperCase() : '?',
//                     style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//
//                 // User name and location
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         userName,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[900],
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
//                           const SizedBox(width: 4),
//                           Text(
//                             location,
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             // Action buttons for job offers
//             if (isJobOffer)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: Row(
//                   children: [
//                     // Decline button
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => _handleDeclineBooking(booking.id),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.grey[800],
//                           side: const BorderSide(color: Colors.grey),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text('Decline'),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//
//                     // Accept button
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () => _handleAcceptBooking(booking.id),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepOrange,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text('Accept'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   IconData _getServiceIcon(String serviceName) {
//     serviceName = serviceName.toLowerCase();
//
//     if (serviceName.contains('ac') || serviceName.contains('air')) {
//       return Icons.ac_unit;
//     } else if (serviceName.contains('bath') || serviceName.contains('plumb')) {
//       return Icons.bathtub;
//     } else if (serviceName.contains('clean')) {
//       return Icons.cleaning_services;
//     } else if (serviceName.contains('electric')) {
//       return Icons.electrical_services;
//     } else if (serviceName.contains('paint')) {
//       return Icons.format_paint;
//     } else {
//       return Icons.handyman;
//     }
//   }
//
//   // Handle accept booking action
//   Future<void> _handleAcceptBooking(String bookingId) async {
//     try {
//       await _bookingService.acceptBooking(bookingId);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking accepted successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error accepting booking: $e')),
//       );
//     }
//   }
//
//   // Handle decline booking action
//   Future<void> _handleDeclineBooking(String bookingId) async {
//     try {
//       await _bookingService.declineBooking(bookingId);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking declined')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error declining booking: $e')),
//       );
//     }
//   }
// }



//
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// import '../models/booking_model.dart';
// import '../services/booking_service.dart';
// import 'booking_details_page.dart';
//
// class ProviderJobsPage extends StatefulWidget {
//   const ProviderJobsPage({Key? key}) : super(key: key);
//
//   @override
//   State<ProviderJobsPage> createState() => _ProviderJobsPageState();
// }
//
// class _ProviderJobsPageState extends State<ProviderJobsPage> {
//   String _selectedFilter = 'All'; // Default filter
//   final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//   late BookingService _bookingService;
//
//   @override
//   void initState() {
//     super.initState();
//     _bookingService = BookingService();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: AppBarTitle(text: "My Jobs"),
//         backgroundColor: const Color(0xff0F3966), // Updated primary color
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Filter tabs
//           Container(
//             color: const Color(0xff0F3966), // Updated primary color
//             padding: EdgeInsets.zero, // Removed horizontal padding
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildFilterTab('All'),
//                   _buildFilterTab('Pending'),
//                   _buildFilterTab('Active'),
//                   _buildFilterTab('Completed'),
//                   _buildFilterTab('Declined'),
//                 ],
//               ),
//             ),
//           ),
//
//           // Divider
//           const Divider(height: 1, thickness: 1),
//
//           // Bookings list
//           Expanded(
//             child: _buildBookingsList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterTab(String filterName) {
//     bool isSelected = _selectedFilter == filterName;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedFilter = filterName;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: isSelected ? Colors.blue : Colors.transparent,
//               width: 2.0,
//             ),
//           ),
//         ),
//         child: Text(
//           filterName,
//           style: TextStyle(
//             color: isSelected ? Colors.blue : Colors.white.withOpacity(0.7),
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookingsList() {
//     // Use the existing BookingService with the selected filter
//     return StreamBuilder<List<BookingModel>>(
//       stream: _bookingService.getProviderBookings(_selectedFilter),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (snapshot.hasError) {
//           print('Error: ${snapshot.error}');
//           return Center(
//             child: Text('Error loading bookings: ${snapshot.error}'),
//           );
//         }
//
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//             child: Text(
//               'No ${_selectedFilter.toLowerCase()} bookings found',
//               style: const TextStyle(fontSize: 16),
//             ),
//           );
//         }
//
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             var booking = snapshot.data![index];
//             return FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance.collection('users').doc(booking.userId).get(),
//               builder: (context, userSnapshot) {
//                 String userName = 'Unknown User';
//                 String userAddress = 'Unknown Location';
//                 String profileImageUrl = '';
//
//                 if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
//                   final userData = userSnapshot.data!.data() as Map<String, dynamic>;
//                   userName = userData['name'] ?? 'Unknown User';
//                   userAddress = userData['address'] ?? 'Unknown Location';
//                   profileImageUrl = userData['profileImageUrl'] ?? '';
//                 }
//
//                 return GestureDetector(
//                   onTap: () {
//                     // Navigate to booking details page
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BookingDetailsPage(
//                           booking: booking.copyWith(
//                             userName: userName,
//                             address: userAddress,
//                           ),
//                           profileImageUrl: profileImageUrl,
//                         ),
//                       ),
//                     );
//                   },
//                   child: _buildBookingCard(
//                     booking.copyWith(
//                       userName: userName,
//                       address: userAddress,
//                     ),
//                     profileImageUrl,
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildBookingCard(BookingModel booking, String profileImageUrl) {
//     String serviceName = booking.serviceName;
//     String userName = booking.userName;
//     String location = booking.address;
//
//     // Update status checks to match your actual status values
//     bool isPending = booking.status == 'pending' || booking.status == 'pending_payment';
//     bool isConfirmed = booking.status == 'confirmed';
//     bool isDeclined = booking.status == 'declined';
//
//     // Format date and time
//     String formattedDate = DateFormat('dd MMM, yyyy').format(booking.bookingDate);
//     String formattedTime = '${DateFormat('hh:mm a').format(booking.bookingDate)} - ${DateFormat('hh:mm a').format(booking.bookingDate.add(Duration(hours: booking.durationHours)))}';
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Service image from Firestore instead of icon
//                 FutureBuilder<DocumentSnapshot>(
//                   future: FirebaseFirestore.instance.collection('services').doc(booking.serviceId).get(),
//                   builder: (context, serviceSnapshot) {
//                     String workSampleUrl = '';
//
//                     if (serviceSnapshot.hasData && serviceSnapshot.data != null && serviceSnapshot.data!.exists) {
//                       final serviceData = serviceSnapshot.data!.data() as Map<String, dynamic>;
//                       workSampleUrl = serviceData['work_sample'] ?? '';
//                     }
//
//                     return Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: workSampleUrl.isNotEmpty
//                           ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           workSampleUrl,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 value: loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                     : null,
//                                 strokeWidth: 2,
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) => Icon(
//                             _getServiceIcon(serviceName),
//                             size: 30,
//                             color: const Color(0xff0F3966),
//                           ),
//                         ),
//                       )
//                           : Icon(
//                         _getServiceIcon(serviceName),
//                         size: 30,
//                         color: const Color(0xff0F3966),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(width: 16),
//
//                 // Service details
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         serviceName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xff0F3966),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
//                           const SizedBox(width: 4),
//                           Text(
//                             formattedDate,
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
//                           const SizedBox(width: 4),
//                           Text(
//                             formattedTime,
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Status indicator
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(booking.paymentStatus),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     booking.paymentStatus.toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             // User details
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // User avatar
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: Colors.grey[300],
//                   backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
//                   child: profileImageUrl.isEmpty ? Text(
//                     userName.isNotEmpty ? userName[0].toUpperCase() : '?',
//                     style: const TextStyle(color: Color(0xff0F3966), fontWeight: FontWeight.bold),
//                   ) : null,
//                 ),
//                 const SizedBox(width: 12),
//
//                 // User name and location
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         userName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xff0F3966),
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
//                           const SizedBox(width: 4),
//                           Text(
//                             location,
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             // Action buttons for pending jobs
//             if (isPending)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: Row(
//                   children: [
//                     // Decline button
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () => _handleDeclineBooking(booking.id),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           foregroundColor: Colors.white,
//
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text('Decline'),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//
//                     // Accept button
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () => _handleAcceptBooking(booking.id),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text('Accept'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'unpaid':
//
//         return Colors.orange;
//       case 'confirmed':
//       case 'accepted':
//       case 'completed':
//         return Colors.green;
//
//
//
//       default:
//         return Colors.grey;
//     }
//   }
//
//   IconData _getServiceIcon(String serviceName) {
//     serviceName = serviceName.toLowerCase();
//
//     if (serviceName.contains('ac') || serviceName.contains('air')) {
//       return Icons.ac_unit;
//     } else if (serviceName.contains('bath') || serviceName.contains('plumb')) {
//       return Icons.bathtub;
//     } else if (serviceName.contains('clean')) {
//       return Icons.cleaning_services;
//     } else if (serviceName.contains('electric')) {
//       return Icons.electrical_services;
//     } else if (serviceName.contains('paint')) {
//       return Icons.format_paint;
//     } else {
//       return Icons.handyman;
//     }
//   }
//
//   // Handle accept booking action
//   Future<void> _handleAcceptBooking(String bookingId) async {
//     try {
//       await _bookingService.acceptBooking(bookingId);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking accepted successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error accepting booking: $e')),
//       );
//     }
//   }
//
//   // Handle decline booking action
//   Future<void> _handleDeclineBooking(String bookingId) async {
//     try {
//       await _bookingService.declineBooking(bookingId);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking declined')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error declining booking: $e')),
//       );
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'booking_details_page.dart';

class ProviderJobsPage extends StatefulWidget {
  const ProviderJobsPage({Key? key}) : super(key: key);

  @override
  State<ProviderJobsPage> createState() => _ProviderJobsPageState();
}

class _ProviderJobsPageState extends State<ProviderJobsPage> {
  String _selectedFilter = 'All'; // Default filter
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late BookingService _bookingService;

  @override
  void initState() {
    super.initState();
    _bookingService = BookingService();
  }

  // Convert UI filter names to database status values
  String _getFilterStatus(String filter) {
    switch (filter) {

      case 'Active':
        return 'confirmed';
      case 'Completed':
        return 'completed';
      case 'Declined':
        return 'declined';
      case 'All':
      default:
        return 'all'; // Special case handled in BookingService
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
    leading: IconButton(
          onPressed: (){
            Navigator.pushNamedAndRemoveUntil(context, '/serviceProviderHome', (Route route)=>false);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: const AppBarTitle(text: "My Jobs"),
        backgroundColor: const Color(0xff0F3966), // Updated primary color
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: const Color(0xff0F3966), // Updated primary color
            padding: EdgeInsets.zero, // Removed horizontal padding
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 35,
                children: [
                  _buildFilterTab('All'),

                  _buildFilterTab('Active'),
                  _buildFilterTab('Completed'),
                  _buildFilterTab('Declined'),
                ],
              ),
            ),
          ),

          // Divider
          const Divider(height: 1, thickness: 1),

          // Bookings list
          Expanded(
            child: _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filterName) {
    bool isSelected = _selectedFilter == filterName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          filterName,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    // Convert UI filter to database status value
    String filterStatus = _getFilterStatus(_selectedFilter);

    // Use the BookingService with the converted filter
    return StreamBuilder<List<BookingModel>>(
      stream: _bookingService.getProviderBookings(filterStatus),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(
            child: Text('Error loading bookings: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No ${_selectedFilter.toLowerCase()} bookings found',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var booking = snapshot.data![index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(booking.userId).get(),
              builder: (context, userSnapshot) {
                String userName = 'Unknown User';
                String userAddress = 'Unknown Location';
                String profileImageUrl = '';

                if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data();
                  if (userData != null) {
                    // This is the correct way to handle the data
                    final data = userData as Map<String, dynamic>;
                    userName = data['name'] ?? 'Unknown User';
                    userAddress = data['address'] ?? 'Unknown Location';
                    profileImageUrl = data['profileImageUrl'] ?? '';
                  }
                }

                return GestureDetector(
                  onTap: () {
                    // Navigate to booking details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsPage(
                          booking: booking.copyWith(
                            userName: userName,
                            address: userAddress,
                          ),
                          profileImageUrl: profileImageUrl,
                        ),
                      ),
                    );
                  },
                  child: _buildBookingCard(
                    booking.copyWith(
                      userName: userName,
                      address: userAddress,
                    ),
                    profileImageUrl,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }



  Widget _buildBookingCard(BookingModel booking, String profileImageUrl) {
    String serviceName = booking.serviceName;
    String userName = booking.userName;
    String location = booking.address;

    // Update status checks to match your actual status values
    bool isPending = booking.status == 'pending' || booking.status == 'pending_payment';
    bool isConfirmed = booking.status == 'confirmed';
    bool isDeclined = booking.status == 'declined';

    // Format date and time
    String formattedDate = DateFormat('dd MMM, yyyy').format(booking.bookingDate);
    String formattedTime = '${DateFormat('hh:mm a').format(booking.bookingDate)} - ${DateFormat('hh:mm a').format(booking.bookingDate.add(Duration(hours: booking.durationHours)))}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service image from Firestore instead of icon
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('services').doc(booking.serviceId).get(),
                  builder: (context, serviceSnapshot) {
                    String workSampleUrl = '';

                    if (serviceSnapshot.hasData && serviceSnapshot.data != null && serviceSnapshot.data!.exists) {
                      final serviceData = serviceSnapshot.data!.data();
                      if (serviceData != null) {
                        // This is the correct way to handle the data
                        final data = serviceData as Map<String, dynamic>;
                        workSampleUrl = data['work_sample'] ?? '';
                      }
                    }

                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: workSampleUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          workSampleUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getServiceIcon(serviceName),
                            size: 30,
                            color: const Color(0xff0F3966),
                          ),
                        ),
                      )
                          : Icon(
                        _getServiceIcon(serviceName),
                        size: 30,
                        color: const Color(0xff0F3966),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),

                // Service details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0F3966),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.paymentStatus),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    booking.paymentStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(),
            const SizedBox(height: 8),

            // User details
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                  child: profileImageUrl.isEmpty ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xff0F3966), fontWeight: FontWeight.bold),
                  ) : null,
                ),
                const SizedBox(width: 12),

                // User name and location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0F3966),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons for pending jobs
            if (isPending)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    // Decline button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleDeclineBooking(booking.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Accept button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAcceptBooking(booking.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'unpaid':
        return Colors.orange;
      case 'confirmed':
      case 'accepted':
      case 'completed':
      case 'paid':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String serviceName) {
    serviceName = serviceName.toLowerCase();

    if (serviceName.contains('ac') || serviceName.contains('air')) {
      return Icons.ac_unit;
    } else if (serviceName.contains('bath') || serviceName.contains('plumb')) {
      return Icons.bathtub;
    } else if (serviceName.contains('clean')) {
      return Icons.cleaning_services;
    } else if (serviceName.contains('electric')) {
      return Icons.electrical_services;
    } else if (serviceName.contains('paint')) {
      return Icons.format_paint;
    } else {
      return Icons.handyman;
    }
  }

  // Handle accept booking action
  Future<void> _handleAcceptBooking(String bookingId) async {
    try {
      await _bookingService.acceptBooking(bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking accepted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting booking: $e')),
        );
      }
    }
  }

  // Handle decline booking action
  Future<void> _handleDeclineBooking(String bookingId) async {
    try {
      await _bookingService.declineBooking(bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking declined')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error declining booking: $e')),
        );
      }
    }
  }
}