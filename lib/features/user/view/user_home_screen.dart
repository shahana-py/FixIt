
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/features/user/view/view_services_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/core/utils/custom_widgets/service_category_card.dart';
import 'package:fixit/features/user/view/service_providers_list.dart';
import 'package:fixit/features/user/view/user_search_page.dart';
import 'package:fixit/features/user/view/user_side_drawer.dart';
import 'package:fixit/features/user/view/view_service_details_page.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';

import '../../../core/utils/custom_widgets/notification_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _unreadNotifications = 0;
  Position? _currentPosition;
  String? _profileImageUrl;

  // Maps to track favorites
  Set<String> _favoriteServiceIds = {};

  // Data lists
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _nearbyServices = [];

  bool _isLoading = true;
  bool _locationLoading = true;
  final PageController _offersPageController = PageController();
  Timer? _offersTimer;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _setupNotificationListener();
    _fetchOffers();
    _fetchCategories();
    _fetchServices();
    _fetchUserFavorites();

    // Initialize location and nearby services
    _determinePosition().then((_) {
      // Add a small delay to ensure location is set before fetching services
      Future.delayed(Duration(milliseconds: 500), () {
        _fetchNearbyServices();
      });
    });
    _startAutoScroll();
  }

  @override
  void dispose() {
    _offersTimer?.cancel();
    _offersPageController.dispose();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Location Services
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _locationLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() => _locationLoading = false);
    }
  }

  // Future<void> _fetchNearbyServices() async {
  //   if (_currentPosition == null) {
  //     setState(() {
  //       _nearbyServices = _services.take(3).toList();
  //       _locationLoading = false;
  //     });
  //     return;
  //   }
  //
  //   try {
  //     // Get all service providers
  //     QuerySnapshot providersSnapshot = await FirebaseFirestore.instance
  //         .collection('service provider')
  //         .get();
  //
  //     // Calculate distances and filter nearby providers (within 50km)
  //     List<Map<String, dynamic>> nearbyProvidersWithDistance = [];
  //     for (var doc in providersSnapshot.docs) {
  //       Map<String, dynamic> provider = doc.data() as Map<String, dynamic>;
  //       String address = provider['address'] ?? '';
  //
  //       if (address.isNotEmpty) {
  //         try {
  //           // Geocode the address to get latitude and longitude
  //           List<Location> locations = await locationFromAddress(address);
  //           if (locations.isNotEmpty) {
  //             double providerLatitude = locations.first.latitude;
  //             double providerLongitude = locations.first.longitude;
  //
  //             double distance = Geolocator.distanceBetween(
  //               _currentPosition!.latitude,
  //               _currentPosition!.longitude,
  //               providerLatitude,
  //               providerLongitude,
  //             ) / 1000; // Convert to kilometers
  //
  //             if (distance <= 50) { // 50km radius
  //               nearbyProvidersWithDistance.add({
  //                 ...provider,
  //                 'id': doc.id,
  //                 'distance': distance,
  //               });
  //             }
  //           }
  //         } catch (e) {
  //           print('Error geocoding address for provider ${doc.id}: $e');
  //           // Skip this provider if geocoding fails
  //           continue;
  //         }
  //       }
  //     }
  //
  //     // Sort by distance (nearest first)
  //     nearbyProvidersWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));
  //
  //     // Get all services first
  //     QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
  //         .collection('services')
  //         .get();
  //
  //     // Create a map of services by provider_id for quick lookup
  //     Map<String, List<Map<String, dynamic>>> servicesByProvider = {};
  //     for (var doc in servicesSnapshot.docs) {
  //       Map<String, dynamic> service = doc.data() as Map<String, dynamic>;
  //       String providerId = service['provider_id'] ?? '';
  //
  //       if (providerId.isNotEmpty) {
  //         if (!servicesByProvider.containsKey(providerId)) {
  //           servicesByProvider[providerId] = [];
  //         }
  //         servicesByProvider[providerId]!.add({
  //           'id': doc.id,
  //           ...service,
  //         });
  //       }
  //     }
  //
  //     // Build nearby services list maintaining distance order
  //     List<Map<String, dynamic>> nearbyServices = [];
  //
  //     // Process ALL nearby providers (don't break early)
  //     for (var provider in nearbyProvidersWithDistance) {
  //       String providerId = provider['id'];
  //       List<Map<String, dynamic>>? providerServices = servicesByProvider[providerId];
  //
  //       if (providerServices != null && providerServices.isNotEmpty) {
  //         // Add all services from this provider
  //         for (var service in providerServices) {
  //           double averageRating = await _fetchAverageRating(service['id'], providerId);
  //
  //           nearbyServices.add({
  //             'id': service['id'],
  //             'name': service['name'] ?? '',
  //             'hourly_rate': _parseNumber(service['hourly_rate']),
  //             'rating': averageRating,
  //             'rating_count': _parseNumber(service['rating_count']),
  //             'work_sample': service['work_sample'] ?? '',
  //             'work_samples': service['work_samples'] ?? [],
  //             'provider_id': providerId,
  //             'provider_name': provider['name'] ?? 'Unknown',
  //             'provider_image': provider['profileImage'] ?? '',
  //             'isApproved': provider['status'] == 1,
  //             'distance': provider['distance']?.toStringAsFixed(1) ?? 'Unknown',
  //             'isActive': service['isActive'] ?? true,
  //           });
  //         }
  //       }
  //     }
  //
  //     // Sort all services by distance (since we want all services sorted by distance, not just by provider)
  //     nearbyServices.sort((a, b) {
  //       double distanceA = double.tryParse(a['distance'].toString().replaceAll(' km', '')) ?? double.infinity;
  //       double distanceB = double.tryParse(b['distance'].toString().replaceAll(' km', '')) ?? double.infinity;
  //       return distanceA.compareTo(distanceB);
  //     });
  //
  //     // Optional: You can limit the results here if you want to show only a certain number
  //     // For example, to show only top 20 nearest services:
  //     // nearbyServices = nearbyServices.take(20).toList();
  //
  //     setState(() {
  //       _nearbyServices = nearbyServices; // Show ALL nearby services within 50km
  //       _locationLoading = false;
  //     });
  //
  //     print('Found ${nearbyServices.length} nearby services within 50km');
  //
  //   } catch (e) {
  //     print('Error fetching nearby services: $e');
  //     setState(() {
  //       _nearbyServices = _services.take(3).toList();
  //       _locationLoading = false;
  //     });
  //   }
  // }

  Future<void> _fetchNearbyServices() async {
    if (_currentPosition == null) {
      setState(() {
        // Only show top 3 active services from the general services list
        _nearbyServices = _services.where((service) => service['isActive'] == true).take(3).toList();
        _locationLoading = false;
      });
      return;
    }

    try {
      // Get all service providers
      QuerySnapshot providersSnapshot = await FirebaseFirestore.instance
          .collection('service provider')
          .get();

      // Calculate distances and filter nearby providers (within 50km)
      List<Map<String, dynamic>> nearbyProvidersWithDistance = [];
      for (var doc in providersSnapshot.docs) {
        Map<String, dynamic> provider = doc.data() as Map<String, dynamic>;
        String address = provider['address'] ?? '';

        if (address.isNotEmpty) {
          try {
            // Geocode the address to get latitude and longitude
            List<Location> locations = await locationFromAddress(address);
            if (locations.isNotEmpty) {
              double providerLatitude = locations.first.latitude;
              double providerLongitude = locations.first.longitude;

              double distance = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                providerLatitude,
                providerLongitude,
              ) / 1000; // Convert to kilometers

              if (distance <= 50) { // 50km radius
                nearbyProvidersWithDistance.add({
                  ...provider,
                  'id': doc.id,
                  'distance': distance,
                });
              }
            }
          } catch (e) {
            print('Error geocoding address for provider ${doc.id}: $e');
            // Skip this provider if geocoding fails
            continue;
          }
        }
      }

      // Sort by distance (nearest first)
      nearbyProvidersWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));

      // Get all services first
      QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .get();

      // Create a map of services by provider_id for quick lookup
      Map<String, List<Map<String, dynamic>>> servicesByProvider = {};
      for (var doc in servicesSnapshot.docs) {
        Map<String, dynamic> service = doc.data() as Map<String, dynamic>;
        String providerId = service['provider_id'] ?? '';

        if (providerId.isNotEmpty) {
          if (!servicesByProvider.containsKey(providerId)) {
            servicesByProvider[providerId] = [];
          }
          servicesByProvider[providerId]!.add({
            'id': doc.id,
            ...service,
          });
        }
      }

      // Build nearby services list maintaining distance order
      List<Map<String, dynamic>> nearbyServices = [];

      // Process ALL nearby providers (don't break early)
      for (var provider in nearbyProvidersWithDistance) {
        String providerId = provider['id'];
        List<Map<String, dynamic>>? providerServices = servicesByProvider[providerId];

        if (providerServices != null && providerServices.isNotEmpty) {
          // Add all services from this provider
          for (var service in providerServices) {
            // Only add services that are active
            bool isServiceActive = service['isActive'] ?? true;

            if (isServiceActive) {  // Filter out inactive services
              double averageRating = await _fetchAverageRating(service['id'], providerId);

              nearbyServices.add({
                'id': service['id'],
                'name': service['name'] ?? '',
                'hourly_rate': _parseNumber(service['hourly_rate']),
                'rating': averageRating,
                'rating_count': _parseNumber(service['rating_count']),
                'work_sample': service['work_sample'] ?? '',
                'work_samples': service['work_samples'] ?? [],
                'provider_id': providerId,
                'provider_name': provider['name'] ?? 'Unknown',
                'provider_image': provider['profileImage'] ?? '',
                'isApproved': provider['status'] == 1,
                'distance': provider['distance']?.toStringAsFixed(1) ?? 'Unknown',
                'isActive': service['isActive'] ?? true,
              });
            }
          }
        }
      }

      // Sort all services by distance (since we want all services sorted by distance, not just by provider)
      nearbyServices.sort((a, b) {
        double distanceA = double.tryParse(a['distance'].toString().replaceAll(' km', '')) ?? double.infinity;
        double distanceB = double.tryParse(b['distance'].toString().replaceAll(' km', '')) ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });

      // Limit to top 10 nearest active services
      nearbyServices = nearbyServices.take(10).toList();

      setState(() {
        _nearbyServices = nearbyServices; // Show top 10 nearby ACTIVE services within 50km
        _locationLoading = false;
      });

      print('Found ${nearbyServices.length} nearby active services within 50km (showing top 10)');

    } catch (e) {
      print('Error fetching nearby services: $e');
      setState(() {
        // Only show top 10 active services from the general services list as fallback
        _nearbyServices = _services.where((service) => service['isActive'] == true).take(10).toList();
        _locationLoading = false;
      });
    }
  }



  void _refreshFavorites() {
    _fetchUserFavorites();
  }

  void _showOfferPopup(String imageUrl, String offerName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                width: 400,
                height: 500,
                // width: MediaQuery.of(context).size.width * 0.9,
                // height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "assets/images/offer-banner1.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name') // Sort alphabetically
          .get();

      List<Map<String, dynamic>> categories = [];
      for (var doc in categoriesSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        categories.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'image': data['image'] ?? data['icon'] ?? '',
          'icon': data['icon'] ?? data['image'] ?? '',
        });
      }

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _categories = [
          {
            'id': '1',
            'name': 'Plumbing',
            'image':
                'https://imageapi.ralfiz.com/media/ProductImages/scaled_1000572194.jpg',
            'icon':
                'https://imageapi.ralfiz.com/media/ProductImages/scaled_1000572199.jpg'
          },
          {
            'id': '2',
            'name': 'Taxi service',
            'image':
                'https://imageapi.ralfiz.com/media/ProductImages/scaled_1000595027.jpg',
            'icon':
                'https://imageapi.ralfiz.com/media/ProductImages/scaled_1000595028.jpg'
          },
        ];
      });
    }
  }

  Future<void> _fetchUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'] ??
                currentUser.email?.split('@').first ??
                'User';
            _profileImageUrl = userDoc['profileImageUrl'];
          });
        }
      } catch (e) {
        print('Error fetching user name: $e');
        setState(() {
          _userName = currentUser.email?.split('@').first ?? 'User';
        });
      }
    }
  }

  void _setupNotificationListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _notificationSubscription?.cancel();

    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .where('recipientType', whereIn: ['all', 'user'])
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
          final filteredDocs = snapshot.docs.where((doc) {
            final data = doc.data();
            return data['recipientType'] == 'all' ||
                (data['recipientType'] == 'user' &&
                    data['recipientUid'] == currentUser.uid) ||
                (data['recipientType'] == 'user' &&
                    data['recipientId'] == null)
            ;
          }).toList();

          if (mounted) {
            setState(() {
              _unreadNotifications = filteredDocs.length;
            });
          }
        }, onError: (error) {
          print('Error listening to notifications: $error');
        });
  }

  Future<void> _markNotificationsAsRead() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('recipientType', whereIn: ['all', 'user']).get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['recipientType'] == 'all' ||
            (data['recipientType'] == 'user' &&
                data['recipientUid'] == currentUser.uid) ||
            (data['recipientType'] == 'user' &&
                data['recipientId'] == null))
    {
          batch.update(doc.reference, {'isRead': true});
        }
      }

      await batch.commit();

      if (mounted) {
        setState(() {
          _unreadNotifications = 0;
        });
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  void _openNotificationsPage() async {
    await _markNotificationsAsRead();
    await Navigator.pushNamed(context, '/usernotificationpage');
  }

  Future<void> _fetchOffers() async {
    try {
      QuerySnapshot offersSnapshot = await FirebaseFirestore.instance
          .collection('offers')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> offers = [];
      for (var doc in offersSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        offers.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
        });
      }

      setState(() {
        _offers = offers;
      });
    } catch (e) {
      print('Error fetching offers: $e');
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

        double averageRating =
            await _fetchAverageRating(doc.id, data['provider_id']);

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
          'isActive': data['isActive'] ?? true, // Add isActive field
        });
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        _isLoading = false;
      });
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

  void _startAutoScroll() {
    _offersTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_offersPageController.hasClients && _offers.isNotEmpty) {
        final currentPage = _offersPageController.page?.round() ?? 0;
        final nextPage = (currentPage + 1) % _offers.length;
        _offersPageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
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
        if (userData.containsKey('favorites') &&
            userData['favorites'] is List) {
          setState(() {
            _favoriteServiceIds =
                Set<String>.from(userData['favorites'] as List);
          });
        }
      }
    } catch (e) {
      print('Error fetching user favorites: $e');
    }
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

  num _parseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      final cleanedValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return num.tryParse(cleanedValue) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: UserSideDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: CircleAvatar(
                backgroundColor:
                    _profileImageUrl == null ? Colors.yellowAccent[600] : null,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? Icon(Icons.person, color: Colors.blue)
                    : null,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textAlign: TextAlign.start,
              "Hello,",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            AppBarTitle(text: _userName),
          ],
        ),
        actions: [
          GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, '/userfavouritespage');
                _refreshFavorites(); // Add this line to refresh when returning from favorites page
              },
              child: Icon(Icons.favorite, color: Colors.white, size: 24)),
          SizedBox(width: 10),
          Stack(
            children: [
              IconButton(
                onPressed: _openNotificationsPage,
                icon: Icon(Icons.notifications, color: Colors.white, size: 24),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966),))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Search Bar Section (same as before)
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchPage())),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Text(
                                    "Search for Services",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18),
                                  ),
                                ],
                              ),
                              Icon(Icons.keyboard_voice, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(color: Colors.black54),

                    // Offers Section (same as before)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SubText(text: "Offers"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 208,
                      child: PageView.builder(
                        controller: _offersPageController,
                        itemCount: _offers.isEmpty ? 1 : _offers.length,
                        itemBuilder: (context, index) {
                          if (_offers.isEmpty) {
                            return GestureDetector(
                              onTap: () => _showOfferPopup("", "Default Offer"),
                              child: Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    "assets/images/offer-banner1.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            );
                          }
                          return GestureDetector(
                            onTap: () => _showOfferPopup(
                                _offers[index]['imageUrl'],
                                _offers[index]['name']),
                            child: Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  _offers[index]['imageUrl'],
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    "assets/images/offer-banner1.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Divider(color: Colors.black54),
                    ),

                    // Categories Section - Now shows ALL categories
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SubText(text: "Categories"),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/userviewservicespage');
                              },
                              child: SubText(
                                text: "View All",
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ))
                        ],
                      ),
                    ),

                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                      children: _categories.map((category) {
                        return ServiceCard(
                          networkImage: category['image'],
                          serviceName: category['name'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewServicesPage(
                                  selectedCategoryName: category['name'], // Pass the category name
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    // GridView.count(
                    //   crossAxisCount: 3,
                    //   shrinkWrap: true,
                    //   physics: NeverScrollableScrollPhysics(),
                    //   mainAxisSpacing: 12,
                    //   crossAxisSpacing: 12,
                    //   childAspectRatio: 0.8,
                    //   children: _categories.map((category) {
                    //     return ServiceCard(
                    //       networkImage: category['image'],
                    //       serviceName: category['name'],
                    //       onTap: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => ServiceProvidersPage(
                    //               serviceCategory: category['name'],
                    //               serviceCategoryId: category['id'],
                    //             ),
                    //           ),
                    //         );
                    //       },
                    //     );
                    //   }).toList(),
                    // ),

                    // Nearby Services Section - Updated with location and favorites

                    // Nearby Services Section - Updated with location and favorites
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SubText(text: "Near on You"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 270, // Fixed height for both animation and content
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Content that will appear
                          if (_nearbyServices.isNotEmpty)
                            AnimatedOpacity(
                              opacity: _locationLoading ? 0 : 1,
                              duration: const Duration(milliseconds: 400),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _nearbyServices.map((service) {
                                    return _buildNearbyServiceProviderCard(
                                        name: service['provider_name'],
                                        service: service['name'],
                                        networkImage: service['work_sample'] ?? service['provider_image'],
                                        rating: service['rating'].toDouble(),
                                        ratingCount: service['rating_count'].toInt(),
                                        hourlyRate: service['hourly_rate'].toInt(),
                                        distance: "${service['distance']} km",
                                        serviceId: service['id'] ?? '',
                                        providerId: service['provider_id'] ?? '',
                                        isFavorite: _favoriteServiceIds.contains(service['id']),
                                        isActive: service['isActive'] ?? true);
                                  }).toList(),
                                ),
                              ),
                            ),

                          // Loading animation with constrained height
                          AnimatedOpacity(
                            opacity: _locationLoading ? 1 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: SizedBox(
                              height: 150, // Reduced height for animation
                              child: Lottie.asset(
                                'assets/json/searching nearby services.json',
                                fit: BoxFit.fitHeight,
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10,bottom: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       SubText(text: "Near on You"),
                    //
                    //     ],
                    //   ),
                    // ),
                    // _locationLoading
                    //     ? Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 20),
                    //   // child: CircularProgressIndicator(),
                    //   child: Lottie.asset(
                    //     'assets/json/searching nearby services.json',
                    //     fit: BoxFit.contain,
                    //   ),
                    // )
                    //     : SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: _nearbyServices.map((service) {
                    //       return _buildNearbyServiceProviderCard(
                    //           name: service['provider_name'],
                    //           service: service['name'],
                    //           networkImage: service['work_sample'] ?? service['provider_image'],
                    //           rating: service['rating'].toDouble(),
                    //           ratingCount: service['rating_count'].toInt(),
                    //           hourlyRate: service['hourly_rate'].toInt(),
                    //           distance: "${service['distance']} km",
                    //           serviceId: service['id'] ?? '',
                    //           providerId: service['provider_id'] ?? '',
                    //           isFavorite: _favoriteServiceIds.contains(service['id']),
                    //           isActive: service['isActive'] ?? true);
                    //     }).toList(),
                    //   ),
                    // ),



                    // All Services Section (same as before)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SubText(text: "All Services"),
                          SubText(
                            text: "View All",
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                    GridView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _services.isEmpty ? 6 : _services.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        if (_services.isEmpty) {
                          return _buildServiceCard(
                            name: "John",
                            service: "Plumbing",
                            imagePath: "assets/images/Jhon_plumber5.jpeg",
                            rating: 4.9,
                            hourlyRate: 500,
                            serviceId: "dummy_service_id",
                            isFavorite: false,
                            isApproved: false,
                            isActive: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('No service details available')),
                              );
                            },
                          );
                        } else {
                          final service = _services[index];
                          return _buildServiceCard(
                            name: service['provider_name'],
                            service: service['name'],
                            networkImage: service['work_sample'],
                            rating: service['rating'].toDouble(),
                            hourlyRate: service['hourly_rate'].toInt(),
                            serviceId: service['id'] ?? '',
                            isFavorite:
                                _favoriteServiceIds.contains(service['id']),
                            isApproved: service['isApproved'] ?? false,
                            isActive: service['isActive'] ?? true,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewServiceDetailsPage(
                                    serviceId: service['id'] ?? '',
                                  ),
                                ),
                              );

                              if (result == true) {
                                _refreshFavorites(); // Add this line
                                setState(() {});
                              }
                            },
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // 4. Update _buildNearbyServiceProviderCard method
  Widget _buildNearbyServiceProviderCard({
    required String name,
    required String service,
    String? imagePath,
    String? networkImage,
    required num rating,
    required num ratingCount,
    required num hourlyRate,
    required String distance,
    required String serviceId,
    required String providerId,
    required bool isFavorite,
    bool isActive = true, // Add this parameter
  }) {
    return GestureDetector(
      onTap: () async {
        if (serviceId.isNotEmpty) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ViewServiceDetailsPage(serviceId: serviceId),
            ),
          );
          if (result == true) {
            _refreshFavorites(); // Add this line
            setState(() {});
          }
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    child: networkImage != null && networkImage.isNotEmpty
                        ? Image.network(
                            networkImage,
                            width: 300,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              imagePath ?? 'assets/images/Jhon_plumber5.jpeg',
                              width: 300,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            imagePath ?? 'assets/images/Jhon_plumber5.jpeg',
                            width: 300,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Service Unavailable Overlay - Add this
                  if (!isActive)
                    Container(
                      width: 300,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            'This service is currently unavailable',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
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
              Container(
                width: 300,
                height: 100,
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(12)),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: TextStyle(
                                      color: Color(0xff0F3966),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              Text(service,
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text("${rating.toStringAsFixed(1)}",
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("₹${hourlyRate.toInt()}/hr",
                              style: TextStyle(color: Colors.black87)),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.blue, size: 16),
                              SizedBox(width: 3),
                              Text(distance.isNotEmpty ? "$distance away" : "",
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Update _buildServiceCard method
  Widget _buildServiceCard({
    required String name,
    required String service,
    String? imagePath,
    String? networkImage,
    required num rating,
    required num hourlyRate,
    required String serviceId,
    required bool isFavorite,
    required bool isApproved,
    required VoidCallback onTap,
    bool isActive = true, // Add this parameter
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: networkImage != null && networkImage.isNotEmpty
                      ? Image.network(
                          networkImage,
                          height: 175,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            imagePath ?? "assets/images/Jhon_plumber5.jpeg",
                            height: 175,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          imagePath ?? "assets/images/Jhon_plumber5.jpeg",
                          height: 175,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),

                // Service Unavailable Overlay - Add this
                if (!isActive)
                  Container(
                    height: 175,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'This service is currently unavailable',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (isApproved)
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F3966),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(service,
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        width: 47,
                        height: 25,
                        decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹${hourlyRate.toInt()}/hr",
                          style: TextStyle(
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
