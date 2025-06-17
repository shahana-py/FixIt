import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/shared/services/image_service.dart';
import '../../../core/utils/custom_texts/app_bar_text.dart';

class ViewAllServicesPage extends StatefulWidget {
  const ViewAllServicesPage({super.key});

  @override
  State<ViewAllServicesPage> createState() => _ViewAllServicesPageState();
}

class _ViewAllServicesPageState extends State<ViewAllServicesPage> {
  final ImageService _imageService = ImageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _errorMessage = '';
  // Add this map to your state class to store service-specific ratings
  final Map<String, double> _serviceRatings = {}; // Key: 'providerId_serviceId', Value: average rating
  final Map<String, int> _serviceRatingCounts = {}; // Key: 'providerId_serviceId', Value: rating count


  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      // 1. First fetch all ratings to calculate averages
      await _fetchServiceRatings();

      // 2. Fetch all services
      final servicesSnapshot = await _firestore.collection('services').get();

      List<Map<String, dynamic>> services = [];

      // 3. Process each service
      for (var serviceDoc in servicesSnapshot.docs) {
        final serviceData = serviceDoc.data();
        final serviceId = serviceDoc.id;
        final providerId = serviceData['provider_id'];

        // 4. Fetch provider details
        final providerDoc = await _firestore.collection('service provider')
            .doc(providerId).get();
        final providerData = providerDoc.data() ?? {};

        // 5. Format work samples
        dynamic workSamples = serviceData['work_sample'] ?? '';
        List<String> workSampleList = [];

        if (workSamples is String) {
          if (workSamples.isNotEmpty) {
            workSampleList.add(workSamples);
          }
        } else if (workSamples is List) {
          workSampleList = List<String>.from(workSamples.whereType<String>());
        }

        // 6. Get the service's specific rating
        final ratingKey = '${providerId}_$serviceId';
        final averageRating = _serviceRatings[ratingKey] ?? 0.0;
        final ratingCount = _serviceRatingCounts[ratingKey] ?? 0;

        // 7. Format the complete service
        services.add({
          'id': serviceId,
          'name': serviceData['name'] ?? 'Unknown Service',
          'description': serviceData['description'] ?? '',
          'hourly_rate': (serviceData['hourly_rate'] ?? 0).toString(),
          'experience': (serviceData['experience'] ?? 0).toString(),
          'rating': averageRating,
          'rating_count': ratingCount,
          'created_at': (serviceData['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'available_areas': List<String>.from(serviceData['available_areas'] ?? []),
          'available_days': List<String>.from(serviceData['available_days'] ?? []),
          'work_samples': workSampleList,
          'provider_data': {
            'name': providerData['name'] ?? 'Unknown Provider',
            'profileImage': providerData['profileImage'] ?? '',
            'address': providerData['address'] ?? '',
            'phone': providerData['phone'] ?? '',
            'id': providerId,
          }
        });
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load services: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchServiceRatings() async {
    try {
      final ratingsSnapshot = await _firestore.collection('ratings').get();
      final Map<String, List<double>> serviceRatingsMap = {};

      // Group ratings by providerId_serviceId combination
      for (var doc in ratingsSnapshot.docs) {
        final data = doc.data();
        final providerId = data['provider_id'];
        final serviceId = data['service_id'];
        final rating = (data['rating'] ?? 0).toDouble();

        final ratingKey = '${providerId}_$serviceId';

        if (serviceRatingsMap.containsKey(ratingKey)) {
          serviceRatingsMap[ratingKey]!.add(rating);
        } else {
          serviceRatingsMap[ratingKey] = [rating];
        }
      }

      // Calculate average and count for each service
      serviceRatingsMap.forEach((key, ratings) {
        final average = ratings.reduce((a, b) => a + b) / ratings.length;
        _serviceRatings[key] = double.parse(average.toStringAsFixed(1));
        _serviceRatingCounts[key] = ratings.length;
      });
    } catch (e) {
      debugPrint('Error fetching service ratings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff0F3966),
        title: const AppBarTitle(text: "Manage Services"),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchServices,
            tooltip: 'Refresh services',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : _services.isEmpty
            ? const Center(
          child: Text(
            'No services available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final service = _services[index];
            return _buildServiceCard(service);
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
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
            // Service and Provider info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service image (first work sample if available)
                if (service['work_samples'].isNotEmpty)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildNetworkImage(service['work_samples'].first),
                    ),
                  ),
                if (service['work_samples'].isEmpty)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(
                      child: Icon(Icons.work, size: 40, color: Colors.grey),
                    ),
                  ),

                const SizedBox(width: 16),

                // Service details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'],
                        style: const TextStyle(
                          color: Color(0xff0F3966),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildRatingStars(service['rating']),
                          const SizedBox(width: 8),
                          Text(
                            '(${service['rating_count']})',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${service['hourly_rate']}/hour',
                        style: TextStyle(
                          color: Color(0xff0F3966),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Provider info
                      Row(
                        children: [
                          _buildProviderImage(service['provider_data']['profileImage']),
                          const SizedBox(width: 8),
                          Text(
                            service['provider_data']['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),





            const SizedBox(height: 16),

            // Details expansion tile
            ExpansionTile(
              title: const Text(
                'Service Details',
                style: TextStyle(
                    color: Color(0xff0F3966),
                    fontWeight: FontWeight.bold),
              ),
              children: [
                _buildDetailRow('Description', service['description']),
                _buildDetailRow('Experience', '${service['experience']} years'),
                _buildDetailRow('Available Areas', service['available_areas'].join(', ')),
                _buildDetailRow('Available Days', service['available_days'].join(', ')),
                _buildDetailRow('Created On', DateFormat('MMM d, y').format(service['created_at'])),

                // Work samples expansion if available
                if (service['work_samples'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ExpansionTile(
                    title: const Text(
                      'Work Samples',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: service['work_samples'].length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 160,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _buildNetworkImage(service['work_samples'][index]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Admin actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _deleteService(service['id']),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
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

  Widget _buildProviderImage(String imageUrl) {
    return FutureBuilder<String>(
      future: _imageService.getPlaceholderImage(),
      builder: (context, snapshot) {
        final placeholder = snapshot.data ?? '';
        return CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(imageUrl.isNotEmpty ? imageUrl : placeholder),
          onBackgroundImageError: (exception, stackTrace) =>
          const Icon(Icons.person, size: 16),
          child: imageUrl.isEmpty ? const Icon(Icons.person, size: 16) : null,
        );
      },
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return FutureBuilder<String>(
      future: _imageService.getPlaceholderImage(),
      builder: (context, snapshot) {
        final placeholder = snapshot.data ?? '';
        return Image.network(
          imageUrl.isNotEmpty ? imageUrl : placeholder,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }



  Future<void> _deleteService(String serviceId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
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
        await _firestore.collection('services').doc(serviceId).delete();
        setState(() {
          _services.removeWhere((service) => service['id'] == serviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete service: ${e.toString()}')),
        );
      }
    }
  }
}