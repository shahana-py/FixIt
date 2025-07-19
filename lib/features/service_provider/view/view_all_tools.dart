

import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/features/service_provider/view/provider_tools_order_history.dart';
import 'package:fixit/features/service_provider/view/provider_tools_ordering_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAllToolsPage extends StatefulWidget {
  const ViewAllToolsPage({Key? key}) : super(key: key);

  @override
  _ViewAllToolsPageState createState() => _ViewAllToolsPageState();
}

class _ViewAllToolsPageState extends State<ViewAllToolsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> _recommendedProducts = [];
  List<Map<String, dynamic>> _favoriteProducts = [];
  String _selectedCategory = 'All';
  double _minPrice = 0;
  double _maxPrice = 5000;
  bool _isLoading = true;
  bool _showRecommended = true;

  // New variables for improved price filter
  String _priceFilterType = 'All'; // 'All', 'Below', 'Above'
  double _priceFilterValue = 0;

  Set<String> _categories = {'All'};
  Map<String, dynamic>? _currentServiceProvider;
  List<String> _currentUserServices = [];
  Set<String> _favoriteProductIds = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchCurrentServiceProvider();
    _fetchProducts();
    _fetchCategories();
    _fetchFavorites();
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot categorySnapshot =
          await _firestore.collection('categories').get();

      Set<String> fetchedCategories = {'All'};
      for (var doc in categorySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['name'] != null) {
          fetchedCategories.add(data['name'].toString());
        }
      }

      setState(() {
        _categories = fetchedCategories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchProductRatings(String productId) async {
    try {
      QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('productId', isEqualTo: productId)
          .where('rating', isGreaterThan: 0) // Only rated orders
          .get();

      if (ratingSnapshot.docs.isEmpty) {
        return {'averageRating': 0.0, 'totalRatings': 0};
      }

      double totalRating = 0;
      int count = 0;

      for (var doc in ratingSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] ?? 0).toDouble();
        count++;
      }

      double averageRating = totalRating / count;
      return {'averageRating': averageRating, 'totalRatings': count};
    } catch (e) {
      print('Error fetching ratings: $e');
      return {'averageRating': 0.0, 'totalRatings': 0};
    }
  }

  Future<void> _fetchFavorites() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot favoritesDoc = await _firestore
          .collection('service provider')
          .doc(user.uid)
          .collection('favorites')
          .doc('products')
          .get();

      if (favoritesDoc.exists) {
        setState(() {
          _favoriteProductIds =
              Set<String>.from(favoritesDoc['productIds'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      if (_favoriteProductIds.contains(productId)) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
    });

    try {
      await _firestore
          .collection('service provider')
          .doc(user.uid)
          .collection('favorites')
          .doc('products')
          .set({
        'productIds': _favoriteProductIds.toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> products = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to product data
        return data;
      }).toList();

      setState(() {
        _allProducts = products;
        _filteredProducts = List.from(products);
      });

      if (_currentServiceProvider != null) {
        _initializeData();
      }
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading products: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchCurrentServiceProvider() async {
    try {
      setState(() {
        _isLoading = true;
      });

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      DocumentSnapshot serviceProviderDoc = await _firestore
          .collection('service provider')
          .doc(currentUser.uid)
          .get();

      if (serviceProviderDoc.exists) {
        Map<String, dynamic> serviceProviderData =
            serviceProviderDoc.data() as Map<String, dynamic>;

        setState(() {
          _currentServiceProvider = serviceProviderData;
          _currentUserServices =
              List<String>.from(serviceProviderData['services'] ?? []);
        });

        print('Current user services: $_currentUserServices'); // Debug log

        if (_allProducts.isNotEmpty) {
          _initializeData();
        }
      } else {
        print('Service provider document not found');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching service provider: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading service provider data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initializeData() {
    // Extract categories from products
    for (var product in _allProducts) {
      if (product['serviceCategories'] != null) {
        List<String> categories =
            List<String>.from(product['serviceCategories']);
        _categories.addAll(categories);
      }
    }

    // Find max price for slider
    if (_allProducts.isNotEmpty) {
      _maxPrice = _allProducts
          .map((p) => (p['price'] ?? 0).toDouble())
          .reduce((a, b) => a > b ? a : b);
    }

    _generateRecommendedProducts();

    setState(() {
      _isLoading = false;
    });
  }

  void _generateRecommendedProducts() {
    if (_currentUserServices.isEmpty) {
      setState(() {
        _showRecommended = false;
        _recommendedProducts = [];
      });
      return;
    }

    print(
        'Generating recommendations for services: $_currentUserServices'); // Debug log

    List<Map<String, dynamic>> recommended = _allProducts.where((product) {
      List<String> productCategories =
          List<String>.from(product['serviceCategories'] ?? []);
      print(
          'Product: ${product['name']}, Categories: $productCategories'); // Debug log

      // Check if any product category matches any user service (case-insensitive)
      bool matches = productCategories.any((productCategory) =>
          _currentUserServices.any((userService) =>
              productCategory.toLowerCase().trim() ==
              userService.toLowerCase().trim()));

      print('Product ${product['name']} matches: $matches'); // Debug log
      return matches;
    }).toList();

    print('Total recommended products: ${recommended.length}'); // Debug log

    setState(() {
      _showRecommended = recommended.isNotEmpty;
      _recommendedProducts = recommended;
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allProducts);

    // Search filter
    if (_searchController.text.isNotEmpty) {
      String searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((product) {
        String name = (product['name'] ?? '').toString().toLowerCase();
        String description =
            (product['description'] ?? '').toString().toLowerCase();
        return name.contains(searchTerm) || description.contains(searchTerm);
      }).toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) {
        List<String> categories =
            List<String>.from(product['serviceCategories'] ?? []);
        return categories.contains(_selectedCategory);
      }).toList();
    }

    // Price filter
    if (_priceFilterType != 'All' && _priceFilterValue > 0) {
      filtered = filtered.where((product) {
        double price = (product['price'] ?? 0).toDouble();
        if (_priceFilterType == 'Below') {
          return price <= _priceFilterValue;
        } else if (_priceFilterType == 'Above') {
          return price >= _priceFilterValue;
        }
        return true;
      }).toList();
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filters'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Price Filter',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _priceFilterType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['All', 'Below', 'Above'].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                              type == 'All' ? 'All' : '$type'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          _priceFilterType = newValue!;
                        });
                      },
                    ),
                    if (_priceFilterType != 'All') ...[
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Enter Price (₹)',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setDialogState(() {
                            _priceFilterValue = double.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',style: TextStyle(color:Color(0xff0F3966) ),),
                ),
                ElevatedButton(

                  onPressed: () {
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply',style: TextStyle(color:Color(0xff0F3966) ),),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget _buildProductCard(Map<String, dynamic> product,
  //     {bool isRecommended = false}) {
  //   double rating = 4.2 + (product.hashCode % 6) * 0.1;
  //   int reviewCount = 50 + (product.hashCode % 200);
  //   bool isFavorite = _favoriteProductIds.contains(product['id']);
  //
  //   return Container(
  //     margin: EdgeInsets.only(bottom: isRecommended ? 0 : 16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Stack(
  //           children: [
  //             // Product Image
  //             ClipRRect(
  //               borderRadius:
  //               const BorderRadius.vertical(top: Radius.circular(16)),
  //               child: Container(
  //                 height: 120,
  //                 width: double.infinity,
  //                 child: Image.network(
  //                   product['imageUrl'] ?? '',
  //                   fit: BoxFit.fill,
  //                   errorBuilder: (context, error, stackTrace) {
  //                     return Container(
  //                       color: Colors.grey[200],
  //                       child: Icon(
  //                         Icons.image_not_supported,
  //                         size: 50,
  //                         color: Colors.grey[400],
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //             // Favorite Icon
  //             Positioned(
  //               top: 8,
  //               right: 8,
  //               child: GestureDetector(
  //                 onTap: () => _toggleFavorite(product['id']),
  //                 child: Container(
  //                   padding: const EdgeInsets.all(4),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white.withOpacity(0.8),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: Icon(
  //                     isFavorite ? Icons.favorite : Icons.favorite_border,
  //                     color: isFavorite ? Colors.red : Colors.grey[700],
  //                     size: 20,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //
  //         // Product Info
  //         Padding(
  //           padding: const EdgeInsets.all(12.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Product Name
  //               Text(
  //                 product['name'] ?? 'Unknown Product',
  //                 style: TextStyle(
  //                   fontSize: isRecommended ? 14 : 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black87,
  //                 ),
  //                 maxLines: 2,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               const SizedBox(height: 3),
  //
  //               // Rating
  //               Row(
  //                 children: [
  //                   Icon(Icons.star, color: Colors.amber, size: 16),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     rating.toStringAsFixed(1),
  //                     style: const TextStyle(
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     '($reviewCount)',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.grey[600],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 3),
  //
  //               // Price
  //               Text(
  //                 '₹${product['price'] ?? 0}',
  //                 style: TextStyle(
  //                   fontSize: isRecommended ? 16 : 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.green[700],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildProductCard(Map<String, dynamic> product,
      {bool isRecommended = false}) {
    bool isFavorite = _favoriteProductIds.contains(product['id']);

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchProductRatings(product['id']),
      builder: (context, snapshot) {
        double rating =
            snapshot.hasData ? snapshot.data!['averageRating'] : 0.0;
        int reviewCount = snapshot.hasData ? snapshot.data!['totalRatings'] : 0;

        return Container(
          margin: EdgeInsets.only(bottom: isRecommended ? 0 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (keep existing image/favorite UI)
              Stack(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      child: Image.network(
                        product['imageUrl'] ?? '',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Favorite Icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product['id']),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: isRecommended ? 13 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($reviewCount)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product['price'] ?? 0}',
                      style: TextStyle(
                        fontSize: isRecommended ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle the bottom button action
  void _onBottomButtonPressed() {
    // Navigate to order history page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersHistoryPage(),
      ),
    );

    // Or you can implement any other functionality:
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Bottom button pressed!')),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/serviceProviderHome', (Route route) => false);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: AppBarTitle(text: "All Tools"),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff0F3966),
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Navigate to favorites page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(
                    favoriteProducts: _allProducts
                        .where((product) =>
                            _favoriteProductIds.contains(product['id']))
                        .toList(),
                  ),
                ),
              ).then((_) {
                // Refresh favorites when returning from favorites page
                _fetchFavorites();
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main content with padding at bottom to avoid overlap with button
          Padding(
            padding:
                const EdgeInsets.only(bottom: 80.0), // Space for the button
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await _fetchCurrentServiceProvider();
                      await _fetchProducts();
                      await _fetchCategories();
                      await _fetchFavorites();
                    },
                    child: CustomScrollView(
                      slivers: [
                        // Search and Filter Section
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: 'Search tools...',
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                        onChanged: (value) => _applyFilters(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.blue[200]!),
                                      ),
                                      child: IconButton(
                                        onPressed: _showFilterDialog,
                                        icon: Icon(Icons.tune,
                                            color: Colors.blue[600]),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Recommended Products Section
                        if (_showRecommended && _recommendedProducts.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.recommend,
                                          color: Colors.orange[600]),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Recommended for You',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Based on your services: ${_currentUserServices.join(', ')}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (_showRecommended && _recommendedProducts.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Container(
                              height: 230,
                              color: Colors.white,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                itemCount: _recommendedProducts.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailPage(
                                            product:
                                                _recommendedProducts[index],
                                          ),
                                        ),
                                      ).then((_) {
                                        // Refresh favorites when returning from details page
                                        _fetchFavorites();
                                      });
                                    },
                                    child: Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: _buildProductCard(
                                          _recommendedProducts[index],
                                          isRecommended: true),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        if (_showRecommended && _recommendedProducts.isNotEmpty)
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 16),
                          ),

                        // All Products Section
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'All Tools (${_filteredProducts.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_selectedCategory != 'All' ||
                                    _searchController.text.isNotEmpty ||
                                    _priceFilterType != 'All')
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = 'All';
                                        _searchController.clear();
                                        _priceFilterType = 'All';
                                        _priceFilterValue = 0;
                                      });
                                      _applyFilters();
                                    },
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Clear Filters'),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Products Grid
                        _filteredProducts.isEmpty
                            ? SliverToBoxAdapter(
                                child: Container(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.search_off,
                                            size: 64, color: Colors.grey),
                                        SizedBox(height: 16),
                                        Text(
                                          'No tools found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Try adjusting your search or filters',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.all(16.0),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetailPage(
                                                product:
                                                    _filteredProducts[index],
                                              ),
                                            ),
                                          ).then((_) {
                                            // Refresh favorites when returning from details page
                                            _fetchFavorites();
                                          });
                                        },
                                        child: _buildProductCard(
                                            _filteredProducts[index]),
                                      );
                                    },
                                    childCount: _filteredProducts.length,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
          ),

          // Fixed bottom button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _onBottomButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0F3966),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View Order History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteProducts;

  const FavoritesPage({Key? key, required this.favoriteProducts})
      : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Set<String> _favoriteProductIds = {};
  List<Map<String, dynamic>> _currentFavorites = [];

  @override
  void initState() {
    super.initState();
    _currentFavorites = List.from(widget.favoriteProducts);
    _favoriteProductIds = Set<String>.from(
        widget.favoriteProducts.map((product) => product['id']).toList());
  }

  Future<Map<String, dynamic>> _fetchProductRatings(String productId) async {
    try {
      QuerySnapshot ratingSnapshot = await _firestore
          .collection('orders')
          .where('productId', isEqualTo: productId)
          .where('rating', isGreaterThan: 0)
          .get();

      if (ratingSnapshot.docs.isEmpty) {
        return {'averageRating': 0.0, 'totalRatings': 0};
      }

      double totalRating = 0;
      for (var doc in ratingSnapshot.docs) {
        totalRating += (doc['rating'] as num).toDouble();
      }

      double averageRating = totalRating / ratingSnapshot.docs.length;
      return {
        'averageRating': averageRating,
        'totalRatings': ratingSnapshot.docs.length,
      };
    } catch (e) {
      print('Error fetching ratings: $e');
      return {'averageRating': 0.0, 'totalRatings': 0};
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _favoriteProductIds.remove(productId);
      _currentFavorites.removeWhere((product) => product['id'] == productId);
    });

    await _firestore
        .collection('service provider')
        .doc(user.uid)
        .collection('favorites')
        .doc('products')
        .set({
      'productIds': _favoriteProductIds.toList(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(text: "Favorite Tools"),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff0F3966),
      ),
      body: _currentFavorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite tools yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _currentFavorites.length,
              // itemBuilder: (context, index) {
              //   return GestureDetector(
              //     onTap: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => ProductDetailPage(
              //             product: _currentFavorites[index],
              //           ),
              //         ),
              //       );
              //     },
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(16),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.grey.withOpacity(0.1),
              //             spreadRadius: 1,
              //             blurRadius: 8,
              //             offset: const Offset(0, 2),
              //           ),
              //         ],
              //       ),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Stack(
              //             children: [
              //               // Product Image
              //               ClipRRect(
              //                 borderRadius: const BorderRadius.vertical(
              //                     top: Radius.circular(16)),
              //                 child: Container(
              //                   height: 120,
              //                   width: double.infinity,
              //                   child: Image.network(
              //                     _currentFavorites[index]['imageUrl'] ?? '',
              //                     fit: BoxFit.fill,
              //                     errorBuilder: (context, error, stackTrace) {
              //                       return Container(
              //                         color: Colors.grey[200],
              //                         child: Icon(
              //                           Icons.image_not_supported,
              //                           size: 50,
              //                           color: Colors.grey[400],
              //                         ),
              //                       );
              //                     },
              //                   ),
              //                 ),
              //               ),
              //               // Unfavorite Icon
              //               Positioned(
              //                 top: 8,
              //                 right: 8,
              //                 child: GestureDetector(
              //                   onTap: () => _toggleFavorite(
              //                       _currentFavorites[index]['id']),
              //                   child: Container(
              //                     padding: const EdgeInsets.all(4),
              //                     decoration: BoxDecoration(
              //                       color: Colors.white.withOpacity(0.8),
              //                       shape: BoxShape.circle,
              //                     ),
              //                     child: Icon(
              //                       Icons.favorite,
              //                       color: Colors.red,
              //                       size: 20,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //
              //           // Product Info
              //           Padding(
              //             padding: const EdgeInsets.all(12.0),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 // Product Name
              //                 Text(
              //                   _currentFavorites[index]['name'] ??
              //                       'Unknown Product',
              //                   style: const TextStyle(
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.bold,
              //                     color: Colors.black87,
              //                   ),
              //                   maxLines: 2,
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //                 const SizedBox(height: 8),
              //
              //                 // Price
              //                 Text(
              //                   '₹${_currentFavorites[index]['price'] ?? 0}',
              //                   style: TextStyle(
              //                     fontSize: 16,
              //                     fontWeight: FontWeight.bold,
              //                     color: Colors.green[700],
              //                     // Continuing from where your code was cut off...
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   );
              // },
        itemBuilder: (context, index) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchProductRatings(_currentFavorites[index]['id']),
            builder: (context, snapshot) {
              double rating = snapshot.data?['averageRating'] ?? 0.0;
              int reviewCount = snapshot.data?['totalRatings'] ?? 0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        product: _currentFavorites[index],
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... (keep existing image/favorite stack)
                  Stack(
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Container(
                                    height: 120,
                                    width: double.infinity,
                                    child: Image.network(
                                      _currentFavorites[index]['imageUrl'] ?? '',
                                      fit: BoxFit.fill,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Unfavorite Icon
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _toggleFavorite(
                                        _currentFavorites[index]['id']),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentFavorites[index]['name'] ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($reviewCount)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${_currentFavorites[index]['price'] ?? 0}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
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
}

// ProductDetailPage class that's referenced in your navigation
class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isFavorite = false;
  bool _isLoading = false;
  double _averageRating = 0.0;
  int _totalRatings = 0;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _fetchProductRatings();
  }

  Future<void> _checkIfFavorite() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot favoritesDoc = await _firestore
          .collection('service provider')
          .doc(user.uid)
          .collection('favorites')
          .doc('products')
          .get();

      if (favoritesDoc.exists) {
        List<String> favoriteIds =
            List<String>.from(favoritesDoc['productIds'] ?? []);
        setState(() {
          _isFavorite = favoriteIds.contains(widget.product['id']);
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot favoritesDoc = await _firestore
          .collection('service provider')
          .doc(user.uid)
          .collection('favorites')
          .doc('products')
          .get();

      Set<String> favoriteIds = {};
      if (favoritesDoc.exists) {
        favoriteIds = Set<String>.from(favoritesDoc['productIds'] ?? []);
      }

      if (_isFavorite) {
        favoriteIds.remove(widget.product['id']);
      } else {
        favoriteIds.add(widget.product['id']);
      }

      await _firestore
          .collection('service provider')
          .doc(user.uid)
          .collection('favorites')
          .doc('products')
          .set({
        'productIds': favoriteIds.toList(),
      }, SetOptions(merge: true));

      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          backgroundColor: _isFavorite ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorites'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _fetchProductRatings() async {
    try {
      QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('productId', isEqualTo: widget.product['id'])
          .where('rating', isGreaterThan: 0)
          .get();

      if (ratingSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in ratingSnapshot.docs) {
        totalRating += (doc['rating'] ?? 0).toDouble();
      }

      setState(() {
        _averageRating = totalRating / ratingSnapshot.docs.length;
        _totalRatings = ratingSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching ratings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double rating = 4.2 + (widget.product.hashCode % 6) * 0.1;
    int reviewCount = 50 + (widget.product.hashCode % 200);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.product['name'] ?? 'Product Details'),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff0F3966),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _toggleFavorite,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                widget.product['imageUrl'] ?? '',
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),

            // Product Details
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product['name'] ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F3966),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < _averageRating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,

                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($_totalRatings)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Text(
                    '₹${widget.product['price'] ?? 0}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (widget.product['description'] != null &&
                      widget.product['description'].isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Categories
                  if (widget.product['serviceCategories'] != null &&
                      (widget.product['serviceCategories'] as List)
                          .isNotEmpty) ...[
                    const Text(
                      'Service categories for which this tool can be used for:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (widget.product['serviceCategories']
                              as List<dynamic>)
                          .map<Widget>((category) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Text(
                                  category.toString(),
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to OrderToolsPage with the current product
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderToolsPage(product: widget.product),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white),
                label: const Text('Buy Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rent Tool'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tool: ${widget.product['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Price: ₹${widget.product['price']}'),
              const SizedBox(height: 16),
              const Text('Select rental duration:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['1 Day', '3 Days', '1 Week', '2 Weeks', '1 Month']
                    .map((String duration) {
                  return DropdownMenuItem<String>(
                    value: duration,
                    child: Text(duration),
                  );
                }).toList(),
                onChanged: (String? value) {
                  // Handle duration selection
                },
                hint: const Text('Select duration'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Rental booking feature not implemented yet')),
                );
              },
              child: const Text('Book Now'),
            ),
          ],
        );
      },
    );
  }
}
