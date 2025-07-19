
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';

import '../../../core/shared/services/image_service.dart';


class ManageApprovalsPage extends StatefulWidget {
  const ManageApprovalsPage({super.key});

  @override
  State<ManageApprovalsPage> createState() => _ManageApprovalsPageState();
}

class _ManageApprovalsPageState extends State<ManageApprovalsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService(); // Initialize ImageService
  Map<String, bool> _expandedState = {};
  String _searchQuery = "";
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: "Search unverified providers...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        )
            : AppBarTitle(text: "Verification Requests"),
        backgroundColor: Color(0xff0F3966),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = "";
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderStats(),
          Expanded(child: _buildUnverifiedProviderList()),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('service provider').where('status', isEqualTo: 0).snapshots(),
      builder: (context, snapshot) {
        int pendingCount = 0;

        if (snapshot.hasData) {
          pendingCount = snapshot.data!.docs.length;
        }

        return Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          color: Color(0xffF5F8FB),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$pendingCount',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F3966),
                      ),
                    ),
                    Text(
                      'Pending Requests',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
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

  Widget _buildUnverifiedProviderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('service provider').where('status', isEqualTo: 0).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 60, color: Colors.green[300]),
                SizedBox(height: 16),
                Text(
                  "All caught up!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff0F3966)),
                ),
                SizedBox(height: 8),
                Text(
                  "No pending verification requests",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        var providers = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {"id": doc.id, ...data};
        }).toList();

        providers = providers.where((provider) {
          String name = provider['name']?.toString().toLowerCase() ?? "";
          String email = provider['email']?.toString().toLowerCase() ?? "";
          String phone = provider['phone']?.toString().toLowerCase() ?? "";
          String address = provider['address']?.toString().toLowerCase() ?? "";
          return name.contains(_searchQuery) ||
              email.contains(_searchQuery) ||
              phone.contains(_searchQuery) ||
              address.contains(_searchQuery);
        }).toList();

        if (providers.isEmpty) {
          return Center(
            child: Text(
              "No matching providers found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          itemCount: providers.length,
          itemBuilder: (context, index) {
            var provider = providers[index];
            String providerId = provider["id"];
            bool isExpanded = _expandedState[providerId] ?? false;
            String providerName = provider['name']?.toString() ?? "Unknown";
            String? profileImageUrl = provider['profileImage']?.toString();

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: _buildProviderAvatar(providerName, profileImageUrl),
                    title: Text(
                      providerName,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff0F3966)),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider['email']?.toString() ?? "No email"),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              "Pending verification",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isLoading
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : IconButton(
                          icon: Icon(Icons.check_circle_outline),
                          color: Colors.green,
                          tooltip: "Verify Provider",
                          onPressed: () => _verifyProvider(providerId),
                        ),
                        IconButton(
                          icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _expandedState[providerId] = !isExpanded;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded) _buildProviderDetails(provider),
                  if (isExpanded) _buildVerificationActions(providerId),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProviderAvatar(String providerName, String? profileImageUrl) {
    // If we have a profile image URL, use it
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Color(0xffE6EFF9),
        radius: 25,
        backgroundImage: NetworkImage(profileImageUrl),
        // Don't set a child here - that's why the letter is showing up
        // The backgroundImage will fill the CircleAvatar
        onBackgroundImageError: (exception, stackTrace) {
          print("Error loading profile image: $exception");
          // We can't return a widget here, but we can handle the fallback elsewhere
        },
      );
    } else {
      // Otherwise show the fallback avatar with first letter
      return _buildFallbackAvatar(providerName);
    }
  }

  // Fallback avatar with first letter
  Widget _buildFallbackAvatar(String providerName) {
    String firstLetter = providerName.isNotEmpty ? providerName[0].toUpperCase() : "?";

    return CircleAvatar(
      backgroundColor: Color(0xffE6EFF9),
      radius: 25,
      child: Text(
        firstLetter,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xff0F3966),
        ),
      ),
    );
  }

  Future<void> _verifyProvider(String providerId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('service provider').doc(providerId).update({
        'status': 1,
        'isApproved': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Provider verified successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Widget _buildProviderDetails(Map<String, dynamic> provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffF5F8FB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          _buildDetailRow(Icons.phone, "Phone", provider['phone']?.toString() ?? 'N/A'),
          SizedBox(height: 8),
          _buildDetailRow(Icons.location_on, "Address", provider['address']?.toString() ?? 'N/A'),
          SizedBox(height: 8),
          _buildDetailRow(Icons.work, "Experience", "${provider['experience']?.toString() ?? 'N/A'} years"),
          SizedBox(height: 12),
          _buildServicesList("Services", (provider['services'] as List?)?.map((e) => e.toString()).toList() ?? []),
          SizedBox(height: 12),
          _buildServicesList("Availability", (provider['availability'] as List?)?.map((e) => e.toString()).toList() ?? []),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Color(0xff0F3966)),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              title == "Services" ? Icons.construction : Icons.access_time,
              size: 18,
              color: Color(0xff0F3966),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        items.isEmpty
            ? Text('N/A', style: TextStyle(fontSize: 14))
            : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xff0F3966).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff0F3966),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVerificationActions(String providerId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () {
              _showRejectDialog(providerId);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text("Reject"),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _verifyProvider(providerId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0F3966),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text("Approve Provider"),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String providerId) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reject Provider"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please provide a reason for rejection:"),
              SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: "Enter reason...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (reasonController.text.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await _firestore.collection('service provider').doc(providerId).update({
                      'status': 2, // 2 for rejected
                      'rejectionReason': reasonController.text,
                      'rejectedAt': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Provider rejected"),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Reason is required"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Reject", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}