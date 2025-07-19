


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