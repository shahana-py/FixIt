import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReportComplaintsPage extends StatefulWidget {
  const ReportComplaintsPage({Key? key}) : super(key: key);

  @override
  _ReportComplaintsPageState createState() => _ReportComplaintsPageState();
}

class _ReportComplaintsPageState extends State<ReportComplaintsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Service Quality';
  String _selectedPriority = 'Medium';
  bool _isLoading = false;
  String _userRole = '';
  String _userName = '';

  // List of complaint categories
  final List<String> _categories = [
    'Service Quality',
    'Pricing Issues',
    'Cancellation/Refund',
    'Provider Behavior',
    'App Technical Issues',
    'Payment Issues',
    'Other'
  ];

  // List of priority levels
  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Urgent'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // First check the login collection for role
        final loginDoc = await FirebaseFirestore.instance
            .collection('login')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (loginDoc.docs.isNotEmpty) {
          final roleData = loginDoc.docs.first.data();
          final role = roleData['role'] as String;
          setState(() {
            _userRole = role;
          });

          // Based on role, fetch user name from appropriate collection
          if (role == 'user') {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .where('uid', isEqualTo: user.uid)
                .get();

            if (userDoc.docs.isNotEmpty) {
              setState(() {
                _userName = userDoc.docs.first.data()['name'] as String;
              });
            }
          } else if (role == 'service provider') {
            final providerDoc = await FirebaseFirestore.instance
                .collection('service provider')
                .where('uid', isEqualTo: user.uid)
                .get();

            if (providerDoc.docs.isNotEmpty) {
              setState(() {
                _userName = providerDoc.docs.first.data()['name'] as String;
              });
            }
          }
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: ${error.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('No user logged in');
        }

        // Create a new complaint document
        await FirebaseFirestore.instance.collection('complaints').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'reportedBy': _userRole, // 'user' or 'service provider'
          'reporterName': _userName,
          'reporterUid': user.uid,
          'status': 'Pending', // Initial status
          'timestamp': FieldValue.serverTimestamp(),
          'resolved': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
        );

        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = _categories[0];
          _selectedPriority = 'Medium';
        });

        // Navigate back or to a confirmation screen
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting complaint: ${error.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Report a Complaint"),
        backgroundColor: Color(0xff0F3966),
      ),
      body: _isLoading && _userName.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xff0F3966),))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(child: Text("Hi $_userName,",style: TextStyle(color: Colors.black87,fontSize: 22,fontWeight: FontWeight.w600),)),
              Center(child: Text("We are here to help you!",style: TextStyle(color: Colors.black87,fontSize: 22,fontWeight: FontWeight.w600),)),
              SizedBox(
                height: 10,
              ),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Complaint Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Complaint Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0F3966),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Submit Complaint',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}