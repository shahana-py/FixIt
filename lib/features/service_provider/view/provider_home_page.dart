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


//
// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:fixit/features/service_provider/view/provider_add_service_page.dart';
// import 'package:fixit/features/service_provider/view/provider_service_detailed_page.dart';
// import 'package:fixit/features/service_provider/view/provider_side_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../../core/shared/services/image_service.dart';
// import '../models/booking_model.dart';
// import 'booking_details_page.dart';
// import 'earnings_analysis.dart';
//
// class ServiceProviderHomePage extends StatefulWidget {
//   const ServiceProviderHomePage({super.key});
//
//   @override
//   State<ServiceProviderHomePage> createState() => _ServiceProviderHomePageState();
// }
//
// class _ServiceProviderHomePageState extends State<ServiceProviderHomePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final ImageService _imageService = ImageService();
//
//   String _providerName = '';
//   String? _profileImageUrl;
//   String? _currentProviderId;
//   File? _workSampleImage;
//   String? _workSampleUrl;
//   bool _isUploading = false;
//   bool _isSaving = false;
//   int _status = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProviderData();
//   }
//
//   Future<void> _fetchProviderData() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc =
//       await _firestore.collection('service provider').doc(user.uid).get();
//       if (userDoc.exists) {
//         setState(() {
//           _providerName = userDoc['name'] ?? '';
//           _profileImageUrl = userDoc['profileImage'];
//           _status = userDoc['status'] ?? 0;
//           _currentProviderId = userDoc['uid'] ?? '';
//         });
//       }
//     }
//   }
//
//   Future<Map<String, double>> _getServiceRatings() async {
//     final ratings = <String, double>{};
//     try {
//       // Get all services for this provider
//       final services = await _firestore
//           .collection('services')
//           .where('provider_id', isEqualTo: _auth.currentUser?.uid)
//           .get();
//
//       for (final service in services.docs) {
//         // Get all ratings for this service
//         final ratingsSnapshot = await _firestore
//             .collection('ratings')
//             .where('service_id', isEqualTo: service.id)
//             .get();
//
//         if (ratingsSnapshot.docs.isNotEmpty) {
//           double totalRating = 0;
//           for (final ratingDoc in ratingsSnapshot.docs) {
//             totalRating += (ratingDoc['rating'] as num).toDouble();
//           }
//           final averageRating = totalRating / ratingsSnapshot.docs.length;
//           ratings[service.id] = double.parse(averageRating.toStringAsFixed(1));
//         } else {
//           ratings[service.id] = 0.0;
//         }
//       }
//     } catch (e) {
//       print('Error fetching ratings: $e');
//     }
//     return ratings;
//   }
//
//   void _navigateToAddServicePage() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const AddServicePage(),
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
//               padding: const EdgeInsets.only(left: 15),
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
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AppBarTitle(text: _providerName),
//             if (_status == 1)
//               Padding(
//                 padding: const EdgeInsets.only(left: 4.0),
//                 child: Icon(Icons.verified, color: Colors.blue, size: 20),
//               ),
//           ],
//         ),
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
//           // Container(
//           //   width: 70,
//           //   height: 40,
//           //   decoration: BoxDecoration(
//           //     boxShadow: BoxShadow(),
//           //     borderRadius: BorderRadius.circular(30),
//           //     color: Colors.blue
//           //   ),
//           //   child: Center(child: Text("Earnings",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
//           // ),
//           IconButton(
//             onPressed: () {
//
//               if (_currentProviderId != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ProviderEarningsPage(providerId: _currentProviderId!),
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Unable to load my earnings. Please try again.')),
//                 );
//               }
//             },
//             icon: Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
//           ),
//           SizedBox(width: 10),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Banner Card
//             Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: Card(
//                 shadowColor: Colors.black,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                 child: Container(
//                   height: 300,
//                   width: double.infinity,
//                   padding: EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     image: DecorationImage(
//                         fit: BoxFit.cover,
//                         image: AssetImage(
//                             "assets/images/service provider home banner.png")),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(top: 10, left: 5),
//                         child: Text(
//                           "Be the Expert Everyone's Looking For!",
//                           style: TextStyle(
//                             fontSize: 27,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xff444444),
//                             fontFamily: 'Raleway',
//                             letterSpacing: 0.7,
//                             height: 1.5,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // My Services Section
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SubText(
//                         text: "My Services",
//                         fontSize: 20,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pushNamed(context, "/providerAllServicesPage");
//                         },
//                         child: SubText(
//                           text: "View All",
//                           color: Colors.blue,
//                           fontSize: 18,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     height: 200,
//                     child: FutureBuilder<Map<String, double>>(
//                       future: _getServiceRatings(),
//                       builder: (context, ratingsSnapshot) {
//                         if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
//                           return Center(child: CircularProgressIndicator(color: Color(0xff0F3966)));
//                         }
//
//                         return StreamBuilder<QuerySnapshot>(
//                           stream: _firestore
//                               .collection('services')
//                               .where('provider_id', isEqualTo: _auth.currentUser?.uid)
//                               .snapshots(),
//                           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return Center(child: CircularProgressIndicator(color: Color(0xff0F3966)));
//                             }
//
//                             if (snapshot.hasError) {
//                               return Center(child: Text('Error: ${snapshot.error}'));
//                             }
//
//                             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                               return Center(child: Text('No services found. Add your first service!'));
//                             }
//
//                             var services = snapshot.data!.docs;
//
//                             return ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               padding: EdgeInsets.symmetric(horizontal: 1),
//                               itemCount: services.length,
//                               itemBuilder: (context, index) {
//                                 final serviceDoc = services[index];
//                                 final data = serviceDoc.data() as Map<String, dynamic>;
//                                 final workSampleUrl = data['work_sample'];
//                                 final hasImage = workSampleUrl != null;
//
//                                 final serviceName = data['name'] ?? 'Unnamed';
//                                 final hourlyRate = data['hourly_rate']?.toString() ?? 'N/A';
//
//                                 // Get rating from our ratings map
//                                 final avgRating = ratingsSnapshot.hasData
//                                     ? ratingsSnapshot.data![serviceDoc.id] ?? 0.0
//                                     : 0.0;
//
//                                 return Container(
//                                   width: 160,
//                                   margin: EdgeInsets.only(right: 2),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => ServiceDetailsPage(serviceId: serviceDoc.id),
//                                         ),
//                                       );
//                                     },
//                                     child: Card(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       elevation:2,
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           // Image section
//                                           Container(
//                                             height: 120,
//                                             width: double.infinity,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.vertical(
//                                                   top: Radius.circular(20)),
//                                               color: hasImage ? null : Color(0xffC9E4CA),
//                                               image: hasImage
//                                                   ? DecorationImage(
//                                                 image: NetworkImage(workSampleUrl),
//                                                 fit: BoxFit.cover,
//                                               )
//                                                   : null,
//                                             ),
//                                             child: hasImage
//                                                 ? null
//                                                 : Icon(Icons.build, color: Color(0xff0F3966)),
//                                           ),
//
//                                           // Text section
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   serviceName,
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     color: Color(0xff0F3966),
//                                                     fontWeight: FontWeight.bold,
//                                                     overflow: TextOverflow.ellipsis,
//                                                   ),
//                                                   maxLines: 1,
//                                                 ),
//                                                 SizedBox(height: 4),
//                                                 Text(
//                                                   "₹$hourlyRate/h",
//                                                   style: TextStyle(
//                                                     fontSize: 10,
//                                                     color: Color(0xff0F3966),
//                                                     overflow: TextOverflow.ellipsis,
//                                                   ),
//                                                   maxLines: 1,
//                                                 ),
//                                                 SizedBox(height: 4),
//                                                 Row(
//                                                   children: [
//                                                     Icon(Icons.star,
//                                                         color: Colors.amber, size: 14),
//                                                     SizedBox(width: 4),
//                                                     Text(
//                                                       avgRating.toStringAsFixed(1),
//                                                       style: TextStyle(
//                                                         fontSize: 11,
//                                                         fontWeight: FontWeight.w600,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Upcoming Bookings Section
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SubText(
//                     text: "Upcoming Bookings",
//                     fontSize: 20,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushNamed(context, "/providerAllBookingsPage");
//                     },
//                     child: SubText(
//                       text: "View All",
//                       color: Colors.blue,
//                       fontSize: 18,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Bookings List with ExpansionTile
//             StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('bookings')
//                   .where('provider_id', isEqualTo: _auth.currentUser?.uid)
//                   .where('status', isNotEqualTo: 'completed') // Exclude completed bookings
//                   .orderBy('booking_date', descending: false)
//                   .limit(5)
//                   .snapshots(),
//               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator(color: Color(0xff0F3966)));
//                 }
//
//                 if (snapshot.hasError) {
//                   print('Firestore Error: ${snapshot.error}');
//
//                   if (snapshot.error.toString().contains('index')) {
//                     print('\n🔥 FIREBASE INDEX CREATION LINK:');
//                     print('----------------------------------');
//                     print(snapshot.error.toString().split('here: ')[1].split(')')[0]);
//                     print('----------------------------------');
//                     print('Copy this URL and open in browser to create the required index');
//                   }
//
//                   return Center(child: Text('Error loading bookings'));
//                 }
//
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No upcoming bookings'));
//                 }
//
//                 var bookings = snapshot.data!.docs;
//
//                 return ListView.builder(
//                   itemCount: bookings.length,
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   itemBuilder: (context, index) {
//                     final bookingData = bookings[index].data() as Map<String, dynamic>;
//
//                     // Extract booking information
//                     final serviceName = bookingData['service_name'] ?? 'Unnamed Service';
//                     final serviceId = bookingData['service_id'] ?? '';
//                     final bookingDate = bookingData['booking_date'] as Timestamp?;
//                     final formattedDate = bookingDate != null
//                         ? DateFormat('MMM dd, yyyy • hh:mm a').format(bookingDate.toDate())
//                         : 'Date not specified';
//                     final status = bookingData['status'] ?? 'pending';
//                     final userId = bookingData['user_id'] ?? '';
//                     final durationHours = bookingData['duration_hours']?.toString() ?? '1';
//                     final hourlyRate = bookingData['hourly_rate'] ?? '0';
//                     final totalCost = bookingData['total_cost']?.toString() ?? '0';
//                     final paymentStatus = bookingData['payment_status'] ?? 'unpaid';
//                     final notes = bookingData['notes'] ?? '';
//
//                     return Card(
//                       margin: EdgeInsets.only(bottom: 10),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       elevation: 2,
//                       child: FutureBuilder<List<DocumentSnapshot>>(
//                         future: Future.wait([
//                           _firestore.collection('users').doc(userId).get(),
//                           _firestore.collection('services').doc(serviceId).get(),
//                         ]),
//                         builder: (context, snapshots) {
//                           // Default user info
//                           String userName = 'User';
//                           String userAddress = '';
//                           String? profileImageUrl;
//
//                           // Default service info
//                           String? workSample;
//
//                           if (snapshots.hasData && snapshots.data != null) {
//                             // Extract user data
//                             final userDoc = snapshots.data![0];
//                             if (userDoc.exists) {
//                               final userData = userDoc.data() as Map<String, dynamic>?;
//                               if (userData != null) {
//                                 userName = userData['name'] ?? 'User';
//                                 userAddress = userData['address'] ?? '';
//                                 profileImageUrl = userData['profileImageUrl'];
//                               }
//                             }
//
//                             // Extract service data
//                             final serviceDoc = snapshots.data![1];
//                             if (serviceDoc.exists) {
//                               final serviceData = serviceDoc.data() as Map<String, dynamic>?;
//                               if (serviceData != null) {
//                                 workSample = serviceData['work_sample'];
//                               }
//                             }
//                           }
//
//                           // Status color and text helper functions
//                           Color _getStatusColor(String status) {
//                             switch (status.toLowerCase()) {
//                               case 'completed':
//                                 return Colors.green;
//                               case 'pending':
//                               case 'pending_payment':
//                                 return Colors.orange;
//                               case 'cancelled':
//                                 return Colors.red;
//                               case 'confirmed':
//                                 return Colors.blue;
//                               default:
//                                 return Colors.grey;
//                             }
//                           }
//
//                           String _getStatusText(String status) {
//                             switch (status.toLowerCase()) {
//                               case 'pending_payment':
//                                 return 'Payment Pending';
//                               case 'completed':
//                                 return 'Completed';
//                               case 'pending':
//                                 return 'Pending';
//                               case 'cancelled':
//                                 return 'Cancelled';
//                               case 'confirmed':
//                                 return 'Confirmed';
//                               default:
//                                 return status.substring(0, 1).toUpperCase() + status.substring(1);
//                             }
//                           }
//
//                           return ExpansionTile(
//                             tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                             childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
//                             leading: CircleAvatar(
//                               radius: 22,
//                               backgroundColor: Colors.grey[200],
//                               backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
//                                   ? NetworkImage(profileImageUrl)
//                                   : null,
//                               child: (profileImageUrl == null || profileImageUrl.isEmpty)
//                                   ? Icon(Icons.person, color: Color(0xff0F3966))
//                                   : null,
//                             ),
//                             title: Text(
//                               userName,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                                 color: Color(0xff0F3966),
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             subtitle: userAddress.isNotEmpty
//                                 ? Row(
//                               children: [
//                                 Icon(Icons.location_on, size: 12, color: Colors.grey),
//                                 SizedBox(width: 2),
//                                 Expanded(
//                                   child: Text(
//                                     userAddress,
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: Colors.grey[600],
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             )
//                                 : null,
//
//                             children: [
//                               // Service details section
//                               Row(
//                                 spacing: 20,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//
//                                   // Right column for the work sample image
//                                   if (workSample != null && workSample.isNotEmpty)
//                                     Expanded(
//                                       flex: 2,
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(left: 10.0),
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.circular(8),
//                                           child: Image.network(
//                                             workSample,
//                                             height: 110,
//                                             fit: BoxFit.cover,
//                                             errorBuilder: (context, error, stackTrace) => Container(
//                                               height: 110,
//                                               color: Colors.grey[200],
//                                               child: Icon(Icons.image_not_supported, color: Colors.grey),
//                                             ),
//                                             loadingBuilder: (context, child, loadingProgress) {
//                                               if (loadingProgress == null) return child;
//                                               return Container(
//                                                 height: 80,
//                                                 color: Colors.grey[200],
//                                                 child: Center(
//                                                   child: CircularProgressIndicator(
//                                                     value: loadingProgress.expectedTotalBytes != null
//                                                         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                                         : null,
//                                                     valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0F3966)),
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   // Left column with service details
//                                   Expanded(
//                                     flex: 3,
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           serviceName,
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                         SizedBox(height: 5),
//                                         Row(
//                                           children: [
//                                             Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
//                                             SizedBox(width: 4),
//                                             Expanded(
//                                               child: Text(
//                                                 formattedDate,
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey[600],
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: 5),
//                                         Row(
//                                           children: [
//                                             Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
//                                             SizedBox(width: 4),
//                                             Text(
//                                               "$durationHours hr • ₹$hourlyRate/hr",
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.grey[600],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: 5),
//                                         Row(
//                                           children: [
//                                             Icon(
//                                               paymentStatus == 'paid' ? Icons.check_circle : Icons.pending_actions,
//                                               size: 14,
//                                               color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
//                                             ),
//                                             SizedBox(width: 4),
//                                             Text(
//                                               paymentStatus == 'paid' ? 'Paid' : 'Payment Pending',
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//
//
//                                           ],
//                                         ),
//                                         Text(
//                                           "₹$totalCost",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Color(0xff0F3966),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//
//                                 ],
//                               ),
//
//                               // Action buttons
//                               SizedBox(height: 15),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       // Create a BookingModel from the booking data
//                                       final bookingModel = BookingModel(
//                                         id: bookings[index].id,
//                                         userId: userId,
//                                         providerId: _auth.currentUser?.uid ?? '',
//                                         providerName: _providerName ?? 'Unknown Provider',
//                                         serviceId: serviceId,
//                                         serviceName: serviceName,
//                                         bookingDate: bookingDate?.toDate() ?? DateTime.now(),
//                                         status: status,
//                                         durationHours: int.tryParse(durationHours) ?? 1,
//                                         hourlyRate: double.tryParse(hourlyRate.toString()) ?? 0.0,
//                                         totalCost: double.tryParse(totalCost) ?? 0.0,
//                                         paymentStatus: paymentStatus,
//                                         notes: notes,
//                                         createdAt: DateTime.now(),
//                                         userName: userName,
//                                         address: userAddress,
//                                       );
//
//                                       // Navigate to booking details page with the created model
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => BookingDetailsPage(
//                                             booking: bookingModel,
//                                             profileImageUrl: profileImageUrl ?? '',
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Color(0xff0F3966),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(20)
//                                       ),
//                                       padding: EdgeInsets.symmetric(horizontal: 12),
//                                     ),
//                                     child: Text('View Details', style: TextStyle(fontSize: 12, color: Colors.white)),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             )
//
//             ,SizedBox(height: 20),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _navigateToAddServicePage,
//         backgroundColor: Color(0xff0F3966),
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }




