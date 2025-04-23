// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:fixit/features/service_provider/view/provider_service_detailed_page.dart';
// import 'package:fixit/features/service_provider/view/provider_side_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
//
// class ServiceProviderHomePage extends StatefulWidget {
//   const ServiceProviderHomePage({super.key});
//
//   @override
//   State<ServiceProviderHomePage> createState() =>
//       _ServiceProviderHomePageState();
// }
//
// class _ServiceProviderHomePageState extends State<ServiceProviderHomePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<File> _workSamples = [];
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String providerName = "Provider";
//   String? _profileImageUrl;
//   List<String> _workSampleUrls = []; // Add this to store uploaded image URLs
//   bool _isUploadingImages = false; //
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProviderName();
//   }
//
//   Future<void> _fetchProviderName() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc =
//           await _firestore.collection('service provider').doc(user.uid).get();
//       if (userDoc.exists) {
//         setState(() {
//           providerName = userDoc['name'] ?? "Provider";
//           _profileImageUrl = userDoc['profileImage'];
//         });
//       }
//     }
//   }
//
//   Future<void> _pickImages() async {
//     try {
//       final pickedFiles = await ImagePicker().pickMultiImage();
//       if (pickedFiles != null && pickedFiles.isNotEmpty) {
//         setState(() {
//           _isUploadingImages = true;
//           _workSamples = pickedFiles.map((e) => File(e.path)).toList();
//         });
//
//         // Upload all selected images
//         List<String> uploadedUrls = [];
//         for (var imageFile in _workSamples) {
//           final url = await _uploadImageToFirebase(imageFile);
//           if (url != null) {
//             uploadedUrls.add(url);
//           }
//         }
//
//         setState(() {
//           _workSampleUrls = uploadedUrls;
//           _isUploadingImages = false;
//         });
//       }
//     } catch (e) {
//       setState(() => _isUploadingImages = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to pick images: ${e.toString()}')),
//       );
//     }
//   }
//
//   Future<String?> _uploadImageToFirebase(File image) async {
//     try {
//       String fileName = 'work_samples/${DateTime.now().millisecondsSinceEpoch}_${_auth.currentUser?.uid}.jpg';
//       Reference ref = FirebaseStorage.instance.ref().child(fileName);
//       UploadTask uploadTask = ref.putFile(image);
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       print("Image upload failed: $e");
//       return null;
//     }
//   }
//
//   // void _showAddServiceDialog() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) {
//   //       TextEditingController serviceNameController = TextEditingController();
//   //       TextEditingController experienceController = TextEditingController();
//   //       TextEditingController hourlyRateController = TextEditingController();
//   //
//   //       return AlertDialog(
//   //         shape:
//   //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//   //         title: Text("Add Service",
//   //             style: TextStyle(
//   //                 fontWeight: FontWeight.bold, color: Color(0xff0F3966))),
//   //         content: SingleChildScrollView(
//   //           child: Column(
//   //             mainAxisSize: MainAxisSize.min,
//   //             children: [
//   //               _buildTextField(serviceNameController, "Service Name"),
//   //               _buildTextField(experienceController, "Years of Experience",
//   //                   TextInputType.number),
//   //               _buildTextField(
//   //                   hourlyRateController, "Hourly Rate", TextInputType.number),
//   //               SizedBox(height: 10),
//   //               ElevatedButton.icon(
//   //                 onPressed: _pickImages,
//   //                 icon: Icon(
//   //                   Icons.photo_library,
//   //                   color: Colors.white,
//   //                 ),
//   //                 label: Text(
//   //                   "Add Work Samples",
//   //                   style: TextStyle(color: Colors.white),
//   //                 ),
//   //                 style: ElevatedButton.styleFrom(
//   //                     backgroundColor: Color(0xff0F3966)),
//   //               ),
//   //               Wrap(
//   //                 spacing: 8.0,
//   //                 children: _workSamples
//   //                     .map((image) => Image.file(image, width: 50, height: 50))
//   //                     .toList(),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () => Navigator.pop(context),
//   //             child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//   //           ),
//   //           ElevatedButton(
//   //             onPressed: () async {
//   //               User? user = _auth.currentUser;
//   //               if (user != null) {
//   //                 DocumentSnapshot userDoc = await _firestore
//   //                     .collection('service provider')
//   //                     .doc(user.uid)
//   //                     .get();
//   //
//   //                 if (userDoc.exists) {
//   //                   _firestore.collection('services').add({
//   //                     'name': serviceNameController.text,
//   //                     'experience': experienceController.text,
//   //                     'hourly_rate': hourlyRateController.text,
//   //                     'provider_id':
//   //                         user.uid, // Store the service provider's UID
//   //                   });
//   //                   Navigator.pop(context);
//   //                 } else {
//   //                   ScaffoldMessenger.of(context).showSnackBar(
//   //                     SnackBar(
//   //                         content: Text("Error: Service provider not found")),
//   //                   );
//   //                 }
//   //               }
//   //             },
//   //             style: ElevatedButton.styleFrom(
//   //               backgroundColor: Color(0xff0F3966),
//   //               shape: RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(10)),
//   //             ),
//   //             child: Text(
//   //               "Save",
//   //               style: TextStyle(color: Colors.white),
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
//
//   void _showAddServiceDialog() {
//     List<String> selectedAreas = [];
//     List<String> selectedDays = [];
//
//     final List<String> districtsOfKerala = [
//       'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha',
//       'Kottayam', 'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad',
//       'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod',
//     ];
//
//     final List<String> weekDays = [
//       'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
//     ];
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         TextEditingController serviceNameController = TextEditingController();
//         TextEditingController experienceController = TextEditingController();
//         TextEditingController hourlyRateController = TextEditingController();
//         TextEditingController descriptionController = TextEditingController();
//
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               title: Text("Add Service", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0F3966))),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildTextField(serviceNameController, "Service Name"),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 10.0),
//                       child: TextFormField(
//                         controller: descriptionController,
//                         keyboardType: TextInputType.multiline,
//                         maxLines: 4,
//                         decoration: InputDecoration(
//                           labelText: "Description",
//                           alignLabelWithHint: true,
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                         ),
//                       ),
//                     ),
//                     _buildTextField(experienceController, "Years of Experience", TextInputType.number),
//                     _buildTextField(hourlyRateController, "Hourly Rate", TextInputType.number),
//                     SizedBox(height: 10),
//
//                     // Areas
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text("Available Areas", style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     SizedBox(height: 6),
//                     GestureDetector(
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             return StatefulBuilder(builder: (context, innerSetState) {
//                               return AlertDialog(
//                                 title: Text("Select Available Areas"),
//                                 content: Container(
//                                   width: double.maxFinite,
//                                   child: ListView(
//                                     shrinkWrap: true,
//                                     children: districtsOfKerala.map((district) {
//                                       return CheckboxListTile(
//                                         title: Text(district),
//                                         value: selectedAreas.contains(district),
//                                         onChanged: (bool? selected) {
//                                           innerSetState(() {
//                                             if (selected == true) {
//                                               selectedAreas.add(district);
//                                             } else {
//                                               selectedAreas.remove(district);
//                                             }
//                                           });
//                                           setState(() {}); // to reflect changes in parent dialog
//                                         },
//                                       );
//                                     }).toList(),
//                                   ),
//                                 ),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(context),
//                                     child: Text("Done"),
//                                   )
//                                 ],
//                               );
//                             });
//                           },
//                         );
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 selectedAreas.isEmpty
//                                     ? 'Select Available Areas'
//                                     : selectedAreas.join(', '),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Icon(Icons.arrow_drop_down),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 15),
//
//                     // Days
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text("Available Days", style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Wrap(
//                       spacing: 8.0,
//                       runSpacing: 4.0,
//                       children: weekDays.map((day) {
//                         final isSelected = selectedDays.contains(day);
//                         return FilterChip(
//                           label: Text(day),
//                           selected: isSelected,
//                           backgroundColor: Colors.grey[200],
//                           selectedColor: Color(0xff0F3966),
//                           labelStyle: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black,
//                           ),
//                           onSelected: (bool selected) {
//                             setState(() {
//                               if (selected) {
//                                 selectedDays.add(day);
//                               } else {
//                                 selectedDays.remove(day);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//
//                     SizedBox(height: 10),
//
//                     ElevatedButton.icon(
//                       onPressed: _pickImages,
//                       icon: Icon(Icons.photo_library, color: Colors.white),
//                       label: Text("Add Work Samples", style: TextStyle(color: Colors.white)),
//                       style: ElevatedButton.styleFrom(backgroundColor: Color(0xff0F3966)),
//                     ),
//                     Wrap(
//                       spacing: 8.0,
//                       children: _workSamples.map((image) => Image.file(image, width: 50, height: 50)).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (_isUploadingImages) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("Please wait until images are uploaded")),
//                       );
//                       return;
//                     }
//                     User? user = _auth.currentUser;
//                     if (user != null) {
//                       DocumentSnapshot userDoc = await _firestore
//                           .collection('service provider')
//                           .doc(user.uid)
//                           .get();
//
//                       if (userDoc.exists) {
//                         await _firestore.collection('services').add({
//                           'name': serviceNameController.text,
//                           'experience': experienceController.text,
//                           'hourly_rate': hourlyRateController.text,
//                           'description': descriptionController.text,
//                           'available_areas': selectedAreas,
//                           'available_days': selectedDays,
//                           'work_samples': _workSampleUrls,
//                           'provider_id': user.uid,
//                           'created_at': FieldValue.serverTimestamp(),
//                         });
//                         setState(() {
//                           _workSamples.clear();
//                           _workSampleUrls.clear();
//                         });
//
//                         Navigator.pop(context);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Error: Service provider not found")),
//                         );
//                       }
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xff0F3966),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: Text("Save", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//
//   Widget _buildTextField(TextEditingController controller, String label,
//       [TextInputType type = TextInputType.text]) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         keyboardType: type,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: ProviderSideDrawer(),
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         leading: Builder(
//           builder: (context) => GestureDetector(
//             onTap: () => Scaffold.of(context).openDrawer(),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: CircleAvatar(
//                 backgroundColor: _profileImageUrl == null ? Colors.yellowAccent[600] : null,
//                 backgroundImage: _profileImageUrl != null
//                     ? NetworkImage(_profileImageUrl!)
//                     : null,
//                 child: _profileImageUrl == null
//                     ? Icon(Icons.person, color: Colors.blue)
//                     : null,
//               ),
//             ),
//           ),
//         ),
//         title: AppBarTitle(text: "$providerName"),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/providernotificationpage');
//               },
//               icon: Icon(
//                 Icons.notifications,
//                 color: Colors.white,
//                 size: 24,
//               )),
//           SizedBox(width: 10),
//           IconButton(
//             onPressed: () async {
//               SharedPreferences _pref = await SharedPreferences.getInstance();
//               _pref.clear();
//               FirebaseAuth.instance.signOut().then((value) {
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, '/login', (Route route) => false);
//               });
//             },
//             icon: Icon(Icons.logout, color: Colors.white, size: 24),
//           ),
//           SizedBox(width: 10),
//         ],
//       ),
//       body: Column(
//         children: [
//           Card(
//             shadowColor: Colors.black,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//             child: Container(
//               height: 300,
//               width: double.infinity,
//               padding: EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(25),
//                 image: DecorationImage(
//                     fit: BoxFit.cover,
//                     image: AssetImage(
//                         "assets/images/service provider home banner.png")),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 10, left: 5),
//                     child: Text(
//                       "Be the Expert Everyone’s Looking For!",
//                       style: TextStyle(
//                         fontSize: 27,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xff444444),
//                         fontFamily: 'Raleway',
//                         letterSpacing: 0.7,
//                         height: 1.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SubText(
//                   text: "My Services",
//                   fontSize: 20,
//                 ),
//                 GestureDetector(
//                     onTap: () {
//                       Navigator.pushNamed(context, "/providerAllServicesPage");
//                     },
//                     child: SubText(
//                       text: "View All",
//                       color: Colors.blue,
//                       fontSize: 18,
//                       fontWeight: FontWeight.normal,
//                     ))
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: StreamBuilder(
//                   stream: _firestore
//                       .collection('services')
//                       .where('provider_id', isEqualTo: _auth.currentUser?.uid)
//                       .snapshots(),
//                   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(
//                         child:
//                             CircularProgressIndicator(color: Color(0xff0F3966)),
//                       );
//                     }
//
//                     var services = snapshot.data!.docs;
//
//                     return services.isEmpty
//                         ? Center(
//                             child: Text('No services found'),
//                           )
//                         : SingleChildScrollView(
//                             scrollDirection:
//                                 Axis.horizontal, // Allows horizontal scrolling
//                             child: Padding(
//                               padding: const EdgeInsets.only(right: 10,left: 10),
//                               child: Row(
//                                 children: services.map((serviceDoc) {
//                                   final data = serviceDoc.data() as Map<String, dynamic>? ??{};
//                                   final workSamples = List<String>.from(data['work_samples'] ?? []);
//                                   final hasImages = workSamples.isNotEmpty;
//
//                                   if (data == null) return SizedBox(); // Or skip this card
//
//                                   final serviceName = data['name'] ?? 'Unnamed';
//                                   final hourlyRate = data['hourly_rate']?.toString() ?? 'N/A';
//
//                                   return Container(
//                                     width:
//                                         180, // Ensuring fixed width for each card
//                                     margin: EdgeInsets.only(
//                                         right: 10), // Spacing between cards
//                                     child: GestureDetector(
//                                       onTap: (){
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => ServiceDetailsPage(serviceId: serviceDoc.id),
//                                           ),
//                                         );
//                                       },
//                                       child: Card(
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(20),
//                                         ),
//                                         elevation: 5,
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize
//                                               .min, // Prevents unnecessary expansion
//                                           children: [
//                                             // Top section (icon)
//                                             Container(
//                                               height: 100,
//                                               width: double.infinity,
//                                               decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.vertical(
//                                                     top: Radius.circular(20)),
//                                                 color: hasImages ? null : Color(0xffC9E4CA),
//                                                 image: hasImages
//                                                     ? DecorationImage(
//                                                   image: NetworkImage(workSamples.first),
//                                                   fit: BoxFit.cover,
//                                                 )
//                                                     : null,
//                                               ),
//                                               child: hasImages
//                                                   ? null
//                                                   : Icon(Icons.build, color: Color(0xff0F3966)),
//                                             ),
//
//                                             // Bottom section (text)
//                                             Padding(
//                                               padding: const EdgeInsets.symmetric(
//                                                   horizontal: 8, vertical: 8),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.spaceBetween,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment.start,
//                                                     children: [
//                                                       Text(
//                                                         // service['name'],
//                                                         serviceName,
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           color: Color(0xff0F3966),
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           overflow:
//                                                               TextOverflow.ellipsis,
//                                                         ),
//                                                         maxLines: 1,
//                                                       ),
//                                                       SizedBox(
//                                                           height:
//                                                               4), // Avoids tight spacing
//                                                       Text(
//                                                         // "Rs ${service['hourly_rate']}/h",
//                                                         "₹$hourlyRate/h",
//                                                         style: TextStyle(
//                                                           fontSize: 10,
//                                                           color:Color(0xff0F3966) ,
//                                                           overflow:
//                                                               TextOverflow.ellipsis,
//                                                         ),
//                                                         maxLines: 1,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   Container(
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.white,
//
//                                                         borderRadius: BorderRadius.circular(20)),
//                                                     child: Padding(
//                                                       padding: const EdgeInsets.all(5.0),
//                                                       child: Row(
//                                                         children: [
//
//                                                           Icon(Icons.star,
//                                                               color: Colors.amber,size: 22,),
//                                                           SubText(
//                                                             text: "4.5",
//                                                             fontSize: 13,
//                                                             fontWeight:
//                                                             FontWeight.w600,
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           );
//                   },
//                 ),
//               ),
//             ],
//           ),
//
//           // Expanded(
//           //   child: StreamBuilder(
//           //     stream: _firestore
//           //         .collection('services')
//           //         .where('provider_id', isEqualTo: _auth.currentUser?.uid)
//           //         .snapshots(),
//           //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           //       if (!snapshot.hasData) {
//           //         return Center(
//           //             child:
//           //                 CircularProgressIndicator(color: Color(0xff0F3966)));
//           //       }
//           //       var services = snapshot.data!.docs;
//           //       return services.isEmpty
//           //           ? Center(
//           //               child: GestureDetector(
//           //                 onTap: _showAddServiceDialog,
//           //                 child: Column(
//           //                   mainAxisAlignment: MainAxisAlignment.center,
//           //                   children: [
//           //                     Icon(Icons.add_circle,
//           //                         size: 80, color: Color(0xff0F3966)),
//           //                     SizedBox(height: 10),
//           //                     Text("Add a Service",
//           //                         style: TextStyle(
//           //                             fontSize: 18, color: Color(0xff0F3966))),
//           //                   ],
//           //                 ),
//           //               ),
//           //             )
//           //           : Row(
//           //               mainAxisAlignment: MainAxisAlignment.start,
//           //               crossAxisAlignment: CrossAxisAlignment.start,
//           //               spacing: 10,
//           //               children: services.map((service) {
//           //                 return Card(
//           //                   shape: RoundedRectangleBorder(
//           //                     borderRadius: BorderRadius.circular(30),
//           //                   ),
//           //                   elevation: 5,
//           //                   child: Column(
//           //                     children: [
//           //                       Container(
//           //                         height: 70,
//           //                         width: 150,
//           //                         decoration: BoxDecoration(
//           //                           borderRadius: BorderRadius.only(
//           //                             topLeft: Radius.circular(30),
//           //                             topRight: Radius.circular(30),
//           //                           ),
//           //                           color: Color(0xffC9E4CA),
//           //                         ),
//           //                         child: Icon(Icons.build,
//           //                             color: Color(0xff0F3966)),
//           //                       ),
//           //                       Container(
//           //                         height: 40,
//           //                         width: 100,
//           //                         decoration: BoxDecoration(
//           //                           borderRadius: BorderRadius.only(
//           //                             bottomLeft: Radius.circular(30),
//           //                             bottomRight: Radius.circular(30),
//           //                           ),
//           //                           color: Color(0xffC9E4CA),
//           //                         ),
//           //                         child: Row(
//           //                           mainAxisAlignment:
//           //                               MainAxisAlignment.spaceBetween,
//           //                           crossAxisAlignment:
//           //                               CrossAxisAlignment.center,
//           //                           children: [
//           //                             Column(
//           //                               mainAxisAlignment:
//           //                                   MainAxisAlignment.center,
//           //                               crossAxisAlignment:
//           //                                   CrossAxisAlignment.start,
//           //                               children: [
//           //                                 Text(
//           //                                   service['name'],
//           //                                   style: TextStyle(
//           //                                     fontSize: 12,
//           //                                     fontWeight: FontWeight.bold,
//           //                                   ),
//           //                                 ),
//           //                                 Text(
//           //                                   "${service['experience']} years | \$${service['hourly_rate']}/hr",
//           //                                   style: TextStyle(
//           //                                     fontSize: 10,
//           //                                   ),
//           //                                 ),
//           //                               ],
//           //                             ),
//           //                             Row(
//           //                               children: [
//           //                                 SubText(
//           //                                   text: "4.5",
//           //                                   fontSize: 15,
//           //                                   fontWeight: FontWeight.normal,
//           //                                 ),
//           //                                 Icon(Icons.star, color: Colors.amber),
//           //                               ],
//           //                             ),
//           //                           ],
//           //                         ),
//           //                       ),
//           //                     ],
//           //                   ),
//           //                 );
//           //               }).toList(),
//           //             );
//           //       // : ListView(
//           //       //     children: services.map((service) {
//           //       //       return Card(
//           //       //         shape: RoundedRectangleBorder(
//           //       //             borderRadius: BorderRadius.circular(15)),
//           //       //         elevation: 5,
//           //       //         color: Color(0xffC9E4CA),
//           //       //         margin: EdgeInsets.symmetric(
//           //       //             vertical: 8, horizontal: 10),
//           //       //         child: ListTile(
//           //       //           contentPadding: EdgeInsets.all(12),
//           //       //           title: Text(service['name'],
//           //       //               style: TextStyle(
//           //       //                   fontWeight: FontWeight.bold,
//           //       //                   color: Color(0xff0F3966))),
//           //       //           subtitle: Text(
//           //       //               "${service['experience']} years experience | \$${service['hourly_rate']}/hr"),
//           //       //           leading:
//           //       //               Icon(Icons.build, color: Color(0xff0F3966)),
//           //       //           trailing:
//           //       //           Padding(
//           //       //             padding: const EdgeInsets.only(right: 10),
//           //       //             child: Column(
//           //       //               children: [
//           //       //                 Icon(Icons.star,color: Colors.amber,),
//           //       //                 SubText(text: "4.5",fontSize: 15,fontWeight: FontWeight.normal,)
//           //       //               ],
//           //       //             ),
//           //       //           ),
//           //       //
//           //       //
//           //       //         ),
//           //       //       );
//           //       //     }).toList(),
//           //       //   );
//           //     },
//           //   ),
//           // ),
//
//
//
//
//           // Padding(
//           //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//           //   child: Row(
//           //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //     children: [
//           //       SubText(
//           //         text: "New Requests",
//           //         fontSize: 20,
//           //       ),
//           //       GestureDetector(
//           //           onTap: () {
//           //             // Navigator.pushNamed(context, "/providerAllServicesPage");
//           //           },
//           //           child: SubText(
//           //             text: "View All",
//           //             color: Colors.blue,
//           //             fontSize: 18,
//           //             fontWeight: FontWeight.normal,
//           //           ))
//           //     ],
//           //   ),
//           // ),
//           // Expanded(
//           //   child: ListView(
//           //     shrinkWrap: true,
//           //
//           //     physics:
//           //         NeverScrollableScrollPhysics(), // Prevents conflicts in scrolling
//           //     children: [
//           //       Card(
//           //         shape: RoundedRectangleBorder(
//           //             borderRadius: BorderRadius.circular(15)),
//           //         elevation: 5,
//           //         color: Color(0xffC9E4CA),
//           //         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//           //         child: Container(
//           //           width: double.infinity,
//           //           height: 120,
//           //           child: ListTile(
//           //             contentPadding: EdgeInsets.all(10),
//           //             title: Padding(
//           //               padding: const EdgeInsets.only(left: 20),
//           //               child: Text("Leaky Faucet",
//           //                   style: TextStyle(
//           //                       fontWeight: FontWeight.bold,
//           //                       color: Color(0xff0F3966))),
//           //             ),
//           //             subtitle: Padding(
//           //               padding: const EdgeInsets.only(left: 20),
//           //               child: Column(
//           //                 children: [
//           //                   Row(
//           //                     children: [
//           //                       Icon(Icons.calendar_month),
//           //                       SizedBox(width: 5),
//           //                       Text("30 March 2024")
//           //                     ],
//           //                   ),
//           //                   Row(
//           //                     children: [
//           //                       Icon(Icons.watch_later_outlined),
//           //                       SizedBox(width: 5),
//           //                       Text("10:00 AM")
//           //                     ],
//           //                   ),
//           //                 ],
//           //               ),
//           //             ),
//           //             leading: Container(
//           //               height: 150,
//           //               width: 150,
//           //               decoration: BoxDecoration(
//           //                 color: Colors.blue,
//           //                 borderRadius: BorderRadius.circular(15),
//           //               ),
//           //             ),
//           //           ),
//           //         ),
//           //       )
//           //     ],
//           //   ),
//           // )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddServiceDialog,
//         backgroundColor: Color(0xff0F3966),
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }
//
//
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/features/service_provider/view/provider_add_service_page.dart';
import 'package:fixit/features/service_provider/view/provider_service_detailed_page.dart';
import 'package:fixit/features/service_provider/view/provider_side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/shared/services/image_service.dart';

class ServiceProviderHomePage extends StatefulWidget {
  const ServiceProviderHomePage({super.key});

  @override
  State<ServiceProviderHomePage> createState() =>
      _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState extends State<ServiceProviderHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageService _imageService = ImageService();

  // String providerName = "Provider";
  bool _isApproved = false;

  int _status=0;
  String _providerName = '';
  String? _profileImageUrl;
  File? _workSampleImage;
  String? _workSampleUrl;
  bool _isUploading = false;
  bool _isSaving = false; // For save button loading indicator

  @override
  void initState() {
    super.initState();
    // _fetchProviderName();
    _fetchProviderData();
  }

  // Future<void> _fetchProviderData() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid != null) {
  //     DocumentSnapshot providerDoc = await FirebaseFirestore.instance
  //         .collection('service providers')
  //         .doc(uid)
  //         .get();
  //
  //     setState(() {
  //       _isApproved = providerDoc['isApproved'] ?? false;
  //       // or
  //       _status = providerDoc['status'] ?? 0;
  //       _providerName = providerDoc['name'] ?? '';
  //     });
  //   }
  // }

  Future<void> _fetchProviderData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('service provider').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _providerName = userDoc['name'] ?? '';
          _profileImageUrl = userDoc['profileImage'];
          _status = userDoc['status'] ?? 0;

        });
      }
    }
  }



  Future<void> _pickImage() async {
    final image = await _imageService.showImagePickerDialog(context);
    if (image != null) {
      setState(() {
        _workSampleImage = image;
        _workSampleUrl = null;
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _workSampleImage = null;
      _workSampleUrl = null;
    });
  }

  Future<void> _uploadImage() async {
    if (_workSampleImage == null) return;

    setState(() => _isUploading = true);

    try {
      final url = await _imageService.uploadImageWorking(
          _workSampleImage!,
          _auth.currentUser?.uid ?? 'service_provider'
      );

      if (url != null) {
        setState(() => _workSampleUrl = url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Service added successfully!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddServiceDialog() {
    List<String> selectedAreas = [];
    List<String> selectedDays = [];

    // Reset work sample image state
    setState(() {
      _workSampleImage = null;
      _workSampleUrl = null;
      _isUploading = false;
    });

    final List<String> districtsOfKerala = [
      'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha',
      'Kottayam', 'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad',
      'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod',
    ];

    final List<String> weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController serviceNameController = TextEditingController();
        TextEditingController experienceController = TextEditingController();
        TextEditingController hourlyRateController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();

        // Local variables to track image state in dialog
        File? localWorkSampleImage = _workSampleImage;
        String? localWorkSampleUrl = _workSampleUrl;
        bool localIsUploading = _isUploading;
        bool localIsSaving = _isSaving;

        return StatefulBuilder(
          builder: (context, setState) {
            // Define uploadImage function first
            Future<void> uploadImage(StateSetter dialogSetState) async {
              if (localWorkSampleImage == null) return;

              dialogSetState(() => localIsUploading = true);

              try {
                final url = await _imageService.uploadImageWorking(
                    localWorkSampleImage!,
                    _auth.currentUser?.uid ?? 'service_provider'
                );

                if (url != null) {
                  dialogSetState(() {
                    localWorkSampleUrl = url;
                    localIsUploading = false;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image upload failed')),
                  );
                  dialogSetState(() => localIsUploading = false);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error uploading image: $e')),
                );
                dialogSetState(() => localIsUploading = false);
              }
            }

            // Function to handle image picking within the dialog
            Future<void> pickImage() async {
              final image = await _imageService.showImagePickerDialog(context);
              if (image != null) {
                setState(() {
                  localWorkSampleImage = image;
                  localWorkSampleUrl = null;
                });

                // Start uploading the image immediately
                uploadImage(setState);
              }
            }

            // Function to handle image removal within the dialog
            void removeImage() {
              setState(() {
                localWorkSampleImage = null;
                localWorkSampleUrl = null;
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Add Service", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0F3966))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(serviceNameController, "Service Name"),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: "Description",
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    _buildTextField(experienceController, "Years of Experience", TextInputType.number),
                    _buildTextField(hourlyRateController, "Hourly Rate", TextInputType.number),
                    SizedBox(height: 10),

                    // Areas
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Available Areas", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(builder: (context, innerSetState) {
                              return AlertDialog(
                                title: Text("Select Available Areas"),
                                content: Container(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: districtsOfKerala.map((district) {
                                      return CheckboxListTile(
                                        title: Text(district),
                                        value: selectedAreas.contains(district),
                                        onChanged: (bool? selected) {
                                          innerSetState(() {
                                            if (selected == true) {
                                              selectedAreas.add(district);
                                            } else {
                                              selectedAreas.remove(district);
                                            }
                                          });
                                          setState(() {}); // to reflect changes in parent dialog
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Done"),
                                  )
                                ],
                              );
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedAreas.isEmpty
                                    ? 'Select Available Areas'
                                    : selectedAreas.join(', '),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Days
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Available Days", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: weekDays.map((day) {
                        final isSelected = selectedDays.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          backgroundColor: Colors.grey[200],
                          selectedColor: Color(0xff0F3966),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 15),

                    // Image upload section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Work Sample Image", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 8),

                    // Show work sample image if available
                    if (localWorkSampleImage != null || localWorkSampleUrl != null)
                      Stack(
                        children: [
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: localWorkSampleUrl != null
                                  ? Image.network(
                                localWorkSampleUrl!,
                                fit: BoxFit.cover,
                              )
                                  : Image.file(
                                localWorkSampleImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Show loading indicator while uploading
                          if (localIsUploading)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              ),
                            ),

                          // Remove button
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: localIsUploading ? null : removeImage,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 10),

                    // Add image button
                    ElevatedButton.icon(
                      onPressed: localIsUploading ? null : pickImage,
                      icon: Icon(Icons.photo_library, color: Colors.white),
                      label: Text("Add Work Sample", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xff0F3966)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  onPressed: (localIsUploading || localIsSaving) ? null : () async {
                    if (serviceNameController.text.isEmpty ||
                        descriptionController.text.isEmpty ||
                        experienceController.text.isEmpty ||
                        hourlyRateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    if (localWorkSampleImage == null && localWorkSampleUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please add a work sample image")),
                      );
                      return;
                    }

                    setState(() => localIsSaving = true);

                    try {
                      User? user = _auth.currentUser;
                      if (user != null) {
                        await _firestore.collection('services').add({
                          'name': serviceNameController.text,
                          'experience': experienceController.text,
                          'hourly_rate': hourlyRateController.text,
                          'description': descriptionController.text,
                          'available_areas': selectedAreas,
                          'available_days': selectedDays,
                          'work_sample': localWorkSampleUrl,
                          'provider_id': user.uid,
                          'created_at': FieldValue.serverTimestamp(),
                          'rating': 0,
                          'rating_count': 0,
                        });

                        // Update the main class state
                        _workSampleImage = null;
                        _workSampleUrl = null;

                        Navigator.pop(context);
                        _showSuccessSnackbar();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error saving service: $e")),
                      );
                    } finally {
                      setState(() => localIsSaving = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0F3966),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: localIsSaving || localIsUploading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: type,
      ),
    );
  }
  void _navigateToAddServicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddServicePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProviderSideDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: CircleAvatar(


                backgroundColor: _profileImageUrl == null ? Colors.yellowAccent[600] : null,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? Icon(Icons.person, color: Colors.blue)
                    : null,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBarTitle(text: _providerName),
            if (_status == 1)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.verified, color: Colors.green, size: 20),
              ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/providernotificationpage');
              },
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
                size: 24,
              )),
          SizedBox(width: 10),
          IconButton(
            onPressed: () async {
              SharedPreferences _pref = await SharedPreferences.getInstance();
              _pref.clear();
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route route) => false);
              });
            },
            icon: Icon(Icons.logout, color: Colors.white, size: 24),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Card(
            shadowColor: Colors.black,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Container(
              height: 300,
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                        "assets/images/service provider home banner.png")),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5),
                    child: Text(
                      "Be the Expert Everyone's Looking For!",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff444444),
                        fontFamily: 'Raleway',
                        letterSpacing: 0.7,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SubText(
                  text: "My Services",
                  fontSize: 20,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/providerAllServicesPage");
                    },
                    child: SubText(
                      text: "View All",
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ))
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('services')
                  .where('provider_id', isEqualTo: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xff0F3966)),
                  );
                }

                var services = snapshot.data!.docs;

                return services.isEmpty
                    ? Center(
                  child: Text('No services found'),
                )
                    : GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final serviceDoc = services[index];
                    final data = serviceDoc.data() as Map<String, dynamic>;
                    final workSampleUrl = data['work_sample'];
                    final hasImage = workSampleUrl != null;

                    final serviceName = data['name'] ?? 'Unnamed';
                    final hourlyRate = data['hourly_rate']?.toString() ?? 'N/A';
                    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
                    final ratingCount = (data['rating_count'] as num?)?.toInt() ?? 0;
                    final avgRating = ratingCount > 0 ? (rating / ratingCount) : 0.0;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailsPage(serviceId: serviceDoc.id),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Image section
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                color: hasImage ? null : Color(0xffC9E4CA),
                                image: hasImage
                                    ? DecorationImage(
                                  image: NetworkImage(workSampleUrl),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: hasImage
                                  ? null
                                  : Icon(Icons.build, color: Color(0xff0F3966)),
                            ),

                            // Text section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff0F3966),
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "₹$hourlyRate/h",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff0F3966),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        avgRating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddServicePage,
        backgroundColor: Color(0xff0F3966),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}