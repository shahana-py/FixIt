//
// import 'dart:io';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
//
// class ManageCategoriesPage extends StatefulWidget {
//   const ManageCategoriesPage({Key? key}) : super(key: key);
//
//   @override
//   _ManageCategoriesPageState createState() => _ManageCategoriesPageState();
// }
//
// class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
//   // Controllers for text fields
//   final TextEditingController _categoryNameController = TextEditingController();
//   final TextEditingController _categoryDescController = TextEditingController();
//
//   // Firebase instances
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   // Image picker
//   final ImagePicker _picker = ImagePicker();
//   File? _selectedImage;
//
//   // Loading state
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _categoryNameController.dispose();
//     _categoryDescController.dispose();
//     super.dispose();
//   }
//
//   // Select an image from gallery
//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _selectedImage = File(image.path);
//       });
//     }
//   }
//
//   // Upload image to Firebase Storage
//   Future<String?> _uploadImage() async {
//     if (_selectedImage == null) return null;
//
//     try {
//       final String fileName = '${const Uuid().v4()}.jpg';
//       final Reference ref = _storage.ref().child('category_images/$fileName');
//
//       await ref.putFile(_selectedImage!);
//       final String downloadUrl = await ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading image: $e')),
//       );
//       return null;
//     }
//   }
//
//   // Add a new category to Firestore with image and description
//   Future<void> _addCategory() async {
//     if (_categoryNameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a category name')),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       String? imageUrl = await _uploadImage();
//
//       await _firestore.collection('categories').add({
//         'name': _categoryNameController.text.trim(),
//         'description': _categoryDescController.text.trim(),
//         'imageUrl': imageUrl,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       _categoryNameController.clear();
//       _categoryDescController.clear();
//       setState(() {
//         _selectedImage = null;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.green,
//             content: Text('Category added successfully',style: TextStyle(color: Colors.white),)),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding category: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Delete a category
//   Future<void> _deleteCategory(String categoryId, String? imageUrl) async {
//     bool confirm = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Deletion'),
//         content: const Text('Are you sure you want to delete this category?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     ) ?? false;
//
//     if (!confirm) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       if (imageUrl != null) {
//         try {
//           final String fileName = imageUrl.split('/').last.split('?').first;
//           await _storage.ref().child('category_images/$fileName').delete();
//         } catch (e) {
//           print('Error deleting category image: $e');
//         }
//       }
//
//       await _firestore.collection('categories').doc(categoryId).delete();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.red,
//             content: Text('Category deleted successfully',style: TextStyle(color: Colors.white),)),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting category: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _editCategory(String categoryId, String currentName, String? currentDesc, String? currentImageUrl) async {
//     final TextEditingController nameController = TextEditingController(text: currentName);
//     final TextEditingController descController = TextEditingController(text: currentDesc ?? '');
//     File? newImage;
//     String? newImageUrl = currentImageUrl;
//
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('Edit Category'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: nameController,
//                       decoration: const InputDecoration(labelText: 'Category Name'),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: descController,
//                       decoration: const InputDecoration(labelText: 'Category Description'),
//                       maxLines: 3,
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: () async {
//                             final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//                             if (image != null) {
//                               setState(() {
//                                 newImage = File(image.path);
//                               });
//                             }
//                           },
//                           icon: const Icon(Icons.image),
//                           label: const Text('Change Image'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     if (newImage != null)
//                       Image.file(newImage!, height: 100, width: 100, fit: BoxFit.cover)
//                     else if (currentImageUrl != null)
//                       Image.network(currentImageUrl, height: 100, width: 100, fit: BoxFit.cover),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop();
//
//                     setState(() {
//                       _isLoading = true;
//                     });
//
//                     try {
//                       // Upload new image if selected
//                       if (newImage != null) {
//                         final String fileName = '${const Uuid().v4()}.jpg';
//                         final ref = _storage.ref().child('category_images/$fileName');
//                         await ref.putFile(newImage!);
//                         newImageUrl = await ref.getDownloadURL();
//
//                         // Optionally delete old image
//                         if (currentImageUrl != null) {
//                           try {
//                             final String oldFile = currentImageUrl.split('/').last.split('?').first;
//                             await _storage.ref().child('category_images/$oldFile').delete();
//                           } catch (e) {
//                             print('Error deleting old image: $e');
//                           }
//                         }
//                       }
//
//                       // Update Firestore
//                       await _firestore.collection('categories').doc(categoryId).update({
//                         'name': nameController.text.trim(),
//                         'description': descController.text.trim(),
//                         'imageUrl': newImageUrl,
//                       });
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Category updated successfully')),
//                       );
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error updating category: $e')),
//                       );
//                     } finally {
//                       setState(() {
//                         _isLoading = false;
//                       });
//                     }
//                   },
//                   child: const Text('Save'),
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: AppBarTitle(text: "Category Management"),
//         backgroundColor: Color(0xff0F3966),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Add Category Section
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Add New Category',
//                       style: TextStyle(
//                         color: Color(0xff0F3966),
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _categoryNameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Category Name',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _categoryDescController,
//                       decoration: const InputDecoration(
//                         labelText: 'Category Description',
//                         border: OutlineInputBorder(),
//                       ),
//                       maxLines: 3,
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _pickImage,
//                             icon: const Icon(Icons.image, color: Color(0xff0F3966)),
//                             label: const Text('Select Image', style: TextStyle(color: Color(0xff0F3966))),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue[50],
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     if (_selectedImage != null) ...[
//                       const SizedBox(height: 8),
//                       Container(
//                         height: 100,
//                         width: 100,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Image.file(
//                           _selectedImage!,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _addCategory,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xff0F3966),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text(
//                           'Add Category',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 40),
//
//             // List of Categories
//             Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 25),
//                     child: Divider(
//                       color: Color(0xff0F3966),
//                       thickness: 1,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                     "Categories",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xff0F3966),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 25),
//                     child: Divider(
//                       color: Color(0xff0F3966),
//                       thickness: 1,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             // Stream builder for categories
//             StreamBuilder<QuerySnapshot>(
//               stream: _firestore.collection('categories').orderBy('createdAt', descending: true).snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 }
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
//                   return const Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Text('No categories yet. Add your first category!'),
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final category = snapshot.data!.docs[index];
//                     final categoryId = category.id;
//                     final categoryName = category['name'] as String;
//                     final categoryDesc = category['description'] as String?;
//                     final imageUrl = category['imageUrl'] as String?;
//
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       child: ExpansionTile(
//                         leading: imageUrl != null
//                             ? ClipRRect(
//                           borderRadius: BorderRadius.circular(4),
//                           child: Image.network(
//                             imageUrl,
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 width: 50,
//                                 height: 50,
//                                 color: Colors.grey[300],
//                                 child: const Icon(Icons.error),
//                               );
//                             },
//                           ),
//                         )
//                             : Container(
//                           width: 50,
//                           height: 50,
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.image_not_supported),
//                         ),
//                         title: Text(
//                           categoryName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit, color: Colors.blue),
//                               onPressed: () => _editCategory(categoryId, categoryName, categoryDesc, imageUrl),
//                               tooltip: 'Edit category',
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () => _deleteCategory(categoryId, imageUrl),
//                               tooltip: 'Delete category',
//                             ),
//                           ],
//                         ),
//
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Text(
//                               categoryDesc ?? 'No description available',
//                               style: TextStyle(
//                                 color: Colors.grey[700],
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
//
//
// import '../../../core/shared/services/image_service.dart';
//
// class ManageCategoriesPage extends StatefulWidget {
//   const ManageCategoriesPage({Key? key}) : super(key: key);
//
//   @override
//   State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
// }
//
// class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
//   final TextEditingController _nameController = TextEditingController();
//   File? _imageFile;
//   File? _iconFile;
//   bool _isLoading = false;
//   final ImageService _imageService = ImageService();
//
//   Future<void> _pickImage(bool isIcon) async {
//     try {
//       final File? pickedFile = await _imageService.showImagePickerDialog(context);
//       if (pickedFile != null) {
//         setState(() {
//           if (isIcon) {
//             _iconFile = pickedFile;
//           } else {
//             _imageFile = pickedFile;
//           }
//         });
//       }
//     } catch (e) {
//       _showSnackBar('Error picking image: $e', isError: true);
//     }
//   }
//
//   Future<void> _addCategory() async {
//     final String name = _nameController.text.trim();
//
//     if (name.isEmpty || _imageFile == null || _iconFile == null) {
//       _showSnackBar('All fields are required', isError: true);
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       String? imageUrl = await _imageService.uploadImageWorking(_imageFile!, "categories");
//       String? iconUrl = await _imageService.uploadImageWorking(_iconFile!, "categories");
//
//       if (imageUrl == null || iconUrl == null) {
//         throw Exception('Failed to get download URLs');
//       }
//
//       await FirebaseFirestore.instance.collection('categories').add({
//         'name': name,
//         'image': imageUrl,
//         'icon': iconUrl,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       _nameController.clear();
//       setState(() {
//         _imageFile = null;
//         _iconFile = null;
//       });
//
//       _showSnackBar('Category added successfully');
//     } catch (e) {
//       _showSnackBar('Failed to add category: $e', isError: true);
//     }
//
//     setState(() => _isLoading = false);
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xff0F3966),
//         title: const AppBarTitle(text: "Manage Categories"),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Add Category Section
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Add New Category",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff0F3966),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         labelText: "Category Name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[50],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Image Picker
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Category Image",
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () => _pickImage(false),
//                           child: Container(
//                             height: 150,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               border: Border.all(
//                                 color: Colors.grey[300]!,
//                                 width: 1.5,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: _imageFile != null
//                                 ? ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.file(
//                                 _imageFile!,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                                 : Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.image,
//                                   size: 40,
//                                   color: Colors.grey,
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   "Tap to select image",
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Icon Picker
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Category Icon",
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () => _pickImage(true),
//                           child: Container(
//                             height: 100,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               border: Border.all(
//                                 color: Colors.grey[300]!,
//                                 width: 1.5,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: _iconFile != null
//                                 ? ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.file(
//                                 _iconFile!,
//                                 fit: BoxFit.contain,
//                               ),
//                             )
//                                 : Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.photo_size_select_actual,
//                                   size: 40,
//                                   color: Colors.grey,
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   "Tap to select icon",
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Add Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _addCategory,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xff0F3966),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                           height: 24,
//                           width: 24,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                             : const Text(
//                           "Add Category",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//
//             const SizedBox(height: 40),
//
//             // Offers List Section
//             Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 5),
//                     child: Divider(
//                       color: Color(0xff0F3966), // Line color
//                       thickness: 1, // Line thickness
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8), // Space around the text
//                   child: Text(
//                     "Existing Categories",
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xff0F3966),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 5),
//                     child: Divider(
//                       color: Color(0xff0F3966),
//                       thickness: 1,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('categories')
//                     .orderBy('createdAt', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return Center(child: Text("Error: ${snapshot.error}"));
//                   }
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   final docs = snapshot.data!.docs;
//                   if (docs.isEmpty) {
//                     return const Center(
//                       child: Text(
//                         "No categories found",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     );
//                   }
//
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     physics: const ClampingScrollPhysics(),
//                     itemBuilder: (context, index) {
//                       final data = docs[index].data() as Map<String, dynamic>;
//                       return Card(
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   // Icon
//                                   Container(
//                                     width: 50,
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[100],
//                                       borderRadius: BorderRadius.circular(8),
//
//                                     ),
//                                     child: data['icon'] != null
//                                         ? ClipRRect(
//                                       borderRadius: BorderRadius.circular(8),
//                                       child: Image.network(
//                                         data['icon'],
//                                         fit: BoxFit.cover,
//                                         loadingBuilder: (context, child, loadingProgress) {
//                                           if (loadingProgress == null) return child;
//                                           return Center(
//                                             child: CircularProgressIndicator(
//                                               value: loadingProgress.expectedTotalBytes != null
//                                                   ? loadingProgress.cumulativeBytesLoaded /
//                                                   (loadingProgress.expectedTotalBytes ?? 1)
//                                                   : null,
//                                             ),
//                                           );
//                                         },
//                                         errorBuilder: (context, error, stackTrace) {
//                                           return const Center(
//                                             child: Icon(Icons.error, color: Colors.red),
//                                           );
//                                         },
//                                       ),
//                                     )
//                                         : const Center(
//                                       child: Icon(Icons.category, color: Colors.grey),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   // Name
//                                   Expanded(
//                                     child: Text(
//                                       data['name'] ?? 'Unnamed Category',
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   // Delete Button
//                                   IconButton(
//                                     icon: const Icon(Icons.delete, color: Colors.red),
//                                     onPressed: () => _confirmDeleteCategory(
//                                       docs[index].id,
//                                       data['image'],
//                                       data['icon'],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               // Image Preview
//                               if (data['image'] != null)
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: AspectRatio(
//                                     aspectRatio: 16 / 9,
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey[100],
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Image.network(
//                                         data['image'],
//                                         fit: BoxFit.cover,
//                                         loadingBuilder: (context, child, loadingProgress) {
//                                           if (loadingProgress == null) return child;
//                                           return Center(
//                                             child: CircularProgressIndicator(
//                                               value: loadingProgress.expectedTotalBytes != null
//                                                   ? loadingProgress.cumulativeBytesLoaded /
//                                                   (loadingProgress.expectedTotalBytes ?? 1)
//                                                   : null,
//                                             ),
//                                           );
//                                         },
//                                         errorBuilder: (context, error, stackTrace) {
//                                           return const Center(
//                                             child: Column(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(Icons.broken_image, color: Colors.grey),
//                                                 Text("Failed to load image"),
//                                               ],
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _confirmDeleteCategory(String docId, String? imageUrl, String? iconUrl) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Category"),
//         content: const Text("Are you sure you want to delete this category?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.red,
//             ),
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('categories')
//             .doc(docId)
//             .delete();
//
//         if (imageUrl != null) {
//           await _imageService.deleteImage(imageUrl);
//         }
//
//         if (iconUrl != null) {
//           await _imageService.deleteImage(iconUrl);
//         }
//
//         _showSnackBar('Category deleted successfully');
//       } catch (e) {
//         _showSnackBar('Failed to delete category: $e', isError: true);
//       }
//     }
//   }
// }

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';


import '../../../core/shared/services/image_service.dart'; // Import the existing image service

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({Key? key}) : super(key: key);

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  File? _iconFile;
  bool _isLoading = false;

  // Create an instance of your ImageService
  final ImageService _imageService = ImageService();

  Future<void> _pickImage(bool isIcon) async {
    try {
      // Use the dialog from your image service
      final File? pickedFile = await _imageService.showImagePickerDialog(context);

      if (pickedFile != null) {
        setState(() {
          if (isIcon) {
            _iconFile = pickedFile;
          } else {
            _imageFile = pickedFile;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _addCategory() async {
    final String name = _nameController.text.trim();

    if (name.isEmpty || _imageFile == null || _iconFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use ImageService to upload images
      // businessId can be "categories" or any identifier that makes sense for your application
      String? imageUrl = await _imageService.uploadImageWorking(_imageFile!, "categories");
      String? iconUrl = await _imageService.uploadImageWorking(_iconFile!, "categories");

      // Verify URLs were returned successfully
      if (imageUrl == null || iconUrl == null) {
        throw Exception('Failed to get download URLs');
      }

      // Add to Firestore with the URLs
      await FirebaseFirestore.instance.collection('categories').add({
        'name': name,
        'image': imageUrl,
        'icon': iconUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear the form
      _nameController.clear();
      setState(() {
        _imageFile = null;
        _iconFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add category: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff0F3966),
        title: const AppBarTitle(text: "Manage Categories"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 12),
            Text("Add new Category",style: TextStyle(color:Color(0xff0F3966),fontSize: 25,fontWeight: FontWeight.w600 ),),
            SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            const SizedBox(height: 12),

            // // Image picker
            // GestureDetector(
            //   onTap: () => _pickImage(false),
            //   child: Container(
            //     height: 120,
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.grey),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: _imageFile != null
            //         ? Image.file(_imageFile!, fit: BoxFit.cover)
            //         : const Center(child: Text("Tap to select category image")),
            //   ),
            // ),
            // const SizedBox(height: 12),
            //
            // // Icon picker
            // GestureDetector(
            //   onTap: () => _pickImage(true),
            //   child: Container(
            //     height: 80,
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.grey),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: _iconFile != null
            //         ? Image.file(_iconFile!, fit: BoxFit.contain)
            //         : const Center(child: Text("Tap to select category icon")),
            //   ),
            // ),
            // const SizedBox(height: 20),
            // Image Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Category Image",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(false),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to select image",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Icon Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Category Icon",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(true),
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _iconFile != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _iconFile!,
                                fit: BoxFit.contain,
                              ),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.photo_size_select_actual,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to select icon",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _addCategory,
              child: const Text("Add Category"),
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
                    "Existing Categories",
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

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text("Error loading categories");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("No categories found"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: data['icon'] != null
                            ? Image.network(
                          data['icon'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 50);
                          },
                        )
                            : const Icon(Icons.category, size: 50),
                        title: Text(data['name'] ?? 'Unnamed Category'),
                        subtitle: data['image'] != null
                            ? Container(
                          height: 80,
                          margin: const EdgeInsets.only(top: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              data['image'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 80,
                                  child: Center(child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  )),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 80,
                                  child: Center(child: Text("Failed to load image")),
                                );
                              },
                            ),
                          ),
                        )
                            : const SizedBox(height: 80, child: Center(child: Text("No image"))),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              // Get the image and icon URLs
                              String? imageUrl = data['image'];
                              String? iconUrl = data['icon'];

                              // Delete from Firestore first
                              await FirebaseFirestore.instance
                                  .collection('categories')
                                  .doc(docs[index].id)
                                  .delete();

                              // Then attempt to delete the actual image files
                              if (imageUrl != null) {
                                await _imageService.deleteImage(imageUrl);
                              }

                              if (iconUrl != null) {
                                await _imageService.deleteImage(iconUrl);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Category deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete category: $e')),
                              );
                            }
                          },
                        ),
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

