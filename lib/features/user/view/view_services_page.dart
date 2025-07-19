// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:fixit/features/user/view/view_service_details_page.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ViewServicesPage extends StatefulWidget {
//   @override
//   _ViewServicesPageState createState() => _ViewServicesPageState();
// }
//
// class _ViewServicesPageState extends State<ViewServicesPage> {
//   List<Map<String, dynamic>> categories = [];
//   int selectedCategoryIndex = 0;
//   String searchQuery = "";
//   List<Map<String, dynamic>> serviceProviders = [];
//   Map<String, List<Map<String, dynamic>>> categorizedProviders = {};
//   bool isLoading = true;
//   Set<String> favoriteProviderIds = {};
//
//
//   @override
//   void initState() {
//     super.initState();
//     loadFavorites();
//     fetchCategories();
//   }
//
//   Future<void> loadFavorites() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getStringList('favorites') ?? [];
//     setState(() {
//       favoriteProviderIds = saved.toSet();
//     });
//   }
//
//   Future<void> toggleFavorite(String id) async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       if (favoriteProviderIds.contains(id)) {
//         favoriteProviderIds.remove(id);
//       } else {
//         favoriteProviderIds.add(id);
//       }
//     });
//     prefs.setStringList('favorites', favoriteProviderIds.toList());
//   }
//
//   Future<void> fetchCategories() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       // Add "All" category first
//       categories = [
//         {"name": "All", "icon": null}
//       ];
//
//       // Fetch categories from Firestore
//       QuerySnapshot categorySnapshot =
//           await FirebaseFirestore.instance.collection('categories').get();
//
//       for (var doc in categorySnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         categories.add({
//           "name": data['name'],
//           "icon": data['icon'],
//         });
//       }
//
//       // After fetching categories, fetch services
//       await fetchServices();
//     } catch (e) {
//       print('Error fetching categories: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   // Future<void> fetchServices() async {
//   //   try {
//   //     // Fetch services from Firestore
//   //     QuerySnapshot serviceSnapshot =
//   //         await FirebaseFirestore.instance.collection('services').get();
//   //
//   //     // Initialize the categorized providers map
//   //     categorizedProviders = {"All": []};
//   //     for (var category in categories) {
//   //       if (category["name"] != "All") {
//   //         categorizedProviders[category["name"]] = [];
//   //       }
//   //     }
//   //
//   //     // Process each service
//   //     for (var doc in serviceSnapshot.docs) {
//   //       Map<String, dynamic> serviceData = doc.data() as Map<String, dynamic>;
//   //       String categoryName = serviceData['name'];
//   //       String providerId = serviceData['provider_id'];
//   //
//   //       // Fetch provider details
//   //       DocumentSnapshot providerDoc = await FirebaseFirestore.instance
//   //           .collection('service provider')
//   //           .doc(providerId)
//   //           .get();
//   //
//   //       if (providerDoc.exists) {
//   //         Map<String, dynamic> providerData =
//   //             providerDoc.data() as Map<String, dynamic>;
//   //
//   //         Map<String, dynamic> providerInfo = {
//   //           "id": providerId,
//   //           "name": providerData['name'],
//   //           "service": categoryName,
//   //           "rating": serviceData['rating'].toString(),
//   //           "price": "₹${serviceData['hourly_rate']}/hr",
//   //           "image": providerData['profileImage'],
//   //         };
//   //
//   //         // Add to appropriate category
//   //         if (categorizedProviders.containsKey(categoryName)) {
//   //           categorizedProviders[categoryName]!.add(providerInfo);
//   //         }
//   //
//   //         // Also add to "All" category
//   //         categorizedProviders["All"]!.add(providerInfo);
//   //       }
//   //     }
//   //
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     print('Error fetching services: $e');
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//   Future<void> fetchServices() async {
//     try {
//       QuerySnapshot serviceSnapshot =
//       await FirebaseFirestore.instance.collection('services').get();
//
//       categorizedProviders = {"All": []};
//       for (var category in categories) {
//         if (category["name"] != "All") {
//           categorizedProviders[category["name"]] = [];
//         }
//       }
//
//       for (var doc in serviceSnapshot.docs) {
//         Map<String, dynamic> serviceData = doc.data() as Map<String, dynamic>;
//         String categoryName = serviceData['name'];
//         String providerId = serviceData['provider_id'];
//
//         DocumentSnapshot providerDoc = await FirebaseFirestore.instance
//             .collection('service provider')
//             .doc(providerId)
//             .get();
//
//         if (providerDoc.exists) {
//           Map<String, dynamic> providerData =
//           providerDoc.data() as Map<String, dynamic>;
//
//           Map<String, dynamic> providerInfo = {
//             "id": providerId,
//             "serviceId": doc.id, // Add this line to store the service document ID
//             "name": providerData['name'],
//             "service": categoryName,
//             "rating": serviceData['rating'].toString(),
//             "price": "₹${serviceData['hourly_rate']}/hr",
//             "image": providerData['profileImage'],
//             "isVerified":providerData['status']==1,
//           };
//
//           if (categorizedProviders.containsKey(categoryName)) {
//             categorizedProviders[categoryName]!.add(providerInfo);
//           }
//           categorizedProviders["All"]!.add(providerInfo);
//         }
//       }
//
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching services: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   IconData getCategoryIcon(String categoryName) {
//     // Default mapping for common categories
//     Map<String, IconData> defaultIcons = {
//       "All": Icons.dashboard,
//       "Plumbing": Icons.plumbing,
//       "Electrician": Icons.electrical_services,
//       "Cleaning": Icons.cleaning_services,
//       "Painting": Icons.format_paint,
//       "AC Repair": Icons.ac_unit,
//     };
//
//     return defaultIcons[categoryName] ?? Icons.handyman;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           iconTheme: IconThemeData(color: Colors.white),
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                   context, '/home', (Route route) => false);
//             },
//             icon: Icon(Icons.arrow_back),
//           ),
//           title: AppBarTitle(text: "All Services"),
//           backgroundColor: Color(0xff0F3966),
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     String selectedCategory = categories[selectedCategoryIndex]["name"];
//     List<Map<String, dynamic>> filteredProviders =
//         categorizedProviders[selectedCategory] ?? [];
//
//     // Apply search filter
//     if (searchQuery.isNotEmpty) {
//       filteredProviders = filteredProviders
//           .where((provider) =>
//               provider['name']
//                   .toLowerCase()
//                   .contains(searchQuery.toLowerCase()) ||
//               provider['service']
//                   .toLowerCase()
//                   .contains(searchQuery.toLowerCase()))
//           .toList();
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: AppBarTitle(text: "All Services"),
//         backgroundColor: Color(0xff0F3966),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, '/home', (Route route) => false);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Row(
//         children: [
//           // LEFT SIDE CATEGORY LIST
//           Container(
//             width: 100,
//             color: Color(0xffF0F0F0),
//             child: ListView.builder(
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 Map<String, dynamic> category = categories[index];
//                 String categoryName = category["name"];
//                 bool isSelected = selectedCategoryIndex == index;
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedCategoryIndex = index;
//                       searchQuery = "";
//                     });
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     color: isSelected ? Colors.white : Colors.transparent,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Use network image for category icon if available
//                         category["icon"] != null && categoryName != "All"
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(15),
//                                 child: Image.network(
//                                   category["icon"],
//                                   width: 28,
//                                   height: 28,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       Icon(
//                                     getCategoryIcon(categoryName),
//                                     color: isSelected
//                                         ? Color(0xff0F3966)
//                                         : Colors.grey,
//                                     size: 28,
//                                   ),
//                                   loadingBuilder:
//                                       (context, child, loadingProgress) {
//                                     if (loadingProgress == null) return child;
//                                     return Icon(
//                                       getCategoryIcon(categoryName),
//                                       color: isSelected
//                                           ? Color(0xff0F3966)
//                                           : Colors.grey,
//                                       size: 28,
//                                     );
//                                   },
//                                 ),
//                               )
//                             : Icon(
//                                 getCategoryIcon(categoryName),
//                                 color: isSelected
//                                     ? Color(0xff0F3966)
//                                     : Colors.grey,
//                                 size: 28,
//                               ),
//                         const SizedBox(height: 4),
//                         Text(
//                           categoryName,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color:
//                                 isSelected ? Color(0xff0F3966) : Colors.black54,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // RIGHT SIDE PROVIDERS & SEARCH
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 children: [
//                   // Search bar
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search for providers...",
//                       prefixIcon: Icon(Icons.search, color: Colors.grey),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         searchQuery = value;
//                       });
//                     },
//                   ),
//                   SizedBox(height: 10),
//
//                   // Grid view of providers
//                   Expanded(
//                     child: filteredProviders.isEmpty
//                         ? Center(child: Text("No providers found"))
//                         : GridView.builder(
//                             itemCount: filteredProviders.length,
//                             gridDelegate:
//                                 SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                               childAspectRatio: 0.7,
//                             ),
//                             itemBuilder: (context, index) {
//                               var provider = filteredProviders[index];
//                               bool isFav =
//                                   favoriteProviderIds.contains(provider['id']);
//
//                               return Card(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   elevation: 3,
//                                   child: InkWell(
//                                     // Add this InkWell wrapper for tap functionality
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               ViewServiceDetailsPage(
//                                                 serviceId: provider['serviceId'] ?? '',
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Column(
//                                       children: [
//                                         Stack(
//                                           children: [
//                                             ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.vertical(
//                                                       top: Radius.circular(15)),
//                                               child: Image.network(
//                                                 provider['image'],
//                                                 height: 120,
//                                                 width: double.infinity,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder: (context, error,
//                                                         stackTrace) =>
//                                                     Container(
//                                                   height: 120,
//                                                   width: double.infinity,
//                                                   color: Colors.grey[300],
//                                                   child: Icon(Icons.person,
//                                                       size: 50,
//                                                       color: Colors.grey[600]),
//                                                 ),
//                                                 loadingBuilder: (context, child,
//                                                     loadingProgress) {
//                                                   if (loadingProgress == null)
//                                                     return child;
//                                                   return Container(
//                                                     height: 120,
//                                                     color: Colors.grey[200],
//                                                     child: Center(
//                                                       child:
//                                                           CircularProgressIndicator(
//                                                         value: loadingProgress
//                                                                     .expectedTotalBytes !=
//                                                                 null
//                                                             ? loadingProgress
//                                                                     .cumulativeBytesLoaded /
//                                                                 (loadingProgress
//                                                                         .expectedTotalBytes ??
//                                                                     1)
//                                                             : null,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                             if (provider['isVerified']==true)
//                                               Positioned(
//                                                 top: 8,
//                                                 left: 8,
//                                                 child: Icon(
//                                                   Icons.verified,
//                                                   color: Colors.blue,
//                                                   size: 30,
//                                                 ),
//                                               ),
//                                             Positioned(
//                                               top: 8,
//                                               right: 8,
//                                               child: GestureDetector(
//                                                 onTap: () => toggleFavorite(
//                                                     provider['id']),
//                                                 child: CircleAvatar(
//                                                   backgroundColor:
//                                                       Colors.white70,
//                                                   radius: 16,
//                                                   child: Icon(
//                                                     isFav
//                                                         ? Icons.favorite
//                                                         : Icons.favorite_border,
//                                                     color: isFav
//                                                         ? Colors.red
//                                                         : Colors.grey,
//                                                     size: 18,
//                                                   ),
//                                                 ),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 provider['name'],
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 16,
//                                                   color: Color(0xff0F3966),
//                                                 ),
//                                               ),
//                                               Text(provider['service'],
//                                                   style: TextStyle(
//                                                       color: Colors.black54)),
//                                               SizedBox(height: 5),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       Icon(Icons.star,
//                                                           size: 14,
//                                                           color: Colors.amber),
//                                                       SizedBox(width: 4),
//                                                       Text(provider['rating']),
//                                                     ],
//                                                   ),
//                                                   Text(provider['price'],
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.w600)),
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ));
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/features/user/view/view_service_details_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewServicesPage extends StatefulWidget {
  final String? selectedCategoryName; // Add this parameter

  const ViewServicesPage({Key? key, this.selectedCategoryName}) : super(key: key);
  @override
  _ViewServicesPageState createState() => _ViewServicesPageState();
}

