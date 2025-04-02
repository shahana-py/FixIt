import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePageUser extends StatefulWidget {
  const EditProfilePageUser({super.key});

  @override
  State<EditProfilePageUser> createState() => _EditProfilePageUserState();
}

class _EditProfilePageUserState extends State<EditProfilePageUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;

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
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _addressController.text = userData['address'] ?? '';
        });
      }
    }
  }

  Future<void> updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
      );

      setState(() => _isLoading = false);

      Navigator.pop(context); // Go back to Account Page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Edit Profile", style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Name", Icons.person, "Enter your name"),
              SizedBox(height: 15),
              _buildTextField(_emailController, "Email", Icons.email, "Enter a valid email", isEmail: true),
              SizedBox(height: 15),
              _buildTextField(_phoneController, "Phone", Icons.phone, "Enter a valid phone number", isPhone: true),
              SizedBox(height: 15),
              _buildTextField(_addressController, "Address", Icons.location_on, "Enter your address"),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: updateUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0F3966),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Reusable Widget for TextFields**
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      String validationMessage, {
        bool isEmail = false,
        bool isPhone = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validationMessage;
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
          return "Enter a valid email address";
        }
        if (isPhone && !RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
          return "Enter a valid 10-digit phone number";
        }
        return null;
      },
    );
  }
}
