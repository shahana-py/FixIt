import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageFeedbackComplaintsPage extends StatefulWidget {
  const ManageFeedbackComplaintsPage({Key? key}) : super(key: key);

  @override
  _ManageFeedbackComplaintsPageState createState() => _ManageFeedbackComplaintsPageState();
}

class _ManageFeedbackComplaintsPageState extends State<ManageFeedbackComplaintsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _responseController = TextEditingController();
  String _selectedTab = 'feedback'; // 'feedback' or 'complaints'
  String _selectedStatus = 'pending'; // 'pending' or 'resolved'

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Feedbacks & Complaints"),
        backgroundColor: const Color(0xFF0F3966),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildStatusFilter(),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildContentSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 'feedback'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 'feedback' ? Colors.blue[400] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Feedback',
                    style: TextStyle(
                      color: _selectedTab == 'feedback' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 'complaints'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 'complaints' ? Colors.blue[400] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Complaints',
                    style: TextStyle(
                      color: _selectedTab == 'complaints' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ChoiceChip(
            label: const Text('Pending'),
            selected: _selectedStatus == 'pending',
            selectedColor: Colors.orange[100],
            labelStyle: TextStyle(
              color: _selectedStatus == 'pending' ? Colors.orange[900] : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (selected) => setState(() => _selectedStatus = 'pending'),
          ),
          ChoiceChip(
            label: const Text('Resolved'),
            selected: _selectedStatus == 'resolved',
            selectedColor: Colors.green[100],
            labelStyle: TextStyle(
              color: _selectedStatus == 'resolved' ? Colors.green[900] : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (selected) => setState(() => _selectedStatus = 'resolved'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('feedback_complaints')
          .where('type', isEqualTo: _selectedTab)
          .where('status', isEqualTo: _selectedStatus)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedTab == 'feedback' ? Icons.feedback : Icons.warning,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_selectedTab} found',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                if (_selectedStatus == 'resolved')
                  const Text(
                    'All items are pending',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            return _buildFeedbackCard(doc);
          },
        );
      },
    );
  }

  Widget _buildFeedbackCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp']?.toDate();
    final formattedDate = timestamp != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp)
        : 'Date not available';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _selectedTab == 'complaints' ? Colors.red[50] : Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            _selectedTab == 'complaints' ? Icons.warning : Icons.feedback,
            color: _selectedTab == 'complaints' ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          data['subject'] ?? 'No Subject',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _selectedStatus == 'resolved' ? Colors.grey : Colors.black,
            decoration: _selectedStatus == 'resolved'
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          'From: ${data['userName'] ?? 'Anonymous'} • $formattedDate',
          style: TextStyle(
            color: _selectedStatus == 'resolved' ? Colors.grey : Colors.black54,
            fontSize: 12,
          ),
        ),
        trailing: _selectedStatus == 'pending'
            ? IconButton(
          icon: const Icon(Icons.reply, color: Colors.blue),
          onPressed: () => _showResponseDialog(doc.id),
        )
            : const Icon(Icons.check_circle, color: Colors.green),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['serviceName'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.home_repair_service, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Service: ${data['serviceName']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'Message:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data['message'] ?? 'No message provided',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                if (data['adminResponse'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Response:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(data['adminResponse']),
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

  void _showResponseDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Respond to Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _responseController,
                decoration: const InputDecoration(
                  labelText: 'Your response',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3966),
                    ),
                    onPressed: () {
                      _submitResponse(docId, true);
                      Navigator.pop(context);
                    },
                    child: const Text('Submit & Resolve'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitResponse(String docId, bool markAsResolved) async {
    if (_responseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a response')),
      );
      return;
    }

    try {
      await _firestore.collection('feedback_complaints').doc(docId).update({
        'adminResponse': _responseController.text,
        'status': markAsResolved ? 'resolved' : 'pending',
        'resolvedAt': markAsResolved ? FieldValue.serverTimestamp() : null,
      });

      _responseController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(markAsResolved ? 'Marked as resolved!' : 'Response saved!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}