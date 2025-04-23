// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';
//
// class Offer {
//   final String id;
//   String name;
//   String bannerUrl;
//   bool isActive;
//
//   Offer({
//     required this.id,
//     required this.name,
//     required this.bannerUrl,
//     this.isActive = false,
//   });
//
//   // Convert Offer to a Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'bannerUrl': bannerUrl,
//       'isActive': isActive,
//     };
//   }
//
//   // Create Offer from Firestore document
//   factory Offer.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Offer(
//       id: doc.id,
//       name: data['name'] ?? '',
//       bannerUrl: data['bannerUrl'] ?? '',
//       isActive: data['isActive'] ?? false,
//     );
//   }
// }
//
// class AdminOfferManagementPage extends StatefulWidget {
//   const AdminOfferManagementPage({Key? key}) : super(key: key);
//
//   @override
//   State<AdminOfferManagementPage> createState() => _AdminOfferManagementPageState();
// }
//
// class _AdminOfferManagementPageState extends State<AdminOfferManagementPage> {
//   final TextEditingController _searchController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final CollectionReference _offersCollection = FirebaseFirestore.instance.collection('offers');
//
//   List<Offer> _offers = [];
//   List<Offer> _filteredOffers = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadOffers();
//     _searchController.addListener(_filterOffers);
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadOffers() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       QuerySnapshot querySnapshot = await _offersCollection.get();
//       final List<Offer> loadedOffers = querySnapshot.docs
//           .map((doc) => Offer.fromFirestore(doc))
//           .toList();
//
//       setState(() {
//         _offers = loadedOffers;
//         _filteredOffers = List.from(_offers);
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading offers: $e');
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load offers: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _filterOffers() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredOffers = _offers
//           .where((offer) => offer.name.toLowerCase().contains(query))
//           .toList();
//     });
//   }
//
//   Future<String?> _uploadImageToStorage(File imageFile) async {
//     try {
//       // Create a unique filename
//       final uuid = Uuid();
//       final fileName = 'offer_banners/${uuid.v4()}.jpg';
//
//       // Upload to Firebase Storage
//       final ref = _storage.ref().child(fileName);
//       final uploadTask = ref.putFile(imageFile);
//       final snapshot = await uploadTask;
//
//       // Get download URL
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       print('Error uploading image: $e');
//       return null;
//     }
//   }
//
//   Future<void> _addOrEditOffer(BuildContext context, {Offer? offer}) async {
//     final TextEditingController nameController = TextEditingController(text: offer?.name ?? '');
//     String? selectedImagePath;
//     String? existingImageUrl = offer?.bannerUrl;
//     bool isActive = offer?.isActive ?? false;
//     bool isEditMode = offer != null;
//     bool imageChanged = false;
//
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             Future<void> pickImage() async {
//               final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//               if (image != null) {
//                 setState(() {
//                   selectedImagePath = image.path;
//                   imageChanged = true;
//                 });
//               }
//             }
//
//             Widget imagePreview() {
//               if (selectedImagePath != null) {
//                 // For newly picked images
//                 return Image.file(
//                   File(selectedImagePath!),
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 );
//               } else if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
//                 // For existing images from Firestore
//                 return Image.network(
//                   existingImageUrl!,
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Center(
//                       child: CircularProgressIndicator(
//                         value: loadingProgress.expectedTotalBytes != null
//                             ? loadingProgress.cumulativeBytesLoaded /
//                             (loadingProgress.expectedTotalBytes ?? 1)
//                             : null,
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 150,
//                       width: double.infinity,
//                       color: Colors.grey[300],
//                       child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
//                     );
//                   },
//                 );
//               } else {
//                 // Placeholder for no image
//                 return Container(
//                   height: 150,
//                   width: double.infinity,
//                   color: Colors.grey[300],
//                   child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
//                 );
//               }
//             }
//
//             return AlertDialog(
//               title: Text(isEditMode ? 'Edit Offer' : 'Add New Offer',style: TextStyle(color: Color(0xff0F3966) ),),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextField(
//                       controller: nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Offer Name',
//                         hintText: 'Enter offer name',
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text('Banner Image:'),
//                     const SizedBox(height: 10),
//                     GestureDetector(
//                       onTap: pickImage,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           children: [
//                             imagePreview(),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 (selectedImagePath == null && existingImageUrl == null)
//                                     ? 'Tap to select banner image'
//                                     : 'Tap to change image',
//                                 style: TextStyle(color: Colors.blue),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: isActive,
//                           onChanged: (value) {
//                             setState(() {
//                               isActive = value ?? false;
//                             });
//                           },
//                         ),
//                         const Text('Active'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel',style: TextStyle(color: Colors.red),),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (nameController.text.trim().isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Please enter an offer name'),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                       return;
//                     }
//
//                     if (selectedImagePath == null && existingImageUrl == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Please select a banner image'),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                       return;
//                     }
//
//                     // Show loading indicator
//                     showDialog(
//                       context: context,
//                       barrierDismissible: false,
//                       builder: (context) => const Center(child: CircularProgressIndicator()),
//                     );
//
//                     try {
//                       // Upload image if new or changed
//                       String imageUrl = existingImageUrl ?? '';
//                       if (selectedImagePath != null) {
//                         final uploadedUrl = await _uploadImageToStorage(File(selectedImagePath!));
//                         if (uploadedUrl != null) {
//                           imageUrl = uploadedUrl;
//                         } else {
//                           // Handle image upload failure
//                           Navigator.pop(context); // Close loading dialog
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Failed to upload image'),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                           return;
//                         }
//                       }
//
//                       if (isEditMode && offer != null) {
//                         // Update existing offer in Firestore
//                         await _offersCollection.doc(offer.id).update({
//                           'name': nameController.text.trim(),
//                           'bannerUrl': imageUrl,
//                           'isActive': isActive,
//                         });
//                       } else {
//                         // Add new offer to Firestore
//                         await _offersCollection.add({
//                           'name': nameController.text.trim(),
//                           'bannerUrl': imageUrl,
//                           'isActive': isActive,
//                           'createdAt': FieldValue.serverTimestamp(),
//                         });
//                       }
//
//                       // Reload offers from Firestore
//                       await _loadOffers();
//
//                       // Close dialogs
//                       Navigator.pop(context); // Close loading dialog
//                       Navigator.pop(context); // Close add/edit dialog
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(isEditMode ? 'Offer updated successfully' : 'Offer added successfully'),
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                     } catch (e) {
//                       // Handle errors
//                       Navigator.pop(context); // Close loading dialog
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Error: $e'),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                     }
//                   },
//                   child: Text(isEditMode ? 'Update' : 'Add',style: TextStyle(color:  Color(0xff0F3966)),),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _deleteOffer(String id) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Offer'),
//         content: const Text('Are you sure you want to delete this offer?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               try {
//                 // Delete the offer from Firestore
//                 await _offersCollection.doc(id).delete();
//
//                 // Reload offers
//                 await _loadOffers();
//
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Offer deleted successfully'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } catch (e) {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Failed to delete offer: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _toggleOfferStatus(String id, bool currentStatus) async {
//     try {
//       // Update the offer status in Firestore
//       await _offersCollection.doc(id).update({
//         'isActive': !currentStatus,
//       });
//
//       // Reload offers
//       await _loadOffers();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Offer status updated to ${!currentStatus ? 'active' : 'inactive'}'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update offer status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor:  Color(0xff0F3966),
//         title: AppBarTitle(text: "Offer Management"),
//         elevation: 0,
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor:  Color(0xff0F3966),
//         onPressed: () => _addOrEditOffer(context),
//         child: const Icon(Icons.add,color: Colors.white,),
//         tooltip: 'Add New Offer',
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search Offers',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _filteredOffers.isEmpty
//                 ? const Center(
//               child: Text(
//                 'No offers found',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             )
//                 : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _filteredOffers.length,
//               itemBuilder: (context, index) {
//                 final offer = _filteredOffers[index];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   elevation: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Banner image
//                       ClipRRect(
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
//                         child: Image.network(
//                           offer.bannerUrl,
//                           height: 120,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               height: 120,
//                               width: double.infinity,
//                               color: Colors.grey[200],
//                               child: Center(
//                                 child: CircularProgressIndicator(
//                                   value: loadingProgress.expectedTotalBytes != null
//                                       ? loadingProgress.cumulativeBytesLoaded /
//                                       (loadingProgress.expectedTotalBytes ?? 1)
//                                       : null,
//                                 ),
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               height: 120,
//                               width: double.infinity,
//                               color: Colors.grey[300],
//                               child: const Icon(Icons.broken_image, size: 40),
//                             );
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     offer.name,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   InkWell(
//                                     onTap: () => _toggleOfferStatus(offer.id, offer.isActive),
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: offer.isActive
//                                             ? Colors.green[50]
//                                             : Colors.grey[200],
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: Text(
//                                         offer.isActive ? 'Active' : 'Inactive',
//                                         style: TextStyle(
//                                           color: offer.isActive
//                                               ? Colors.green[800]
//                                               : Colors.grey[700],
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.blue),
//                                   onPressed: () => _addOrEditOffer(context, offer: offer),
//                                   tooltip: 'Edit',
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () => _deleteOffer(offer.id),
//                                   tooltip: 'Delete',
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//

//
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';
// import '../../../core/shared/services/image_service.dart';
//
//
// class Offer {
//   final String id;
//   String name;
//   String bannerUrl;
//   bool isActive;
//
//   Offer({
//     required this.id,
//     required this.name,
//     required this.bannerUrl,
//     this.isActive = false,
//   });
//
//   // Convert Offer to a Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'bannerUrl': bannerUrl,
//       'isActive': isActive,
//     };
//   }
//
//   // Create Offer from Firestore document
//   factory Offer.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Offer(
//       id: doc.id,
//       name: data['name'] ?? '',
//       bannerUrl: data['bannerUrl'] ?? '',
//       isActive: data['isActive'] ?? false,
//     );
//   }
// }
//
// class AdminOfferManagementPage extends StatefulWidget {
//   const AdminOfferManagementPage({Key? key}) : super(key: key);
//
//   @override
//   State<AdminOfferManagementPage> createState() => _AdminOfferManagementPageState();
// }
//
// class _AdminOfferManagementPageState extends State<AdminOfferManagementPage> {
//   final TextEditingController _searchController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final CollectionReference _offersCollection = FirebaseFirestore.instance.collection('offers');
//   final ImageService _imageService = ImageService(); // Initialize the image service
//
//   List<Offer> _offers = [];
//   List<Offer> _filteredOffers = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadOffers();
//     _searchController.addListener(_filterOffers);
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadOffers() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       QuerySnapshot querySnapshot = await _offersCollection.get();
//       final List<Offer> loadedOffers = querySnapshot.docs
//           .map((doc) => Offer.fromFirestore(doc))
//           .toList();
//
//       setState(() {
//         _offers = loadedOffers;
//         _filteredOffers = List.from(_offers);
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading offers: $e');
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load offers: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _filterOffers() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredOffers = _offers
//           .where((offer) => offer.name.toLowerCase().contains(query))
//           .toList();
//     });
//   }
//
//   // Updated method to use the image service
//   Future<String?> _uploadImage(File imageFile) async {
//     try {
//       // Generate a business/offer ID to pass to the image service
//       final uuid = Uuid();
//       final offerId = uuid.v4();
//
//       // Use the image service to upload the image
//       final imageUrl = await _imageService.uploadImageWorking(imageFile, offerId);
//
//       if (imageUrl != null) {
//         return imageUrl;
//       } else {
//         // Fallback to Firebase Storage if image service fails
//         print('Image service upload failed, falling back to Firebase Storage');
//         return _uploadImageToStorage(imageFile);
//       }
//     } catch (e) {
//       print('Error in _uploadImage: $e');
//       // Fallback to Firebase Storage
//       return _uploadImageToStorage(imageFile);
//     }
//   }
//
//   // Keep the original Firebase storage method as fallback
//   Future<String?> _uploadImageToStorage(File imageFile) async {
//     try {
//       // Create a unique filename
//       final uuid = Uuid();
//       final fileName = 'offer_banners/${uuid.v4()}.jpg';
//
//       // Upload to Firebase Storage
//       final ref = _storage.ref().child(fileName);
//       final uploadTask = ref.putFile(imageFile);
//       final snapshot = await uploadTask;
//
//       // Get download URL
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       print('Error uploading image to Firebase Storage: $e');
//       return null;
//     }
//   }
//
//   Future<void> _addOrEditOffer(BuildContext context, {Offer? offer}) async {
//     final TextEditingController nameController = TextEditingController(text: offer?.name ?? '');
//     String? selectedImagePath;
//     String? existingImageUrl = offer?.bannerUrl;
//     bool isActive = offer?.isActive ?? false;
//     bool isEditMode = offer != null;
//     bool imageChanged = false;
//
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             Future<void> pickImage() async {
//               // Use image service to show image picker dialog
//               final File? image = await _imageService.showImagePickerDialog(context);
//               if (image != null) {
//                 setState(() {
//                   selectedImagePath = image.path;
//                   imageChanged = true;
//                 });
//               }
//             }
//
//             // Option to use a placeholder image
//             Future<void> usePlaceholderImage() async {
//               final String? imageUrl = await _imageService.showImageSuggestionsDialog(context, 'Offers');
//               if (imageUrl != null) {
//                 setState(() {
//                   existingImageUrl = imageUrl;
//                   imageChanged = true;
//                   selectedImagePath = null; // Clear any selected file path
//                 });
//               }
//             }
//
//             Widget imagePreview() {
//               if (selectedImagePath != null) {
//                 // For newly picked images
//                 return Image.file(
//                   File(selectedImagePath!),
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 );
//               } else if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
//                 // For existing images from Firestore
//                 return Image.network(
//                   existingImageUrl!,
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Center(
//                       child: CircularProgressIndicator(
//                         value: loadingProgress.expectedTotalBytes != null
//                             ? loadingProgress.cumulativeBytesLoaded /
//                             (loadingProgress.expectedTotalBytes ?? 1)
//                             : null,
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 150,
//                       width: double.infinity,
//                       color: Colors.grey[300],
//                       child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
//                     );
//                   },
//                 );
//               } else {
//                 // Placeholder for no image
//                 return Container(
//                   height: 150,
//                   width: double.infinity,
//                   color: Colors.grey[300],
//                   child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
//                 );
//               }
//             }
//
//             // Replace your AlertDialog implementation in the _addOrEditOffer method with this:
//
//             return Dialog(
//               child: Container(
//                 width: 280.0, // Keep your desired width
//                 constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.8, // Limit to 80% of screen height
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         isEditMode ? 'Edit Offer' : 'Add New Offer',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xff0F3966),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Flexible(
//                         child: SingleChildScrollView(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               TextField(
//                                 controller: nameController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Offer Name',
//                                   hintText: 'Enter offer name',
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               const Text('Banner Image:'),
//                               const SizedBox(height: 10),
//                               GestureDetector(
//                                 onTap: pickImage,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       imagePreview(),
//                                       Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text(
//                                           (selectedImagePath == null && existingImageUrl == null)
//                                               ? 'Tap to select banner image'
//                                               : 'Tap to change image',
//                                           style: TextStyle(color: Colors.blue),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 15),
//                               Row(
//                                 children: [
//                                   Checkbox(
//                                     value: isActive,
//                                     onChanged: (value) {
//                                       setState(() {
//                                         isActive = value ?? false;
//                                       });
//                                     },
//                                   ),
//                                   const Text('Active'),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('Cancel', style: TextStyle(color: Colors.red)),
//                           ),
//                           ElevatedButton(
//                             onPressed: () async {
//                               if (nameController.text.trim().isEmpty) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Please enter an offer name'),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                                 return;
//                               }
//
//                               if (selectedImagePath == null && existingImageUrl == null) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Please select a banner image'),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                                 return;
//                               }
//
//                               // Show loading indicator
//                               showDialog(
//                                 context: context,
//                                 barrierDismissible: false,
//                                 builder: (context) => const Center(child: CircularProgressIndicator()),
//                               );
//
//                               try {
//                                 // Upload image if new or changed
//                                 String imageUrl = existingImageUrl ?? '';
//                                 if (selectedImagePath != null) {
//                                   final uploadedUrl = await _uploadImageToStorage(File(selectedImagePath!));
//                                   if (uploadedUrl != null) {
//                                     imageUrl = uploadedUrl;
//                                   } else {
//                                     // Handle image upload failure
//                                     Navigator.pop(context); // Close loading dialog
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text('Failed to upload image'),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                     return;
//                                   }
//                                 }
//
//                                 if (isEditMode && offer != null) {
//                                   // Update existing offer in Firestore
//                                   await _offersCollection.doc(offer.id).update({
//                                     'name': nameController.text.trim(),
//                                     'bannerUrl': imageUrl,
//                                     'isActive': isActive,
//                                   });
//                                 } else {
//                                   // Add new offer to Firestore
//                                   await _offersCollection.add({
//                                     'name': nameController.text.trim(),
//                                     'bannerUrl': imageUrl,
//                                     'isActive': isActive,
//                                     'createdAt': FieldValue.serverTimestamp(),
//                                   });
//                                 }
//
//                                 // Reload offers from Firestore
//                                 await _loadOffers();
//
//                                 // Close dialogs
//                                 Navigator.pop(context); // Close loading dialog
//                                 Navigator.pop(context); // Close add/edit dialog
//
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(isEditMode ? 'Offer updated successfully' : 'Offer added successfully'),
//                                     backgroundColor: Colors.green,
//                                   ),
//                                 );
//                               } catch (e) {
//                                 // Handle errors
//                                 Navigator.pop(context); // Close loading dialog
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text('Error: $e'),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                               }
//                             },
//                             child: Text(isEditMode ? 'Update' : 'Add', style: TextStyle(color: Color(0xff0F3966))),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _deleteOffer(String id) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Offer'),
//         content: const Text('Are you sure you want to delete this offer?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               try {
//                 // Get the offer to access its banner URL
//                 var offerDoc = await _offersCollection.doc(id).get();
//                 var offerData = offerDoc.data() as Map<String, dynamic>?;
//                 var bannerUrl = offerData?['bannerUrl'] as String?;
//
//                 // Delete the offer from Firestore
//                 await _offersCollection.doc(id).delete();
//
//                 // Try to delete the image if it's not a placeholder
//                 if (bannerUrl != null && bannerUrl.isNotEmpty && !bannerUrl.contains('unsplash.com') && !bannerUrl.contains('placeholder.com')) {
//                   // Try to delete using image service
//                   await _imageService.deleteImage(bannerUrl);
//                 }
//
//                 // Reload offers
//                 await _loadOffers();
//
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Offer deleted successfully'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } catch (e) {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Failed to delete offer: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _toggleOfferStatus(String id, bool currentStatus) async {
//     try {
//       // Update the offer status in Firestore
//       await _offersCollection.doc(id).update({
//         'isActive': !currentStatus,
//       });
//
//       // Reload offers
//       await _loadOffers();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Offer status updated to ${!currentStatus ? 'active' : 'inactive'}'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update offer status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor:  Color(0xff0F3966),
//         title: AppBarTitle(text: "Offer Management"),
//         elevation: 0,
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor:  Color(0xff0F3966),
//         onPressed: () => _addOrEditOffer(context),
//         child: const Icon(Icons.add,color: Colors.white,),
//         tooltip: 'Add New Offer',
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search Offers',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _filteredOffers.isEmpty
//                 ? const Center(
//               child: Text(
//                 'No offers found',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             )
//                 : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _filteredOffers.length,
//               itemBuilder: (context, index) {
//                 final offer = _filteredOffers[index];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   elevation: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Banner image
//                       ClipRRect(
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
//                         child: Image.network(
//                           offer.bannerUrl,
//                           height: 120,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               height: 120,
//                               width: double.infinity,
//                               color: Colors.grey[200],
//                               child: Center(
//                                 child: CircularProgressIndicator(
//                                   value: loadingProgress.expectedTotalBytes != null
//                                       ? loadingProgress.cumulativeBytesLoaded /
//                                       (loadingProgress.expectedTotalBytes ?? 1)
//                                       : null,
//                                 ),
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               height: 120,
//                               width: double.infinity,
//                               color: Colors.grey[300],
//                               child: const Icon(Icons.broken_image, size: 40),
//                             );
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     offer.name,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   InkWell(
//                                     onTap: () => _toggleOfferStatus(offer.id, offer.isActive),
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: offer.isActive
//                                             ? Colors.green[50]
//                                             : Colors.grey[200],
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: Text(
//                                         offer.isActive ? 'Active' : 'Inactive',
//                                         style: TextStyle(
//                                           color: offer.isActive
//                                               ? Colors.green[800]
//                                               : Colors.grey[700],
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.blue),
//                                   onPressed: () => _addOrEditOffer(context, offer: offer),
//                                   tooltip: 'Edit',
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () => _deleteOffer(offer.id),
//                                   tooltip: 'Delete',
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../core/shared/services/image_service.dart';

class AdminOfferManagementPage extends StatefulWidget {
  const AdminOfferManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminOfferManagementPage> createState() => _AdminOfferManagementPageState();
}

class _AdminOfferManagementPageState extends State<AdminOfferManagementPage> {
  final _offerNameController = TextEditingController();
  final ImageService _imageService = ImageService();

  File? _selectedImage;
  bool _isUploading = false;
  // Variable to store direct image URL (for suggested images)
  String? _imageUrl;

  @override
  void dispose() {
    _offerNameController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    // Validate inputs
    if (_offerNameController.text.isEmpty || (_selectedImage == null && _imageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter offer name and select an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? finalImageUrl;

      // If we have a selected file image, upload it
      if (_selectedImage != null) {
        finalImageUrl = await _imageService.uploadImageWorking(_selectedImage!, "offerImages");
      } else if (_imageUrl != null) {
        // If we have a suggested URL image, use it directly
        finalImageUrl = _imageUrl;
      }

      if (finalImageUrl != null) {
        // Add offer to Firestore
        await FirebaseFirestore.instance.collection('offers').add({
          'name': _offerNameController.text,
          'imageUrl': finalImageUrl,
          'createdAt': Timestamp.now(),
        });

        // Reset form
        _offerNameController.clear();
        setState(() {
          _selectedImage = null;
          _imageUrl = null;
          _isUploading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to process image');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding offer: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final image = await _imageService.showImagePickerDialog(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageUrl = null; // Clear any suggested image URL
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Manage Offers"),
        backgroundColor: Color(0xff0F3966),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Offer Form Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add New Offer",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Offer Name Field
                    TextField(
                      controller: _offerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Offer Name*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_offer),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Image Selection Area
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Offer Image*",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                                : _imageUrl != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            )
                                : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text("Tap to select image"),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _submitOffer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff0F3966),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "SAVE OFFER",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Offers List Section
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Divider(
                      color: Color(0xff0F3966), // Line color
                      thickness: 1, // Line thickness
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8), // Space around the text
                  child: Text(
                    "Current Offers",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0F3966),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Divider(
                      color: Color(0xff0F3966),
                      thickness: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stream builder to display offers from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('offers')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Show loading indicator while waiting for data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Handle errors
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // Show message if no offers exist
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No offers available. Add your first one!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                // Display list of offers
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Offer Image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              data['imageUrl'],
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 180,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => SizedBox(
                                height: 180,
                                child: Center(
                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                                ),
                              ),
                            ),
                          ),

                          // Offer Details
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Offer Name
                                Expanded(
                                  child: Text(
                                    data['name'] ?? 'Unnamed Offer',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    // Confirm deletion
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Offer'),
                                        content: const Text('Are you sure you want to delete this offer?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('CANCEL'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('DELETE'),
                                          ),
                                        ],
                                      ),
                                    ) ?? false;

                                    if (shouldDelete) {
                                      try {
                                        // Delete image if it was uploaded (not a placeholder)
                                        if (!data['imageUrl'].toString().contains('unsplash.com') &&
                                            !data['imageUrl'].toString().contains('placeholder.com')) {
                                          await _imageService.deleteImage(data['imageUrl']);
                                        }

                                        // Delete document from Firestore
                                        await FirebaseFirestore.instance
                                            .collection('offers')
                                            .doc(doc.id)
                                            .delete();

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Offer deleted'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error deleting offer: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

    );
  }
}