// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
// import 'package:fixit/core/utils/custom_texts/main_text.dart';
// import 'package:flutter/material.dart';
//
// class FavoritesPage extends StatefulWidget {
//   const FavoritesPage({Key? key}) : super(key: key);
//
//   @override
//   State<FavoritesPage> createState() => _FavoritesPageState();
// }
//
// class _FavoritesPageState extends State<FavoritesPage> {
//   List<Map<String, dynamic>> _favoriteServices = [];
//   bool _isLoading = true;
//   Set<String> _favoriteServiceIds = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchFavoriteServices();
//   }
//
//   Future<void> _fetchFavoriteServices() async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }
//
//     try {
//       // First, get user's favorite service IDs
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();
//
//       List<String> favoriteIds = [];
//       if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
//         var userData = userDoc.data() as Map<String, dynamic>;
//         if (userData.containsKey('favorites') && userData['favorites'] is List) {
//           favoriteIds = List<String>.from(userData['favorites']);
//           _favoriteServiceIds = Set<String>.from(favoriteIds);
//         }
//       }
//
//       if (favoriteIds.isEmpty) {
//         setState(() {
//           _isLoading = false;
//           _favoriteServices = [];
//         });
//         return;
//       }
//
//       // Fetch all favorited services
//       List<Map<String, dynamic>> favoriteServices = [];
//
//       // Process in batches if there are many favorites
//       for (int i = 0; i < favoriteIds.length; i += 10) {
//         int end = (i + 10 < favoriteIds.length) ? i + 10 : favoriteIds.length;
//         List<String> batch = favoriteIds.sublist(i, end);
//
//         QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
//             .collection('services')
//             .where(FieldPath.documentId, whereIn: batch)
//             .get();
//
//         for (var doc in servicesSnapshot.docs) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//           // Get provider details
//           String providerId = data['provider_id'] ?? '';
//           Map<String, dynamic> providerData = {};
//
//           if (providerId.isNotEmpty) {
//             DocumentSnapshot providerDoc = await FirebaseFirestore.instance
//                 .collection('service provider')
//                 .doc(providerId)
//                 .get();
//
//             if (providerDoc.exists) {
//               providerData = providerDoc.data() as Map<String, dynamic>;
//             }
//           }
//
//           favoriteServices.add({
//             'id': doc.id,
//             'name': data['name'] ?? '',
//             'hourly_rate': data['hourly_rate'] ?? 0,
//             'rating': data['rating'] ?? 0,
//             'rating_count': data['rating_count'] ?? 0,
//             'work_sample': data['work_sample'] ?? '',
//             'work_samples': data['work_samples'] ?? [],
//             'provider_name': providerData['name'] ?? 'Unknown',
//             'provider_image': providerData['profileImage'] ?? '',
//             'provider_id': providerId,
//           });
//         }
//       }
//
//       setState(() {
//         _favoriteServices = favoriteServices;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching favorite services: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _toggleFavorite(String serviceId) async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//
//     setState(() {
//       if (_favoriteServiceIds.contains(serviceId)) {
//         _favoriteServiceIds.remove(serviceId);
//         _favoriteServices.removeWhere((service) => service['id'] == serviceId);
//       } else {
//         _favoriteServiceIds.add(serviceId);
//       }
//     });
//
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .update({
//         'favorites': _favoriteServiceIds.toList(),
//       });
//     } catch (e) {
//       print('Error updating favorites: $e');
//       // If update fails, refresh the list
//       await _fetchFavoriteServices();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         title: Text(
//           'My Favorites',
//           style: TextStyle(color: Colors.white),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _favoriteServices.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.favorite_border,
//               size: 80,
//               color: Colors.grey,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'No favorite services yet',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Add services to your favorites\nby clicking the heart icon',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       )
//           : Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Text(
//                 'Your Favorite Services',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xff0F3966),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.7,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: _favoriteServices.length,
//                 itemBuilder: (context, index) {
//                   final service = _favoriteServices[index];
//                   return _buildServiceCard(
//                     id: service['id'],
//                     providerId: service['provider_id'],
//                     name: service['provider_name'],
//                     service: service['name'],
//                     networkImage: service['work_sample'],
//                     rating: service['rating'].toDouble(),
//                     hourlyRate: service['hourly_rate'],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper method to build service card for favorites
//   Widget _buildServiceCard({
//     required String id,
//     required String providerId,
//     required String name,
//     required String service,
//     String? networkImage,
//     required double rating,
//     required int hourlyRate,
//   }) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 child: networkImage != null && networkImage.isNotEmpty
//                     ? Image.network(
//                   networkImage,
//                   height: 175,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Image.asset(
//                     "assets/images/Jhon_plumber5.jpeg",
//                     height: 175,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 )
//                     : Image.asset(
//                   "assets/images/Jhon_plumber5.jpeg",
//                   height: 175,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: GestureDetector(
//                   onTap: () {
//                     _toggleFavorite(id);
//                   },
//                   child: CircleAvatar(
//                     backgroundColor: Colors.white70,
//                     radius: 16,
//                     child: Icon(
//                       Icons.favorite,
//                       color: Colors.red,
//                       size: 18,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             name,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xff0F3966),
//                               fontSize: 16,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           SizedBox(height: 2),
//                           Text(
//                             service,
//                             style: TextStyle(color: Colors.black54),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(4),
//                       width: 47,
//                       height: 25,
//                       decoration: BoxDecoration(
//                         color: Colors.green[700],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.star, color: Colors.white, size: 16),
//                           SizedBox(width: 2),
//                           Text(
//                             "$rating",
//                             style: TextStyle(color: Colors.white, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 6),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "₹$hourlyRate/hr",
//                       style: TextStyle(
//                         color: Color(0xff0F3966),
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         // Navigate to service details page
//                         // You can add navigation to service details here
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Color(0xff0F3966),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           "Details",
//                           style: TextStyle(color: Colors.white, fontSize: 12),
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
import 'package:fixit/core/utils/custom_texts/main_text.dart';
import 'package:fixit/features/user/view/view_service_details_page.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favoriteServices = [];
  bool _isLoading = true;
  Set<String> _favoriteServiceIds = {};

  @override
  void initState() {
    super.initState();
    _fetchFavoriteServices();
  }

  // Future<void> _fetchFavoriteServices() async {
  //   User? currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser == null) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     return;
  //   }
  //
  //   try {
  //     // First, get user's favorite service IDs
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUser.uid)
  //         .get();
  //
  //     List<String> favoriteIds = [];
  //     if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
  //       var userData = userDoc.data() as Map<String, dynamic>;
  //       if (userData.containsKey('favorites') && userData['favorites'] is List) {
  //         favoriteIds = List<String>.from(userData['favorites']);
  //         _favoriteServiceIds = Set<String>.from(favoriteIds);
  //       }
  //     }
  //
  //     if (favoriteIds.isEmpty) {
  //       setState(() {
  //         _isLoading = false;
  //         _favoriteServices = [];
  //       });
  //       return;
  //     }
  //
  //     // Fetch all favorited services
  //     List<Map<String, dynamic>> favoriteServices = [];
  //
  //     // Process in batches if there are many favorites
  //     for (int i = 0; i < favoriteIds.length; i += 10) {
  //       int end = (i + 10 < favoriteIds.length) ? i + 10 : favoriteIds.length;
  //       List<String> batch = favoriteIds.sublist(i, end);
  //
  //       // Make sure we have valid IDs before querying
  //       batch = batch.where((id) => id.isNotEmpty).toList();
  //
  //       if (batch.isEmpty) continue;
  //
  //       QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
  //           .collection('services')
  //           .where(FieldPath.documentId, whereIn: batch)
  //           .get();
  //
  //       for (var doc in servicesSnapshot.docs) {
  //         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //
  //         // Get provider details
  //         String providerId = data['provider_id'] ?? '';
  //         Map<String, dynamic> providerData = {};
  //
  //         if (providerId.isNotEmpty) {
  //           DocumentSnapshot providerDoc = await FirebaseFirestore.instance
  //               .collection('service provider')
  //               .doc(providerId)
  //               .get();
  //
  //           if (providerDoc.exists) {
  //             providerData = providerDoc.data() as Map<String, dynamic>;
  //           }
  //         }
  //
  //         // Parse numeric values safely
  //         num hourlyRate = _parseNumber(data['hourly_rate']);
  //         num rating = _parseNumber(data['rating']);
  //         num ratingCount = _parseNumber(data['rating_count']);
  //
  //         favoriteServices.add({
  //           'id': doc.id,
  //           'name': data['name'] ?? '',
  //           'hourly_rate': hourlyRate,
  //           'rating': rating,
  //           'rating_count': ratingCount,
  //           'work_sample': data['work_sample'] ?? '',
  //           'work_samples': data['work_samples'] ?? [],
  //           'provider_name': providerData['name'] ?? 'Unknown',
  //           'provider_image': providerData['profileImage'] ?? '',
  //           'provider_id': providerId,
  //         });
  //       }
  //     }
  //
  //     setState(() {
  //       _favoriteServices = favoriteServices;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error fetching favorite services: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _fetchFavoriteServices() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      List<String> favoriteIds = [];
      if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('favorites') && userData['favorites'] is List) {
          favoriteIds = List<String>.from(userData['favorites']);
          _favoriteServiceIds = Set<String>.from(favoriteIds);
        }
      }

      if (favoriteIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _favoriteServices = [];
        });
        return;
      }

      List<Map<String, dynamic>> favoriteServices = [];

      for (int i = 0; i < favoriteIds.length; i += 10) {
        int end = (i + 10 < favoriteIds.length) ? i + 10 : favoriteIds.length;
        List<String> batch = favoriteIds.sublist(i, end);
        batch = batch.where((id) => id.isNotEmpty).toList();

        if (batch.isEmpty) continue;

        QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
            .collection('services')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        // Process services and fetch ratings in parallel
        List<Future<Map<String, dynamic>?>> serviceFutures = [];

        for (var doc in servicesSnapshot.docs) {
          serviceFutures.add(_processServiceDocument(doc));
        }

        List<Map<String, dynamic>?> results = await Future.wait(serviceFutures);
        favoriteServices.addAll(results.whereType<Map<String, dynamic>>());
      }

      setState(() {
        _favoriteServices = favoriteServices;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching favorite services: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<Map<String, dynamic>?> _processServiceDocument(QueryDocumentSnapshot doc) async {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String providerId = data['provider_id'] ?? '';

      // Fetch provider details and average rating in parallel
      var results = await Future.wait([
        providerId.isNotEmpty
            ? FirebaseFirestore.instance
            .collection('service provider')
            .doc(providerId)
            .get()
            : Future.value(null),
        _fetchAverageRating(doc.id, providerId),
      ]);

      // Explicitly cast the results
      DocumentSnapshot? providerDoc = results[0] as DocumentSnapshot?;
      double averageRating = results[1] as double;

      Map<String, dynamic> providerData = {};
      if (providerDoc != null && providerDoc.exists) {
        providerData = providerDoc.data() as Map<String, dynamic>;
      }

      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'hourly_rate': _parseNumber(data['hourly_rate']),
        'rating': averageRating,
        'rating_count': _parseNumber(data['rating_count']),
        'work_sample': data['work_sample'] ?? '',
        'work_samples': data['work_samples'] ?? [],
        'provider_name': providerData['name'] ?? 'Unknown',
        'provider_image': providerData['profileImage'] ?? '',
        'provider_id': providerId,
      };
    } catch (e) {
      print('Error processing service document: $e');
      return null;
    }
  }

  // Helper method to safely parse numbers from various formats

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

  Future<double> _fetchAverageRating(String serviceId, String providerId) async {
    try {
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('service_id', isEqualTo: serviceId)
          .where('provider_id', isEqualTo: providerId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] ?? 0).toDouble();
      }

      return totalRating / ratingsSnapshot.docs.length;
    } catch (e) {
      print('Error fetching ratings: $e');
      return 0.0;
    }
  }

  Future<void> _toggleFavorite(String serviceId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      if (_favoriteServiceIds.contains(serviceId)) {
        _favoriteServiceIds.remove(serviceId);
        _favoriteServices.removeWhere((service) => service['id'] == serviceId);
      } else {
        _favoriteServiceIds.add(serviceId);
      }
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'favorites': _favoriteServiceIds.toList(),
      });
    } catch (e) {
      print('Error updating favorites: $e');
      // If update fails, refresh the list
      await _fetchFavoriteServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        title: Text(
          'My Favorites',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favoriteServices.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'No favorite services yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Add services to your favorites\nby clicking the heart icon',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: _favoriteServices.length,
                itemBuilder: (context, index) {
                  final service = _favoriteServices[index];
                  return _buildServiceCard(
                    id: service['id'],
                    providerId: service['provider_id'],
                    name: service['provider_name'],
                    service: service['name'],
                    networkImage: service['work_sample'],
                    rating: service['rating'].toDouble(),
                    hourlyRate: service['hourly_rate'].toInt(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build service card for favorites
  Widget _buildServiceCard({
    required String id,
    required String providerId,
    required String name,
    required String service,
    String? networkImage,
    required double rating,
    required int hourlyRate,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: networkImage != null && networkImage.isNotEmpty
                    ? Image.network(
                  networkImage,
                  height: 175,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    "assets/images/Jhon_plumber5.jpeg",
                    height: 175,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  "assets/images/Jhon_plumber5.jpeg",
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
                    _toggleFavorite(id);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    radius: 16,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F3966),
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            service,
                            style: TextStyle(color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      width: 47,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 16),
                          SizedBox(width: 2),
                          Text(
                            "$rating",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹$hourlyRate/hr",
                      style: TextStyle(
                        color: Color(0xff0F3966),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to service details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewServiceDetailsPage(
                              serviceId: id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xff0F3966),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Details",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
