
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../../../core/shared/services/image_service.dart'; // Update with your actual package path

class ServiceProviderRegisterPage extends StatefulWidget {
  const ServiceProviderRegisterPage({super.key});

  @override
  State<ServiceProviderRegisterPage> createState() =>
      _ServiceProviderRegisterPageState();
}

class _ServiceProviderRegisterPageState
    extends State<ServiceProviderRegisterPage> {
  final _spregisterKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();
  File? _profileImage;
  String? profileImageUrl;

  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  TextEditingController _phonecontroller = TextEditingController();
  TextEditingController _addresscontroller = TextEditingController();
  TextEditingController _servicescontroller = TextEditingController();
  TextEditingController _experiencecontroller = TextEditingController();

  TextEditingController _availabilitycontroller = TextEditingController();

  bool _visible = false;
  bool _isUploading = false;

  List<String> services = [
    "Plumbing",
    "AC Repairing",
    "Painting",
    "Electrical Works",
    "Home Cleaning",
    "Car Wash",
    "Laundry",
    "Gardening"
  ];
  List<String> selectedServices = [];

  List<String> availability = [
    "Thiruvananthapuram",
    "Kollam",
    "Pathanamthitta",
    "Alappuzha",
    "Kottayam",
    "Idukki",
    "Ernakulam",
    "Thrissur",
    "Palakkad",
    "Malappuram",
    "Kozhikode",
    "Wayanad",
    "Kannur",
    "Kasaragod"
  ];
  List<String> selectedAvailability = [];

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imageService.pickImageFromGallery();
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<String?> _uploadImageToServer(File image) async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Using your ImageService to upload the image
      final imageUrl = await _imageService.uploadImageWorking(image, _emailcontroller.text);

      if (imageUrl == null) {
        throw Exception('Image upload failed - no URL returned');
      }

      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffC9E4CA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _spregisterKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Center(
                    child: Text(
                      "Create An Account",
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0F3966)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _buildProfileImage(),
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xff0F3966),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _isUploading ? null : _pickImage,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildTextField(_namecontroller, "Name", Icons.person),
                _buildTextField(_emailcontroller, "Email", Icons.email),
                _buildTextField(passcontroller, "Password", Icons.lock,
                    isPassword: true),
                _buildTextField(_phonecontroller, "Phone", Icons.phone),
                _buildTextField(_addresscontroller, "Address", Icons.location_on),
                _buildTextField(
                    _experiencecontroller, "Years of Experience", Icons.work),

                SizedBox(height: 15),
                _buildMultiSelectChips(
                    "What services do you provide?", services, selectedServices),
                SizedBox(height: 10),
                _buildMultiSelectChips(
                    "Availability", availability, selectedAvailability),

                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isUploading ? null : () async {
                        if (_spregisterKey.currentState!.validate()) {
                          try {
                            // Upload profile image if available
                            if (_profileImage != null) {
                              profileImageUrl = await _uploadImageToServer(_profileImage!);
                              if (profileImageUrl == null) {
                                // Don't proceed if image upload failed
                                return;
                              }
                            }

                            // Create user with email and password
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .createUserWithEmailAndPassword(
                                email: _emailcontroller.text,
                                password: passcontroller.text);

                            if (userCredential.user != null) {
                              // Add user to login collection
                              await FirebaseFirestore.instance
                                  .collection('login')
                                  .doc(userCredential.user!.uid)
                                  .set({
                                "uid": userCredential.user!.uid,
                                'email': userCredential.user!.email,
                                'createdAt': DateTime.now(),
                                'status': 1,
                                'role': "service provider"
                              });

                              // Add user to service provider collection
                              await FirebaseFirestore.instance
                                  .collection('service provider')
                                  .doc(userCredential.user!.uid)
                                  .set({
                                "uid": userCredential.user!.uid,
                                'name': _namecontroller.text,
                                'email': userCredential.user!.email,
                                'phone': _phonecontroller.text,
                                'address': _addresscontroller.text,
                                'experience': _experiencecontroller.text,
                                "profileImage": profileImageUrl ?? "",
                                "services": selectedServices,

                                "availability": selectedAvailability,
                                'createdAt': DateTime.now(),
                                'isApproved':false,
                                'status': 0,
                                'role': "service provider"
                              });

                              // Navigate to service provider home page
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/serviceProviderHome', (Route route) => false);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Registration failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            print("Registration error: $e");
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(40),
                      splashColor: Colors.blue,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: _isUploading ? Colors.grey : Color(0xff0F3966),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        height: 55,
                        width: 230,
                        child: Center(
                          child: _isUploading
                              ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : Text(
                            "Register",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(top: 20,bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account ? ",
                        style: TextStyle(color: Color(0xff0F3966)),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (Route route) => false);
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white,
      backgroundImage: _profileImage != null
          ? FileImage(_profileImage!)
          : (profileImageUrl != null
          ? NetworkImage(profileImageUrl!)
          : null),
      child: _profileImage == null && profileImageUrl == null
          ? Icon(Icons.person, size: 40, color: Color(0xff0F3966))
          : null,
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_visible : false,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Color(0xff0F3966)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_visible ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _visible = !_visible),
          )
              : null,
        ),
        validator: (value) => value!.isEmpty ? "Enter $hintText" : null,
      ),
    );
  }

  Widget _buildMultiSelectChips(
      String title, List<String> options, List<String> selectedOptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F3966))),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
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
        ],
      ),
    );
  }
}