import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/features/service_provider/view/provider_add_service_page.dart';
import 'package:fixit/features/service_provider/view/provider_service_detailed_page.dart';
import 'package:fixit/features/service_provider/view/provider_side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/shared/services/image_service.dart';
import '../models/booking_model.dart';
import 'booking_details_page.dart';
import 'earnings_analysis.dart';

class ServiceProviderHomePage extends StatefulWidget {
  const ServiceProviderHomePage({super.key});

  @override
  State<ServiceProviderHomePage> createState() => _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState extends State<ServiceProviderHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageService _imageService = ImageService();

  String _providerName = '';
  String? _profileImageUrl;
  String? _currentProviderId;
  File? _workSampleImage;
  String? _workSampleUrl;
  bool _isUploading = false;
  bool _isSaving = false;
  int _status = 0;
  int _unreadNotificationsCount = 0;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _fetchProviderData();
    _fetchUnreadNotificationsCount();
    _setupNotificationListener();
  }
  void dispose() {

    _notificationSubscription?.cancel();
    super.dispose();
  }

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
          _currentProviderId = userDoc['uid'] ?? '';
        });
      }
    }
  }

  Future<void> _toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      setState(() {
        _isSaving = true;
      });

      await _firestore.collection('services').doc(serviceId).update({
        'isActive': isActive,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Show a snackbar to confirm the change
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive
              ? 'Service is now activated'
              : 'Service is now deactivated'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update service status: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // This is the corrected code for the notification handling section

  void _setupNotificationListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _notificationSubscription?.cancel();

    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .where('recipientType', whereIn: ['all', 'serviceProvider'])
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        // Check if this notification is for all service providers or specifically for this provider
        return data['recipientType'] == 'all' ||
            (data['recipientType'] == 'serviceProvider' &&
                (data['recipientUid'] == currentUser.uid || data['recipientUid'] == null));
      }).toList();

      if (mounted) {
        setState(() {
          _unreadNotificationsCount = filteredDocs.length;
        });
      }
    }, onError: (error) {
      print('Error listening to notifications: $error');
    });
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Query notifications that are unread and either for all service providers or specifically for this provider
      final query = _firestore
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('recipientType', whereIn: ['all', 'serviceProvider']);

      query.get().then((snapshot) {
        if (mounted) {
          final filteredDocs = snapshot.docs.where((doc) {
            final data = doc.data();
            return data['recipientType'] == 'all' ||
                (data['recipientType'] == 'serviceProvider' &&
                    (data['recipientUid'] == user.uid || data['recipientUid'] == null))||
                (data['recipientType'] == 'serviceProvider' &&
                    (data['recipientId'] == null));
          }).toList();

          setState(() {
            _unreadNotificationsCount = filteredDocs.length;
          });
        }
      });
    }
  }

  Future<void> _markNotificationsAsRead() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('recipientType', whereIn: ['all', 'serviceProvider'])
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['recipientType'] == 'all' ||
            (data['recipientType'] == 'serviceProvider' &&
                (data['recipientUid'] == currentUser.uid || data['recipientUid'] == null))||
            (data['recipientType'] == 'serviceProvider' &&
                (data['recipientId'] == null))) {
          batch.update(doc.reference, {'isRead': true});
        }
      }

      await batch.commit();

      if (mounted) {
        setState(() {
          _unreadNotificationsCount = 0;
        });
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  Future<Map<String, double>> _getServiceRatings() async {
    final ratings = <String, double>{};
    try {
      // Get all services for this provider
      final services = await _firestore
          .collection('services')
          .where('provider_id', isEqualTo: _auth.currentUser?.uid)
          .get();

      for (final service in services.docs) {
        // Get all ratings for this service
        final ratingsSnapshot = await _firestore
            .collection('ratings')
            .where('service_id', isEqualTo: service.id)
            .get();

        if (ratingsSnapshot.docs.isNotEmpty) {
          double totalRating = 0;
          for (final ratingDoc in ratingsSnapshot.docs) {
            totalRating += (ratingDoc['rating'] as num).toDouble();
          }
          final averageRating = totalRating / ratingsSnapshot.docs.length;
          ratings[service.id] = double.parse(averageRating.toStringAsFixed(1));
        } else {
          ratings[service.id] = 0.0;
        }
      }
    } catch (e) {
      print('Error fetching ratings: $e');
    }
    return ratings;
  }


  void _openNotificationsPage() async {
    await _markNotificationsAsRead();
    await Navigator.pushNamed(context, '/providernotificationpage');
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
                child: Icon(Icons.verified, color: Colors.blue, size: 20),
              ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _openNotificationsPage,
                icon: Icon(Icons.notifications, color: Colors.white, size: 24),
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$_unreadNotificationsCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () {
              if (_currentProviderId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProviderEarningsPage(providerId: _currentProviderId!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unable to load my earnings. Please try again.')),
                );
              }
            },
            icon: Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Card
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
            ),

            // My Services Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  Row(
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
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 200,
                    child: FutureBuilder<Map<String, double>>(
                      future: _getServiceRatings(),
                      builder: (context, ratingsSnapshot) {
                        if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: Color(0xff0F3966)));
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('services')
                              .where('provider_id', isEqualTo: _auth.currentUser?.uid)
                              .snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(color: Color(0xff0F3966)));
                            }

                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No services found. Add your first service!'));
                            }

                            var services = snapshot.data!.docs;

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                final serviceDoc = services[index];
                                final data = serviceDoc.data() as Map<String, dynamic>;
                                final workSampleUrl = data['work_sample'];
                                final hasImage = workSampleUrl != null;

                                final serviceName = data['name'] ?? 'Unnamed';
                                final hourlyRate = data['hourly_rate']?.toString() ?? 'N/A';

                                // Get rating from our ratings map
                                final avgRating = ratingsSnapshot.hasData
                                    ? ratingsSnapshot.data![serviceDoc.id] ?? 0.0
                                    : 0.0;

                                return Container(
                                  width: 160,
                                  margin: EdgeInsets.only(right: 2),
                                  child: GestureDetector(
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
                                      elevation:2,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Stack(
                                            children: [
                                              // Image container
                                              // Container(
                                              //   height: 120,
                                              //   width: double.infinity,
                                              //   decoration: BoxDecoration(
                                              //     borderRadius: BorderRadius.vertical(
                                              //         top: Radius.circular(20)),
                                              //     color: hasImage ? null : Color(0xffC9E4CA),
                                              //     image: hasImage
                                              //         ? DecorationImage(
                                              //       image: NetworkImage(workSampleUrl),
                                              //       fit: BoxFit.cover,
                                              //     )
                                              //         : null,
                                              //   ),
                                              //   child: hasImage
                                              //       ? null
                                              //       : Icon(Icons.build, color: Color(0xff0F3966)),
                                              // ),


                                              Container(
                                                height: 120,
                                                width: double.infinity,
                                                child: Stack(
                                                  children: [
                                                    // Image with shimmer fallback
                                                    if (hasImage)
                                                      Shimmer.fromColors(
                                                        baseColor: Colors.grey[300]!,
                                                        highlightColor: Colors.grey[100]!,
                                                        period: Duration(seconds: 2), // Adjust speed
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),

                                                    // Actual image (covers shimmer when loaded)
                                                    if (hasImage)
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                        child: Image.network(
                                                          workSampleUrl,
                                                          fit: BoxFit.cover,
                                                          width: double.infinity,
                                                          height: 120,
                                                        ),
                                                      ),

                                                    // Fallback icon if no image
                                                    if (!hasImage)
                                                      Center(child: Icon(Icons.build, color: Color(0xff0F3966))),
                                                  ],
                                                ),
                                              ),


                                              // Switch positioned at top right
                                              // Positioned(
                                              //   top: 1,
                                              //   right: 1,
                                              //   child: Transform.scale(
                                              //     scale: 0.8,
                                              //     child: Switch(
                                              //       value: data['isActive'] ?? true,
                                              //       activeColor: Colors.green[900],
                                              //       onChanged: (value) {
                                              //         _toggleServiceStatus(serviceDoc.id, value);
                                              //       },
                                              //     ),
                                              //   ),
                                              // ),

                                              Positioned(
                                                top: 1,
                                                right: 1,
                                                child: Transform.scale(
                                                  scale: 0.8,
                                                  child: Container(
                                                    // padding: EdgeInsets.all(2),  // Comma was missing here
                                                    height: 35,
                                                    width: 55,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Switch(  // This is the proper child of Container
                                                      value: data['isActive'] ?? true,
                                                      activeColor: Colors.green[900],
                                                      inactiveThumbColor: Colors.grey[600],
                                                      inactiveTrackColor: Colors.grey[400],
                                                      onChanged: (value) {
                                                        _toggleServiceStatus(serviceDoc.id, value);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Text section
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                                                  ],
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
                                                        color: Colors.amber, size: 14),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      avgRating.toStringAsFixed(1),
                                                      style: TextStyle(
                                                        fontSize: 11,
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
                                  ),
                                );

                                // // Inside your ListView.builder itemBuilder:
                                // return Container(
                                //   width: 160,
                                //   margin: EdgeInsets.only(right: 2),
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (context) => ServiceDetailsPage(serviceId: serviceDoc.id),
                                //         ),
                                //       );
                                //     },
                                //     child: Card(
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(20),
                                //       ),
                                //       elevation: 2,
                                //       child: Column(
                                //         mainAxisSize: MainAxisSize.min,
                                //         children: [
                                //           // Image section
                                //           Container(
                                //             height: 120,
                                //             width: double.infinity,
                                //             decoration: BoxDecoration(
                                //               borderRadius: BorderRadius.vertical(
                                //                   top: Radius.circular(20)),
                                //               color: hasImage ? null : Color(0xffC9E4CA),
                                //               image: hasImage
                                //                   ? DecorationImage(
                                //                 image: NetworkImage(workSampleUrl),
                                //                 fit: BoxFit.cover,
                                //               )
                                //                   : null,
                                //             ),
                                //             child: Stack(
                                //               children: [
                                //                 if (!hasImage)
                                //                   Icon(Icons.build, color: Color(0xff0F3966)),
                                //                 if (data['isActive'] == false)
                                //                   Container(
                                //                     decoration: BoxDecoration(
                                //                         color: Colors.black54,
                                //                         borderRadius: BorderRadius.vertical(
                                //                             top: Radius.circular(20))),
                                //                     child: Center(
                                //                       child: Text(
                                //                         'Not Available',
                                //                         style: TextStyle(
                                //                           color: Colors.white,
                                //                           fontWeight: FontWeight.bold,
                                //                         ),
                                //                       ),
                                //                     ),
                                //                   ),
                                //               ],
                                //             ),
                                //           ),
                                //
                                //           // Text section
                                //           Padding(
                                //             padding: const EdgeInsets.all(8.0),
                                //             child: Column(
                                //               crossAxisAlignment: CrossAxisAlignment.start,
                                //               children: [
                                //                 Row(
                                //                   children: [
                                //                     Text(
                                //                       serviceName,
                                //                       style: TextStyle(
                                //                         fontSize: 12,
                                //                         color: Color(0xff0F3966),
                                //                         fontWeight: FontWeight.bold,
                                //                         overflow: TextOverflow.ellipsis,
                                //                       ),
                                //                       maxLines: 1,
                                //                     ),
                                //                     Transform.scale(
                                //                       scale: 0.8,
                                //                       child: Switch(
                                //                         value: data['isActive'] ?? true,
                                //                         activeColor: Color(0xff0F3966),
                                //                         onChanged: (value) {
                                //                           _toggleServiceStatus(serviceDoc.id, value);
                                //                         },
                                //                       ),
                                //                     ),
                                //                   ],
                                //                 ),
                                //                 SizedBox(height: 4),
                                //                 Text(
                                //                   "₹$hourlyRate/h",
                                //                   style: TextStyle(
                                //                     fontSize: 10,
                                //                     color: Color(0xff0F3966),
                                //                     overflow: TextOverflow.ellipsis,
                                //                   ),
                                //                   maxLines: 1,
                                //                 ),
                                //                 SizedBox(height: 4),
                                //                 Row(
                                //                   children: [
                                //                     Icon(Icons.star,
                                //                         color: Colors.amber, size: 14),
                                //                     SizedBox(width: 4),
                                //                     Text(
                                //                       avgRating.toStringAsFixed(1),
                                //                       style: TextStyle(
                                //                         fontSize: 11,
                                //                         fontWeight: FontWeight.w600,
                                //                       ),
                                //                     ),
                                //                     // Spacer(),
                                //
                                //                   ],
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Upcoming Bookings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SubText(
                    text: "Upcoming Bookings",
                    fontSize: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/providerAllBookingsPage");
                    },
                    child: SubText(
                      text: "View All",
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // Bookings List with ExpansionTile
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('bookings')
                  .where('provider_id', isEqualTo: _auth.currentUser?.uid)
                  .where('status', isNotEqualTo: 'completed') // Exclude completed bookings
                  .orderBy('booking_date', descending: false)
                  .limit(5)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xff0F3966)));
                }

                if (snapshot.hasError) {
                  print('Firestore Error: ${snapshot.error}');

                  if (snapshot.error.toString().contains('index')) {
                    print('\n🔥 FIREBASE INDEX CREATION LINK:');
                    print('----------------------------------');
                    print(snapshot.error.toString().split('here: ')[1].split(')')[0]);
                    print('----------------------------------');
                    print('Copy this URL and open in browser to create the required index');
                  }

                  return Center(child: Text('Error loading bookings'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No upcoming bookings'));
                }

                var bookings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bookings.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  itemBuilder: (context, index) {
                    final bookingData = bookings[index].data() as Map<String, dynamic>;

                    // Extract booking information
                    final serviceName = bookingData['service_name'] ?? 'Unnamed Service';
                    final serviceId = bookingData['service_id'] ?? '';
                    final bookingDate = bookingData['booking_date'] as Timestamp?;
                    final formattedDate = bookingDate != null
                        ? DateFormat('MMM dd, yyyy • hh:mm a').format(bookingDate.toDate())
                        : 'Date not specified';
                    final status = bookingData['status'] ?? 'pending';
                    final userId = bookingData['user_id'] ?? '';
                    final durationHours = bookingData['duration_hours']?.toString() ?? '1';
                    final hourlyRate = bookingData['hourly_rate'] ?? '0';
                    final totalCost = bookingData['total_cost']?.toString() ?? '0';
                    final paymentStatus = bookingData['payment_status'] ?? 'unpaid';
                    final notes = bookingData['notes'] ?? '';

                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: FutureBuilder<List<DocumentSnapshot>>(
                        future: Future.wait([
                          _firestore.collection('users').doc(userId).get(),
                          _firestore.collection('services').doc(serviceId).get(),
                        ]),
                        builder: (context, snapshots) {
                          // Default user info
                          String userName = 'loading';
                          String userAddress = '';
                          String? profileImageUrl;

                          // Default service info
                          String? workSample;

                          if (snapshots.hasData && snapshots.data != null) {
                            // Extract user data
                            final userDoc = snapshots.data![0];
                            if (userDoc.exists) {
                              final userData = userDoc.data() as Map<String, dynamic>?;
                              if (userData != null) {
                                userName = userData['name'] ?? 'User';
                                userAddress = userData['address'] ?? '';
                                profileImageUrl = userData['profileImageUrl'];
                              }
                            }

                            // Extract service data
                            final serviceDoc = snapshots.data![1];
                            if (serviceDoc.exists) {
                              final serviceData = serviceDoc.data() as Map<String, dynamic>?;
                              if (serviceData != null) {
                                workSample = serviceData['work_sample'];
                              }
                            }
                          }

                          // Status color and text helper functions
                          Color _getStatusColor(String status) {
                            switch (status.toLowerCase()) {
                              case 'completed':
                                return Colors.green;
                              case 'pending':
                              case 'pending_payment':
                                return Colors.orange;
                              case 'cancelled':
                                return Colors.red;
                              case 'confirmed':
                                return Colors.blue;
                              default:
                                return Colors.grey;
                            }
                          }

                          String _getStatusText(String status) {
                            switch (status.toLowerCase()) {
                              case 'pending_payment':
                                return 'Payment Pending';
                              case 'completed':
                                return 'Completed';
                              case 'pending':
                                return 'Pending';
                              case 'cancelled':
                                return 'Cancelled';
                              case 'confirmed':
                                return 'Confirmed';
                              default:
                                return status.substring(0, 1).toUpperCase() + status.substring(1);
                            }
                          }

                          return ExpansionTile(
                            tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : null,
                              child: (profileImageUrl == null || profileImageUrl.isEmpty)
                                  ? Icon(Icons.person, color: Color(0xff0F3966))
                                  : null,
                            ),
                            title: Text(
                              userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xff0F3966),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: userAddress.isNotEmpty
                                ? Row(
                              children: [
                                Icon(Icons.location_on, size: 12, color: Colors.grey),
                                SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    userAddress,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                                : null,

                            children: [
                              // Service details section
                              Row(
                                spacing: 20,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // Right column for the work sample image
                                  if (workSample != null && workSample.isNotEmpty)
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            workSample,
                                            height: 110,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              height: 110,
                                              color: Colors.grey[200],
                                              child: Icon(Icons.image_not_supported, color: Colors.grey),
                                            ),
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                height: 80,
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0F3966)),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Left column with service details
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          serviceName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                            SizedBox(width: 4),
                                            Text(
                                              "$durationHours hr • ₹$hourlyRate/hr",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              paymentStatus == 'paid' ? Icons.check_circle : Icons.pending_actions,
                                              size: 14,
                                              color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              paymentStatus == 'paid' ? 'Paid' : 'Payment Pending',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),


                                          ],
                                        ),
                                        Text(
                                          "₹$totalCost",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff0F3966),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),

                              // Action buttons
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  ElevatedButton(
                                    onPressed: () {
                                      // Create a BookingModel from the booking data
                                      final bookingModel = BookingModel(
                                        id: bookings[index].id,
                                        userId: userId,
                                        providerId: _auth.currentUser?.uid ?? '',
                                        providerName: _providerName ?? 'Unknown Provider',
                                        serviceId: serviceId,
                                        serviceName: serviceName,
                                        bookingDate: bookingDate?.toDate() ?? DateTime.now(),
                                        status: status,
                                        durationHours: int.tryParse(durationHours) ?? 1,
                                        hourlyRate: double.tryParse(hourlyRate.toString()) ?? 0.0,
                                        totalCost: double.tryParse(totalCost) ?? 0.0,
                                        paymentStatus: paymentStatus,
                                        notes: notes,
                                        createdAt: DateTime.now(),
                                        userName: userName,
                                        address: userAddress,
                                      );

                                      // Navigate to booking details page with the created model
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookingDetailsPage(
                                            booking: bookingModel,
                                            profileImageUrl: profileImageUrl ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff0F3966),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    child: Text('View Details', style: TextStyle(fontSize: 12, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            )

            ,SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddServicePage,
        backgroundColor: Color(0xff0F3966),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}