// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class UserAccountPage extends StatefulWidget {
//   const UserAccountPage({super.key});
//
//   @override
//   State<UserAccountPage> createState() => _UserAccountPageState();
// }
//
// class _UserAccountPageState extends State<UserAccountPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   Map<String, dynamic>? userData;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserDetails();
//   }
//
//   Future<void> fetchUserDetails() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//
//       if (userDoc.exists) {
//         setState(() {
//           userData = userDoc.data() as Map<String, dynamic>;
//         });
//       }
//     }
//   }
//
//   void _showLogoutConfirmationDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Logout'),
//           content: Text('Are you sure you want to log out?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel',style: TextStyle(color: Colors.red),),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             ElevatedButton(
//               child: Text('Logout',style: TextStyle(color: Colors.white),),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: () async {
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 await prefs.clear();
//                 await _auth.signOut();
//                 Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         iconTheme: IconThemeData(color: Colors.white,size: 24),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, '/home', (Route route) => false);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//         title: Text("Profile", style: TextStyle(color: Colors.white)),
//         actions: [
//           Icon(Icons.bookmark, ),
//           SizedBox(width: 10),
//           Icon(Icons.notifications,),
//           SizedBox(width: 10),
//
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: userData == null
//           ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966),)) // Loading indicator
//           : SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 180,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(30),
//                       bottomRight: Radius.circular(30),
//                     ),
//                     color: Colors.blue,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//
//                     children: [
//                       Text(
//                         "Hello,",
//                         textAlign: TextAlign.start,
//                         style: TextStyle(
//                           color: Colors.white54,
//                           fontSize: 25,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         userData!['name'] ?? 'User',
//                         textAlign: TextAlign.start,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 40,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   top: 25,
//                   left: 20,
//                   child: CircleAvatar(
//                     radius: 55,
//                     backgroundColor: Colors.white60,
//                     child: Icon(Icons.person,color: Colors.indigoAccent,size: 65,),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 50),
//
//             /// **User Information with Styled Cards**
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Column(
//                 children: [
//                   _buildInfoCard(
//                     icon: Icons.email,
//                     title: "Email",
//                     value: userData!['email'] ?? 'Not Available',
//                   ),
//                   SizedBox(height: 10),
//                   _buildInfoCard(
//                     icon: Icons.phone,
//                     title: "Phone",
//                     value: userData!['phone'] ?? 'Not Available',
//                   ),
//                   SizedBox(height: 10),
//                   _buildInfoCard(
//                     icon: Icons.location_on,
//                     title: "Address",
//                     value: userData!['address'] ?? 'Not Available',
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 20),
//
//
//
//             SizedBox(
//               height: 10,
//             ),
//             _buildDrawerItem(
//               icon: Icons.help,
//               title: 'Help Center',
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/userhelpsupportpage');
//               },
//             ),
//             _buildDrawerItem(
//               icon: Icons.feedback,
//               title: 'Report a Complaint',
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/reportcomplaintspage');
//               },
//             ),
//
//             _buildDrawerItem(
//               icon: Icons.settings,
//               title: 'Settings',
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/usersettingspage');
//               },
//             ),
//
//             Divider(color: Colors.grey[300]),
//
//             _buildDrawerItem(
//               icon: Icons.logout,
//               title: 'Logout',
//               onTap: _showLogoutConfirmationDialog,
//               color: Colors.red,
//             ),
//             SizedBox(height: 20,)
//
//
//
//
//
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (){
//           Navigator.pushNamed(context, "/editprofileuser");
//         },
//         backgroundColor: Color(0xff0F3966),
//         child: Icon(Icons.edit, color: Colors.white),
//       ),
//     );
//   }
//
//   /// **Reusable Widget for Displaying User Information**
//   Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue, size: 30),
//         title: Text(
//           title,
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//         subtitle: Text(
//           value,
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//       ),
//     );
//   }
// }
//
// // Helper method to build drawer items
// Widget _buildDrawerItem({
//   required IconData icon,
//   required String title,
//   required VoidCallback onTap,
//   Color? color,
// }) {
//   return Padding(
//     padding: const EdgeInsets.only(left: 20),
//     child: ListTile(
//       leading: Icon(
//         icon,
//         color: color ?? Colors.blue,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           color: color ?? Colors.black87,
//           fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//       onTap: onTap,
//     ),
//   );
// }


//
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../core/shared/services/image_service.dart';
//
//
// class UserAccountPage extends StatefulWidget {
//   const UserAccountPage({super.key});
//
//   @override
//   State<UserAccountPage> createState() => _UserAccountPageState();
// }
//
// class _UserAccountPageState extends State<UserAccountPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final ImageService _imageService = ImageService(); // Create an instance of ImageService
//   Map<String, dynamic>? userData;
//   String? profileImageUrl; // Store the profile image URL
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserDetails();
//   }
//
//   Future<void> fetchUserDetails() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//
//       if (userDoc.exists) {
//         Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
//         setState(() {
//           userData = data;
//           // Get profile image URL if it exists
//           profileImageUrl = data['profileImageUrl'];
//         });
//       }
//     }
//   }
//
//   // Method to handle profile image upload
//   Future<void> _uploadProfileImage() async {
//     try {
//       // Show image picker dialog
//       File? imageFile = await _imageService.showImagePickerDialog(context);
//
//       if (imageFile != null) {
//         // Show loading indicator
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               content: Row(
//                 children: [
//                   CircularProgressIndicator(color: Color(0xff0F3966)),
//                   SizedBox(width: 20),
//                   Text("Uploading image..."),
//                 ],
//               ),
//             );
//           },
//         );
//
//         // Get current user ID
//         String userId = _auth.currentUser!.uid;
//
//         // Upload image and get URL
//         String? uploadedImageUrl = await _imageService.uploadImageWorking(imageFile, userId);
//
//         // Close loading dialog
//         Navigator.of(context).pop();
//
//         if (uploadedImageUrl != null) {
//           // Update Firestore with the image URL
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(userId)
//               .update({'profileImageUrl': uploadedImageUrl});
//
//           // Update state
//           setState(() {
//             profileImageUrl = uploadedImageUrl;
//           });
//
//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Profile picture updated successfully')),
//           );
//         } else {
//           // Show error message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to upload profile picture')),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error uploading profile image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An error occurred while updating profile picture')),
//       );
//     }
//   }
//
//   void _showLogoutConfirmationDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Logout'),
//           content: Text('Are you sure you want to log out?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel',style: TextStyle(color: Colors.red),),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             ElevatedButton(
//               child: Text('Logout',style: TextStyle(color: Colors.white),),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: () async {
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 await prefs.clear();
//                 await _auth.signOut();
//                 Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         iconTheme: IconThemeData(color: Colors.white,size: 24),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, '/home', (Route route) => false);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//         title: Text("Profile", style: TextStyle(color: Colors.white)),
//         actions: [
//           Icon(Icons.bookmark, ),
//           SizedBox(width: 10),
//           Icon(Icons.notifications,),
//           SizedBox(width: 10),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: userData == null
//           ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966),)) // Loading indicator
//           : SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 180,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(30),
//                       bottomRight: Radius.circular(30),
//                     ),
//                     color: Colors.blue,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Hello,",
//                         textAlign: TextAlign.start,
//                         style: TextStyle(
//                           color: Colors.white54,
//                           fontSize: 25,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         userData!['name'] ?? 'User',
//                         textAlign: TextAlign.start,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 40,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   top: 25,
//                   left: 20,
//                   child: Stack(
//                     children: [
//                       CircleAvatar(
//                         radius: 55,
//                         backgroundColor: Colors.white60,
//                         // Display profile image if available, otherwise show icon
//                         backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
//                         child: profileImageUrl == null
//                             ? Icon(Icons.person, color: Colors.indigoAccent, size: 65)
//                             : null,
//                       ),
//                       // Add a small camera icon for uploading profile picture
//                       Positioned(
//                         right: 0,
//                         bottom: 0,
//                         child: Container(
//                           height: 40,
//                           width: 40,
//                           decoration: BoxDecoration(
//                             color: Color(0xff0F3966),
//                             shape: BoxShape.circle,
//                             border: Border.all(width: 2, color: Colors.white),
//                           ),
//                           child: IconButton(
//                             padding: EdgeInsets.zero,
//                             icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
//                             onPressed: _uploadProfileImage,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 50),
//
//             /// **User Information with Styled Cards**
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Column(
//                 children: [
//                   _buildInfoCard(
//                     icon: Icons.email,
//                     title: "Email",
//                     value: userData!['email'] ?? 'Not Available',
//                   ),
//                   SizedBox(height: 10),
//                   _buildInfoCard(
//                     icon: Icons.phone,
//                     title: "Phone",
//                     value: userData!['phone'] ?? 'Not Available',
//                   ),
//                   SizedBox(height: 10),
//                   _buildInfoCard(
//                     icon: Icons.location_on,
//                     title: "Address",
//                     value: userData!['address'] ?? 'Not Available',
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 20),
//
//             SizedBox(
//               height: 10,
//             ),
//             _buildDrawerItem(
//               icon: Icons.help,
//               title: 'Help Center',
//               onTap: () {
//
//                 Navigator.pushNamed(context, '/userhelpsupportpage');
//               },
//             ),
//             _buildDrawerItem(
//               icon: Icons.feedback,
//               title: 'Report a Complaint',
//               onTap: () {
//
//                 Navigator.pushNamed(context, '/reportcomplaintspage');
//               },
//             ),
//
//             _buildDrawerItem(
//               icon: Icons.settings,
//               title: 'Settings',
//               onTap: () {
//
//                 Navigator.pushNamed(context, '/usersettingspage');
//               },
//             ),
//
//             Divider(color: Colors.grey[300]),
//
//             _buildDrawerItem(
//               icon: Icons.logout,
//               title: 'Logout',
//               onTap: _showLogoutConfirmationDialog,
//               color: Colors.red,
//             ),
//             SizedBox(height: 20,)
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (){
//           Navigator.pushNamed(context, "/editprofileuser");
//         },
//         backgroundColor: Color(0xff0F3966),
//         child: Icon(Icons.edit, color: Colors.white),
//       ),
//     );
//   }
//
//   /// **Reusable Widget for Displaying User Information**
//   Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue, size: 30),
//         title: Text(
//           title,
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//         subtitle: Text(
//           value,
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//       ),
//     );
//   }
// }
//
// // Helper method to build drawer items
// Widget _buildDrawerItem({
//   required IconData icon,
//   required String title,
//   required VoidCallback onTap,
//   Color? color,
// }) {
//   return Padding(
//     padding: const EdgeInsets.only(left: 20),
//     child: ListTile(
//       leading: Icon(
//         icon,
//         color: color ?? Colors.blue,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           color: color ?? Colors.black87,
//           fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//       onTap: onTap,
//     ),
//   );
// }


import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/shared/services/image_service.dart';


class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  Map<String, dynamic>? userData;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            userData = data;
            // Get profile image URL if it exists
            profileImageUrl = data['profileImageUrl'];
            print('Profile image URL from Firestore: $profileImageUrl');
          });
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data')),
      );
    }
  }

  // Method to handle profile image upload
  Future<void> _uploadProfileImage() async {
    try {
      // Show image picker dialog
      File? imageFile = await _imageService.showImagePickerDialog(context);

      if (imageFile != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(color: Color(0xff0F3966)),
                  SizedBox(width: 20),
                  Text("Uploading image..."),
                ],
              ),
            );
          },
        );

        // Get current user ID
        String userId = _auth.currentUser!.uid;

        // Upload image and get URL
        String? uploadedImageUrl = await _imageService.uploadImageWorking(imageFile, userId);

        // Close loading dialog
        Navigator.of(context).pop();

        if (uploadedImageUrl != null) {
          // Debug print to verify URL returned from the upload service
          print('Uploaded image URL: $uploadedImageUrl');

          // Update Firestore with the image URL
          await _firestore
              .collection('users')
              .doc(userId)
              .update({'profileImageUrl': uploadedImageUrl});

          // Update state
          setState(() {
            profileImageUrl = uploadedImageUrl;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile picture updated successfully')),
          );

          // Refresh user details to ensure we have the latest data
          await fetchUserDetails();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload profile picture')),
          );
        }
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while updating profile picture')),
      );
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
          GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/userfavouritespage');
              },
              child: Icon(Icons.favorite, color: Colors.white, size: 24)
          ),
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
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white60,
                        // Display profile image if available, otherwise show icon
                        backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : null,
                        child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                            ? Icon(Icons.person, color: Colors.indigoAccent, size: 65)
                            : null,
                      ),
                      // Add a small camera icon for uploading profile picture
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Color(0xff0F3966),
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.white),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: _uploadProfileImage,
                          ),
                        ),
                      ),
                    ],
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
                Navigator.pushNamed(context, '/userhelpsupportpage');
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