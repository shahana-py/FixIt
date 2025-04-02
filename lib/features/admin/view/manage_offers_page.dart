import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class Offer {
  final String id;
  String name;
  String bannerUrl;
  bool isActive;

  Offer({
    required this.id,
    required this.name,
    required this.bannerUrl,
    this.isActive = false,
  });

  // Convert Offer to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bannerUrl': bannerUrl,
      'isActive': isActive,
    };
  }

  // Create Offer from Firestore document
  factory Offer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Offer(
      id: doc.id,
      name: data['name'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      isActive: data['isActive'] ?? false,
    );
  }
}

class AdminOfferManagementPage extends StatefulWidget {
  const AdminOfferManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminOfferManagementPage> createState() => _AdminOfferManagementPageState();
}

class _AdminOfferManagementPageState extends State<AdminOfferManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _offersCollection = FirebaseFirestore.instance.collection('offers');

  List<Offer> _offers = [];
  List<Offer> _filteredOffers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
    _searchController.addListener(_filterOffers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await _offersCollection.get();
      final List<Offer> loadedOffers = querySnapshot.docs
          .map((doc) => Offer.fromFirestore(doc))
          .toList();

      setState(() {
        _offers = loadedOffers;
        _filteredOffers = List.from(_offers);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading offers: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load offers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterOffers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOffers = _offers
          .where((offer) => offer.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      // Create a unique filename
      final uuid = Uuid();
      final fileName = 'offer_banners/${uuid.v4()}.jpg';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(fileName);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addOrEditOffer(BuildContext context, {Offer? offer}) async {
    final TextEditingController nameController = TextEditingController(text: offer?.name ?? '');
    String? selectedImagePath;
    String? existingImageUrl = offer?.bannerUrl;
    bool isActive = offer?.isActive ?? false;
    bool isEditMode = offer != null;
    bool imageChanged = false;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickImage() async {
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  selectedImagePath = image.path;
                  imageChanged = true;
                });
              }
            }

            Widget imagePreview() {
              if (selectedImagePath != null) {
                // For newly picked images
                return Image.file(
                  File(selectedImagePath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              } else if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
                // For existing images from Firestore
                return Image.network(
                  existingImageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                    );
                  },
                );
              } else {
                // Placeholder for no image
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                );
              }
            }

            return AlertDialog(
              title: Text(isEditMode ? 'Edit Offer' : 'Add New Offer',style: TextStyle(color: Color(0xff0F3966) ),),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Offer Name',
                        hintText: 'Enter offer name',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Banner Image:'),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            imagePreview(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (selectedImagePath == null && existingImageUrl == null)
                                    ? 'Tap to select banner image'
                                    : 'Tap to change image',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value ?? false;
                            });
                          },
                        ),
                        const Text('Active'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',style: TextStyle(color: Colors.red),),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter an offer name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectedImagePath == null && existingImageUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a banner image'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      // Upload image if new or changed
                      String imageUrl = existingImageUrl ?? '';
                      if (selectedImagePath != null) {
                        final uploadedUrl = await _uploadImageToStorage(File(selectedImagePath!));
                        if (uploadedUrl != null) {
                          imageUrl = uploadedUrl;
                        } else {
                          // Handle image upload failure
                          Navigator.pop(context); // Close loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to upload image'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      if (isEditMode && offer != null) {
                        // Update existing offer in Firestore
                        await _offersCollection.doc(offer.id).update({
                          'name': nameController.text.trim(),
                          'bannerUrl': imageUrl,
                          'isActive': isActive,
                        });
                      } else {
                        // Add new offer to Firestore
                        await _offersCollection.add({
                          'name': nameController.text.trim(),
                          'bannerUrl': imageUrl,
                          'isActive': isActive,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      }

                      // Reload offers from Firestore
                      await _loadOffers();

                      // Close dialogs
                      Navigator.pop(context); // Close loading dialog
                      Navigator.pop(context); // Close add/edit dialog

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditMode ? 'Offer updated successfully' : 'Offer added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Handle errors
                      Navigator.pop(context); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(isEditMode ? 'Update' : 'Add',style: TextStyle(color:  Color(0xff0F3966)),),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteOffer(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer'),
        content: const Text('Are you sure you want to delete this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Delete the offer from Firestore
                await _offersCollection.doc(id).delete();

                // Reload offers
                await _loadOffers();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Offer deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete offer: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleOfferStatus(String id, bool currentStatus) async {
    try {
      // Update the offer status in Firestore
      await _offersCollection.doc(id).update({
        'isActive': !currentStatus,
      });

      // Reload offers
      await _loadOffers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer status updated to ${!currentStatus ? 'active' : 'inactive'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update offer status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor:  Color(0xff0F3966),
        title: AppBarTitle(text: "Offer Management"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Color(0xff0F3966),
        onPressed: () => _addOrEditOffer(context),
        child: const Icon(Icons.add,color: Colors.white,),
        tooltip: 'Add New Offer',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Offers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOffers.isEmpty
                ? const Center(
              child: Text(
                'No offers found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredOffers.length,
              itemBuilder: (context, index) {
                final offer = _filteredOffers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        child: Image.network(
                          offer.bannerUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 40),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _toggleOfferStatus(offer.id, offer.isActive),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: offer.isActive
                                            ? Colors.green[50]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        offer.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: offer.isActive
                                              ? Colors.green[800]
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _addOrEditOffer(context, offer: offer),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteOffer(offer.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

