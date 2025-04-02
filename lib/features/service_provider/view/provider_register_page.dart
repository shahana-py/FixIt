// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class ServiceProviderRegisterPage extends StatefulWidget {
//   const ServiceProviderRegisterPage({super.key});
//
//   @override
//   State<ServiceProviderRegisterPage> createState() => _ServiceProviderRegisterPageState();
// }
//
// class _ServiceProviderRegisterPageState extends State<ServiceProviderRegisterPage> {
//   TextEditingController _namecontroller = TextEditingController();
//   TextEditingController _emailcontroller = TextEditingController();
//   TextEditingController passcontroller = TextEditingController();
//   TextEditingController _phonecontroller = TextEditingController();
//   TextEditingController _addresscontroller = TextEditingController();
//   // TextEditingController _gendercontroller = TextEditingController();
//
//   TextEditingController _servicescontroller = TextEditingController();
//   // TextEditingController _qualificationcontroller = TextEditingController();
//   TextEditingController _experiencecontroller = TextEditingController();
//   TextEditingController _hourlypaymentcontroller = TextEditingController();
//
//
//   final _spregisterKey = GlobalKey<FormState>();
//   bool _visible = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffC9E4CA),
//       body: Container(
//           child: Form(
//             key: _spregisterKey,
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 spacing: 10,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: Text(
//                       "Create An Account",
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff0F3966),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: double.infinity,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                           image: AssetImage("assets/images/register_bg.png")),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
//                     child: Center(child: Text("Personal Information",style: TextStyle(color: Color(0xff0F3966),fontSize: 30,fontWeight: FontWeight.w600),)),
//                   ),
//                   Padding(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//                     child: TextFormField(
//                       cursorColor: Color(0xff0F3966),
//                       cursorErrorColor: Colors.red,
//                       keyboardType: TextInputType.name,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Enter your Name";
//                         } else {
//                           return null;
//                         }
//                       },
//                       controller: _namecontroller,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(vertical: 20),
//                         prefixIcon: Icon(Icons.person),
//                         filled: true,
//                         fillColor: Colors.white,
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide(color: Colors.red)),
//                         hintText: "Name",
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: TextFormField(
//                       cursorColor: Color(0xff0F3966),
//                       cursorErrorColor: Colors.red,
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Enter your Email";
//                         } else {
//                           return null;
//                         }
//                       },
//                       controller: _emailcontroller,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(vertical: 20),
//                         prefixIcon: Icon(Icons.email),
//                         filled: true,
//                         fillColor: Colors.white,
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide(color: Colors.red)),
//                         hintText: "Email",
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: TextFormField(
//
//                       cursorColor: Color(0xff0F3966),
//                       cursorErrorColor: Colors.red,
//                       keyboardType: TextInputType.text,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Enter your Password";
//                         } else {
//                           return null;
//                         }
//                       },
//                       obscureText: _visible,
//                       obscuringCharacter: "*",
//                       controller: passcontroller,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(vertical: 20),
//                         filled: true,
//                         fillColor: Colors.white,
//                         prefixIcon: Icon(Icons.lock),
//                         suffixIcon: IconButton(
//                           onPressed: () {
//                             setState(() {
//                               _visible = !_visible;
//                             });
//                           },
//                           icon: _visible == false
//                               ? Icon(Icons.visibility)
//                               : Icon(Icons.visibility_off),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide(color: Colors.red)),
//                         hintText: "Password",
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: TextFormField(
//                       cursorColor: Color(0xff0F3966),
//                       cursorErrorColor: Colors.red,
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Enter your Phone number";
//                         } else {
//                           return null;
//                         }
//                       },
//                       controller: _phonecontroller,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(vertical: 20),
//                         prefixIcon: Icon(Icons.phone),
//                         filled: true,
//                         fillColor: Colors.white,
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide(color: Colors.red)),
//                         hintText: "Phone number",
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: TextFormField(
//                       cursorColor: Color(0xff0F3966),
//                       cursorErrorColor: Colors.red,
//                       keyboardType: TextInputType.streetAddress,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Enter your Address";
//                         } else {
//                           return null;
//                         }
//                       },
//                       controller: _addresscontroller,
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(vertical: 20),
//                         prefixIcon: Icon(Icons.location_on),
//                         filled: true,
//                         fillColor: Colors.white,
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide(color: Colors.red)),
//                         hintText: "Address",
//                       ),
//                     ),
//                   ),
//
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
//                     child: Center(child: Text("Professional Information",style: TextStyle(color: Color(0xff0F3966),fontSize: 30,fontWeight: FontWeight.w600),)),
//                   ),
//                   // Padding(
//                   //   padding:
//                   //   const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//                   //   child: TextFormField(
//                   //     cursorColor: Color(0xff0F3966),
//                   //     cursorErrorColor: Colors.red,
//                   //     keyboardType: TextInputType.text,
//                   //     validator: (value) {
//                   //       if (value!.isEmpty) {
//                   //         return "What are the services you provide";
//                   //       } else {
//                   //         return null;
//                   //       }
//                   //     },
//                   //     controller: _servicescontroller,
//                   //     decoration: InputDecoration(
//                   //       contentPadding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
//                   //
//                   //       filled: true,
//                   //       fillColor: Colors.white,
//                   //       enabledBorder: OutlineInputBorder(
//                   //         borderRadius: BorderRadius.circular(15),
//                   //       ),
//                   //       focusedBorder: OutlineInputBorder(
//                   //         borderRadius: BorderRadius.circular(15),
//                   //       ),
//                   //       errorBorder: OutlineInputBorder(
//                   //           borderRadius: BorderRadius.circular(15),
//                   //           borderSide: BorderSide(color: Colors.red)),
//                   //       hintText: "What are the services you provide",
//                   //     ),
//                   //   ),
//                   // ),
//                   //
//                   // Padding(
//                   //   padding:
//                   //   const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//                   //   child: TextFormField(
//                   //     cursorColor: Color(0xff0F3966),
//                   //     cursorErrorColor: Colors.red,
//                   //     keyboardType: TextInputType.text,
//                   //     validator: (value) {
//                   //       if (value!.isEmpty) {
//                   //         return "Your experience";
//                   //       } else {
//                   //         return null;
//                   //       }
//                   //     },
//                   //     controller: _experiencecontroller,
//                   //     decoration: InputDecoration(
//                   //       contentPadding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
//                   //
//                   //       filled: true,
//                   //       fillColor: Colors.white,
//                   //       enabledBorder: OutlineInputBorder(
//                   //         borderRadius: BorderRadius.circular(15),
//                   //       ),
//                   //       focusedBorder: OutlineInputBorder(
//                   //         borderRadius: BorderRadius.circular(15),
//                   //       ),
//                   //       errorBorder: OutlineInputBorder(
//                   //           borderRadius: BorderRadius.circular(15),
//                   //           borderSide: BorderSide(color: Colors.red)),
//                   //       hintText: "Your experience",
//                   //     ),
//                   //   ),
//                   // ),
//                   // Padding(
//                   //   padding:
//                   //   const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//                   //   child: TextFormField(
//                   //     cursorColor: Color(0xff0F3966),
//                   //     cursorErrorColor: Colors.red,
//                   //     keyboardType: TextInputType.text,
//                   //     validator: (value) {
//                   //       if (value!.isEmpty) {
//                   //         return "Enter your hourly payment";
//                   //       } else {
//                   //         return null;
//                   //       }
//                   //     },
//                   //     controller: _hourlypaymentcontroller,
//                   //     decoration: InputDecoration(
//                   //       contentPadding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
//                   //
//                   //       filled: true,
//                   //       fillColor: Colors.white,
//                   //       enabledBorder: OutlineInputBorder(
//                   //         borderRadius: BorderRadius.circular(15),
//                   //       ),
//                   //       focusedBorder: OutlineInputBorder(
//                   //         borderRadius: BorderRadius.circular(15),
//                   //       ),
//                   //       errorBorder: OutlineInputBorder(
//                   //           borderRadius: BorderRadius.circular(15),
//                   //           borderSide: BorderSide(color: Colors.red)),
//                   //       hintText: "Enter you hourly payment",
//                   //     ),
//                   //   ),
//                   // ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: Material(
//                       color:
//                       Colors.transparent, // To keep only the gradient visible
//                       child: InkWell(
//                         onTap: () async {
//                           if (_spregisterKey.currentState!.validate()) {
//                             UserCredential userCredential = await FirebaseAuth
//                                 .instance
//                                 .createUserWithEmailAndPassword(
//                                 email: _emailcontroller.text,
//                                 password: passcontroller.text);
//                             if (userCredential.user!.uid != null) {
//                               FirebaseFirestore.instance
//                                   .collection('login')
//                                   .doc(userCredential.user!.uid)
//                                   .set({
//                                 "uid": userCredential.user!.uid,
//                                 'email': userCredential.user!.email,
//                                 'createdAt': DateTime.now(),
//                                 'status': 1,
//                                 'role': "service provider"
//                               });
//
//                               FirebaseFirestore.instance
//                                   .collection('service provider')
//                                   .doc(userCredential.user!.uid)
//                                   .set({
//                                 "uid": userCredential.user!.uid,
//                                 'name': _namecontroller.text,
//                                 'email': userCredential.user!.email,
//                                 'phone': _phonecontroller.text,
//                                 'address': _addresscontroller.text,
//                                 // 'gender': _gendercontroller.text,
//                                 'services': _servicescontroller.text,
//                                 // 'qualification': _qualificationcontroller.text,
//                                 'experience': _experiencecontroller.text,
//                                 'hourly payment': _hourlypaymentcontroller.text,
//
//                                 'createdAt': DateTime.now(),
//                                 'status': 1,
//                                 'role': "service provider"
//                               }).then((value) {
//                                 Navigator.pushNamedAndRemoveUntil(
//                                     context, '/login', (Route route) => false);
//                               });
//                             }
//                           }
//                         },
//                         borderRadius: BorderRadius.circular(
//                             40), // Match the container's border radius
//                         splashColor: Colors.blue, // Ripple effect color
//                         child: Ink(
//                           decoration: BoxDecoration(
//                             color: Color(0xff0F3966),
//                             borderRadius: BorderRadius.circular(40),
//                           ),
//                           height: 55,
//                           width: 230,
//                           child: Center(
//                             child: Text(
//                               "Register",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 22),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     spacing: 10,
//                     children: [
//                       Text(
//                         "Already have an account ?",
//                         style: TextStyle(color: Color(0xff0F3966)),
//                       ),
//                       InkWell(
//                           onTap: () {
//                             // to register
//                           },
//                           child: GestureDetector(
//                               onTap: () {
//                                 // Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
//                                 //   return UserRegisterPage();
//                                 // }));
//                                 Navigator.pop(context);
//                               },
//                               child: Text(
//                                 "Login",
//                                 style: TextStyle(color: Colors.blue),
//                               )))
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           )),
//     );
//   }
// }



