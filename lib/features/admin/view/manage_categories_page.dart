import 'dart:io';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({Key? key}) : super(key: key);

  @override
  _ManageCategoriesPageState createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  // Controllers for text fields
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _subcategoryNameController = TextEditingController();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Currently selected category for adding subcategories
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // List to store categories for dropdown
  List<Map<String, dynamic>> _categories = [];

  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Fetch categories for dropdown
  Future<void> _fetchCategories() async {
    final QuerySnapshot snapshot = await _firestore.collection('categories').orderBy('name').get();

    setState(() {
      _categories = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': (doc.data() as Map<String, dynamic>)['name'] as String,
      }).toList();
    });
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _subcategoryNameController.dispose();
    super.dispose();
  }

  // Add a new category to Firestore
  Future<void> _addCategory() async {
    if (_categoryNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('categories').add({
        'name': _categoryNameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _categoryNameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added successfully')),
      );

      // Refresh categories list for dropdown
      await _fetchCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding category: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete a category
  Future<void> _deleteCategory(String categoryId) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this category? This will also delete all associated subcategories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get all subcategories that belong to this category
      final QuerySnapshot subcategories = await _firestore
          .collection('subcategories')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      // Delete all subcategories
      for (final doc in subcategories.docs) {
        // If there's an image, delete it from storage
        final String? imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'] as String?;
        if (imageUrl != null) {
          try {
            // Extract file name from URL
            final String fileName = imageUrl.split('/').last.split('?').first;
            await _storage.ref().child('subcategory_images/$fileName').delete();
          } catch (e) {
            print('Error deleting subcategory image: $e');
          }
        }

        // Delete subcategory document
        await doc.reference.delete();
      }

      // Delete the category document
      await _firestore.collection('categories').doc(categoryId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );

      // Refresh categories list for dropdown
      await _fetchCategories();

      // Clear selection if the deleted category was selected
      if (_selectedCategoryId == categoryId) {
        setState(() {
          _selectedCategoryId = null;
          _selectedCategoryName = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete a subcategory
  Future<void> _deleteSubcategory(String subcategoryId, String? imageUrl) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this subcategory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // If there's an image, delete it from storage
      if (imageUrl != null) {
        try {
          // Extract file name from URL
          final String fileName = imageUrl.split('/').last.split('?').first;
          await _storage.ref().child('subcategory_images/$fileName').delete();
        } catch (e) {
          print('Error deleting subcategory image: $e');
        }
      }

      // Delete subcategory document
      await _firestore.collection('subcategories').doc(subcategoryId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subcategory deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting subcategory: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Select an image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      final Reference ref = _storage.ref().child('subcategory_images/$fileName');

      await ref.putFile(_selectedImage!);
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  // Add a subcategory to a category (using separate collection)
  Future<void> _addSubcategory() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category first')),
      );
      return;
    }

    if (_subcategoryNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subcategory name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      // Add to subcategories collection with reference to category
      await _firestore.collection('subcategories').add({
        'name': _subcategoryNameController.text.trim(),
        'categoryId': _selectedCategoryId,
        'categoryName': _selectedCategoryName,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _subcategoryNameController.clear();
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subcategory added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding subcategory: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Select a category from dropdown
  void _onCategorySelected(String? id) {
    if (id == null) return;

    final selectedCategory = _categories.firstWhere((cat) => cat['id'] == id);
    setState(() {
      _selectedCategoryId = id;
      _selectedCategoryName = selectedCategory['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Category Management"),
        backgroundColor: Color(0xff0F3966),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Category Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Category',
                      style: TextStyle(
                        color: Color(0xff0F3966),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryNameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff0F3966),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Add Category',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Add Subcategory Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Subcategory',
                      style: TextStyle(
                        color: Color(0xff0F3966),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown to select category
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategoryId,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: _onCategorySelected,
                      hint: const Text('Select a category'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _subcategoryNameController,
                      decoration: const InputDecoration(
                        labelText: 'Subcategory Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image, color: Color(0xff0F3966)),
                            label: const Text('Select Image', style: TextStyle(color: Color(0xff0F3966))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[50],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedCategoryId != null ? _addSubcategory : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff0F3966),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Add Subcategory',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // List of Categories and Subcategories
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Divider(
                      color: Color(0xff0F3966), // Line color
                      thickness: 1, // Line thickness
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8), // Space around the text
                  child: Text(
                    "Categories & Subcategories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0F3966),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Divider(
                      color: Color(0xff0F3966),
                      thickness: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stream builder for categories
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('categories').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No categories yet. Add your first category!'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final category = snapshot.data!.docs[index];
                    final categoryId = category.id;
                    final categoryName = category['name'] as String;

                    return Card(
                      color: Colors.blue[50],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Delete button for category
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(categoryId),
                              tooltip: 'Delete category',
                            ),
                          ],
                        ),
                        children: [
                          // Stream builder for subcategories from main collection
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('subcategories')
                                .where('categoryId', isEqualTo: categoryId)
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, subSnapshot) {
                              if (subSnapshot.hasError) {
                                print(subSnapshot.error);
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Error: ${subSnapshot.error}'),
                                );
                              }

                              if (subSnapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              if (subSnapshot.data == null || subSnapshot.data!.docs.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('No subcategories yet.'),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: subSnapshot.data!.docs.length,
                                itemBuilder: (context, subIndex) {
                                  final subcategory = subSnapshot.data!.docs[subIndex];
                                  final subcategoryId = subcategory.id;
                                  final subcategoryName = subcategory['name'] as String;
                                  final imageUrl = subcategory['imageUrl'] as String?;

                                  return ListTile(
                                    leading: imageUrl != null
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          );
                                        },
                                      ),
                                    )
                                        : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                    title: Text(subcategoryName),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteSubcategory(subcategoryId, imageUrl),
                                      tooltip: 'Delete subcategory',
                                    ),
                                  );
                                },
                              );
                            },
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