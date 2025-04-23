// import 'package:flutter/material.dart';
//
// class ViewServicesPage extends StatefulWidget {
//   const ViewServicesPage({super.key});
//
//   @override
//   State<ViewServicesPage> createState() => _ViewServicesPageState();
// }
//
// class _ViewServicesPageState extends State<ViewServicesPage> {
//   String? selectedCategory; // To track selected category
//
//   // Define categories and their corresponding sub-services
//   final Map<String, List<Map<String, String>>> serviceCategories = {
//     'Maintenance Services': [
//       {'name': 'Plumbing works', 'image': 'assets/images/Plumbing.jpg'},
//       {'name': 'Electrical Works', 'image': 'assets/images/electrical work.jpg'},
//       {'name': 'AC Repairing', 'image': 'assets/images/AC repair.jpg'},
//       {'name': 'Painting', 'image': 'assets/images/painting.jpeg'},
//     ],
//     'Cleaning Services': [
//       {'name': 'Cleaning', 'image': 'assets/images/cleaning.jpeg'},
//       {'name': 'Car Wash', 'image': 'assets/images/car wash.jpeg'},
//       {'name': 'Laundry', 'image': 'assets/images/laundry.jpg'},
//     ],
//     'Beauty Services': [
//       {'name': "Men's Grooming", 'image': 'assets/images/mens grooming.png'},
//       {'name': "Women's Grooming", 'image': 'assets/images/womens grooming.jpg'},
//     ],
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine the services to show based on selected category
//     List<Map<String, String>> displayedServices = selectedCategory == null
//         ? serviceCategories.values.expand((services) => services).toList()
//         : serviceCategories[selectedCategory!] ?? [];
//
//     return Scaffold(
//       backgroundColor: Colors.white,
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
//         title: Text("All Services", style: TextStyle(color: Colors.white)),
//         actions: [
//           Icon(Icons.bookmark,),
//           SizedBox(width: 10),
//           Icon(Icons.notifications,),
//           SizedBox(width: 10),
//           Icon(Icons.search,),
//           SizedBox(width: 10),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Categories Section
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Text(
//               "Categories",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color(0xff0F3966)),
//             ),
//           ),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: serviceCategories.keys.map((category) {
//                 bool isSelected = category == selectedCategory;
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedCategory = (selectedCategory == category) ? null : category;
//                     });
//                   },
//                   child: Container(
//                     margin: EdgeInsets.symmetric(horizontal: 8),
//                     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.blue : Colors.white54,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected ? Colors.blue[700]! : Colors.grey[500]!,
//
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     child: Text(
//                       category,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Color(0xff0F3966),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//
//           // Services Grid Section
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: GridView.builder(
//                 itemCount: displayedServices.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 1, // Keep cards square
//                 ),
//                 itemBuilder: (context, index) {
//                   return ServiceCard(
//                     serviceImage: displayedServices[index]['image']!,
//                     serviceName: displayedServices[index]['name']!,
//                     onTap: () {
//                       Navigator.pushNamed(context, "/viewallproviderspage");
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Service Card Widget
// class ServiceCard extends StatelessWidget {
//   final String serviceImage;
//   final String serviceName;
//   final VoidCallback onTap;
//
//
//   const ServiceCard({required this.serviceImage, required this.serviceName, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                 child: Image.asset(
//                   serviceImage,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
//               ),
//               child: Center(
//                 child: Text(
//                   serviceName,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ViewServicesPage extends StatefulWidget {
//   @override
//   _ViewServicesPageState createState() => _ViewServicesPageState();
// }
//
// class _ViewServicesPageState extends State<ViewServicesPage> {
//   final Map<String, IconData> categoryIcons = {
//     "All": Icons.dashboard,
//     "Plumbing": Icons.plumbing,
//     "Electrician": Icons.electrical_services,
//     "Cleaning": Icons.cleaning_services,
//     "Painting": Icons.format_paint,
//     "AC Repair": Icons.ac_unit,
//   };
//
//   final List<String> categories = ["All", "Plumbing", "Electrician", "Cleaning", "Painting", "AC Repair"];
//   int selectedCategoryIndex = 0;
//   String searchQuery = "";
//
//   Map<String, List<Map<String, dynamic>>> serviceProviders = {
//     "Plumbing": [
//       {
//         "id": "1",
//         "name": "John",
//         "service": "Plumber",
//         "rating": "4.8",
//         "price": "₹500/hr",
//         "image": "assets/images/Jhon_plumber5.jpeg"
//       },
//       {
//         "id": "2",
//         "name": "Sam",
//         "service": "Plumber",
//         "rating": "4.6",
//         "price": "₹450/hr",
//         "image": "assets/images/Jhon_plumber5.jpeg"
//       },
//     ],
//     "Electrician": [
//       {
//         "id": "3",
//         "name": "Alex",
//         "service": "Electrician",
//         "rating": "4.7",
//         "price": "₹400/hr",
//         "image": "assets/images/Jhon_plumber5.jpeg"
//       },
//     ],
//     "Cleaning": [],
//     "Painting": [],
//     "AC Repair": [],
//   };
//
//   Set<String> favoriteProviderIds = {};
//
//   @override
//   void initState() {
//     super.initState();
//     loadFavorites();
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
//   @override
//   Widget build(BuildContext context) {
//     String selectedCategory = categories[selectedCategoryIndex];
//
//     List<Map<String, dynamic>> filteredProviders = selectedCategory == "All"
//         ? serviceProviders.values.expand((list) => list).toList()
//         : serviceProviders[selectedCategory] ?? [];
//
//     filteredProviders = filteredProviders
//         .where((provider) =>
//     provider['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
//         provider['service'].toLowerCase().contains(searchQuery.toLowerCase()))
//         .toList();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Service Categories'),
//         backgroundColor: Color(0xff0F3966),
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
//                 String category = categories[index];
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
//                         Icon(
//                           categoryIcons[category] ?? Icons.category,
//                           color: isSelected ? Color(0xff0F3966) : Colors.grey,
//                           size: 28,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           category,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: isSelected ? Color(0xff0F3966) : Colors.black54,
//                             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
//                       contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
//                       itemCount: filteredProviders.length,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 0.7,
//                       ),
//                       itemBuilder: (context, index) {
//                         var provider = filteredProviders[index];
//                         bool isFav = favoriteProviderIds.contains(provider['id']);
//
//                         return Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           elevation: 3,
//                           child: Column(
//                             children: [
//                               Stack(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//                                     child: Image.asset(
//                                       provider['image'],
//                                       height: 120,
//                                       width: double.infinity,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: 8,
//                                     right: 8,
//                                     child: GestureDetector(
//                                       onTap: () => toggleFavorite(provider['id']),
//                                       child: CircleAvatar(
//                                         backgroundColor: Colors.white70,
//                                         radius: 16,
//                                         child: Icon(
//                                           isFav ? Icons.favorite : Icons.favorite_border,
//                                           color: isFav ? Colors.red : Colors.grey,
//                                           size: 18,
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       provider['name'],
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Color(0xff0F3966),
//                                       ),
//                                     ),
//                                     Text(provider['service'], style: TextStyle(color: Colors.black54)),
//                                     SizedBox(height: 5),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Icon(Icons.star, size: 14, color: Colors.amber),
//                                             SizedBox(width: 4),
//                                             Text(provider['rating']),
//                                           ],
//                                         ),
//                                         Text(provider['price'], style: TextStyle(fontWeight: FontWeight.w600)),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         );
//                       },
//                     ),
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

class ViewServicesPage extends StatefulWidget {
  @override
  _ViewServicesPageState createState() => _ViewServicesPageState();
}

class _ViewServicesPageState extends State<ViewServicesPage> {
  List<Map<String, dynamic>> categories = [];
  int selectedCategoryIndex = 0;
  String searchQuery = "";
  List<Map<String, dynamic>> serviceProviders = [];
  Map<String, List<Map<String, dynamic>>> categorizedProviders = {};
  bool isLoading = true;
  Set<String> favoriteProviderIds = {};

  @override
  void initState() {
    super.initState();
    loadFavorites();
    fetchCategories();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorites') ?? [];
    setState(() {
      favoriteProviderIds = saved.toSet();
    });
  }

  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteProviderIds.contains(id)) {
        favoriteProviderIds.remove(id);
      } else {
        favoriteProviderIds.add(id);
      }
    });
    prefs.setStringList('favorites', favoriteProviderIds.toList());
  }

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

      // After fetching categories, fetch services
      await fetchServices();
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> fetchServices() async {
  //   try {
  //     // Fetch services from Firestore
  //     QuerySnapshot serviceSnapshot =
  //         await FirebaseFirestore.instance.collection('services').get();
  //
  //     // Initialize the categorized providers map
  //     categorizedProviders = {"All": []};
  //     for (var category in categories) {
  //       if (category["name"] != "All") {
  //         categorizedProviders[category["name"]] = [];
  //       }
  //     }
  //
  //     // Process each service
  //     for (var doc in serviceSnapshot.docs) {
  //       Map<String, dynamic> serviceData = doc.data() as Map<String, dynamic>;
  //       String categoryName = serviceData['name'];
  //       String providerId = serviceData['provider_id'];
  //
  //       // Fetch provider details
  //       DocumentSnapshot providerDoc = await FirebaseFirestore.instance
  //           .collection('service provider')
  //           .doc(providerId)
  //           .get();
  //
  //       if (providerDoc.exists) {
  //         Map<String, dynamic> providerData =
  //             providerDoc.data() as Map<String, dynamic>;
  //
  //         Map<String, dynamic> providerInfo = {
  //           "id": providerId,
  //           "name": providerData['name'],
  //           "service": categoryName,
  //           "rating": serviceData['rating'].toString(),
  //           "price": "₹${serviceData['hourly_rate']}/hr",
  //           "image": providerData['profileImage'],
  //         };
  //
  //         // Add to appropriate category
  //         if (categorizedProviders.containsKey(categoryName)) {
  //           categorizedProviders[categoryName]!.add(providerInfo);
  //         }
  //
  //         // Also add to "All" category
  //         categorizedProviders["All"]!.add(providerInfo);
  //       }
  //     }
  //
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error fetching services: $e');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
  Future<void> fetchServices() async {
    try {
      QuerySnapshot serviceSnapshot =
      await FirebaseFirestore.instance.collection('services').get();

      categorizedProviders = {"All": []};
      for (var category in categories) {
        if (category["name"] != "All") {
          categorizedProviders[category["name"]] = [];
        }
      }

      for (var doc in serviceSnapshot.docs) {
        Map<String, dynamic> serviceData = doc.data() as Map<String, dynamic>;
        String categoryName = serviceData['name'];
        String providerId = serviceData['provider_id'];

        DocumentSnapshot providerDoc = await FirebaseFirestore.instance
            .collection('service provider')
            .doc(providerId)
            .get();

        if (providerDoc.exists) {
          Map<String, dynamic> providerData =
          providerDoc.data() as Map<String, dynamic>;

          Map<String, dynamic> providerInfo = {
            "id": providerId,
            "serviceId": doc.id, // Add this line to store the service document ID
            "name": providerData['name'],
            "service": categoryName,
            "rating": serviceData['rating'].toString(),
            "price": "₹${serviceData['hourly_rate']}/hr",
            "image": providerData['profileImage'],
          };

          if (categorizedProviders.containsKey(categoryName)) {
            categorizedProviders[categoryName]!.add(providerInfo);
          }
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
        body: Center(child: CircularProgressIndicator()),
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
      ),
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
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              var provider = filteredProviders[index];
                              bool isFav =
                                  favoriteProviderIds.contains(provider['id']);

                              return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 3,
                                  child: InkWell(
                                    // Add this InkWell wrapper for tap functionality
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewServiceDetailsPage(
                                                serviceId: provider['serviceId'] ?? '',
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
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () => toggleFavorite(
                                                    provider['id']),
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
                                                  Row(
                                                    children: [
                                                      Icon(Icons.star,
                                                          size: 14,
                                                          color: Colors.amber),
                                                      SizedBox(width: 4),
                                                      Text(provider['rating']),
                                                    ],
                                                  ),
                                                  Text(provider['price'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600)),
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
