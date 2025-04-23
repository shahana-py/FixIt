//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'message_provider_page.dart';
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
//                         top: MediaQuery.of(context).padding.top + 8,
//                         right: 16,
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white,
//                           radius: 22,
//                           child: IconButton(
//                             icon: Icon(Icons.more_horiz, size: 18),
//                             onPressed: () {},
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
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
//                       icon: Icon(Icons.message, size: 16,color: Color(0xff0F3966),),
//                       label: Text('Message',style: TextStyle(color: Color(0xff0F3966),fontWeight: FontWeight.bold,fontSize: 16),),
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
//                       onPressed: () {
//                         // Handle hiring process
//                       },
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

import 'package:fixit/features/user/view/service_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_provider_page.dart';



class ViewServiceDetailsPage extends StatefulWidget {
  final String serviceId;

  const ViewServiceDetailsPage({Key? key, required this.serviceId}) : super(key: key);

  @override
  _ViewServiceDetailsPageState createState() => _ViewServiceDetailsPageState();
}

class _ViewServiceDetailsPageState extends State<ViewServiceDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? serviceData;
  Map<String, dynamic>? providerData;
  bool isLoading = true;
  int currentImageIndex = 0;
  final pageController = PageController();
  bool showFullDescription = false;
  List<String> serviceImages = [];

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    try {
      // Fetch service details
      DocumentSnapshot serviceDoc =
      await _firestore.collection('services').doc(widget.serviceId).get();

      if (serviceDoc.exists) {
        serviceData = serviceDoc.data() as Map<String, dynamic>;

        // Initialize service images array
        serviceImages = [];

        // Add work sample if exists
        if (serviceData!.containsKey('work_sample') &&
            serviceData!['work_sample'] != null &&
            serviceData!['work_sample'].toString().isNotEmpty) {
          serviceImages.add(serviceData!['work_sample']);
        }

        // Add additional work samples if they exist
        if (serviceData!.containsKey('additional_work_samples') &&
            serviceData!['additional_work_samples'] is List &&
            (serviceData!['additional_work_samples'] as List).isNotEmpty) {
          for (var image in serviceData!['additional_work_samples']) {
            if (image != null && image.toString().isNotEmpty) {
              serviceImages.add(image);
            }
          }
        }

        // If no images at all, add a placeholder
        if (serviceImages.isEmpty) {
          serviceImages.add('https://via.placeholder.com/400?text=No+Images');
        }

        // Fetch provider details
        if (serviceData!.containsKey('provider_id')) {
          DocumentSnapshot providerDoc = await _firestore
              .collection('service provider')
              .doc(serviceData!['provider_id'])
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

  void _navigateToChat() {
    if (serviceData != null && providerData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            providerId: serviceData!['provider_id'],
            providerName: providerData!['name'] ?? 'Service Provider',
            providerImage: providerData!['profileImage'] ?? '',
            serviceId: widget.serviceId,
            serviceName: serviceData!['name'] ?? 'Service',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open chat at this moment')),
      );
    }
  }

  // Navigate to the booking page
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

    // Get available areas and days
    List<dynamic> availableAreas = serviceData?['available_areas'] ?? [];
    List<dynamic> availableDays = serviceData?['available_days'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : serviceData == null
          ? Center(child: Text('Service not found'))
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image slider with back and more buttons
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
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
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Navigation buttons
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new, size: 18),
                            onPressed: () => Navigator.pop(context),
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22,
                          child: IconButton(
                            icon: Icon(Icons.more_horiz, size: 18),
                            onPressed: () {},
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Page indicator dots - only show if more than one image
                      if (serviceImages.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              serviceImages.length,
                                  (index) => Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
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
                      // Service provider profile picture
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
                                providerData!.containsKey('profileImage') &&
                                providerData!['profileImage'] != null
                                ? Image.network(
                              providerData!['profileImage'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.person, size: 30, color: Colors.grey[400]),
                                );
                              },
                            )
                                : Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.person, size: 30, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Profile info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                providerName,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF344D67),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  avgRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' (${ratingCount})',
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
                        Text(
                          '$serviceName • ${experience} year Experience',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 24),
                        Text(
                          'About me',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF344D67),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          serviceData!['description'] ??
                              'I\'m $providerName, a dedicated $serviceName with $experience years of hands-on experience. I specialize in everything from routine maintenance to complex installations and repairs.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: showFullDescription ? null : 3,
                          overflow: showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showFullDescription = !showFullDescription;
                            });
                          },
                          child: Text(
                            showFullDescription ? 'Show less' : 'Read more...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),

                        // Available Areas Section
                        if (availableAreas.isNotEmpty)
                          _buildInfoSection('Available Areas', availableAreas),

                        // Available Days Section
                        if (availableDays.isNotEmpty)
                          _buildInfoSection('Available Days', availableDays),

                        SizedBox(height: 24),

                        // Reviews section
                        Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF344D67),
                          ),
                        ),
                        SizedBox(height: 8),

                        // Stars
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        SizedBox(height: 8),

                        // Review text
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '"$providerName is a true professional. ${providerName.split(' ')[0]} quickly diagnosed the issue and fixed it with ease. Impressive expertise and dedication to the work. Good job!"',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 12),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  'Alex T',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom hire section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      icon: Icon(Icons.message, size: 16, color: Color(0xff0F3966)),
                      label: Text('Message', style: TextStyle(color: Color(0xff0F3966), fontWeight: FontWeight.bold, fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xff0F3966),
                        side: BorderSide(color: Color(0xff0F3966)),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _navigateToBooking, // Updated to use the new navigation method
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff0F3966),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
