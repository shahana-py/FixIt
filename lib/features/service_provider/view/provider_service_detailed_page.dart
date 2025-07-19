
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/features/service_provider/view/provider_edit_service_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


import '../../../core/shared/services/image_service.dart'; // Update with your path

class ServiceDetailsPage extends StatefulWidget {
  final String serviceId;

  const ServiceDetailsPage({required this.serviceId});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  Map<String, dynamic>? serviceData;
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  Future<void> _loadServiceData() async {
    var doc = await FirebaseFirestore.instance
        .collection('services')
        .doc(widget.serviceId)
        .get();
    if (doc.exists) {
      var data = doc.data()!;

      // Handle both 'work_sample' (string) and 'work_samples' (array) cases
      List<String> workSamples = [];
      if (data.containsKey('work_samples')) {
        workSamples = List<String>.from(data['work_samples'] ?? []);
      } else if (data.containsKey('work_sample') && data['work_sample'] != null) {
        workSamples = [data['work_sample'] as String];
      }

      setState(() {
        serviceData = data;
        // Ensure work_samples exists as an array in serviceData
        serviceData!['work_samples'] = workSamples;
      });
    }
  }

  Future<void> _toggleServiceStatus(bool isActive) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 10),
              Text(isActive ? 'Activating service...' : 'Deactivating service...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Update the service status in Firestore
      await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.serviceId)
          .update({
        'isActive': isActive,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Refresh the data
      await _loadServiceData();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive
              ? '✅ Service activated! Customers can now book this service.'
              : '⚠️ Service deactivated! Customers will see it with an "Unavailable" overlay and cannot be booked'),
          backgroundColor: isActive ? Colors.green : Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update service status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> _pickAndUploadSampleImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        // Upload using your ImageService
        String? downloadUrl = await _imageService.uploadImageWorking(
            imageFile, widget.serviceId);

        if (downloadUrl != null) {
          // Get current samples (handles both cases)
          List currentSamples = serviceData!['work_samples'] ?? [];
          currentSamples.add(downloadUrl);

          await FirebaseFirestore.instance
              .collection('services')
              .doc(widget.serviceId)
              .update({'work_samples': currentSamples});

          await _loadServiceData(); // Refresh UI
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $e")),
        );
      }
    }
  }

  Future<void> _removeImage(String url) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove Image"),
        content: Text("Are you sure you want to remove this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xff0F3966)),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        // Remove from Firestore
        List currentSamples = List.from(serviceData!['work_samples']);
        currentSamples.remove(url);

        await FirebaseFirestore.instance
            .collection('services')
            .doc(widget.serviceId)
            .update({'work_samples': currentSamples});

        // Delete from Storage using your ImageService
        await _imageService.deleteImage(url);

        await _loadServiceData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to remove image: $e")),
        );
      }
    }
  }

  void _showEditDialog() {
    final TextEditingController nameController =
    TextEditingController(text: serviceData?['name']);
    final TextEditingController descriptionController =
    TextEditingController(text: serviceData?['description']);
    final TextEditingController experienceController =
    TextEditingController(text: serviceData?['experience'].toString());
    final TextEditingController rateController =
    TextEditingController(text: serviceData?['hourly_rate'].toString());

    List<String> selectedAreas =
    List<String>.from(serviceData?['available_areas'] ?? []);
    List<String> selectedDays =
    List<String>.from(serviceData?['available_days'] ?? []);

    final List<String> districtsOfKerala = [
      'Thiruvananthapuram',
      'Kollam',
      'Pathanamthitta',
      'Alappuzha',
      'Kottayam',
      'Idukki',
      'Ernakulam',
      'Thrissur',
      'Palakkad',
      'Malappuram',
      'Kozhikode',
      'Wayanad',
      'Kannur',
      'Kasaragod',
    ];

    final List<String> weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Service",
                  style: TextStyle(color: Color(0xff0F3966))),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(nameController, "Service Name"),
                    _buildTextField(descriptionController, "Description",
                        maxLines: 3),
                    _buildTextField(experienceController, "Experience (Years)",
                        inputType: TextInputType.number),
                    _buildTextField(rateController, "Hourly Rate",
                        inputType: TextInputType.number),
                    SizedBox(height: 16),

                    // Available Areas Selector
                    _buildSectionHeader("Available Areas"),
                    SizedBox(height: 8),
                    _buildMultiSelectField(
                      context: context,
                      selectedItems: selectedAreas,
                      allItems: districtsOfKerala,
                      title: "Select Available Areas",
                      onSelectionChanged: (List<String> items) {
                        setState(() {
                          selectedAreas = items;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Available Days Selector
                    _buildSectionHeader("Available Days"),
                    SizedBox(height: 8),
                    _buildChipSelector(
                      items: weekDays,
                      selectedItems: selectedDays,
                      onSelectionChanged: (item, selected) {
                        setState(() {
                          if (selected) {
                            selectedDays.add(item);
                          } else {
                            selectedDays.remove(item);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                  Text("Cancel", style: TextStyle(color: Colors.grey[700])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0F3966),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('services')
                        .doc(widget.serviceId)
                        .update({
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'experience': int.tryParse(experienceController.text) ?? 0,
                      'hourly_rate': double.tryParse(rateController.text) ?? 0,
                      'available_areas': selectedAreas,
                      'available_days': selectedDays,
                    });

                    Navigator.pop(context);
                    await _loadServiceData();
                  },
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xff0F3966),
        ),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required BuildContext context,
    required List<String> selectedItems,
    required List<String> allItems,
    required String title,
    required Function(List<String>) onSelectionChanged,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) {
            List<String> tempSelected = List.from(selectedItems);

            return StatefulBuilder(
              builder: (context, setDropState) {
                return AlertDialog(
                  title: Text(title, style: TextStyle(color: Color(0xff0F3966))),
                  content: Container(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Search...",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            // Implement search functionality if needed
                          },
                        ),
                        SizedBox(height: 10),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: allItems.map((item) {
                              return CheckboxListTile(
                                title: Text(item),
                                value: tempSelected.contains(item),
                                onChanged: (bool? selected) {
                                  setDropState(() {
                                    if (selected == true) {
                                      tempSelected.add(item);
                                    } else {
                                      tempSelected.remove(item);
                                    }
                                  });
                                },
                                activeColor: Color(0xff0F3966),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child:
                      Text("Cancel", style: TextStyle(color: Colors.grey[700])),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff0F3966),
                      ),
                      onPressed: () {
                        onSelectionChanged(tempSelected);
                        Navigator.pop(ctx);
                      },
                      child: Text("Apply", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedItems.isEmpty
                    ? 'Select'
                    : selectedItems.join(', '),
                style: TextStyle(
                  color:
                  selectedItems.isEmpty ? Colors.grey : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSelector({
    required List<String> items,
    required List<String> selectedItems,
    required Function(String, bool) onSelectionChanged,
  }) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((day) {
        return ChoiceChip(
          label: Text(day),
          selected: selectedItems.contains(day),
          onSelected: (selected) => onSelectionChanged(day, selected),
          selectedColor: Color(0xff0F3966).withOpacity(0.2),
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: selectedItems.contains(day)
                ? Color(0xff0F3966)
                : Colors.black87,
            fontWeight: selectedItems.contains(day)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selectedItems.contains(day)
                  ? Color(0xff0F3966)
                  : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xff0F3966), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServicePage(
          serviceId: widget.serviceId,
          initialData: serviceData!,
          onSave: _loadServiceData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (serviceData == null) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: AppBarTitle(text: "Service Details"),
          backgroundColor: Color(0xff0F3966),
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xff0F3966)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Service Details"),
        backgroundColor: Color(0xff0F3966),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          serviceData!['name'] ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F3966),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: serviceData!['isActive'] ?? true,
                            activeColor: Color(0xff0F3966),
                            onChanged: (value) {
                              _toggleServiceStatus(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      serviceData!['description'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Service Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Service Information"),
                    SizedBox(height: 12),
                    _buildDetailRow(
                        "Experience:", "${serviceData!['experience']} years"),
                    Divider(height: 20, color: Colors.grey[300]),
                    _buildDetailRow(
                        "Hourly Rate:", "₹${serviceData!['hourly_rate']}"),
                    Divider(height: 20, color: Colors.grey[300]),
                    _buildDetailRow("Available Areas:",
                        (serviceData!['available_areas'] as List).join(', ')),
                    Divider(height: 20, color: Colors.grey[300]),
                    _buildDetailRow("Available Days:",
                        (serviceData!['available_days'] as List).join(', ')),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Work Samples Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader("Work Samples"),
                        ElevatedButton.icon(
                          onPressed: _pickAndUploadSampleImage,
                          icon: Icon(Icons.add, size: 18, color: Colors.white),
                          label: Text("Add", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff0F3966),
                            padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (serviceData!.containsKey('work_samples') &&
                        (serviceData!['work_samples'] as List).isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: (serviceData!['work_samples'] as List).length,
                        itemBuilder: (context, index) {
                          String url = serviceData!['work_samples'][index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Image.network(
                                  url,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                            .expectedTotalBytes !=
                                            null
                                            ? loadingProgress
                                            .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: Color(0xff0F3966),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.close,
                                          size: 16, color: Colors.white),
                                      onPressed: () => _removeImage(url),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.image, size: 40, color: Colors.grey[400]),
                              SizedBox(height: 8),
                              Text("No samples added yet",
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff0F3966),
        child: Icon(Icons.edit, color: Colors.white),
        // onPressed: _showEditDialog,
        onPressed: _navigateToEditPage,
        tooltip: "Edit Service",
        elevation: 2,
      ),
    );
  }
}


