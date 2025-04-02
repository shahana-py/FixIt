

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderProfilePage extends StatefulWidget {
  const ProviderProfilePage({super.key});

  @override
  State<ProviderProfilePage> createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? providerData;
  bool _isLoading = true;

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
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Hello,", style: TextStyle(color: Colors.white54, fontSize: 30, fontWeight: FontWeight.bold)),
                      Center(
                        child: Text(
                          providerData!['name'] ?? 'Provider',
                          style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
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
                    backgroundImage: providerData!['profileImage'] != null && providerData!['profileImage'].isNotEmpty
                        ? NetworkImage(providerData!['profileImage'])
                        : null,
                    backgroundColor: Colors.yellow,
                    child: providerData!['profileImage'] == null || providerData!['profileImage'].isEmpty
                        ? Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildInfoCard(icon: Icons.email, title: "Email", value: providerData!['email'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.phone, title: "Phone", value: providerData!['phone'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.location_on, title: "Address", value: providerData!['address'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.work, title: "Experience", value: providerData!['experience'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.school, title: "Certifications", value: providerData!['certifications'] ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.home_repair_service, title: "Services", value: providerData!['services']?.join(", ") ?? 'Not Available'),
                  SizedBox(height: 10),
                  _buildInfoCard(icon: Icons.location_city, title: "Availability", value: providerData!['availability']?.join(", ") ?? 'Not Available'),
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () async {
                // Navigate to edit profile and refresh data when returning
                final result = await Navigator.pushNamed(context, "/editprofileprovider");
                if (result == true) {
                  fetchProviderDetails(); // Refresh data when returning from edit page
                } else {
                  // Also refresh as a fallback in case we don't get a result
                  fetchProviderDetails();
                }
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 22),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
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
}
