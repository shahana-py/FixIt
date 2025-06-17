// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
//
// class ManageServiceProvidersPage extends StatefulWidget {
//   const ManageServiceProvidersPage({super.key});
//
//   @override
//   State<ManageServiceProvidersPage> createState() => _ManageServiceProvidersPageState();
// }
//
// class _ManageServiceProvidersPageState extends State<ManageServiceProvidersPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, bool> _expandedState = {};
//   String _searchQuery = "";
//   String _filterStatus = "All";
//   bool _isSearching = false;
//   TextEditingController _searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: _isSearching
//             ? TextField(
//           controller: _searchController,
//           autofocus: true,
//           onChanged: (value) {
//             setState(() {
//               _searchQuery = value.toLowerCase();
//             });
//           },
//           decoration: InputDecoration(
//             hintText: "Search...",
//             border: InputBorder.none,
//             hintStyle: TextStyle(color: Colors.white),
//           ),
//           style: TextStyle(color: Colors.white),
//         )
//             : AppBarTitle(text: "Manage Service Providers"),
//         backgroundColor: Color(0xff0F3966),
//         actions: [
//           IconButton(
//             icon: Icon(_isSearching ? Icons.close : Icons.search),
//             onPressed: () {
//               setState(() {
//                 _isSearching = !_isSearching;
//                 if (!_isSearching) {
//                   _searchQuery = "";
//                   _searchController.clear();
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildFilterBar(),
//           Expanded(child: _buildProviderList()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterBar() {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildFilterChip("All"),
//           _buildFilterChip("Verified"),
//           _buildFilterChip("Pending"),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterChip(String status) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 5),
//       child: FilterChip(
//         label: Text(status),
//         selected: _filterStatus == status,
//         selectedColor: Colors.blue,
//         onSelected: (selected) => setState(() => _filterStatus = status),
//       ),
//     );
//   }
//
//   Widget _buildProviderList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore.collection('service provider').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(child: Text("No service providers found"));
//         }
//
//         var providers = snapshot.data!.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           return {"id": doc.id, ...data};
//         }).toList();
//
//         providers = providers.where((provider) {
//           String name = provider['name']?.toString().toLowerCase() ?? "";
//           String email = provider['email']?.toString().toLowerCase() ?? "";
//           String phone = provider['phone']?.toString().toLowerCase() ?? "";
//           return name.contains(_searchQuery) ||
//               email.contains(_searchQuery) ||
//               phone.contains(_searchQuery);
//         }).toList();
//
//         if (_filterStatus == "Verified") {
//           providers = providers.where((provider) => provider['status'] == 1).toList();
//         } else if (_filterStatus == "Pending") {
//           providers = providers.where((provider) => provider['status'] == 0).toList();
//         }
//
//         if (providers.isEmpty) {
//           return Center(
//             child: Text(
//               _filterStatus == "Pending"
//                   ? "No pending approvals."
//                   : _filterStatus == "Verified"
//                   ? "No verified providers."
//                   : "No providers found.",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//           );
//         }
//
//         return ListView.builder(
//           itemCount: providers.length,
//           itemBuilder: (context, index) {
//             var provider = providers[index];
//             String providerId = provider["id"];
//             bool isVerified = provider['status'] == 1;
//             bool isExpanded = _expandedState[providerId] ?? false;
//
//             return Card(
//               margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Color(0xffE6EFF9),
//                       child: Icon(Icons.business, color: Color(0xff0F3966)),
//                     ),
//                     title: Text(
//                       provider['name']?.toString() ?? "Unknown",
//                       style: TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff0F3966)),
//                     ),
//                     subtitle: Text(provider['email']?.toString() ?? "No email"),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           isVerified ? Icons.check_circle : Icons.pending_actions,
//                           color: isVerified ? Colors.green : Colors.orange,
//                         ),
//                         PopupMenuButton<String>(
//                           icon: Icon(Icons.more_vert, color: Color(0xff0F3966)),
//                           onSelected: (value) {
//                             _handleProviderAction(value, providerId, isVerified);
//                           },
//                           itemBuilder: (context) => [
//                             if (isVerified)
//                               PopupMenuItem(
//                                 value: 'revoke',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.cancel, color: Colors.red),
//                                     SizedBox(width: 8),
//                                     Text('Revoke Verification'),
//                                   ],
//                                 ),
//                               )
//                             else
//                               PopupMenuItem(
//                                 value: 'verify',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.check_circle, color: Colors.green),
//                                     SizedBox(width: 8),
//                                     Text('Verify Provider'),
//                                   ],
//                                 ),
//                               ),
//                             PopupMenuItem(
//                               value: 'delete',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.delete, color: Colors.red),
//                                   SizedBox(width: 8),
//                                   Text('Delete Provider'),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       setState(() {
//                         _expandedState[providerId] = !isExpanded;
//                       });
//                     },
//                   ),
//                   if (isExpanded) _buildProviderDetails(provider),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _handleProviderAction(String action, String providerId, bool isCurrentlyVerified) async {
//     try {
//       if (action == 'revoke' && isCurrentlyVerified) {
//         await _firestore.collection('service provider').doc(providerId).update({
//           'status': 0,
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Provider verification revoked')),
//         );
//       } else if (action == 'verify' && !isCurrentlyVerified) {
//         await _firestore.collection('service provider').doc(providerId).update({
//           'status': 1,
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Provider verified successfully')),
//         );
//       } else if (action == 'delete') {
//         // Show confirmation dialog before deleting
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Confirm Deletion'),
//               content: Text('Are you sure you want to delete this provider? This action cannot be undone.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop();
//                     await _firestore.collection('service provider').doc(providerId).delete();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Provider deleted successfully')),
//                     );
//                   },
//                   child: Text('Delete', style: TextStyle(color: Colors.red)),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
//
//   Widget _buildProviderDetails(Map<String, dynamic> provider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Color(0xffF5F8FB),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(10),
//           bottomRight: Radius.circular(10),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Divider(),
//           _buildDetailRow(Icons.phone, "Phone", provider['phone']?.toString() ?? 'N/A'),
//           SizedBox(height: 8),
//           _buildDetailRow(Icons.location_on, "Address", provider['address']?.toString() ?? 'N/A'),
//           SizedBox(height: 8),
//           _buildDetailRow(Icons.work, "Experience", "${provider['experience']?.toString() ?? 'N/A'} years"),
//
//           SizedBox(height: 12),
//           _buildServicesList("Services", (provider['services'] as List?)?.map((e) => e.toString()).toList() ?? []),
//           SizedBox(height: 12),
//           _buildServicesList("Availability", (provider['availability'] as List?)?.map((e) => e.toString()).toList() ?? []),
//           SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 18, color: Color(0xff0F3966)),
//         SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildServicesList(String title, List<String> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               title == "Services" ? Icons.construction : Icons.access_time,
//               size: 18,
//               color: Color(0xff0F3966),
//             ),
//             SizedBox(width: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 6),
//         items.isEmpty
//             ? Text('N/A', style: TextStyle(fontSize: 14))
//             : Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: items.map((item) {
//             return Container(
//               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Color(0xff0F3966).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Text(
//                 item,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Color(0xff0F3966),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';

