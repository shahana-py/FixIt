import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          : Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 200,
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
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData!['name'] ?? 'User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -45,
                left: MediaQuery.of(context).size.width / 2 - 45,
                child: CircleAvatar(
                  radius: 45,
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

          /// **Edit Profile Button**
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, "/editprofileuser");
            },
            borderRadius: BorderRadius.circular(40),
            splashColor: Colors.blue,
            child: Ink(
              decoration: BoxDecoration(
                color: Color(0xff0F3966),
                borderRadius: BorderRadius.circular(40),
              ),
              height: 55,
              width: 230,
              child: Center(
                child: Text(
                  "Edit Your Profile",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                ),
              ),
            ),
          ),
        ],
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


