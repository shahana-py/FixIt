import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
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
  List<Map<String, dynamic>> serviceProviders = [];

  @override
  void initState() {
    super.initState();
    fetchServiceProviders();
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
          serviceProviders = [];
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
          serviceProviders = [];
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
        providers.add(data);
      }

      // Optional: Sort service providers by experience
      providers.sort((a, b) {
        int expA = int.tryParse(a['experience'] ?? '0') ?? 0;
        int expB = int.tryParse(b['experience'] ?? '0') ?? 0;
        return expB.compareTo(expA);
      });

      setState(() {
        serviceProviders = providers;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching service providers: $e');
      setState(() {
        isLoading = false;
      });
    }
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
            icon: Icon(Icons.bookmark),
            color: Colors.white,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color:Color(0xFF1A3E64) ,))
          : Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.white,
            child: Text(
              'BEST IN ${widget.serviceCategory.toUpperCase()}',
              style: TextStyle(
                color: Color(0xFF1A3E64),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: serviceProviders.isEmpty
                ? Center(
              child: Text('No service providers available'),
            )
                : ListView.builder(
              itemCount: serviceProviders.length + 1, // +1 for the "See all" button
              itemBuilder: (context, index) {
                if (index == 0 && serviceProviders.isNotEmpty) {
                  // Top service provider card (highlighted)
                  return _buildTopServiceProviderCard(serviceProviders[0]);
                } else if (index == 1) {
                  // "See all service providers" button
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: Text(
                        'SEE ALL SERVICE PROVIDERS\nIN THIS CATEGORY',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A3E64)
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  // Regular service provider cards
                  return _buildServiceProviderCard(serviceProviders[index - 1]);
                }
              },
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildTopServiceProviderCard(Map<String, dynamic> provider) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),

      ),
      child: Container(
        height: 207,

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(20),
          color: Color(0xFF1A3E64),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 161,
                  height: 189,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),

                  child: provider['profileImage'] != null && provider['profileImage'].isNotEmpty
                      ? Image.network(
                    provider['profileImage'],
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.person, size: 70, color: Colors.grey),
                ),
              ),
            ),
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
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      widget.serviceCategory,
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${provider['experience']}+ years experience',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '₹${_calculateRate(provider)} Rs per hour',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),

                    _buildRatingStars(provider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceProviderCard(Map<String, dynamic> provider) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.black26, // Border color
          width: 1,           // Border width
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
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 161,
                  height: 189,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),

                  child: provider['profileImage'] != null && provider['profileImage'].isNotEmpty
                      ? Image.network(
                    provider['profileImage'],
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.person, size: 70, color: Colors.grey),
                ),
              ),
            ),
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
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
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
                      '₹${_calculateRate(provider)} Rs per hour',
                      style: TextStyle(
                        color: Color(0xFF1A3E64),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    _buildRatingStars(provider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(Map<String, dynamic> provider) {
    // Calculate rating based on experience
    int experience = int.tryParse(provider['experience'] ?? '0') ?? 0;
    int rating = experience > 3 ? 4 : experience > 2 ? 3 : experience > 1 ? 2 : 1;

    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Row(
        children: List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          );
        }),
      ),
    );
  }

  int _calculateRate(Map<String, dynamic> provider) {
    // Calculate rate based on experience (just for demo purposes)
    int experience = int.tryParse(provider['experience'] ?? '0') ?? 0;

    if (experience > 3) {
      return 500;
    } else if (experience > 2) {
      return 450;
    } else if (experience > 1) {
      return 400;
    } else {
      return 350;
    }
  }
}