import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ServiceProviderRegisterPage extends StatefulWidget {
  const ServiceProviderRegisterPage({super.key});

  @override
  State<ServiceProviderRegisterPage> createState() =>
      _ServiceProviderRegisterPageState();
}

class _ServiceProviderRegisterPageState
    extends State<ServiceProviderRegisterPage> {
  final _spregisterKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? profileImageUrl; // Added this missing variable

  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  TextEditingController _phonecontroller = TextEditingController();
  TextEditingController _addresscontroller = TextEditingController();

  TextEditingController _servicescontroller = TextEditingController();
  TextEditingController _experiencecontroller = TextEditingController();

  TextEditingController _certificationscontroller = TextEditingController();

  TextEditingController _availabilitycontroller = TextEditingController();

  bool _visible = false;
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      String fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
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
                _buildProfileImage(),
                SizedBox(height: 20),
                _buildTextField(_namecontroller, "Buisness Name", Icons.person),
                _buildTextField(_emailcontroller, "Email", Icons.email),
                _buildTextField(passcontroller, "Password", Icons.lock,
                    isPassword: true),
                _buildTextField(_phonecontroller, "Phone", Icons.phone),
                _buildTextField(_addresscontroller, "Address", Icons.location_on),
                _buildTextField(
                    _experiencecontroller, "Years of Experience", Icons.work),
                _buildTextField(_certificationscontroller,
                    "Certifications (if any)", Icons.school),
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
                    color:
                    Colors.transparent, // To keep only the gradient visible
                    child: InkWell(
                      onTap: () async {
                        if (_spregisterKey.currentState!.validate()) {
                          try {
                            // Upload profile image if available
                            if (_profileImage != null) {
                              profileImageUrl = await _uploadImageToFirebase(_profileImage!);
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
                                "certifications": _certificationscontroller.text,
                                "availability": selectedAvailability,
                                'createdAt': DateTime.now(),
                                'status': 1,
                                'role': "service provider"
                              });

                              // Navigate to login page
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/serviceProviderHome', (Route route) => false);
                            }
                          } catch (e) {
                            // Show error message
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
                      borderRadius: BorderRadius.circular(
                          40), // Match the container's border radius
                      splashColor: Colors.blue, // Ripple effect color
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Color(0xff0F3966),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        height: 55,
                        width: 230,
                        child: Center(
                          child: Text(
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
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage:
        _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? Icon(Icons.camera_alt, size: 40, color: Color(0xff0F3966))
            : null,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_visible : false,  // Fixed the logic here
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
            icon:
            Icon(_visible ? Icons.visibility : Icons.visibility_off),
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
        mainAxisAlignment: MainAxisAlignment.start,
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
