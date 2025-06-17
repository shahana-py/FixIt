// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../../../core/shared/services/image_service.dart';
// import '../../../core/utils/custom_texts/app_bar_text.dart';
//
// class ViewAllBookingsPage extends StatefulWidget {
//   @override
//   _ViewAllBookingsPageState createState() => _ViewAllBookingsPageState();
// }
//
// class _ViewAllBookingsPageState extends State<ViewAllBookingsPage> {
//   final ImageService _imageService = ImageService();
//
//   Future<List<Map<String, dynamic>>> fetchBookings() async {
//     final bookingsSnapshot =
//     await FirebaseFirestore.instance.collection('bookings').get();
//
//     List<Map<String, dynamic>> bookingDetails = [];
//
//     for (var bookingDoc in bookingsSnapshot.docs) {
//       final bookingData = bookingDoc.data();
//       final bookingId = bookingDoc.id;
//
//       // Fetch user details
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .where('uid', isEqualTo: bookingData['user_id'])
//           .get();
//
//       final userData = userDoc.docs.isNotEmpty ? userDoc.docs.first.data() : {};
//
//       // Fetch provider details
//       final providerDoc = await FirebaseFirestore.instance
//           .collection('service provider')
//           .where('uid', isEqualTo: bookingData['provider_id'])
//           .get();
//
//       final providerData =
//       providerDoc.docs.isNotEmpty ? providerDoc.docs.first.data() : {};
//
//       // Fetch rating details
//       final ratingDoc = await FirebaseFirestore.instance
//           .collection('ratings')
//           .where('booking_id', isEqualTo: bookingId)
//           .get();
//
//       final ratingData =
//       ratingDoc.docs.isNotEmpty ? ratingDoc.docs.first.data() : null;
//
//       bookingDetails.add({
//         'bookingId': bookingId,
//         'userName': userData['name'] ?? '',
//         'userPlace': userData['address'] ?? '',
//         'userProfilePic': userData['profileImageUrl'] ?? '',
//         'serviceName': bookingData['service_name'] ?? '',
//         'providerName': providerData['name'] ?? '',
//         'providerProfilePic': providerData['profileImage'] ?? '',
//         'bookingDateTime': bookingData['booking_date']?.toDate(),
//         'status': bookingData['status'] ?? '',
//         'paymentStatus': bookingData['payment_status'] ?? '',
//         'totalCost': bookingData['total_cost'] ?? '',
//         'durationHours': bookingData['duration_hours'] ?? '',
//         'hourlyRate': bookingData['hourly_rate'] ?? '',
//         'notes': bookingData['notes'] ?? '',
//         'rating': ratingData?['rating'],
//       });
//     }
//
//     return bookingDetails;
//   }
//
//   String formatDateTime(DateTime? dateTime) {
//     if (dateTime == null) return '';
//     return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
//   }
//
//   Widget _buildShimmerBookingCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(width: 120, height: 12, color: Colors.grey[300]),
//                     const SizedBox(height: 8),
//                     Container(width: 80, height: 10, color: Colors.grey[300]),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Container(width: double.infinity, height: 10, color: Colors.grey[300]),
//             const SizedBox(height: 8),
//             Container(width: 200, height: 10, color: Colors.grey[300]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xff0F3966),
//         title: const AppBarTitle(text: "User Bookings"),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: fetchBookings(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return ListView.builder(
//               itemCount: 6,
//               itemBuilder: (context, index) => _buildShimmerBookingCard(),
//             );
//           }
//
//           if (snapshot.hasError) {
//             return const Center(child: Text('Something went wrong'));
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No bookings found'));
//           }
//
//           final bookings = snapshot.data!;
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: bookings.length,
//             itemBuilder: (context, index) {
//               final booking = bookings[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 4,
//                 child: Theme(
//                   data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                   child: ExpansionTile(
//                     tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     collapsedShape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     title: Row(
//                       children: [
//                         CircleAvatar(
//                           backgroundImage: NetworkImage(booking['userProfilePic']),
//                           radius: 26,
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 booking['userName'],
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 booking['userPlace'],
//                                 style: const TextStyle(fontSize: 13, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     children: [
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             backgroundImage: NetworkImage(booking['providerProfilePic']),
//                             radius: 24,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               booking['providerName'],
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       _bookingDetailRow('Service', booking['serviceName']),
//                       _bookingDetailRow('Booking Date', formatDateTime(booking['bookingDateTime'])),
//                       _bookingDetailRow('Status', booking['status']),
//                       _bookingDetailRow('Payment Status', booking['paymentStatus']),
//                       _bookingDetailRow('Duration', '${booking['durationHours']} hrs'),
//                       _bookingDetailRow('Hourly Rate', '₹${booking['hourlyRate']}'),
//                       _bookingDetailRow('Total Cost', '₹${booking['totalCost']}'),
//                       if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
//                         _bookingDetailRow('Notes', booking['notes']),
//                       const SizedBox(height: 8),
//                       if (booking['rating'] != null)
//                         Row(
//                           children: [
//                             const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.w600)),
//                             ...List.generate(
//                               booking['rating'],
//                                   (index) => const Icon(Icons.star, color: Colors.amber, size: 20),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _bookingDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$title: ',
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/shared/services/image_service.dart';
import '../../../core/utils/custom_texts/app_bar_text.dart';