class _ViewServicesPageState extends State<ViewServicesPage> {
  List<Map<String, dynamic>> categories = [];
  int selectedCategoryIndex = 0;
  String searchQuery = "";
  Map<String, List<Map<String, dynamic>>> categorizedProviders = {};
  bool isLoading = true;
  Set<String> favoriteServiceIds = {};
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserFavorites();
    fetchCategories();
  }

  Future<void> _fetchUserFavorites() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('favorites') &&
            userData['favorites'] is List) {
          setState(() {
            favoriteServiceIds =
                Set<String>.from(userData['favorites'] as List);
          });
        }
      }
    } catch (e) {
      print('Error fetching user favorites: $e');
    }
  }

  void _setSelectedCategoryIndex() {
    if (widget.selectedCategoryName != null) {
      int index = categories.indexWhere(
              (category) => category['name'] == widget.selectedCategoryName
      );
      if (index != -1) {
        selectedCategoryIndex = index;
      }
    }
  }

  Future<double> _fetchAverageRating(
      String serviceId, String providerId) async {
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

  Future<void> toggleFavorite(String serviceId) async {
    if (currentUser == null) return;

    try {
      bool isCurrentlyFavorite = favoriteServiceIds.contains(serviceId);
      Set<String> newFavorites = Set<String>.from(favoriteServiceIds);

      if (isCurrentlyFavorite) {
        newFavorites.remove(serviceId);
      } else {
        newFavorites.add(serviceId);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'favorites': newFavorites.toList()});

      setState(() {
        favoriteServiceIds = newFavorites;
      });
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // Future<void> fetchCategories() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     // Add "All" category first
  //     categories = [
  //       {"name": "All", "icon": null}
  //     ];
  //
  //     // Fetch categories from Firestore
  //     QuerySnapshot categorySnapshot =
  //         await FirebaseFirestore.instance.collection('categories').get();
  //
  //     for (var doc in categorySnapshot.docs) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       categories.add({
  //         "name": data['name'],
  //         "icon": data['icon'],
  //       });
  //     }
  //
  //     // After fetching categories, fetch services
  //     await fetchServices();
  //   } catch (e) {
  //     print('Error fetching categories: $e');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }


  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Add "All" category first
      categories = [
        {"name": "All", "icon": null}
      ];

      // Fetch categories from Firestore
      QuerySnapshot categorySnapshot =
      await FirebaseFirestore.instance.collection('categories').get();

      for (var doc in categorySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        categories.add({
          "name": data['name'],
          "icon": data['icon'],
        });
      }

      // Add this line to set the selected category index
      _setSelectedCategoryIndex();

      // After fetching categories, fetch services
      await fetchServices();
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> fetchServices() async {
    try {
      QuerySnapshot serviceSnapshot =
          await FirebaseFirestore.instance.collection('services').get();

      // Initialize the categorized providers map
      categorizedProviders = {"All": []};
      for (var category in categories) {
        if (category["name"] != "All") {
          categorizedProviders[category["name"]] = [];
        }
      }

      // Process each service
      for (var doc in serviceSnapshot.docs) {
        Map<String, dynamic> serviceData = doc.data() as Map<String, dynamic>;
        String categoryName = serviceData['name'];
        String providerId = serviceData['provider_id'];

        // Fetch provider details and average rating in parallel
        var results = await Future.wait([
          FirebaseFirestore.instance
              .collection('service provider')
              .doc(providerId)
              .get(),
          _fetchAverageRating(doc.id, providerId),
        ]);

        DocumentSnapshot providerDoc = results[0] as DocumentSnapshot;
        double averageRating = results[1] as double;

        if (providerDoc.exists) {
          Map<String, dynamic> providerData =
              providerDoc.data() as Map<String, dynamic>;

          // Get the first worksample image or fallback to profile image
          String imageUrl =
              serviceData['work_sample'] ?? providerData['profileImage'] ?? '';

          Map<String, dynamic> providerInfo = {
            "id": providerId,
            "serviceId": doc.id,
            "name": providerData['name'],
            "service": categoryName,
            "rating": averageRating
                .toStringAsFixed(1), // Display rating with 1 decimal
            "price": "₹${serviceData['hourly_rate']}/hr",
            "image": imageUrl,
            "isVerified": providerData['status'] == 1,
            "isActive": serviceData['isActive'] ?? true,
          };

          // Add to appropriate category
          if (categorizedProviders.containsKey(categoryName)) {
            categorizedProviders[categoryName]!.add(providerInfo);
          }

          // Also add to "All" category
          categorizedProviders["All"]!.add(providerInfo);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  IconData getCategoryIcon(String categoryName) {
    // Default mapping for common categories
    Map<String, IconData> defaultIcons = {
      "All": Icons.dashboard,
      "Plumbing": Icons.plumbing,
      "Electrician": Icons.electrical_services,
      "Cleaning": Icons.cleaning_services,
      "Painting": Icons.format_paint,
      "AC Repair": Icons.ac_unit,
    };

    return defaultIcons[categoryName] ?? Icons.handyman;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (Route route) => false);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: AppBarTitle(text: "All Services"),
          backgroundColor: Color(0xff0F3966),
        ),
        body: Center(child: CircularProgressIndicator(color: Color(0xff0F3966),)),
      );
    }

    String selectedCategory = categories[selectedCategoryIndex]["name"];
    List<Map<String, dynamic>> filteredProviders =
        categorizedProviders[selectedCategory] ?? [];

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredProviders = filteredProviders
          .where((provider) =>
              provider['name']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              provider['service']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }

    // if (searchQuery.isNotEmpty) {
    //   filteredProviders = filteredProviders
    //       .where((provider) =>
    //   (provider['name']
    //       .toLowerCase()
    //       .contains(searchQuery.toLowerCase()) ||
    //       provider['service']
    //           .toLowerCase()
    //           .contains(searchQuery.toLowerCase())) &&
    //       provider['isActive'] == true) // Add this condition to exclude unavailable services
    //       .toList();
    // } else {
    //   // Also filter out unavailable services when no search query
    //   filteredProviders = filteredProviders
    //       .where((provider) => provider['isActive'] == true)
    //       .toList();
    // }

    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: AppBarTitle(text: "All Services"),
          backgroundColor: Color(0xff0F3966),
          leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (Route route) => false);
            },
            icon: Icon(Icons.arrow_back),
          ),
          actions: [
            GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/userfavouritespage');
                },
                child: Icon(Icons.favorite, color: Colors.white, size: 24)),
            SizedBox(width: 20),
          ]),
      body: Row(
        children: [
          // LEFT SIDE CATEGORY LIST
          Container(
            width: 100,
            color: Color(0xffF0F0F0),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> category = categories[index];
                String categoryName = category["name"];
                bool isSelected = selectedCategoryIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryIndex = index;
                      searchQuery = "";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: isSelected ? Colors.white : Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Use network image for category icon if available
                        category["icon"] != null && categoryName != "All"
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  category["icon"],
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    getCategoryIcon(categoryName),
                                    color: isSelected
                                        ? Color(0xff0F3966)
                                        : Colors.grey,
                                    size: 28,
                                  ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Icon(
                                      getCategoryIcon(categoryName),
                                      color: isSelected
                                          ? Color(0xff0F3966)
                                          : Colors.grey,
                                      size: 28,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                getCategoryIcon(categoryName),
                                color: isSelected
                                    ? Color(0xff0F3966)
                                    : Colors.grey,
                                size: 28,
                              ),
                        const SizedBox(height: 4),
                        Text(
                          categoryName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSelected ? Color(0xff0F3966) : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // RIGHT SIDE PROVIDERS & SEARCH
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search for providers...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),

                  // Grid view of providers
                  Expanded(
                    child: filteredProviders.isEmpty
                        ? Center(child: Text("No providers found"))
                        : GridView.builder(
                            itemCount: filteredProviders.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              var provider = filteredProviders[index];
                              bool isFav = favoriteServiceIds
                                  .contains(provider['serviceId']);

                              return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 3,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewServiceDetailsPage(
                                            serviceId:
                                                provider['serviceId'] ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(15)),
                                              child: Image.network(
                                                provider['image'],
                                                height: 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  height: 120,
                                                  width: double.infinity,
                                                  color: Colors.grey[300],
                                                  child: Icon(Icons.person,
                                                      size: 50,
                                                      color: Colors.grey[600]),
                                                ),
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    height: 120,
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                (loadingProgress
                                                                        .expectedTotalBytes ??
                                                                    1)
                                                            : null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),

                                            // Service Unavailable Overlay - Add this
                                            if (provider['isActive'] != true) // Changed from !isActive to provider['isActive'] != true
                                              Container(
                                                width: 300,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.4),
                                                  borderRadius: BorderRadius.vertical(
                                                      top: Radius.circular(15)), // Changed from 20 to 15 to match the card border radius
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 20),
                                                    child: Text(
                                                      'This service is currently unavailable',
                                                      textAlign: TextAlign.center, // Add text alignment for better display
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (provider['isVerified'] == true)
                                              Positioned(
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
                                                onTap: () => toggleFavorite(
                                                    provider['serviceId']),
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.white70,
                                                  radius: 16,
                                                  child: Icon(
                                                    isFav
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: isFav
                                                        ? Colors.red
                                                        : Colors.grey,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                provider['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xff0F3966),
                                                ),
                                              ),
                                              Text(provider['service'],
                                                  style: TextStyle(
                                                      color: Colors.black54)),
                                              SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(provider['price'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.star,
                                                          size: 14,
                                                          color: Colors.amber),
                                                      SizedBox(width: 4),
                                                      Text(provider['rating']),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ));
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
