import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProviderProfilePage extends StatefulWidget {
  const ProviderProfilePage({super.key});

  @override
  State<ProviderProfilePage> createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? providerData;
  bool _isLoading = true;
  // Add a timestamp to force image refresh
  String _imageTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
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
          // Update timestamp to force image refresh
          _imageTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white, size: 24),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/serviceProviderHome', (Route route) => false);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("My Profile", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color:Color(0xff0F3966) ,))
          : providerData == null
          ? Center(child: Text("No profile data found"))
          : SingleChildScrollView(
        child: Column(
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildProfileAvatar(),
                        SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hello,", style: TextStyle(color: Colors.white54, fontSize: 30, fontWeight: FontWeight.bold)),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Text(
                                providerData!['name'] ?? 'Provider',
                                style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (providerData!['status']==1)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("You are an approved provider now!",style: TextStyle(color: Colors.blue,fontSize: 20),),
                    SizedBox(width: 5),
                    Icon(Icons.verified, color: Colors.green, size: 30),
                  ],
                ),
              ),
            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildInfoCard(icon: Icons.email, title: "Email", value: providerData!['email'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.phone, title: "Phone", value: providerData!['phone'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.location_on, title: "Address", value: providerData!['address'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.work, title: "Experience", value: providerData!['experience'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.home_repair_service, title: "Services", value: providerData!['services']?.join(", ") ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.location_city, title: "Availability", value: providerData!['availability']?.join(", ") ?? 'Not Available'),
                  Divider(color: Colors.grey[300]),

                  _buildDrawerItem(
                    icon: Icons.help,
                    title: 'Help Center',
                    onTap: () {
                      Navigator.pushNamed(context, '/providerhelpsupportpage');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.feedback,
                    title: 'Report a Complaint',
                    onTap: () {
                      Navigator.pushNamed(context, '/reportcomplaintspage');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
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
                ],
              ),
            ),
            SizedBox(height: 20),
            // InkWell(
            //   onTap: () async {
            //     // Navigate to edit profile and refresh data when returning
            //     final result = await Navigator.pushNamed(context, "/editprofileprovider");
            //     // Always refresh data when returning from edit page
            //     fetchProviderDetails();
            //   },
            //   borderRadius: BorderRadius.circular(40),
            //   splashColor: Colors.blue,
            //   child: Ink(
            //     decoration: BoxDecoration(
            //       color: Color(0xff0F3966),
            //       borderRadius: BorderRadius.circular(40),
            //     ),
            //     height: 55,
            //     width: 230,
            //     child: Center(
            //       child: Text(
            //         "Edit Your Profile",
            //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 22),
            //       ),
            //     ),
            //   ),
            // ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async {
          // Navigate to edit profile and refresh data when returning
          final result = await Navigator.pushNamed(context, "/editprofileprovider");
          // Always refresh data when returning from edit page
          fetchProviderDetails();
        },
        backgroundColor: Color(0xff0F3966),
        child: Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  // Widget _buildProfileAvatar() {
  //   final profileImageUrl = providerData?['profileImage'];
  //   final hasImage = profileImageUrl != null && profileImageUrl.isNotEmpty;
  //
  //   return CircleAvatar(
  //     radius: 60,
  //     backgroundColor: Colors.white38,
  //     backgroundImage: hasImage
  //         ? NetworkImage('$profileImageUrl?t=$_imageTimestamp')
  //         : null,
  //     child: hasImage
  //         ? null
  //         : Icon(Icons.person, size: 50, color: Colors.white),
  //   );
  // }
  Widget _buildProfileAvatar() {
    final profileImageUrl = providerData?['profileImage'];
    final hasImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Shimmer placeholder
        if (hasImage)
          Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),

        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white38,
          backgroundImage: hasImage
              ? NetworkImage('$profileImageUrl?t=$_imageTimestamp')
              : null,
          child: hasImage
              ? null
              : Icon(Icons.person, size: 50, color: Colors.white),
        ),
      ],
    );
  }

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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
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
    );
  }
}