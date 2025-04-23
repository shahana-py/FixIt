import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
      }
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white,size: 24),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (Route route) => false);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        actions: [
          Icon(Icons.bookmark, ),
          SizedBox(width: 10),
          Icon(Icons.notifications,),
          SizedBox(width: 10),

        ],
      ),
      backgroundColor: Colors.white,
      body: userData == null
          ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966),)) // Loading indicator
          : SingleChildScrollView(
            child: Column(
                    children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    color: Colors.blue,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        "Hello,",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userData!['name'] ?? 'User',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 25,
                  left: 20,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.yellow,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),

            /// **User Information with Styled Cards**
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.email,
                    title: "Email",
                    value: userData!['email'] ?? 'Not Available',
                  ),
                  SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.phone,
                    title: "Phone",
                    value: userData!['phone'] ?? 'Not Available',
                  ),
                  SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: "Address",
                    value: userData!['address'] ?? 'Not Available',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),



            SizedBox(
              height: 10,
            ),
            _buildDrawerItem(
              icon: Icons.help,
              title: 'Help Center',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/userhelpsupportpage');
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
                      SizedBox(height: 20,)





                    ],
                  ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, "/editprofileuser");
        },
        backgroundColor: Color(0xff0F3966),
        child: Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  /// **Reusable Widget for Displaying User Information**
  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}

// Helper method to build drawer items
Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? color,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 20),
    child: ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.blue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    ),
  );
}





