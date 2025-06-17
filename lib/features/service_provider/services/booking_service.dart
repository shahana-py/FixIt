// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../models/booking_model.dart';
//
// class BookingService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
//
//   // Get stream of bookings for current provider based on filter
//   Stream<List<BookingModel>> getProviderBookings(String filter) {
//     // Convert filter names to status values for querying
//     Map<String, List<String>> filterToStatus = {
//       'All': [], // Empty list means no filter
//       'Pending': ['pending', 'pending_payment'],
//       'Completed': ['completed']
//     };
//
//     List<String> statusesToQuery = filterToStatus[filter] ?? [];
//
//     Query query = _firestore.collection('bookings')
//         .where('provider_id', isEqualTo: currentUserId);
//
//     // Apply status filter if not showing all
//     if (statusesToQuery.isNotEmpty) {
//       query = query.where('status', whereIn: statusesToQuery);
//     }
//
//     // Order by booking date
//     query = query.orderBy('booking_date', descending: true);
//
//     return query.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         // Create a map with the document data and add the id
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         data['id'] = doc.id; // Add the document ID to the data map
//
//         return BookingModel.fromFirestore(data);
//       }).toList();
//     });
//   }
//
//   // Update booking status when accepting
//   Future<void> acceptBooking(String bookingId) async {
//     try {
//       await _firestore.collection('bookings').doc(bookingId).update({
//         'status': 'confirmed',
//       });
//     } catch (e) {
//       throw Exception('Error accepting booking: $e');
//     }
//   }
//
//   // Update booking status when declining
//   Future<void> declineBooking(String bookingId) async {
//     try {
//       await _firestore.collection('bookings').doc(bookingId).update({
//         'status': 'declined',
//       });
//     } catch (e) {
//       throw Exception('Error declining booking: $e');
//     }
//   }
//
//   // This method is no longer needed as we're fetching user details directly in the UI
//   // But keeping it for backward compatibility
//   Future<void> fetchUserDetailsForBooking(BookingModel booking) async {
//     if (booking.userName.isEmpty) {
//       try {
//         final userDoc = await _firestore.collection('users').doc(booking.userId).get();
//         if (userDoc.exists) {
//           final userData = userDoc.data() as Map<String, dynamic>;
//
//           // Update the booking with user details
//           await _firestore.collection('bookings').doc(booking.id).update({
//             'user_name': userData['name'] ?? 'Unknown User',
//             'address': userData['address'] ?? 'Unknown Location',
//             'user_phone': userData['phone'] ?? '',
//           });
//         }
//       } catch (e) {
//         print('Error fetching user details: $e');
//       }
//     }
//   }
// }

//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../models/booking_model.dart';
//
// class BookingService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
//
//   // Get stream of bookings for current provider based on filter
//   Stream<List<BookingModel>> getProviderBookings(String filter) {
//     // Convert filter names to status values for querying
//     Map<String, List<String>> filterToStatus = {
//       'All': [], // Empty list means no filter
//       'Pending': ['pending', 'pending_payment'],
//       'Active': ['confirmed', 'accepted', 'in_progress','dispatched','arrived'], // Added mapping for Active
//       'Completed': ['completed'],
//       'Declined': ['declined'] // Added mapping for Declined
//     };
//
//     List<String> statusesToQuery = filterToStatus[filter] ?? [];
//
//     Query query = _firestore.collection('bookings')
//         .where('provider_id', isEqualTo: currentUserId);
//
//     // Apply status filter if not showing all
//     if (statusesToQuery.isNotEmpty) {
//       query = query.where('status', whereIn: statusesToQuery);
//     }
//
//     // Order by booking date
//     query = query.orderBy('booking_date', descending: true);
//
//     return query.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         // Create a map with the document data and add the id
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         data['id'] = doc.id; // Add the document ID to the data map
//
//         return BookingModel.fromFirestore(data);
//       }).toList();
//     });
//   }
//
//   // Update booking status when accepting
//   Future<void> acceptBooking(String bookingId) async {
//     try {
//       await _firestore.collection('bookings').doc(bookingId).update({
//         'status': 'confirmed',
//       });
//     } catch (e) {
//       throw Exception('Error accepting booking: $e');
//     }
//   }
//
//   // Update booking status when declining
//   Future<void> declineBooking(String bookingId) async {
//     try {
//       await _firestore.collection('bookings').doc(bookingId).update({
//         'status': 'declined',
//       });
//     } catch (e) {
//       throw Exception('Error declining booking: $e');
//     }
//   }
//
//   // This method is no longer needed as we're fetching user details directly in the UI
//   // But keeping it for backward compatibility
//   Future<void> fetchUserDetailsForBooking(BookingModel booking) async {
//     if (booking.userName.isEmpty) {
//       try {
//         final userDoc = await _firestore.collection('users').doc(booking.userId).get();
//         if (userDoc.exists) {
//           final userData = userDoc.data() as Map<String, dynamic>;
//
//           // Update the booking with user details
//           await _firestore.collection('bookings').doc(booking.id).update({
//             'user_name': userData['name'] ?? 'Unknown User',
//             'address': userData['address'] ?? 'Unknown Location',
//             'user_phone': userData['phone'] ?? '',
//           });
//         }
//       } catch (e) {
//         print('Error fetching user details: $e');
//       }
//     }
//   }
// }


