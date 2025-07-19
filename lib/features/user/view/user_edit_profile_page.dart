
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/shared/services/image_service.dart';


class EditProfilePageUser extends StatefulWidget {
  const EditProfilePageUser({super.key});

  @override
  State<EditProfilePageUser> createState() => _EditProfilePageUserState();
}

class _EditProfilePageUserState extends State<EditProfilePageUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  String? _profileImageUrl; // Store the current profile image URL
  File? _newProfileImage; // Store the new profile image file selected by user
  bool _isUploadingImage = false; // Track image upload state

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    setState(() => _isLoading = true);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
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
            _profileImageUrl = userData['profileImageUrl']; // Get the profile image URL
            print('Fetched profile image URL: $_profileImageUrl');
          });
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data')),
      );
    }

    setState(() => _isLoading = false);
  }

  // Method to handle profile image selection
  Future<void> _selectProfileImage() async {
    try {
      File? selectedImage = await _imageService.showImagePickerDialog(context);

      if (selectedImage != null) {
        setState(() {
          _newProfileImage = selectedImage;
        });
      }
    } catch (e) {
      print('Error selecting profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image')),
      );
    }
  }

  // Method to upload the profile image
  Future<String?> _uploadProfileImage() async {
    if (_newProfileImage == null) return _profileImageUrl; // Return existing URL if no new image

    setState(() => _isUploadingImage = true);

    try {
      String userId = _auth.currentUser!.uid;
      String? uploadedImageUrl = await _imageService.uploadImageWorking(_newProfileImage!, userId);

      // Debug print the returned URL
      print('Uploaded image URL: $uploadedImageUrl');

      setState(() => _isUploadingImage = false);

      return uploadedImageUrl;
    } catch (e) {
      setState(() => _isUploadingImage = false);
      print('Error uploading profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile picture')),
      );
      return null;
    }
  }

  Future<void> updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload profile image if changed
      String? imageUrl = _profileImageUrl;
      if (_newProfileImage != null) {
        imageUrl = await _uploadProfileImage();
        if (imageUrl == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload profile image"), backgroundColor: Colors.red),
          );
          return;
        }
      }

      User? user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> updateData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        };

        // Only update the image URL if we have a valid one
        if (imageUrl != null && imageUrl.isNotEmpty) {
          updateData['profileImageUrl'] = imageUrl;
        }

        // Update Firestore document
        await _firestore.collection('users').doc(user.uid).update(updateData);

        // Verify the image URL was saved by fetching the updated document
        DocumentSnapshot updatedDoc = await _firestore.collection('users').doc(user.uid).get();
        Map<String, dynamic> updatedData = updatedDoc.data() as Map<String, dynamic>;
        print('Updated profile image URL in Firestore: ${updatedData['profileImageUrl']}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
        );

        setState(() => _isLoading = false);

        Navigator.pop(context); // Go back to Account Page
      }
    } catch (e) {
      print('Error updating profile: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e"), backgroundColor: Colors.red),
      );
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
          ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _isUploadingImage
                            ? Center(child: CircularProgressIndicator(color: Color(0xff0F3966)))
                            : _newProfileImage != null
                            ? Image.file(
                          _newProfileImage!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                            : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                            ? Image.network(
                          _profileImageUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Color(0xff0F3966),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading network image: $error');
                            return Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xff0F3966),
                            );
                          },
                        )
                            : Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xff0F3966),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          color: Color(0xff0F3966),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _selectProfileImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

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