import '../../../core/shared/services/image_service.dart';


class ManageServiceProvidersPage extends StatefulWidget {
  const ManageServiceProvidersPage({super.key});

  @override
  State<ManageServiceProvidersPage> createState() => _ManageServiceProvidersPageState();
}

class _ManageServiceProvidersPageState extends State<ManageServiceProvidersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  Map<String, bool> _expandedState = {};
  String _searchQuery = "";
  String _filterStatus = "All";
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  Widget _buildProviderAvatar(String? profileImageUrl, String name) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xffE6EFF9),
        backgroundImage: NetworkImage(profileImageUrl),
        child: profileImageUrl.isEmpty
            ? Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      );
    } else {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xff0F3966),
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

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
            hintText: "Search...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        )
            : AppBarTitle(text: "Manage Service Providers"),
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
          _buildFilterBar(),
          Expanded(child: _buildProviderList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip("All"),
          _buildFilterChip("Verified"),
          _buildFilterChip("Pending"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        label: Text(status),
        selected: _filterStatus == status,
        selectedColor: Colors.blue,
        onSelected: (selected) => setState(() => _filterStatus = status),
      ),
    );
  }

  Widget _buildProviderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('service provider').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No service providers found"));
        }

        var providers = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {"id": doc.id, ...data};
        }).toList();

        providers = providers.where((provider) {
          String name = provider['name']?.toString().toLowerCase() ?? "";
          String email = provider['email']?.toString().toLowerCase() ?? "";
          String phone = provider['phone']?.toString().toLowerCase() ?? "";
          return name.contains(_searchQuery) ||
              email.contains(_searchQuery) ||
              phone.contains(_searchQuery);
        }).toList();

        if (_filterStatus == "Verified") {
          providers = providers.where((provider) => provider['status'] == 1).toList();
        } else if (_filterStatus == "Pending") {
          providers = providers.where((provider) => provider['status'] == 0).toList();
        }

        if (providers.isEmpty) {
          return Center(
            child: Text(
              _filterStatus == "Pending"
                  ? "No pending approvals."
                  : _filterStatus == "Verified"
                  ? "No verified providers."
                  : "No providers found.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          itemCount: providers.length,
          itemBuilder: (context, index) {
            var provider = providers[index];
            String providerId = provider["id"];
            bool isVerified = provider['status'] == 1;
            bool isExpanded = _expandedState[providerId] ?? false;
            String name = provider['name']?.toString() ?? "Unknown";
            String? profileImageUrl = provider['profileImage'];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: _buildProviderAvatar(profileImageUrl, name),
                    title: Text(
                      name,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff0F3966)),
                    ),
                    subtitle: Text(provider['email']?.toString() ?? "No email"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVerified ? Icons.check_circle : Icons.pending_actions,
                          color: isVerified ? Colors.green : Colors.orange,
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Color(0xff0F3966)),
                          onSelected: (value) {
                            _handleProviderAction(value, providerId, isVerified);
                          },
                          itemBuilder: (context) => [
                            if (isVerified)
                              PopupMenuItem(
                                value: 'revoke',
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Revoke Verification'),
                                  ],
                                ),
                              )
                            else
                              PopupMenuItem(
                                value: 'verify',
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('Verify Provider'),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete Provider'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _expandedState[providerId] = !isExpanded;
                      });
                    },
                  ),
                  if (isExpanded) _buildProviderDetails(provider),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleProviderAction(String action, String providerId, bool isCurrentlyVerified) async {
    try {
      if (action == 'revoke' && isCurrentlyVerified) {
        await _firestore.collection('service provider').doc(providerId).update({
          'status': 0,
          'isApproved': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Provider verification revoked')),
        );
      } else if (action == 'verify' && !isCurrentlyVerified) {
        await _firestore.collection('service provider').doc(providerId).update({
          'status': 1,
          'isApproved': true,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Provider verified successfully')),
        );
      } else if (action == 'delete') {
        // Show confirmation dialog before deleting
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Deletion'),
              content: Text('Are you sure you want to delete this provider? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _firestore.collection('service provider').doc(providerId).delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Provider deleted successfully')),
                    );
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
}