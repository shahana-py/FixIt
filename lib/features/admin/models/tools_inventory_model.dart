// lib/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final DateTime createdAt;
  final List<String> serviceCategories; // Categories this product can be used for
  // final String serviceName; // Specific service name for recommendations

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
    required this.serviceCategories,
    // required this.serviceName, // New field for specific service
  });

  // Convert Product object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'serviceCategories': serviceCategories,
      // 'serviceName': serviceName, // Added to map
    };
  }

  // Create Product object from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle the serviceCategories field which is stored as an array in Firestore
    List<String> categories = [];
    if (data['serviceCategories'] != null) {
      categories = List<String>.from(data['serviceCategories']);
    }

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      serviceCategories: categories,
      // serviceName: data['serviceName'] ?? '', // Added to constructor
    );
  }
}