
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fixit/features/user/view/view_service_details_page.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class SearchPage extends StatefulWidget {
//   const SearchPage({Key? key}) : super(key: key);
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<String> recentSearches = [];
//   List<Map<String, dynamic>> searchResults = [];
//   bool isSearching = false;
//   bool isLoading = false;
//
//   List<Map<String, dynamic>> _services = [];
//   Set<String> _favoriteServiceIds = {};
//
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//
//   // Firebase references
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _loadRecentSearches();
//     _fetchUserFavorites();
//
//     _searchController.addListener(() {
//       final query = _searchController.text.trim();
//       setState(() {
//         isSearching = query.isNotEmpty;
//       });
//
//       if (query.isNotEmpty) {
//         _performSearch(query);
//       } else {
//         setState(() {
//           searchResults = [];
//         });
//       }
//     });
//   }
//
//   Future<void> _loadRecentSearches() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       recentSearches = prefs.getStringList('recentSearches') ?? [];
//     });
//   }
//
//   Future<void> _addToRecentSearches(String search) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     search = search.trim();
//
//     // Remove if already exists to avoid duplicates
//     recentSearches.remove(search);
//
//     // Add to beginning of list
//     recentSearches.insert(0, search);
//
//     // Keep only the last 10 searches
//     if (recentSearches.length > 10) {
//       recentSearches = recentSearches.sublist(0, 10);
//     }
//
//     await prefs.setStringList('recentSearches', recentSearches);
//
//     // Clear the search field after selection
//     _searchController.clear();
//     setState(() {
//       isSearching = false;
//       searchResults = [];
//     });
//   }
//
//   void _startListening() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(onResult: (result) {
//         setState(() {
//           _searchController.text = result.recognizedWords;
//         });
//       });
//     }
//   }
//
//   void _stopListening() {
//     _speech.stop();
//     setState(() => _isListening = false);
//   }
//
//   void _clearRecentSearches() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       recentSearches.clear();
//     });
//     await prefs.remove('recentSearches');
//   }
//
//   void _reuseSearch(String search) {
//     _searchController.text = search;
//     // Trigger search immediately
//     setState(() {
//       isSearching = true;
//     });
//     _performSearch(search);
//   }
//
//   Future<void> _performSearch(String query) async {
//     if (query.isEmpty) return;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       print("Searching for: $query");
//       // Prepare to store results
//       List<Map<String, dynamic>> results = [];
//
//       // Convert query to lowercase for case-insensitive search
//       final lowercaseQuery = query.toLowerCase();
//
//       print("Fetching services...");
//       // Get all services
//       final servicesSnapshot = await _firestore.collection('services').get();
//       print("Services fetched: ${servicesSnapshot.docs.length}");
//
//       for (var doc in servicesSnapshot.docs) {
//         final data = doc.data();
//         final serviceName = data['name']?.toString().toLowerCase() ?? '';
//
//         // Check if service name contains the query string (case insensitive)
//         if (serviceName.contains(lowercaseQuery)) {
//           print("Match found - service: ${data['name']}");
//           results.add({
//             'id': doc.id,
//             'name': data['name'] ?? 'Unknown Service',
//             'type': 'service',
//             'provider_id': data['provider_id'],
//
//             'description': data['description'] ?? '',
//             'rating': data['rating'] ?? 0,
//             'experience': data['experience'] ?? 0,
//             'hourly_rate': data['hourly_rate'] ?? 0,
//             'work_sample': data['work_sample'] ?? '',
//             'work_samples': data['work_samples'] ?? [],
//           });
//         }
//       }
//
//       // We've removed the service provider search code since you only want service results
//
//       print("Search complete. Found ${results.length} service results.");
//       setState(() {
//         searchResults = results;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error searching: $e');
//       setState(() {
//         searchResults = [];
//         isLoading = false;
//       });
//     }
//   }
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
//       if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
//         var userData = userDoc.data() as Map<String, dynamic>;
//         if (userData.containsKey('favorites') && userData['favorites'] is List) {
//           setState(() {
//             _favoriteServiceIds = Set<String>.from(userData['favorites'] as List);
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching user favorites: $e');
//     }
//   }
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
//         double averageRating = await _fetchAverageRating(doc.id, data['provider_id']);
//
//         services.add({
//           'id': doc.id,
//           'name': data['name'] ?? '',
//           'hourly_rate': _parseNumber(data['hourly_rate']),
//           'rating': averageRating,
//           'rating_count': _parseNumber(data['rating_count']),
//           'work_sample': data['work_sample'] ?? '',
//           'work_samples': data['work_samples'] ?? [],
//           'provider_id': data['provider_id'] ?? '',
//           'provider_name': providerData['name'] ?? 'Unknown',
//           'provider_image': providerData['profileImage'] ?? '',
//           'isApproved': providerData['status'] == 1,
//         });
//       }
//
//       setState(() {
//         _services = services;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching services: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//   Future<double> _fetchAverageRating(String serviceId, String providerId) async {
//     try {
//       QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
//           .collection('ratings')
//           .where('service_id', isEqualTo: serviceId)
//           .where('provider_id', isEqualTo: providerId)
//           .get();
//
//       if (ratingsSnapshot.docs.isEmpty) return 0.0;
//
//       double totalRating = 0;
//       for (var doc in ratingsSnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         totalRating += (data['rating'] ?? 0).toDouble();
//       }
//
//       return totalRating / ratingsSnapshot.docs.length;
//     } catch (e) {
//       print('Error fetching ratings: $e');
//       return 0.0;
//     }
//   }
//   num _parseNumber(dynamic value) {
//     if (value == null) return 0;
//     if (value is num) return value;
//     if (value is String) {
//       final cleanedValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
//       return num.tryParse(cleanedValue) ?? 0;
//     }
//     return 0;
//   }
//
//   Future<void> _toggleFavorite(String serviceId) async {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//
//     try {
//       bool isCurrentlyFavorite = _favoriteServiceIds.contains(serviceId);
//       Set<String> newFavorites = Set<String>.from(_favoriteServiceIds);
//
//       if (isCurrentlyFavorite) {
//         newFavorites.remove(serviceId);
//       } else {
//         newFavorites.add(serviceId);
//       }
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .update({'favorites': newFavorites.toList()});
//
//       setState(() {
//         _favoriteServiceIds = newFavorites;
//       });
//     } catch (e) {
//       print('Error toggling favorite: $e');
//     }
//   }
//
//
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _speech.stop();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xff0F3966),
//         title: Container(
//           height: 45,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.search, color: Colors.grey),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: const InputDecoration(
//                     hintText: "Search for services...", // Updated hint text
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.mic,
//                   color: _isListening ? Colors.blue : Colors.grey,
//                 ),
//                 onPressed: _isListening ? _stopListening : _startListening,
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Show recent searches only when not actively searching
//             if (!isSearching && recentSearches.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "Your Recent Searches",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: _clearRecentSearches,
//                         child: const Text(
//                           "Clear all",
//                           style: TextStyle(color: Colors.blue),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   ...recentSearches.map((search) => ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     dense: true,
//                     leading: const Icon(Icons.history, color: Colors.grey),
//                     title: Text(
//                       search,
//                       style: const TextStyle(fontSize: 15),
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.search, size: 20),
//                       onPressed: () => _reuseSearch(search),
//                     ),
//                     onTap: () => _reuseSearch(search),
//                   )),
//                 ],
//               ),
//
//             // Show search results when typing
//             if (isSearching)
//             // In your GridView.builder, replace with this:
//               Expanded(
//                 child: isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : searchResults.isEmpty
//                     ? const Center(child: Text("No services found"))
//                     : GridView.builder(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 0.75,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                   ),
//                   itemCount: searchResults.length,
//                   itemBuilder: (context, index) {
//                     // Add bounds checking
//                     if (index >= searchResults.length) {
//                       return const SizedBox.shrink();
//                     }
//
//                     final result = searchResults[index];
//                     return _buildServiceCard(
//                       name: result['name'] ?? 'Unknown Service',
//                       // service: result['description'] ?? '',
//                       networkImage: result['work_sample'] ?? '',
//                       rating: double.tryParse(result['rating']?.toString() ?? '0') ?? 0,
//                       hourlyRate: int.tryParse(result['hourly_rate']?.toString() ?? '0') ?? 0,
//                       serviceId: result['id'] ?? '',
//                       isFavorite: _favoriteServiceIds.contains(result['id']),
//                       isApproved: true, // Update this based on your actual data
//                       onTap: () async {
//                         _addToRecentSearches(result['name'] ?? '');
//                         final serviceResult = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ViewServiceDetailsPage(
//                               serviceId: result['id'] ?? '',
//                             ),
//                           ),
//                         );
//                         if (serviceResult == true) {
//                           _fetchUserFavorites();
//                         }
//                       },
//                     );
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildServiceCard({
//     required String name,
//     // required String service,
//     String? imagePath,
//     String? networkImage,
//     required num rating,
//     required num hourlyRate,
//     required String serviceId,
//     required bool isFavorite,
//     required bool isApproved,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                   child: networkImage != null && networkImage.isNotEmpty
//                       ? Image.network(
//                     networkImage,
//                     height: 175,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) =>
//                         Image.asset(
//                           imagePath ?? "assets/images/Jhon_plumber5.jpeg",
//                           height: 175,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                   )
//                       : Image.asset(
//                     imagePath ?? "assets/images/Jhon_plumber5.jpeg",
//                     height: 175,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//
//                 if (isApproved)
//                   Positioned(
//                     top: 8,
//                     left: 8,
//                     child: Icon(
//                       Icons.verified,
//                       color: Colors.blue,
//                       size: 30,
//                     ),
//                   ),
//
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: GestureDetector(
//                     onTap: () => _toggleFavorite(serviceId),
//                     child: CircleAvatar(
//                       backgroundColor: Colors.white70,
//                       radius: 16,
//                       child: Icon(
//                         isFavorite ? Icons.favorite : Icons.favorite_border,
//                         color: isFavorite ? Colors.red : Colors.grey,
//                         size: 18,
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             name,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xff0F3966),
//                               fontSize: 16,
//                             ),
//                           ),
//                           // SizedBox(height: 2),
//                           // Text(service,
//                           //     style: TextStyle(color: Colors.black54)),
//                         ],
//                       ),
//                       Container(
//                         padding: EdgeInsets.all(4),
//                         width: 47,
//                         height: 25,
//                         decoration: BoxDecoration(
//                             color: Colors.green[700],
//                             borderRadius: BorderRadius.circular(20)),
//                         child: Row(
//                           children: [
//                             Icon(Icons.star, color: Colors.white, size: 16),
//                             SizedBox(width: 4),
//                             Text(rating.toStringAsFixed(1),
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 12)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 6),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("₹${hourlyRate.toInt()}/hr",
//                           style: TextStyle(
//                               color: Color(0xff0F3966),
//                               fontWeight: FontWeight.w600,
//                               fontSize: 13)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/features/user/view/view_service_details_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  bool isLoading = false;

  List<Map<String, dynamic>> _services = [];
  Set<String> _favoriteServiceIds = {};

  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadRecentSearches();
    _fetchUserFavorites();

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      setState(() {
        isSearching = query.isNotEmpty;
      });

      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          searchResults = [];
        });
      }
    });
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _addToRecentSearches(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    search = search.trim();

    // Remove if already exists to avoid duplicates
    recentSearches.remove(search);

    // Add to beginning of list
    recentSearches.insert(0, search);

    // Keep only the last 10 searches
    if (recentSearches.length > 10) {
      recentSearches = recentSearches.sublist(0, 10);
    }

    await prefs.setStringList('recentSearches', recentSearches);

    // Clear the search field after selection
    _searchController.clear();
    setState(() {
      isSearching = false;
      searchResults = [];
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _clearRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches.clear();
    });
    await prefs.remove('recentSearches');
  }

  void _reuseSearch(String search) {
    _searchController.text = search;
    // Trigger search immediately
    setState(() {
      isSearching = true;
    });
    _performSearch(search);
  }

  // Future<void> _performSearch(String query) async {
  //   if (query.isEmpty) return;
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     print("Searching for: $query");
  //     List<Map<String, dynamic>> results = [];
  //     Set<String> addedServiceIds = {};
  //     final lowercaseQuery = query.toLowerCase();
  //
  //     // Get all services and providers in parallel
  //     final [servicesSnapshot, providersSnapshot] = await Future.wait([
  //       _firestore.collection('services').get(),
  //
  //       _firestore.collection('service provider').get(),
  //     ]);
  //
  //     // Create provider map
  //     final providersMap = {
  //       for (var doc in providersSnapshot.docs)
  //         doc.id: doc.data()
  //     };
  //
  //     // Search through services
  //     for (var doc in servicesSnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       final serviceName = data['name']?.toString().toLowerCase() ?? '';
  //       final providerId = data['provider_id']?.toString();
  //
  //       // Skip if already added
  //       if (addedServiceIds.contains(doc.id)) continue;
  //
  //       // Check service name match
  //       bool matchesServiceName = serviceName.contains(lowercaseQuery);
  //
  //       // Check provider name match if provider exists
  //       bool matchesProviderName = false;
  //       if (providerId != null && providersMap.containsKey(providerId)) {
  //         final providerName = providersMap[providerId]!['name']?.toString().toLowerCase() ?? '';
  //         matchesProviderName = providerName.contains(lowercaseQuery);
  //       }
  //
  //       // If either matches, add to results
  //       if (matchesServiceName || matchesProviderName) {
  //         final providerData = providerId != null ? providersMap[providerId] : null;
  //         double averageRating = await _fetchAverageRating(doc.id, providerId ?? '');
  //
  //         results.add({
  //           'id': doc.id,
  //           'name': data['name'] ?? 'Unknown Service',
  //           'type': 'service',
  //           'provider_id': providerId,
  //           'provider_name': providerData?['name'] ?? 'Unknown Provider',
  //           'isApproved': providerData?['status'] == 1,
  //           'description': data['description'] ?? '',
  //           'rating': averageRating,
  //           'experience': data['experience'] ?? 0,
  //           'hourly_rate': data['hourly_rate'] ?? 0,
  //           'work_sample': data['work_sample'] ?? '',
  //           'work_samples': data['work_samples'] ?? [],
  //         });
  //
  //         addedServiceIds.add(doc.id);
  //       }
  //     }
  //
  //     print("Search complete. Found ${results.length} results.");
  //     setState(() {
  //       searchResults = results;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error searching: $e');
  //     setState(() {
  //       searchResults = [];
  //       isLoading = false;
  //     });
  //   }
  // }
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      print("Searching for: $query");
      List<Map<String, dynamic>> results = [];
      Set<String> addedServiceIds = {};
      final lowercaseQuery = query.toLowerCase();

      // Get all services and providers in parallel
      final [servicesSnapshot, providersSnapshot] = await Future.wait([
        _firestore.collection('services').get(),
        _firestore.collection('service provider').get(),
      ]);

      // Create provider map
      final providersMap = {
        for (var doc in providersSnapshot.docs)
          doc.id: doc.data()
      };

      // Search through services
      for (var doc in servicesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Skip if isActive exists and is false
        if (data.containsKey('isActive') && data['isActive'] == false) {
          continue;
        }

        final serviceName = data['name']?.toString().toLowerCase() ?? '';
        final providerId = data['provider_id']?.toString();

        // Skip if already added
        if (addedServiceIds.contains(doc.id)) continue;

        // Check service name match
        bool matchesServiceName = serviceName.contains(lowercaseQuery);

        // Check provider name match if provider exists
        bool matchesProviderName = false;
        if (providerId != null && providersMap.containsKey(providerId)) {
          final providerName = providersMap[providerId]!['name']?.toString().toLowerCase() ?? '';
          matchesProviderName = providerName.contains(lowercaseQuery);
        }

        // If either matches, add to results
        if (matchesServiceName || matchesProviderName) {
          final providerData = providerId != null ? providersMap[providerId] : null;
          double averageRating = await _fetchAverageRating(doc.id, providerId ?? '');

          results.add({
            'id': doc.id,
            'name': data['name'] ?? 'Unknown Service',
            'type': 'service',
            'provider_id': providerId,
            'provider_name': providerData?['name'] ?? 'Unknown Provider',
            'isApproved': providerData?['status'] == 1,
            'description': data['description'] ?? '',
            'rating': averageRating,
            'experience': data['experience'] ?? 0,
            'hourly_rate': data['hourly_rate'] ?? 0,
            'work_sample': data['work_sample'] ?? '',
            'work_samples': data['work_samples'] ?? [],
          });

          addedServiceIds.add(doc.id);
        }
      }

      print("Search complete. Found ${results.length} results.");
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error searching: $e');
      setState(() {
        searchResults = [];
        isLoading = false;
      });
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

      if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('favorites') && userData['favorites'] is List) {
          setState(() {
            _favoriteServiceIds = Set<String>.from(userData['favorites'] as List);
          });
        }
      }
    } catch (e) {
      print('Error fetching user favorites: $e');
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

        DocumentSnapshot providerDoc = await FirebaseFirestore.instance
            .collection('service provider')
            .doc(data['provider_id'])
            .get();

        Map<String, dynamic> providerData = {};
        if (providerDoc.exists) {
          providerData = providerDoc.data() as Map<String, dynamic>;
        }

        double averageRating = await _fetchAverageRating(doc.id, data['provider_id']);

        services.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'hourly_rate': _parseNumber(data['hourly_rate']),
          'rating': averageRating,
          'rating_count': _parseNumber(data['rating_count']),
          'work_sample': data['work_sample'] ?? '',
          'work_samples': data['work_samples'] ?? [],
          'provider_id': data['provider_id'] ?? '',
          'provider_name': providerData['name'] ?? 'Unknown',
          'provider_image': providerData['profileImage'] ?? '',
          'isApproved': providerData['status'] == 1,
        });
      }

      setState(() {
        _services = services;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        isLoading = false;
      });
    }
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

  num _parseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      final cleanedValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return num.tryParse(cleanedValue) ?? 0;
    }
    return 0;
  }

  Future<void> _toggleFavorite(String serviceId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      bool isCurrentlyFavorite = _favoriteServiceIds.contains(serviceId);
      Set<String> newFavorites = Set<String>.from(_favoriteServiceIds);

      if (isCurrentlyFavorite) {
        newFavorites.remove(serviceId);
      } else {
        newFavorites.add(serviceId);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'favorites': newFavorites.toList()});

      setState(() {
        _favoriteServiceIds = newFavorites;
      });
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff0F3966),
        title: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search for services or providers...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.mic,
                  color: _isListening ? Colors.blue : Colors.grey,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show recent searches only when not actively searching
            if (!isSearching && recentSearches.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Your Recent Searches",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearRecentSearches,
                        child: const Text(
                          "Clear all",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...recentSearches.map((search) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(
                      search,
                      style: const TextStyle(fontSize: 15),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.search, size: 20),
                      onPressed: () => _reuseSearch(search),
                    ),
                    onTap: () => _reuseSearch(search),
                  )),
                ],
              ),

            // Show search results when typing
            if (isSearching)
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchResults.isEmpty
                    ? const Center(child: Text("No services found"))
                    : GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    // Add bounds checking
                    if (index >= searchResults.length) {
                      return const SizedBox.shrink();
                    }

                    final result = searchResults[index];
                    return _buildServiceCard(
                      name: result['name'] ?? 'Unknown Service',
                      providerName: result['provider_name'] ?? 'Unknown Provider',
                      networkImage: result['work_sample'] ?? '',
                      rating: result['rating'] ?? 0.0,
                      hourlyRate: int.tryParse(result['hourly_rate']?.toString() ?? '0') ?? 0,
                      serviceId: result['id'] ?? '',
                      isFavorite: _favoriteServiceIds.contains(result['id']),
                      isApproved: result['isApproved'] ?? false,
                      onTap: () async {
                        _addToRecentSearches(result['name'] ?? '');
                        final serviceResult = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewServiceDetailsPage(
                              serviceId: result['id'] ?? '',
                            ),
                          ),
                        );
                        if (serviceResult == true) {
                          _fetchUserFavorites();
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String name,
    required String providerName,
    String? imagePath,
    String? networkImage,
    required double rating,
    required num hourlyRate,
    required String serviceId,
    required bool isFavorite,
    required bool isApproved,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: networkImage != null && networkImage.isNotEmpty
                      ? Image.network(
                    networkImage,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                          imagePath ?? "assets/images/Jhon_plumber5.jpeg",
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  )
                      : Image.asset(
                    imagePath ?? "assets/images/Jhon_plumber5.jpeg",
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                if (isApproved)
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(serviceId),
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      radius: 16,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
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
                              "$providerName",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 2),
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0F3966),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        width: 47,
                        height: 25,
                        decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹${hourlyRate.toInt()}/hr",
                          style: const TextStyle(
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
}