//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../models/booking_model.dart';
//
// class BookingService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
//
//   Stream<List<BookingModel>> getProviderBookings(String filter) {
//     Map<String, List<String>> filterToStatus = {
//       'All': [],
//       'Pending': ['pending', 'pending_payment'],
//       'Active': ['confirmed', 'accepted', 'in_progress', 'dispatched', 'arrived'],
//       'Completed': ['completed'],
//       'Declined': ['declined'],
//     };
//
//     List<String> statusesToQuery = filterToStatus[filter] ?? [];
//
//     Query<Map<String, dynamic>> query = _firestore
//         .collection('bookings')
//         .where('provider_id', isEqualTo: currentUserId);
//
//     if (statusesToQuery.isNotEmpty) {
//       query = query.where('status', whereIn: statusesToQuery);
//     }
//
//     query = query.orderBy('booking_date', descending: true);
//
//     return query.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data(); // ✅ Get Map<String, dynamic>
//         data['id'] = doc.id;      // ✅ Add document ID manually
//         return BookingModel.fromFirestore(data as DocumentSnapshot<Object?>); // ✅ Pass map, not doc
//       }).toList();
//     });
//   }
//
//
//   // Accept booking
//   Future<void> acceptBooking(String bookingId) async {
//     try {
//       await _firestore.collection('bookings').doc(bookingId).update({
//         'status': 'confirmed',
//       });
//     } catch (e) {
//       throw Exception('Error accepting booking: $e');
//     }
//   }
//
//   // Decline booking
//   Future<void> declineBooking(String bookingId) async {
//     try {
//       await _firestore.collection('bookings').doc(bookingId).update({
//         'status': 'declined',
//       });
//     } catch (e) {
//       throw Exception('Error declining booking: $e');
//     }
//   }
//
//   // Fetch and update user details in booking if not already available
//   Future<void> fetchUserDetailsForBooking(BookingModel booking) async {
//     if (booking.userName.isEmpty) {
//       try {
//         final userDoc = await _firestore.collection('users').doc(booking.userId).get();
//         if (userDoc.exists) {
//           final userData = userDoc.data() as Map<String, dynamic>;
//
//           await _firestore.collection('bookings').doc(booking.id).update({
//             'user_name': userData['name'] ?? 'Unknown User',
//             'address': userData['address'] ?? 'Unknown Location',
//             'user_phone': userData['phone'] ?? '',
//           });
//         }
//       } catch (e) {
//         print('Error fetching user details: $e');
//       }
//     }
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Stream<List<BookingModel>> getProviderBookings(String filter) {
    Map<String, List<String>> filterToStatus = {
      'all': [], // Changed to lowercase to match _getFilterStatus
      'pending': ['pending', 'pending_payment'],
      'confirmed': ['confirmed', 'accepted', 'in_progress', 'dispatched', 'arrived'],
      'completed': ['completed'],
      'declined': ['declined'],
    };

    List<String> statusesToQuery = filterToStatus[filter] ?? [];

    Query<Map<String, dynamic>> query = _firestore
        .collection('bookings')
        .where('provider_id', isEqualTo: currentUserId);

    if (statusesToQuery.isNotEmpty) {
      query = query.where('status', whereIn: statusesToQuery);
    }

    query = query.orderBy('booking_date', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Here's the fix: pass the DocumentSnapshot directly to the fromFirestore factory
        return BookingModel.fromFirestore(doc);
      }).toList();
    });
  }

  // Accept booking
  Future<void> acceptBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'confirmed',
      });
    } catch (e) {
      throw Exception('Error accepting booking: $e');
    }
  }

  // Decline booking
  Future<void> declineBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'declined',
      });
    } catch (e) {
      throw Exception('Error declining booking: $e');
    }
  }

  // Fetch and update user details in booking if not already available
  Future<void> fetchUserDetailsForBooking(BookingModel booking) async {
    if (booking.userName.isEmpty) {
      try {
        final userDoc = await _firestore.collection('users').doc(booking.userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          await _firestore.collection('bookings').doc(booking.id).update({
            'user_name': userData['name'] ?? 'Unknown User',
            'address': userData['address'] ?? 'Unknown Location',
            'user_phone': userData['phone'] ?? '',
          });
        }
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }
  }
}
