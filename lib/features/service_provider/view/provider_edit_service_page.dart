import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditServicePage extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic> initialData;
  final Function onSave;

  const EditServicePage({
    required this.serviceId,
    required this.initialData,
    required this.onSave,
  });

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _experienceController;
  late TextEditingController _rateController;
  late List<String> _selectedAreas;
  late List<String> _selectedDays;

  final List<String> _districtsOfKerala = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha',
    'Kottayam', 'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad',
    'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod',
  ];

  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name']);
    _descriptionController = TextEditingController(text: widget.initialData['description']);
    _experienceController = TextEditingController(text: widget.initialData['experience'].toString());
    _rateController = TextEditingController(text: widget.initialData['hourly_rate'].toString());
    _selectedAreas = List<String>.from(widget.initialData['available_areas'] ?? []);
    _selectedDays = List<String>.from(widget.initialData['available_days'] ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.serviceId)
          .update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'hourly_rate': double.tryParse(_rateController.text) ?? 0,
        'available_areas': _selectedAreas,
        'available_days': _selectedDays,
      });

      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update service: $e')),
      );
    }
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildMultiSelectChips({
    required List<String> items,
    required List<String> selectedItems,
    required Function(String, bool) onSelectionChanged,
  }) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) {
        return ChoiceChip(
          label: Text(item),
          selected: selectedItems.contains(item),
          onSelected: (selected) => onSelectionChanged(item, selected),
          selectedColor: Color(0xff0F3966).withOpacity(0.2),
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: selectedItems.contains(item)
                ? Color(0xff0F3966)
                : Colors.black87,
            fontWeight: selectedItems.contains(item)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selectedItems.contains(item)
                  ? Color(0xff0F3966)
                  : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: 'Edit Service'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Service Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _experienceController,
              decoration: InputDecoration(
                labelText: 'Experience (Years)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _rateController,
              decoration: InputDecoration(
                labelText: 'Hourly Rate',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Available Areas'),
            _buildMultiSelectChips(
              items: _districtsOfKerala,
              selectedItems: _selectedAreas,
              onSelectionChanged: (item, selected) {
                setState(() {
                  if (selected) {
                    _selectedAreas.add(item);
                  } else {
                    _selectedAreas.remove(item);
                  }
                });
              },
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Available Days'),
            _buildMultiSelectChips(
              items: _weekDays,
              selectedItems: _selectedDays,
              onSelectionChanged: (item, selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(item);
                  } else {
                    _selectedDays.remove(item);
                  }
                });
              },
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0F3966),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: _saveChanges,
                child: Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}