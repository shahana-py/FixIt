import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSideDrawer extends StatefulWidget {
  const UserSideDrawer({super.key});

  @override
  State<UserSideDrawer> createState() => _UserSideDrawerState();
}

class _UserSideDrawerState extends State<UserSideDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    setState(() => _isLoading = true);

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
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
          ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966),))
          : userData == null
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
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: userData!['profileImage'] != null && userData!['profileImage'].isNotEmpty
                  ? NetworkImage(userData!['profileImage'])
                  : null,
              child: userData!['profileImage'] == null || userData!['profileImage'].isEmpty
                  ? Icon(Icons.person, color: Colors.blueAccent, size: 50)
                  : null,
            ),
            accountName: Text(
              userData!['name'] ?? 'User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              userData!['email'] ?? 'email@example.com',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),

          // Drawer Menu Items
          _buildDrawerItem(
            icon: Icons.person,
            title: 'My Profile',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/userprofilepage');
            },
          ),

          _buildDrawerItem(
            icon: Icons.bookmark,
            title: 'Bookmarks',
            onTap: () {
              Navigator.pop(context);
              // Navigate to bookmarks page
            },
          ),

          _buildDrawerItem(
            icon: Icons.history,
            title: 'Service History',
            onTap: () {
              Navigator.pop(context);
              // Navigate to service history page
            },
          ),

          _buildDrawerItem(
            icon: Icons.request_page,
            title: 'My Requests',
            onTap: () {
              Navigator.pop(context);
              // Navigate to my requests page
            },
          ),

          _buildDrawerItem(
            icon: Icons.support,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/userhelpsupportpage');
            },
          ),

          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/usersettingspage');
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

