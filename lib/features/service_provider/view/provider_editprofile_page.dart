
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePageProvider extends StatefulWidget {
  const EditProfilePageProvider({super.key});

  @override
  State<EditProfilePageProvider> createState() => _EditProfilePageProviderState();
}

class _EditProfilePageProviderState extends State<EditProfilePageProvider> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  String? _profileImageUrl;
  bool _isImageUpdated = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();


  List<String> _selectedServices = [];
  List<String> _selectedAvailability = [];

  List<String> _availableServices = [
    'Plumbing', 'AC Repairing', 'Painting', 'Electrical Works',
    'Home Cleaning', 'Car Wash', 'Laundry', 'Gardening'
  ];

  List<String> _availableLocations = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha',
    'Kottayam', 'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad',
    'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod'
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProviderDetails();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _isImageUpdated = true;
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      // Create a unique filename to avoid cache issues
      String fileName = 'profile_pictures/${_auth.currentUser?.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      // Set metadata to prevent caching issues
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'timestamp': DateTime.now().toIso8601String()},
      );

      UploadTask uploadTask = ref.putFile(image, metadata);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
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
        Map<String, dynamic> providerData = providerDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = providerData['name'] ?? '';
          _emailController.text = providerData['email'] ?? '';
          _phoneController.text = providerData['phone'] ?? '';
          _addressController.text = providerData['address'] ?? '';
          _experienceController.text = providerData['experience'] ?? '';

          _profileImageUrl = providerData['profileImage'];

          _selectedServices = List<String>.from(providerData['services'] ?? []);
          _selectedAvailability = List<String>.from(providerData['availability'] ?? []);
        });
      }
    }

    setState(() => _isLoading = false);
  }

  // Future<void> updateProviderProfile() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   User? user = _auth.currentUser;
  //   if (user != null) {
  //     try {
  //       // Upload new profile image if selected
  //       String? imageUrl = _profileImageUrl;
  //       if (_isImageUpdated && _profileImage != null) {
  //         imageUrl = await _uploadImageToFirebase(_profileImage!);
  //       }
  //
  //       // Add a timestamp to force update
  //       final updateData = {
  //         'name': _nameController.text.trim(),
  //         'email': _emailController.text.trim(),
  //         'phone': _phoneController.text.trim(),
  //         'address': _addressController.text.trim(),
  //         'experience': _experienceController.text.trim(),
  //         'services': _selectedServices,
  //         'availability': _selectedAvailability,
  //         'profileImage': imageUrl ?? '',
  //         'lastUpdated': FieldValue.serverTimestamp(), // Add a timestamp
  //       };
  //
  //       await FirebaseFirestore.instance
  //           .collection('service provider')
  //           .doc(user.uid)
  //           .update(updateData);
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
  //       );
  //
  //       // Return a result to indicate successful update
  //       Navigator.pop(context, true);
  //     } catch (e) {
  //       print("Error updating profile: $e");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error updating profile. Please try again."), backgroundColor: Colors.red),
  //       );
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }
  Future<void> updateProviderProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Upload new profile image if selected
        String? imageUrl = _profileImageUrl;
        if (_isImageUpdated && _profileImage != null) {
          imageUrl = await _uploadImageToFirebase(_profileImage!);
        }

        // Only update profileImage if we have a valid URL
        final updateData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'experience': _experienceController.text.trim(),
          'services': _selectedServices,
          'availability': _selectedAvailability,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        // Only add profileImage if it's not null or empty
        if (imageUrl != null && imageUrl.isNotEmpty) {
          updateData['profileImage'] = imageUrl;
        }

        await FirebaseFirestore.instance
            .collection('service provider')
            .doc(user.uid)
            .update(updateData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
        );

        // Return true to indicate successful update
        Navigator.pop(context, true);
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile. Please try again."), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _buildProfileImage(),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, "Business Name", Icons.person),
              SizedBox(height: 15),
              _buildTextField(_emailController, "Email", Icons.email, isEmail: true),
              SizedBox(height: 15),
              _buildTextField(_phoneController, "Phone", Icons.phone, isPhone: true),
              SizedBox(height: 15),
              _buildTextField(_addressController, "Address", Icons.location_on),
              SizedBox(height: 15),
              _buildTextField(_experienceController, "Years of Experience", Icons.work),
              SizedBox(height: 20),


              _buildMultiSelectChips("Services Offered", _availableServices, _selectedServices),
              SizedBox(height: 20),

              _buildMultiSelectChips("Available Locations", _availableLocations, _selectedAvailability),
              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: updateProviderProfile,
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
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildProfileImage() {
  //   return GestureDetector(
  //     onTap: _pickImage,
  //     child: Stack(
  //       children: [
  //         CircleAvatar(
  //           radius: 60,
  //           backgroundColor: Colors.white,
  //           backgroundImage: _profileImage != null
  //               ? FileImage(_profileImage!)
  //               : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
  //               ? NetworkImage(_profileImageUrl! + "?t=${DateTime.now().millisecondsSinceEpoch}") as ImageProvider
  //               : null,
  //           child: (_profileImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty))
  //               ? Icon(Icons.camera_alt, size: 40, color: Color(0xff0F3966))
  //               : null,
  //         ),
  //         Positioned(
  //           bottom: 0,
  //           right: 0,
  //           child: Container(
  //             padding: EdgeInsets.all(4),
  //             decoration: BoxDecoration(
  //               color: Color(0xff0F3966),
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(
  //               Icons.edit,
  //               color: Colors.white,
  //               size: 20,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                ? NetworkImage(_profileImageUrl!)
                : null,
            child: (_profileImage == null &&
                (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                ? Icon(Icons.camera_alt, size: 40, color: Color(0xff0F3966))
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xff0F3966),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isEmail = false,
        bool isPhone = false,
        bool isPassword = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Color(0xff0F3966)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Enter $label";
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

  Widget _buildMultiSelectChips(
      String title, List<String> options, List<String> selectedOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff0F3966))),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              bool isSelected = selectedOptions.contains(option);
              return ChoiceChip(
                label: Text(option,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black)),
                selected: isSelected,
                selectedColor: Color(0xff0F3966),
                onSelected: (selected) {
                  setState(() {
                    selected
                        ? selectedOptions.add(option)
                        : selectedOptions.remove(option);
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}