class ViewAllBookingsPage extends StatefulWidget {
  @override
  _ViewAllBookingsPageState createState() => _ViewAllBookingsPageState();
}

class _ViewAllBookingsPageState extends State<ViewAllBookingsPage> {
  final ImageService _imageService = ImageService();

  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final bookingsSnapshot =
    await FirebaseFirestore.instance.collection('bookings').get();

    List<Map<String, dynamic>> bookingDetails = [];

    for (var bookingDoc in bookingsSnapshot.docs) {
      final bookingData = bookingDoc.data();
      final bookingId = bookingDoc.id;

      // Fetch user details
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: bookingData['user_id'])
          .get();

      final userData = userDoc.docs.isNotEmpty ? userDoc.docs.first.data() : {};

      // Fetch provider details
      final providerDoc = await FirebaseFirestore.instance
          .collection('service provider')
          .where('uid', isEqualTo: bookingData['provider_id'])
          .get();

      final providerData =
      providerDoc.docs.isNotEmpty ? providerDoc.docs.first.data() : {};

      // Fetch rating details
      final ratingDoc = await FirebaseFirestore.instance
          .collection('ratings')
          .where('booking_id', isEqualTo: bookingId)
          .get();

      final ratingData =
      ratingDoc.docs.isNotEmpty ? ratingDoc.docs.first.data() : null;

      bookingDetails.add({
        'bookingId': bookingId,
        'userName': userData['name'] ?? '',
        'userPlace': userData['address'] ?? '',
        'userProfilePic': userData['profileImageUrl'] ?? '',
        'serviceName': bookingData['service_name'] ?? '',
        'providerName': providerData['name'] ?? '',
        'providerProfilePic': providerData['profileImage'] ?? '',
        'bookingDateTime': bookingData['booking_date']?.toDate(),
        'status': bookingData['status'] ?? '',
        'paymentStatus': bookingData['payment_status'] ?? '',
        'totalCost': bookingData['total_cost'] ?? '',
        'durationHours': bookingData['duration_hours'] ?? '',
        'hourlyRate': bookingData['hourly_rate'] ?? '',
        'notes': bookingData['notes'] ?? '',
        'rating': ratingData?['rating']?.toInt(), // Convert to int here
      });
    }

    return bookingDetails;
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  Widget _buildShimmerBookingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 12, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 10, color: Colors.grey[300]),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 10, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(width: 200, height: 10, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff0F3966),
        title: const AppBarTitle(text: "User Bookings"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => _buildShimmerBookingCard(),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(booking['userProfilePic']),
                          radius: 26,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['userName'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking['userPlace'],
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(booking['providerProfilePic']),
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              booking['providerName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _bookingDetailRow('Service', booking['serviceName']),
                      _bookingDetailRow('Booking Date', formatDateTime(booking['bookingDateTime'])),
                      _bookingDetailRow('Status', booking['status']),
                      _bookingDetailRow('Payment Status', booking['paymentStatus']),
                      _bookingDetailRow('Duration', '${booking['durationHours']} hrs'),
                      _bookingDetailRow('Hourly Rate', '₹${booking['hourlyRate']}'),
                      _bookingDetailRow('Total Cost', '₹${booking['totalCost']}'),
                      if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
                        _bookingDetailRow('Notes', booking['notes']),
                      const SizedBox(height: 8),
                      if (booking['rating'] != null)
                        Row(
                          children: [
                            const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.w600)),
                            ...List.generate(
                              5, // Always generate 5 stars
                                  (index) => Icon(
                                Icons.star,
                                color: index < (booking['rating'] ?? 0)
                                    ? Colors.amber
                                    : Colors.grey[300],
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _bookingDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
