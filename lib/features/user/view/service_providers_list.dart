import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/features/user/view/view_service_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvidersPage extends StatefulWidget {
  final String serviceCategory;
  final String serviceCategoryId;

  const ServiceProvidersPage({
    Key? key,
    required this.serviceCategory,
    required this.serviceCategoryId
  }) : super(key: key);

  @override
  _ServiceProvidersPageState createState() => _ServiceProvidersPageState();
}

class _ServiceProvidersPageState extends State<ServiceProvidersPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> topRatedProviders = [];
  List<Map<String, dynamic>> allProviders = [];
  List<Map<String, dynamic>> filteredProviders = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchServiceProviders();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (searchController.text.isEmpty) {
        isSearching = false;
        filteredProviders = [];
      } else {
        isSearching = true;
        filteredProviders = allProviders.where((provider) {
          return provider['name']
              .toString()
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) ||
              provider['address']
                  .toString()
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> fetchServiceProviders() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Get service entries matching the selected category name
      QuerySnapshot serviceSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('name', isEqualTo: widget.serviceCategory)
          .get();

      if (serviceSnapshot.docs.isEmpty) {
        setState(() {
          topRatedProviders = [];
          allProviders = [];
          isLoading = false;
        });
        return;
      }

      // Step 2: Extract all unique provider IDs from the services documents
      List<String> providerIds = serviceSnapshot.docs
          .map((doc) => doc['provider_id'] as String)
          .toSet()
          .toList();

      if (providerIds.isEmpty) {
        setState(() {
          topRatedProviders = [];
          allProviders = [];
          isLoading = false;
        });
        return;
      }

      // Step 3: Fetch service providers matching those IDs and are active
      QuerySnapshot providerSnapshot = await FirebaseFirestore.instance
          .collection('service provider')
          .where(FieldPath.documentId, whereIn: providerIds)
          .where('status', isEqualTo: 1)
          .get();

      List<Map<String, dynamic>> providers = [];

      for (var doc in providerSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Fetch rating for this provider
        double avgRating = await _fetchProviderRating(doc.id);
        data['avgRating'] = avgRating;

        // Fetch work sample from services collection
        String workSample = await _fetchWorkSample(doc.id);
        data['workSample'] = workSample;

        providers.add(data);
      }

      // Sort providers by rating (highest first)
      providers.sort((a, b) {
        double ratingA = a['avgRating'] ?? 0.0;
        double ratingB = b['avgRating'] ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      // Separate top-rated (4+ rating) and all providers
      List<Map<String, dynamic>> topRated = providers
          .where((provider) => (provider['avgRating'] ?? 0.0) >= 4.0)
          .toList();

      setState(() {
        topRatedProviders = topRated;
        allProviders = providers;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching service providers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<double> _fetchProviderRating(String providerId) async {
    try {
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('provider_id', isEqualTo: providerId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) {
        return 0.0;
      }

      double totalRating = 0.0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc['rating'] ?? 0).toDouble();
      }

      return totalRating / ratingsSnapshot.docs.length;
    } catch (e) {
      print('Error fetching rating: $e');
      return 0.0;
    }
  }

  Future<String> _fetchWorkSample(String providerId) async {
    try {
      QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('provider_id', isEqualTo: providerId)
          .limit(1)
          .get();

      if (servicesSnapshot.docs.isNotEmpty) {
        return servicesSnapshot.docs.first['work_sample'] ?? '';
      }
      return '';
    } catch (e) {
      print('Error fetching work sample: $e');
      return '';
    }
  }

  void _navigateToServiceDetails(Map<String, dynamic> provider) {
    // Navigate to service details page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewServiceDetailsPage(
          serviceId: provider['id'] ?? '', // Changed from service['id'] to provider['id']
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A3E64),
        title: AppBarTitle(text: '${widget.serviceCategory}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredProviders = [];
                }
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF1A3E64)))
          : Column(
        children: [
          // Search Bar
          if (isSearching)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search service providers...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF1A3E64)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF1A3E64)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF1A3E64), width: 2),
                  ),
                ),
              ),
            ),

          // Show search results or normal content
          if (isSearching && searchController.text.isNotEmpty)
            Expanded(
              child: filteredProviders.isEmpty
                  ? Center(child: Text('No providers found'))
                  : ListView.builder(
                itemCount: filteredProviders.length,
                itemBuilder: (context, index) {
                  return _buildServiceProviderCard(filteredProviders[index]);
                },
              ),
            )
          else ...[
            // Top Rated Section
            if (topRatedProviders.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                color: Colors.white,
                child: Text(
                  'TOP RATED IN ${widget.serviceCategory.toUpperCase()}',
                  style: TextStyle(
                    color: Color(0xFF1A3E64),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: topRatedProviders.length,
                  itemBuilder: (context, index) {
                    return _buildTopRatedProviderCard(topRatedProviders[index]);
                  },
                ),
              ),
            ],

            // All Providers Section
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.white,
              child: Text(
                'ALL SERVICE PROVIDERS\nIN THIS CATEGORY',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A3E64)
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Expanded(
              child: allProviders.isEmpty
                  ? Center(child: Text('No service providers available'))
                  : ListView.builder(
                itemCount: allProviders.length,
                itemBuilder: (context, index) {
                  return _buildServiceProviderCard(allProviders[index]);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopRatedProviderCard(Map<String, dynamic> provider) {
    return GestureDetector(
      onTap: () => _navigateToServiceDetails(provider),
      child: Container(
        width: 300,
        margin: EdgeInsets.only(right: 10),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFF1A3E64),
            ),
            child: Row(
              children: [
                _buildFlippingImageCard(provider, true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider['name'] ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.serviceCategory,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${provider['experience']}+ years',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 5),
                        _buildRatingStars(provider, true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceProviderCard(Map<String, dynamic> provider) {
    return GestureDetector(
      onTap: () => _navigateToServiceDetails(provider),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.black26,
            width: 1,
          ),
        ),
        child: Container(
          height: 207,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Row(
            children: [
              _buildFlippingImageCard(provider, false),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider['name'] ?? 'Unknown',
                        style: TextStyle(
                          color: Color(0xFF1A3E64),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.serviceCategory,
                        style: TextStyle(
                          color: Color(0xFF1A3E64),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${provider['experience']}+ years experience',
                        style: TextStyle(
                          color: Color(0xFF1A3E64),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        provider['address'] ?? 'Location not specified',
                        style: TextStyle(
                          color: Color(0xFF1A3E64),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildRatingStars(provider, false),
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

  Widget _buildFlippingImageCard(Map<String, dynamic> provider, bool isTopRated) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isTopRated ? 20 : 20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 120,
          height: isTopRated ? 180 : 189,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTopRated ? 15 : 15),
            color: Colors.grey[200],
          ),
          child: FlippingImageWidget(
            profileImage: provider['profileImage'] ?? '',
            workSample: provider['workSample'] ?? '',
            borderRadius: isTopRated ? 15 : 15,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(Map<String, dynamic> provider, bool isTopRated) {
    double rating = provider['avgRating'] ?? 0.0;
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < fullStars) {
              return Icon(
                Icons.star,
                color: Colors.amber,
                size: isTopRated ? 16 : 20,
              );
            } else if (index == fullStars && hasHalfStar) {
              return Icon(
                Icons.star_half,
                color: Colors.amber,
                size: isTopRated ? 16 : 20,
              );
            } else {
              return Icon(
                Icons.star_border,
                color: Colors.amber,
                size: isTopRated ? 16 : 20,
              );
            }
          }),
        ),
        SizedBox(width: 5),
        Text(
          '(${rating.toStringAsFixed(1)})',
          style: TextStyle(
            color: isTopRated ? Colors.white70 : Color(0xFF1A3E64),
            fontSize: isTopRated ? 12 : 14,
          ),
        ),
      ],
    );
  }
}

class FlippingImageWidget extends StatefulWidget {
  final String profileImage;
  final String workSample;
  final double borderRadius;

  const FlippingImageWidget({
    Key? key,
    required this.profileImage,
    required this.workSample,
    required this.borderRadius,
  }) : super(key: key);

  @override
  _FlippingImageWidgetState createState() => _FlippingImageWidgetState();
}

class _FlippingImageWidgetState extends State<FlippingImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showProfileImage = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start auto-flipping
    _startAutoFlip();
  }

  void _startAutoFlip() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        _flipImage();
        _startAutoFlip();
      }
    });
  }

  void _flipImage() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }

    setState(() {
      _showProfileImage = !_showProfileImage;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value * 3.14159),
          child: _animation.value <= 0.5
              ? _buildImageContainer(_showProfileImage ? widget.profileImage : widget.workSample, true)
              : Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(3.14159),
            child: _buildImageContainer(_showProfileImage ? widget.workSample : widget.profileImage, false),
          ),
        );
      },
    );
  }

  Widget _buildImageContainer(String imageUrl, bool isProfile) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: imageUrl.isNotEmpty
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              isProfile ? Icons.person : Icons.work,
              size: 50,
              color: Colors.grey,
            );
          },
        )
            : Icon(
          isProfile ? Icons.person : Icons.work,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}