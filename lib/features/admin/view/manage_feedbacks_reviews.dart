
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/shared/services/image_service.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  final ImageService _imageService = ImageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      // 1. Fetch all reviews from ratings collection
      final ratingsSnapshot = await _firestore.collection('ratings').get();

      List<Map<String, dynamic>> reviews = [];

      // 2. Process each review
      for (var ratingDoc in ratingsSnapshot.docs) {
        final ratingData = ratingDoc.data();

        // 3. Fetch user details
        final userDoc = await _firestore.collection('users').doc(ratingData['user_id']).get();
        final userData = userDoc.data() ?? {};

        // 4. Fetch provider details
        final providerDoc = await _firestore.collection('service provider').doc(ratingData['provider_id']).get();
        final providerData = providerDoc.data() ?? {};

        // 5. Fetch service details
        final serviceDoc = await _firestore.collection('services').doc(ratingData['service_id']).get();
        final serviceData = serviceDoc.data() ?? {};

        // 6. Format the complete review
        reviews.add({
          'booking_id': ratingDoc.id,
          'created_at': (ratingData['created_at'] as Timestamp).toDate(),
          'feedback': ratingData['feedback'] ?? '',
          'rating': (ratingData['rating'] ?? 0).toInt(), // Convert to int here
          'user_data': {
            'name': userData['name'] ?? 'Unknown User',
            'address': userData['address'] ?? '',
            'profileImageUrl': userData['profileImageUrl'] ?? '',
          },
          'service_data': {
            'name': serviceData['name'] ?? 'Unknown Service',
          },
          'provider_data': {
            'name': providerData['name'] ?? 'Unknown Provider',
            'profileImage': providerData['profileImage'] ?? '',
          }
        });
      }

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reviews: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Customer Reviews"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReviews,
            tooltip: 'Refresh reviews',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : _reviews.isEmpty
            ? const Center(
          child: Text(
            'No reviews available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return _buildReviewCard(review);
          },
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User and Provider info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildProfileImage(
                            review['user_data']['profileImageUrl'],
                            review['user_data']['name'],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['user_data']['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                review['user_data']['address'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reviewed ${DateFormat('MMM d, y').format(review['created_at'])}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Provider info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                review['provider_data']['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                review['service_data']['name'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          _buildProfileImage(
                            review['provider_data']['profileImage'],
                            review['provider_data']['name'],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRatingStars(review['rating'].toDouble()), // Convert to double here
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Feedback text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review['feedback'],
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 8),

            // Booking ID and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID: ${review['booking_id']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flag, size: 20),
                      onPressed: () => _flagReview(review['booking_id']),
                      tooltip: 'Flag review',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _deleteReview(review['booking_id']),
                      tooltip: 'Delete review',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl, String name) {
    return FutureBuilder<String>(
      future: _imageService.getPlaceholderImage(),
      builder: (context, snapshot) {
        final placeholder = snapshot.data ?? '';
        return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(imageUrl.isNotEmpty ? imageUrl : placeholder),
          onBackgroundImageError: (exception, stackTrace) =>
          const Icon(Icons.person, size: 20),
          child: imageUrl.isEmpty ? Text(name[0]) : null,
        );
      },
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Future<void> _flagReview(String bookingId) async {
    try {
      await _firestore.collection('ratings').doc(bookingId).update({
        'flagged': true,
        'flagged_at': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review flagged for moderation')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to flag review: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteReview(String bookingId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _firestore.collection('ratings').doc(bookingId).delete();
        setState(() {
          _reviews.removeWhere((review) => review['booking_id'] == bookingId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete review: ${e.toString()}')),
        );
      }
    }
  }
}