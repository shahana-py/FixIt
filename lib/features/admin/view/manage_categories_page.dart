

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // <-- ADD THIS for shimmer

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
  String? _editingCategoryId;
  bool _isEditing = false;
  String? _currentImageUrl;
  String? _currentIconUrl;

  // Create an instance of your ImageService
  final ImageService _imageService = ImageService();

  Future<void> _pickImage(bool isIcon) async {
    try {
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

  Future<void> _editCategory(String categoryId, Map<String, dynamic> currentData) async {
    setState(() {
      _isEditing = true;
      _editingCategoryId = categoryId;
      _nameController.text = currentData['name'] ?? '';
      // Clear current files since we're editing
      _imageFile = null;
      _iconFile = null;
      // Store current URLs to display existing images
      _currentImageUrl = currentData['image'];
      _currentIconUrl = currentData['icon'];
    });
  }

  Future<void> _addCategory() async {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name is required')),
      );
      return;
    }

    // For new categories, require all fields
    if (!_isEditing && (_imageFile == null || _iconFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required for new category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      String? iconUrl;

      if (_isEditing) {
        // Get current data for editing
        final doc = await FirebaseFirestore.instance
            .collection('categories')
            .doc(_editingCategoryId)
            .get();
        final currentData = doc.data() as Map<String, dynamic>;

        // Upload new image if selected, otherwise keep existing
        if (_imageFile != null) {
          // Delete old image
          if (currentData['image'] != null) {
            await _imageService.deleteImage(currentData['image']);
          }
          imageUrl = await _imageService.uploadImageWorking(_imageFile!, "categories");
        } else {
          imageUrl = currentData['image'];
        }

        // Upload new icon if selected, otherwise keep existing
        if (_iconFile != null) {
          // Delete old icon
          if (currentData['icon'] != null) {
            await _imageService.deleteImage(currentData['icon']);
          }
          iconUrl = await _imageService.uploadImageWorking(_iconFile!, "categories");
        } else {
          iconUrl = currentData['icon'];
        }

        // Update existing category
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(_editingCategoryId)
            .update({
          'name': name,
          'image': imageUrl,
          'icon': iconUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      } else {
        // Add new category (existing logic)
        imageUrl = await _imageService.uploadImageWorking(_imageFile!, "categories");
        iconUrl = await _imageService.uploadImageWorking(_iconFile!, "categories");

        if (imageUrl == null || iconUrl == null) {
          throw Exception('Failed to get download URLs');
        }

        await FirebaseFirestore.instance.collection('categories').add({
          'name': name,
          'image': imageUrl,
          'icon': iconUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      }

      // Clear form
      _nameController.clear();
      setState(() {
        _imageFile = null;
        _iconFile = null;
        _isEditing = false;
        _editingCategoryId = null;
        _currentImageUrl = null;
        _currentIconUrl = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${_isEditing ? 'update' : 'add'} category: $e')),
      );
    }

    setState(() => _isLoading = false);
  }
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingCategoryId = null;
      _nameController.clear();
      _imageFile = null;
      _iconFile = null;
      _currentImageUrl = null;
      _currentIconUrl = null;
    });
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
            const SizedBox(height: 12),
            Text(
              _isEditing ? "Edit Category" : "Add new Category",
              style: const TextStyle(color: Color(0xff0F3966), fontSize: 25, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            const SizedBox(height: 12),

            // Category Image Picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Category Image", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickImage(false),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                        : (_isEditing && _currentImageUrl != null)
                        ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _currentImageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error, size: 40, color: Colors.grey));
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Tap to change",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text("Tap to select image", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Icon Picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Category Icon", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _iconFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_iconFile!, fit: BoxFit.contain),
                    )
                        : (_isEditing && _currentIconUrl != null)
                        ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _currentIconUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error, size: 40, color: Colors.grey));
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Tap to change",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_size_select_actual, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text("Tap to select icon", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor:Color(0xff0F3966) ),
                    onPressed: _addCategory,
                    child: Text(_isEditing ? "Update Category" : "Add Category",style: TextStyle(color:Colors.white ),),
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _cancelEditing,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text("Cancel",style: TextStyle(color:Color(0xff0F3966) ),),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 40),

            // Existing Categories Section
            Row(
              children: [
                const Expanded(
                  child: Divider(color: Color(0xff0F3966), thickness: 1),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Existing Categories",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, color: Color(0xff0F3966)),
                  ),
                ),
                const Expanded(
                  child: Divider(color: Color(0xff0F3966), thickness: 1),
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
                  // Shimmer Placeholder
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.white,
                          ),
                          title: Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.white,
                          ),
                          subtitle: Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: double.infinity,
                            height: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
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
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Text("Failed to load image"));
                              },
                            ),
                          ),
                        )
                            : const SizedBox(height: 80, child: Center(child: Text("No image"))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCategory(docs[index].id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  String? imageUrl = data['image'];
                                  String? iconUrl = data['icon'];

                                  await FirebaseFirestore.instance
                                      .collection('categories')
                                      .doc(docs[index].id)
                                      .delete();

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
                          ],
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




