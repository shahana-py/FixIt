class ApiConstants {
  static const String baseUrl = 'https://imageapi.ralfiz.com';
  static const String apiPath = '/api/images';

  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';

    // Print for debugging
    print('Processing image URL: $imageUrl');

    // If it's already a full URL starting with http/https, return as is
    if (imageUrl.startsWith('http')) {
      print('Full URL detected: $imageUrl');
      return imageUrl;
    }

    // For all other cases (relative paths starting with / or not),
    // ensure we have a properly formed absolute URL
    final cleanUrl = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    final fullUrl = baseUrl + cleanUrl;
    print('Constructed full URL: $fullUrl');
    return fullUrl;
  }

  static Uri getApiUri([String? path]) {
    if (path == null) {
      return Uri.parse('$baseUrl$apiPath/');
    }
    String cleanPath = path;
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return Uri.parse('$baseUrl$apiPath/$cleanPath');
  }
}