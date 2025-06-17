import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/features/service_provider/view/view_reviews.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/shared/services/image_service.dart';
import 'earnings_analysis.dart';

class ProviderSideDrawer extends StatefulWidget {
  const ProviderSideDrawer({super.key});

  @override
  State<ProviderSideDrawer> createState() => _ProviderSideDrawerState();
}

class _ProviderSideDrawerState extends State<ProviderSideDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageService _imageService = ImageService();
  Map<String, dynamic>? providerData;
  bool _isLoading = true;
  String? _currentProviderId;

  @override
  void initState() {
    super.initState();
    _currentProviderId = _auth.currentUser?.uid;
    fetchProviderDetails();
  }

  Future<void> fetchProviderDetails() async {
    setState(() => _isLoading = true);

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot providerDoc = await FirebaseFirestore.instance
          .collection('service provider')
          .doc(user.uid)
          .get();

      if (providerDoc.exists) {
        setState(() {
          providerData = providerDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Logout',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await _auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966,)))
          : providerData == null
          ? Center(child: Text("No profile data found"))
          : ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header with Profile Information
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),

            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage: providerData!['profileImage'] != null && providerData!['profileImage'].isNotEmpty
                  ? NetworkImage(providerData!['profileImage'])
                  : null,
              child: providerData!['profileImage'] == null || providerData!['profileImage'].isEmpty
                  ? Icon(Icons.person, color: Colors.blueAccent, size: 50)
                  : null,
            ),
            accountName: Row(
              children: [
                Text(
                  providerData!['name'] ?? 'Provider',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (providerData!['status']==1)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.verified, color: Colors.green[900], size: 30),
                  ),
              ],
            ),

            accountEmail: Text(
              providerData!['email'] ?? 'email@example.com',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),

          // Drawer Menu Items
          Padding(
            padding: const EdgeInsets.only(top: 10,left: 20),
            child: Text("EXPLORE",style: TextStyle(color: Colors.black38,fontWeight: FontWeight.w600),),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'My Profile',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/providerprofilepage');
            },
          ),

          _buildDrawerItem(
            icon: Icons.work,
            title: 'My Services',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/providerAllServicesPage');
            },
          ),

          _buildDrawerItem(
            icon: Icons.request_page,
            title: 'Booking Requests',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/providerjobspage');
            },
          ),

          _buildDrawerItem(
            icon: Icons.chat,
            title: 'Customer Messages',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/providermessagespage');
            },
          ),

          _buildDrawerItem(
            icon: Icons.star,
            title: 'Reviews',
            onTap: () {
              Navigator.pop(context);
              if (_currentProviderId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProviderReviewsPage(
                      providerId: _currentProviderId!,
                      imageService: _imageService,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unable to load reviews. Please try again.')),
                );
              }
            },
          ),
          _buildDrawerItem(
            icon: Icons.account_balance_wallet,
            title: 'My Earnings',
            onTap: () {
              Navigator.pop(context);
              if (_currentProviderId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProviderEarningsPage(providerId: _currentProviderId!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unable to load my earnings. Please try again.')),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10,left: 20),
            child: Text("HELP & SUPPORT",style: TextStyle(color: Colors.black38,fontWeight: FontWeight.w600),),
          ),


          _buildDrawerItem(
            icon: Icons.help,
            title: 'Help Center',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/providerhelpsupportpage');
            },
          ),
          _buildDrawerItem(
            icon: Icons.feedback,
            title: 'Report a Complaint',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reportcomplaintspage');
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/providersettingspage');
            },
          ),

          Divider(color: Colors.grey[300]),

          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _showLogoutConfirmationDialog,
            color: Colors.red,
          ),

          // Footer or Additional Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Color(0xff0F3966),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}