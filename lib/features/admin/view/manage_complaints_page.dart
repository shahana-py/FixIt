//
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// class ManageComplaintsPage extends StatefulWidget {
//   const ManageComplaintsPage({Key? key}) : super(key: key);
//
//   @override
//   _ManageComplaintsPageState createState() => _ManageComplaintsPageState();
// }
//
// class _ManageComplaintsPageState extends State<ManageComplaintsPage>
//     with SingleTickerProviderStateMixin {
//   bool _isLoading = false;
//   TabController? _tabController;
//   List<Map<String, dynamic>> _complaints = [];
//   String _selectedFilter = 'All';
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();
//   String? _selectedStatus;
//
//   final List<String> _filterOptions = ['All', 'Pending', 'In Progress', 'Resolved'];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController!.addListener(_handleTabChange);
//     _fetchComplaints();
//   }
//
//   void _handleTabChange() {
//     if (_tabController!.indexIsChanging) {
//       setState(() {
//         _selectedFilter = 'All';
//         _searchQuery = '';
//         _searchController.clear();
//       });
//       _fetchComplaints();
//     }
//   }
//
//   Future<void> _fetchComplaints() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       String reportedBy = _tabController!.index == 0 ? 'user' : 'service provider';
//
//       Query query = FirebaseFirestore.instance
//           .collection('complaints')
//           .where('reportedBy', isEqualTo: reportedBy)
//           .orderBy('timestamp', descending: true);
//
//       if (_selectedFilter != 'All') {
//         query = query.where('status', isEqualTo: _selectedFilter);
//       }
//
//       final snapshot = await query.get();
//
//       final complaints = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return {
//           'id': doc.id,
//           ...data,
//           'timestamp': data['timestamp']?.toDate() ?? DateTime.now(),
//           'resolvedAt': data['resolvedAt']?.toDate(),
//         };
//       }).toList();
//
//       setState(() {
//         _complaints = complaints;
//         _isLoading = false;
//       });
//     } catch (error) {
//       print('Error fetching complaints: $error');
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error fetching complaints: ${error.toString()}'),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     }
//   }
//
//   void _filterComplaints(String filter) {
//     setState(() {
//       _selectedFilter = filter;
//     });
//     _fetchComplaints();
//   }
//
//   void _searchComplaints(String query) {
//     setState(() {
//       _searchQuery = query.toLowerCase();
//     });
//   }
//
//   List<Map<String, dynamic>> get _filteredComplaints {
//     if (_searchQuery.isEmpty) {
//       return _complaints;
//     }
//
//     return _complaints.where((complaint) {
//       final title = complaint['title'].toString().toLowerCase();
//       final description = complaint['description'].toString().toLowerCase();
//       final reporterName = complaint['reporterName'].toString().toLowerCase();
//
//       return title.contains(_searchQuery) ||
//           description.contains(_searchQuery) ||
//           reporterName.contains(_searchQuery);
//     }).toList();
//   }
//
//   Future<void> _updateComplaintStatus(String complaintId, String newStatus) async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });
//
//       final complaintDoc = await FirebaseFirestore.instance
//           .collection('complaints')
//           .doc(complaintId)
//           .get();
//
//       final complaintData = complaintDoc.data();
//
//       if (complaintData == null) {
//         throw Exception('Complaint not found');
//       }
//
//       final reporterUid = complaintData['reporterUid'] as String;
//       final reportedBy = complaintData['reportedBy'] as String;
//       final reporterName = complaintData['reporterName'] as String;
//       final complaintTitle = complaintData['title'] as String;
//
//       await FirebaseFirestore.instance
//           .collection('complaints')
//           .doc(complaintId)
//           .update({
//         'status': newStatus,
//         'resolved': newStatus == 'Resolved',
//         'resolvedAt': newStatus == 'Resolved' ? FieldValue.serverTimestamp() : null,
//         'resolvedBy': 'admin@gmail.com',
//       });
//
//       if (newStatus == 'Resolved') {
//         await _sendNotificationToReporter(
//           reporterUid: reporterUid,
//           reportedBy: reportedBy,
//           complaintId: complaintId,
//           complaintTitle: complaintTitle,
//           reporterName: reporterName,
//         );
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Complaint status updated to $newStatus'),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       await _fetchComplaints();
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error updating status: ${error.toString()}'),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _sendNotificationToReporter({
//     required String reporterUid,
//     required String reportedBy,
//     required String complaintId,
//     required String complaintTitle,
//     required String reporterName,
//   }) async {
//     try {
//       String collectionName = reportedBy == 'user' ? 'users' : 'service provider';
//
//       await FirebaseFirestore.instance.collection('notifications').add({
//         'createdAt': FieldValue.serverTimestamp(),
//         'title': 'Complaint Resolved',
//         'message': 'Your complaint "$complaintTitle" has been resolved.',
//         'recipientUid': reporterUid,
//         'recipientType': reportedBy,
//         'senderEmail': 'admin@gmail.com',
//         'senderName': 'Admin',
//         'type': 'complaint_resolved',
//         'complaintId': complaintId,
//         'isRead': false,
//         'action': '/complaints/$complaintId',
//       });
//
//       await FirebaseFirestore.instance
//           .collection(collectionName)
//           .doc(reporterUid)
//           .collection('notifications')
//           .add({
//         'createdAt': FieldValue.serverTimestamp(),
//         'title': 'Complaint Resolved',
//         'message': 'Your complaint "$complaintTitle" has been resolved.',
//         'isRead': false,
//         'type': 'complaint_resolved',
//         'complaintId': complaintId,
//       });
//
//       print('Notification sent successfully to $reportedBy ($reporterUid)');
//     } catch (error) {
//       print('Failed to send notification: $error');
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Pending':
//         return Colors.orange;
//       case 'In Progress':
//         return Colors.blue;
//       case 'Resolved':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   Future<void> _showComplaintDetails(Map<String, dynamic> complaint) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           complaint['title'],
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Color(0xff0F3966),
//           ),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         content: SingleChildScrollView(
//           child: Container(
//             width: double.maxFinite,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildDetailItem(
//                   'Description',
//                   complaint['description'],
//                   isMultiLine: true,
//                 ),
//                 Divider(height: 24),
//                 _buildDetailItem(
//                   'Reported By',
//                   '${complaint['reporterName']} (${complaint['reportedBy']})',
//                 ),
//                 SizedBox(height: 16),
//                 _buildDetailItem(
//                   'Date',
//                   DateFormat('MMM d, yyyy - hh:mm a').format(complaint['timestamp']),
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'Status:',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     fontSize: 15,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(complaint['status']),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     complaint['status'],
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 if (complaint['status'] == 'Resolved' && complaint['resolvedAt'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16.0),
//                     child: _buildDetailItem(
//                       'Resolved on',
//                       DateFormat('MMM d, yyyy - hh:mm a').format(complaint['resolvedAt']!),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'Close',
//               style: TextStyle(
//                 color: Colors.red,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           if (complaint['status'] != 'Resolved')
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xff0F3966),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _showStatusUpdateDialog(complaint);
//               },
//               child: Text(
//                 'Update Status',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailItem(String label, String value, {bool isMultiLine = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '$label:',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//             fontSize: 15,
//           ),
//         ),
//         SizedBox(height: 6),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.black54,
//             height: isMultiLine ? 1.5 : 1.2,
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showStatusUpdateDialog(Map<String, dynamic> complaint) {
//     final List<String> statusOptions = ['Pending', 'In Progress', 'Resolved'];
//     _selectedStatus = complaint['status'];
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Text(
//               'Update Complaint Status',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xff0F3966),
//               ),
//             ),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             content: Container(
//               width: double.maxFinite,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: statusOptions.map((status) => RadioListTile<String>(
//                   title: Text(
//                     status,
//                     style: TextStyle(
//                       color: _getStatusColor(status),
//                       fontWeight: _selectedStatus == status ? FontWeight.bold : FontWeight.normal,
//                     ),
//                   ),
//                   value: status,
//                   groupValue: _selectedStatus,
//                   activeColor: _getStatusColor(status),
//                   onChanged: (String? value) {
//                     setState(() {
//                       _selectedStatus = value;
//                     });
//                   },
//                 )).toList(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xff0F3966),
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: () {
//                   if (_selectedStatus != null) {
//                     Navigator.of(context).pop();
//                     _updateComplaintStatus(complaint['id'], _selectedStatus!);
//                   }
//                 },
//                 child: Text(
//                   'Update',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildComplaintsList() {
//     if (_isLoading) {
//       return Center(
//         child: CircularProgressIndicator(
//           color: Color(0xff0F3966),
//           strokeWidth: 3,
//         ),
//       );
//     }
//
//     if (_filteredComplaints.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.inbox_outlined,
//               size: 86,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _selectedFilter == 'All'
//                   ? 'No complaints found'
//                   : 'No ${_selectedFilter.toLowerCase()} complaints found',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Pull down to refresh',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _fetchComplaints,
//       color: Color(0xff0F3966),
//       child: ListView.builder(
//         itemCount: _filteredComplaints.length,
//         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         itemBuilder: (context, index) {
//           final complaint = _filteredComplaints[index];
//           return Card(
//             margin: EdgeInsets.only(bottom: 12),
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () => _showComplaintDetails(complaint),
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             complaint['title'],
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Color(0xff0F3966),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: _getStatusColor(complaint['status']),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             complaint['status'],
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12),
//                     Text(
//                       complaint['description'],
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                         height: 1.3,
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     Divider(height: 1, thickness: 1, color: Colors.grey[200]),
//                     SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               backgroundColor: Colors.grey[200],
//                               radius: 12,
//                               child: Icon(
//                                 Icons.person,
//                                 size: 14,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             SizedBox(width: 6),
//                             Text(
//                               complaint['reporterName'],
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey[600],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 14,
//                               color: Colors.grey[600],
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               DateFormat('MMM d, yyyy').format(complaint['timestamp']),
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//         title: AppBarTitle(text: "Complaint Management"),
//         backgroundColor: Color(0xff0F3966),
//
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(kToolbarHeight),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Color(0xff0F3966),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: TabBar(
//               unselectedLabelColor: Colors.white.withOpacity(0.7),
//               controller: _tabController,
//               indicatorColor: Colors.blue[100],
//               indicatorWeight: 3,
//               labelColor: Colors.blue[100],
//               labelStyle: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15,
//               ),
//               unselectedLabelStyle: TextStyle(
//                 fontWeight: FontWeight.normal,
//                 fontSize: 15,
//               ),
//               tabs: const [
//                 Tab(text: 'User Complaints'),
//                 Tab(text: 'Provider Complaints'),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search complaints...',
//                       hintStyle: TextStyle(color: Colors.grey[400]),
//                       prefixIcon: Icon(Icons.search, color: Color(0xff0F3966)),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Color(0xff0F3966)),
//                       ),
//                       contentPadding: EdgeInsets.symmetric(vertical: 0),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     onChanged: _searchComplaints,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     height: 48,
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!),
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.white,
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: _selectedFilter,
//                         isExpanded: true,
//                         icon: Icon(Icons.filter_list, color: Color(0xff0F3966)),
//                         iconSize: 20,
//                         borderRadius: BorderRadius.circular(12),
//                         style: TextStyle(
//                           color: Colors.black87,
//                           fontSize: 14,
//                         ),
//                         items: _filterOptions.map((String filter) {
//                           return DropdownMenuItem<String>(
//                             value: filter,
//                             child: Text(
//                               filter,
//                               style: TextStyle(
//                                 fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
//                                 color: filter != 'All' ? _getStatusColor(filter) : Colors.black87,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           if (newValue != null) {
//                             _filterComplaints(newValue);
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             alignment: Alignment.centerLeft,
//             child: Text(
//               'Total: ${_filteredComplaints.length} complaints',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildComplaintsList(),
//                 _buildComplaintsList(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _tabController?.removeListener(_handleTabChange);
//     _tabController?.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
// }



import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../core/shared/services/image_service.dart';

class ManageComplaintsPage extends StatefulWidget {
  const ManageComplaintsPage({Key? key}) : super(key: key);

  @override
  _ManageComplaintsPageState createState() => _ManageComplaintsPageState();
}

class _ManageComplaintsPageState extends State<ManageComplaintsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  TabController? _tabController;
  List<Map<String, dynamic>> _complaints = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  final ImageService _imageService = ImageService();

  final List<String> _filterOptions = ['All', 'Pending', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_handleTabChange);
    _fetchComplaints();
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {
      setState(() {
        _selectedFilter = 'All';
        _searchQuery = '';
        _searchController.clear();
      });
      _fetchComplaints();
    }
  }

  Future<void> _fetchComplaints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String reportedBy = _tabController!.index == 0 ? 'user' : 'service provider';

      Query query = FirebaseFirestore.instance
          .collection('complaints')
          .where('reportedBy', isEqualTo: reportedBy)
          .orderBy('timestamp', descending: true);

      if (_selectedFilter != 'All') {
        query = query.where('status', isEqualTo: _selectedFilter);
      }

      final snapshot = await query.get();

      final complaints = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'timestamp': data['timestamp']?.toDate() ?? DateTime.now(),
          'resolvedAt': data['resolvedAt']?.toDate(),
        };
      }).toList();

      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching complaints: $error');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching complaints: ${error.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _filterComplaints(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _fetchComplaints();
  }

  void _searchComplaints(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Map<String, dynamic>> get _filteredComplaints {
    if (_searchQuery.isEmpty) {
      return _complaints;
    }

    return _complaints.where((complaint) {
      final title = complaint['title'].toString().toLowerCase();
      final description = complaint['description'].toString().toLowerCase();
      final reporterName = complaint['reporterName'].toString().toLowerCase();

      return title.contains(_searchQuery) ||
          description.contains(_searchQuery) ||
          reporterName.contains(_searchQuery);
    }).toList();
  }

  Future<void> _updateComplaintStatus(String complaintId, String newStatus) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final complaintDoc = await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .get();

      final complaintData = complaintDoc.data();

      if (complaintData == null) {
        throw Exception('Complaint not found');
      }

      final reporterUid = complaintData['reporterUid'] as String;
      final reportedBy = complaintData['reportedBy'] as String;
      final reporterName = complaintData['reporterName'] as String;
      final complaintTitle = complaintData['title'] as String;

      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .update({
        'status': newStatus,
        'resolved': newStatus == 'Resolved',
        'resolvedAt': newStatus == 'Resolved' ? FieldValue.serverTimestamp() : null,
        'resolvedBy': 'admin@gmail.com',
      });

      if (newStatus == 'Resolved') {
        await _sendNotificationToReporter(
          reporterUid: reporterUid,
          reportedBy: reportedBy,
          complaintId: complaintId,
          complaintTitle: complaintTitle,
          reporterName: reporterName,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint status updated to $newStatus'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );

      await _fetchComplaints();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${error.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendNotificationToReporter({
    required String reporterUid,
    required String reportedBy,
    required String complaintId,
    required String complaintTitle,
    required String reporterName,
  }) async {
    try {
      String collectionName = reportedBy == 'user' ? 'users' : 'service provider';

      await FirebaseFirestore.instance.collection('notifications').add({
        'createdAt': FieldValue.serverTimestamp(),
        'title': 'Complaint Resolved',
        'message': 'Your complaint "$complaintTitle" has been resolved.',
        'recipientUid': reporterUid,
        'recipientType': reportedBy,
        'senderEmail': 'admin@gmail.com',
        'senderName': 'Admin',
        'type': 'complaint_resolved',
        'complaintId': complaintId,
        'isRead': false,
        'action': '/complaints/$complaintId',
      });

      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(reporterUid)
          .collection('notifications')
          .add({
        'createdAt': FieldValue.serverTimestamp(),
        'title': 'Complaint Resolved',
        'message': 'Your complaint "$complaintTitle" has been resolved.',
        'isRead': false,
        'type': 'complaint_resolved',
        'complaintId': complaintId,
      });

      print('Notification sent successfully to $reportedBy ($reporterUid)');
    } catch (error) {
      print('Failed to send notification: $error');
    }
  }

  // Fetch reporter profile image from Firestore
  Future<String?> _fetchReporterProfileImage(String reporterUid, String reportedBy) async {
    try {
      final String collectionName = reportedBy == 'user' ? 'users' : 'service provider';

      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(reporterUid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        // Note: service provider collection uses 'profileImage' while users collection uses 'profileImageUrl'
        return data?[reportedBy == 'user' ? 'profileImageUrl' : 'profileImage'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }


  Widget _buildProfileAvatar(String reporterName, String? profileImageUrl) {
    final String firstLetter = reporterName.isNotEmpty ? reporterName[0].toUpperCase() : '?';

    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundColor: Colors.blueGrey,
        child: Text(
          firstLetter,
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }

    // For more reliable image handling without changing your image service API
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 24,
        height: 24,
        color: Colors.blueGrey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Text(
                firstLetter,
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            Image.network(
              profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Just return an empty container when error occurs
                // The first letter text below in the stack will be visible
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showComplaintDetails(Map<String, dynamic> complaint) async {
    // Fetch the profile image for the details view
    final profileImageUrl = await _fetchReporterProfileImage(
        complaint['reporterUid'],
        complaint['reportedBy']
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          complaint['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff0F3966),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem(
                  'Description',
                  complaint['description'],
                  isMultiLine: true,
                ),
                Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Reported By',
                        '${complaint['reporterName']} (${complaint['reportedBy']})',
                      ),
                    ),
                    SizedBox(width: 10),
                    _buildProfileAvatar(complaint['reporterName'], profileImageUrl),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailItem(
                  'Date',
                  DateFormat('MMM d, yyyy - hh:mm a').format(complaint['timestamp']),
                ),
                SizedBox(height: 16),
                Text(
                  'Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(complaint['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    complaint['status'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (complaint['status'] == 'Resolved' && complaint['resolvedAt'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildDetailItem(
                      'Resolved on',
                      DateFormat('MMM d, yyyy - hh:mm a').format(complaint['resolvedAt']!),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (complaint['status'] != 'Resolved')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0F3966),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showStatusUpdateDialog(complaint);
              },
              child: Text(
                'Update Status',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isMultiLine = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: isMultiLine ? 1.5 : 1.2,
          ),
        ),
      ],
    );
  }

  void _showStatusUpdateDialog(Map<String, dynamic> complaint) {
    final List<String> statusOptions = ['Pending', 'In Progress', 'Resolved'];
    _selectedStatus = complaint['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Update Complaint Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff0F3966),
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: statusOptions.map((status) => RadioListTile<String>(
                  title: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: _selectedStatus == status ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  value: status,
                  groupValue: _selectedStatus,
                  activeColor: _getStatusColor(status),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                )).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0F3966),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_selectedStatus != null) {
                    Navigator.of(context).pop();
                    _updateComplaintStatus(complaint['id'], _selectedStatus!);
                  }
                },
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildComplaintsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xff0F3966),
          strokeWidth: 3,
        ),
      );
    }

    if (_filteredComplaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 86,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'All'
                  ? 'No complaints found'
                  : 'No ${_selectedFilter.toLowerCase()} complaints found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchComplaints,
      color: Color(0xff0F3966),
      child: ListView.builder(
        itemCount: _filteredComplaints.length,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemBuilder: (context, index) {
          final complaint = _filteredComplaints[index];

          return FutureBuilder<String?>(
            future: _fetchReporterProfileImage(
                complaint['reporterUid'],
                complaint['reportedBy']
            ),
            builder: (context, snapshot) {
              // Get the profile image URL from the snapshot if available
              final profileImageUrl = snapshot.data;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showComplaintDetails(complaint),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                complaint['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xff0F3966),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(complaint['status']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                complaint['status'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          complaint['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 12),
                        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildProfileAvatar(complaint['reporterName'], profileImageUrl),
                                SizedBox(width: 6),
                                Text(
                                  complaint['reporterName'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d, yyyy').format(complaint['timestamp']),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Complaint Management"),
        backgroundColor: Color(0xff0F3966),

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xff0F3966),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: TabBar(
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              controller: _tabController,
              indicatorColor: Colors.blue[100],
              indicatorWeight: 3,
              labelColor: Colors.blue[100],
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'User Complaints'),
                Tab(text: 'Provider Complaints'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search complaints...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Color(0xff0F3966)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xff0F3966)),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _searchComplaints,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        icon: Icon(Icons.filter_list, color: Color(0xff0F3966)),
                        iconSize: 20,
                        borderRadius: BorderRadius.circular(12),
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        items: _filterOptions.map((String filter) {
                          return DropdownMenuItem<String>(
                            value: filter,
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                                color: filter != 'All' ? _getStatusColor(filter) : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _filterComplaints(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Total: ${_filteredComplaints.length} complaints',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildComplaintsList(),
                _buildComplaintsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}