// lib/shared/services/image_service.dart

import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;

import 'api_constants.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  // Upload image using the working approach from your other project
  Future<String?> uploadImageWorking(File imageFile, String businessId) async {
    try {
      // Use the API endpoint that worked in your other project
      final uri = ApiConstants.getApiUri(null); // This gives the base API path without additional segments
      print('Uploading to URI: $uri');

      // Create a multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add the fields that worked in your other project
      request.fields['project_name'] = 'ProductImages';
      request.fields['description'] = 'Product image for $businessId';

      // Add the image file with the correct field name
      var multipartFile = await http.MultipartFile.fromPath(
        'image', // Make sure this matches exactly what your API expects
        imageFile.path,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send the request
      print('Sending request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Log the response for debugging
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Process the response
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse the JSON response
        var responseData = json.decode(response.body);
        print('Parsed response: $responseData');

        // Extract the image path/URL from the response
        String? imagePath;

        // Try to get the image path from common response formats
        if (responseData['image_path'] != null) {
          imagePath = responseData['image_path'];
        } else if (responseData['imagePath'] != null) {
          imagePath = responseData['imagePath'];
        } else if (responseData['path'] != null) {
          imagePath = responseData['path'];
        } else if (responseData['url'] != null) {
          imagePath = responseData['url'];
        } else if (responseData['image'] != null) {
          imagePath = responseData['image'];
        }

        // If we found an image path/URL
        if (imagePath != null) {
          // Convert to a full URL if needed
          return ApiConstants.getFullImageUrl(imagePath);
        } else {
          print('Could not find image path in response: $responseData');
          return null;
        }
      } else {
        print('Failed to upload image: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image from your custom API
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract the relative path from the full URL
      // This assumes the API expects just the path portion for deletion
      String relativePath = imageUrl.replaceAll(ApiConstants.baseUrl, '');

      // Create delete URI
      final Uri deleteUri = ApiConstants.getApiUri('delete');

      // Send delete request
      final response = await http.post(
        deleteUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'imagePath': relativePath}),
      );

      final responseData = json.decode(response.body);

      // Check if deletion was successful
      return response.statusCode == 200 && responseData['success'] == true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Show image picker dialog
  Future<File?> showImagePickerDialog(context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () async {
                    final File? image = await pickImageFromGallery();
                    Navigator.of(context).pop(image);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () async {
                    final File? image = await pickImageFromCamera();
                    Navigator.of(context).pop(image);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Placeholder method that returns a dummy URL - use this if API integration is not ready
  Future<String> getPlaceholderImage() async {
    return 'https://via.placeholder.com/400x300?text=Product+Image';
  }

  // Get category-based placeholder image suggestions
  Future<String> suggestPlaceholderImage(String? category) {
    // Define placeholder image URLs for common categories
    final Map<String, List<String>> categoryImages = {
      'Food': [
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187'
      ],
      'Electronics': [
        'https://images.unsplash.com/photo-1498049794561-7780e7231661',
        'https://images.unsplash.com/photo-1546054454-aa26e2b734c7',
        'https://images.unsplash.com/photo-1588508065123-287b28e013da'
      ],
      'Clothing': [
        'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f',
        'https://images.unsplash.com/photo-1562157873-818bc0726f68',
        'https://images.unsplash.com/photo-1542060748-10c28b62716f'
      ],
      'Home': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
        'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92'
      ],
      'Beauty': [
        'https://images.unsplash.com/photo-1596462502278-27bfdc403348',
        'https://images.unsplash.com/photo-1571646034647-67637202d685',
        'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9'
      ],
      'Sports': [
        'https://images.unsplash.com/photo-1461896836934-ffe607ba8211',
        'https://images.unsplash.com/photo-1579952363873-27f3bade9f55',
        'https://images.unsplash.com/photo-1535131749006-b7f58c99034b'
      ],
      'Toys': [
        'https://images.unsplash.com/photo-1545558014-8692077e9b5c',
        'https://images.unsplash.com/photo-1516627145497-ae6968895b74',
        'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088'
      ]
    };

    // Get a random image for the specified category or a general one
    if (category != null && categoryImages.containsKey(category)) {
      final images = categoryImages[category]!;
      final random = Random().nextInt(images.length);
      return Future.value(images[random]);
    } else {
      // Get a random image from any category
      final allCategories = categoryImages.keys.toList();
      final randomCategory = allCategories[Random().nextInt(allCategories.length)];
      final images = categoryImages[randomCategory]!;
      final random = Random().nextInt(images.length);
      return Future.value(images[random]);
    }
  }

  // Show image suggestion dialog based on product category
  Future<String?> showImageSuggestionsDialog(BuildContext context, String? category) async {
    // Get image suggestions for this category
    final categoryName = category ?? 'General';
    final List<String> suggestions = [];

    // Add 3 suggestions for this category
    for (int i = 0; i < 3; i++) {
      suggestions.add(await suggestPlaceholderImage(category));
    }

    // Show the dialog with suggestions
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suggested $categoryName Images'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select one of these placeholder images:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...suggestions.map((url) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => Navigator.pop(context, url),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 100,
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
                            height: 100,
                            child: Center(
                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        url.split('/').last,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, getPlaceholderImage()),
            child: const Text('USE GENERIC PLACEHOLDER'),
          ),
        ],
      ),
    );
  }
}