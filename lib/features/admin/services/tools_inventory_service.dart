import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/shared/services/image_service.dart';
import '../models/tools_inventory_model.dart';



class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  final String _businessId = 'admin'; // You can customize this as needed

  // Reference to the products collection
  CollectionReference get _productsCollection =>
      _firestore.collection('products');

  // Reference to the categories collection
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');

  // Add a new product
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required File? imageFile,
    required List<String> serviceCategories,
    // required String serviceName, // New parameter for specific service
  }) async {
    try {
      String imageUrl = '';

      // Upload the image if provided
      if (imageFile != null) {
        final uploadedImageUrl = await _imageService.uploadImageWorking(
            imageFile,
            _businessId
        );

        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        } else {
          // If upload fails, use a placeholder
          imageUrl = await _imageService.getPlaceholderImage();
        }
      } else {
        // If no image provided, use a placeholder
        imageUrl = await _imageService.getPlaceholderImage();
      }

      // Create product object
      final product = Product(
        id: '', // Will be assigned by Firestore
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        serviceCategories: serviceCategories,
        // serviceName: serviceName, // Added to constructor
      );

      // Add to Firestore
      await _productsCollection.add(product.toMap());

      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // Update existing product
  Future<bool> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String currentImageUrl,
    required List<String> serviceCategories,
    // required String serviceName, // New parameter for specific service
    File? newImageFile,
  }) async {
    try {
      String imageUrl = currentImageUrl;

      // Upload new image if provided
      if (newImageFile != null) {
        // Delete the old image if it exists and is not a placeholder
        if (imageUrl.isNotEmpty &&
            !imageUrl.contains('placeholder') &&
            !imageUrl.contains('unsplash')) {
          await _imageService.deleteImage(imageUrl);
        }

        // Upload the new image
        final uploadedImageUrl = await _imageService.uploadImageWorking(
            newImageFile,
            _businessId
        );

        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        }
      }

      // Update the product
      await _productsCollection.doc(id).update({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'serviceCategories': serviceCategories,
        // 'serviceName': serviceName, // Added to update
      });

      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(Product product) async {
    try {
      // Delete the image if it's not a placeholder
      if (!product.imageUrl.contains('placeholder') &&
          !product.imageUrl.contains('unsplash')) {
        await _imageService.deleteImage(product.imageUrl);
      }

      // Delete from Firestore
      await _productsCollection.doc(product.id).delete();

      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Get all products
  Stream<List<Product>> getProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList());
  }

  // Get products by service category
  Stream<List<Product>> getProductsByService(String serviceCategory) {
    return _productsCollection
        .where('serviceCategories', arrayContains: serviceCategory)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList());
  }

  // // Get products by specific service name (for recommendations)
  // Stream<List<Product>> getProductsByServiceName(String serviceName) {
  //   return _productsCollection
  //       .where('serviceName', isEqualTo: serviceName)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //       .map((doc) => Product.fromFirestore(doc))
  //       .toList());
  // }

  // Get all available service categories from Firestore
  Future<List<Map<String, dynamic>>> getAllServiceCategories() async {
    try {
      QuerySnapshot snapshot = await _categoriesCollection.get();
      List<Map<String, dynamic>> categories = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        categories.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'icon': data['icon'] ?? '',
          'image': data['image'] ?? '',
          'createdAt': data['createdAt'],
        });
      }

      // Sort by name
      categories.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

      return categories;
    } catch (e) {
      print('Error fetching service categories: $e');
      return [];
    }
  }

  // Get all service category names only
  Future<List<String>> getServiceCategoryNames() async {
    try {
      List<Map<String, dynamic>> categories = await getAllServiceCategories();
      return categories.map((category) => category['name'].toString()).toList();
    } catch (e) {
      print('Error fetching service category names: $e');
      return [];
    }
  }
}