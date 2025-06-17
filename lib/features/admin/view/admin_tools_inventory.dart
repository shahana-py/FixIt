import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/shared/services/image_service.dart';
import '../models/tools_inventory_model.dart';
import '../services/tools_inventory_service.dart';


class AdminToolsInventoryPage extends StatefulWidget {
  const AdminToolsInventoryPage({Key? key}) : super(key: key);

  @override
  _AdminToolsInventoryPageState createState() => _AdminToolsInventoryPageState();
}

class _AdminToolsInventoryPageState extends State<AdminToolsInventoryPage> {
  final ProductService _productService = ProductService();
  final ImageService _imageService = ImageService();

  // Controllers for the form fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _serviceController = TextEditingController(); // For adding new service categories

  // Selected service categories for multi-select
  List<String> _selectedServiceCategories = [];
  // Available service categories from Firestore
  List<Map<String, dynamic>> _availableServiceCategories = [];

  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _loadServiceCategories();
  }

  // Load service categories from Firestore
  Future<void> _loadServiceCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      List<Map<String, dynamic>> categories = await _productService.getAllServiceCategories();
      setState(() {
        _availableServiceCategories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error loading service categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading service categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  // Reset form fields
  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _serviceController.clear();
    setState(() {
      _selectedImage = null;
      _selectedServiceCategories = [];
    });
  }

  // Toggle selection of a service category
  void _toggleServiceCategory(String category) {
    setState(() {
      if (_selectedServiceCategories.contains(category)) {
        _selectedServiceCategories.remove(category);
      } else {
        _selectedServiceCategories.add(category);
      }
    });
  }

  // Show add/edit product bottom sheet
  void _showAddProductSheet({Product? product}) {
    // If editing, populate the fields
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _selectedServiceCategories = List.from(product.serviceCategories);
    } else {
      _resetForm();
    }

    // Show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product == null ? 'Add Product' : 'Edit Product',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0F3966),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product Image
                  GestureDetector(
                    onTap: () async {
                      File? image = await _imageService.showImagePickerDialog(context);
                      if (image != null) {
                        setSheetState(() {
                          _selectedImage = image;
                        });
                      }
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                          : product != null && product.imageUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xff0F3966),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Color(0xff0F3966),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap to add product image',
                            style: TextStyle(
                              color: Color(0xff0F3966),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      hintText: 'Enter product name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.inventory_2_outlined, color: Color(0xff0F3966)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Product Price
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Price',
                      hintText: 'Enter product price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 10,left: 18),
                        child: Text("₹",style: TextStyle(color: Color(0xff0F3966),fontSize: 25,fontWeight: FontWeight.w600),),
                      )
                      // const Icon(Icons.money, color: Color(0xff0F3966)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Product Description
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter product description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.description_outlined, color: Color(0xff0F3966)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Service Categories Section
                  const Text(
                    'Service Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F3966),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Select all services this product can be used for:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Selected Categories Chips
                  if (_selectedServiceCategories.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedServiceCategories.map((category) {
                        return Chip(
                          label: Text(category),
                          backgroundColor: const Color(0xff0F3966).withOpacity(0.1),
                          deleteIconColor: const Color(0xff0F3966),
                          onDeleted: () {
                            setSheetState(() {
                              _selectedServiceCategories.remove(category);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // Available Service Categories
                  const Text(
                    'Available Categories:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_isLoadingCategories)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xff0F3966)),
                    )
                  else if (_availableServiceCategories.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.category_outlined, size: 40, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text(
                            'No service categories found',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadServiceCategories,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0F3966),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Reload Categories'),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableServiceCategories.map((categoryData) {
                            final categoryName = categoryData['name'];
                            final isSelected = _selectedServiceCategories.contains(categoryName);
                            return FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (categoryData['icon'] != null && categoryData['icon'].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        categoryData['icon'],
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: const Color(0xff0F3966).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.category,
                                              size: 12,
                                              color: Color(0xff0F3966),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  if (categoryData['icon'] != null && categoryData['icon'].isNotEmpty)
                                    const SizedBox(width: 6),
                                  Text(categoryName),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setSheetState(() {
                                  _toggleServiceCategory(categoryName);
                                });
                              },
                              selectedColor: const Color(0xff0F3966).withOpacity(0.2),
                              checkmarkColor: const Color(0xff0F3966),
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                        // Validation
                        if (_nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a product name')),
                          );
                          return;
                        }

                        if (_priceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a product price')),
                          );
                          return;
                        }

                        if (_descriptionController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a product description')),
                          );
                          return;
                        }

                        if (_selectedServiceCategories.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select at least one service category')),
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final double price = double.parse(_priceController.text);
                          bool success;

                          if (product == null) {
                            // Add new product
                            success = await _productService.addProduct(
                              name: _nameController.text,
                              description: _descriptionController.text,
                              price: price,
                              imageFile: _selectedImage,
                              serviceCategories: _selectedServiceCategories,
                            );
                          } else {
                            // Update existing product
                            success = await _productService.updateProduct(
                              id: product.id,
                              name: _nameController.text,
                              description: _descriptionController.text,
                              price: price,
                              currentImageUrl: product.imageUrl,
                              newImageFile: _selectedImage,
                              serviceCategories: _selectedServiceCategories,
                            );
                          }

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    product == null
                                        ? 'Product added successfully!'
                                        : 'Product updated successfully!'
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                            _resetForm();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    product == null
                                        ? 'Failed to add product'
                                        : 'Failed to update product'
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0F3966),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        product == null ? 'Add Product' : 'Update Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _isLoading = true;
              });

              bool success = await _productService.deleteProduct(product);

              setState(() {
                _isLoading = false;
              });

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete product'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Manage Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff0F3966),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with Add Product button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F3966),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddProductSheet(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Product',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0F3966),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Trigger rebuild
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff0F3966),
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first product to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddProductSheet(),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Product',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0F3966),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                product.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xff0F3966),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  );
                                },
                              )
                                  : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff0F3966),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\₹${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Service Categories
                                  if (product.serviceCategories.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: product.serviceCategories.take(3).map((category) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      }).toList()
                                        ..addAll(product.serviceCategories.length > 3
                                            ? [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '+${product.serviceCategories.length - 3}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ]
                                            : []),
                                    ),
                                ],
                              ),
                            ),

                            // Action Buttons
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () => _showAddProductSheet(product: product),
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xff0F3966),
                                  ),
                                  tooltip: 'Edit Product',
                                ),
                                IconButton(
                                  onPressed: () => _showDeleteDialog(product),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Delete Product',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}