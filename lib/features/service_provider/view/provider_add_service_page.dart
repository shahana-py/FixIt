import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../../../core/shared/services/image_service.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageService _imageService = ImageService();

  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();

  List<String> selectedAreas = [];
  List<String> selectedDays = [];
  File? _workSampleImage;
  String? _workSampleUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  final List<String> districtsOfKerala = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha',
    'Kottayam', 'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad',
    'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod',
  ];

  final List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  Future<void> _pickImage() async {
    final image = await _imageService.showImagePickerDialog(context);
    if (image != null) {
      setState(() {
        _workSampleImage = image;
        _workSampleUrl = null;
      });
      await _uploadImage();
    }
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
          const SnackBar(content: Text('Image upload failed')),
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

  void _removeImage() {
    setState(() {
      _workSampleImage = null;
      _workSampleUrl = null;
    });
  }

  Future<void> _saveService() async {
    if (_serviceNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _experienceController.text.isEmpty ||
        _hourlyRateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (_workSampleImage == null && _workSampleUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a work sample image")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('services').add({
          'name': _serviceNameController.text,
          'experience': _experienceController.text,
          'hourly_rate': _hourlyRateController.text,
          'description': _descriptionController.text,
          'available_areas': selectedAreas,
          'available_days': selectedDays,
          'work_sample': _workSampleUrl,
          'provider_id': user.uid,
          'created_at': FieldValue.serverTimestamp(),
          'rating': 0,
          'rating_count': 0,
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving service: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
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

  void _showAreasSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, innerSetState) {
          return AlertDialog(
            title: const Text("Select Available Areas"),
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
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff0F3966),
        title: AppBarTitle(text: "Add New Service"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveService,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_serviceNameController, "Service Name"),

            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextFormField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            _buildTextField(_experienceController, "Years of Experience", TextInputType.number),
            _buildTextField(_hourlyRateController, "Hourly Rate", TextInputType.number),
            const SizedBox(height: 16),

            // Available Areas
            const Text("Available Areas", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _showAreasSelectionDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Available Days
            const Text("Available Days", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: weekDays.map((day) {
                final isSelected = selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  backgroundColor: Colors.grey[200],
                  selectedColor: const Color(0xff0F3966),
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

            const SizedBox(height: 16),

            // Image upload section
            const Text("Work Sample Image", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Show work sample image if available
            if (_workSampleImage != null || _workSampleUrl != null)
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
                      child: _workSampleUrl != null
                          ? Image.network(
                        _workSampleUrl!,
                        fit: BoxFit.cover,
                      )
                          : Image.file(
                        _workSampleImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Show loading indicator while uploading
                  if (_isUploading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),

                  // Remove button
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // Add image button
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: const Icon(Icons.photo_library, color: Colors.white),
              label: const Text("Add Work Sample", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0F3966),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving || _isUploading ? null : _saveService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0F3966),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving || _isUploading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Save Service", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}