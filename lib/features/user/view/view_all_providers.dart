import 'package:flutter/material.dart';

class ViewAllServiceProvidersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Service Providers'),
        backgroundColor: Color(0xff0F3966),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with actual provider list length
        itemBuilder: (context, index) {
          // Replace with actual provider data
          return ProviderCard(
            name: 'Provider Name $index',
            categories: ['Category 1', 'Category 2'],
            rating: 4.5, // Replace with actual rating
            imageUrl: 'assets/images/provider_$index.jpg', // Replace with actual image URL
            onPressed: () {
              // Implement navigation to provider details page
            },
          );
        },
      ),
    );
  }
}

class ProviderCard extends StatelessWidget {
  final String name;
  final List<String> categories;
  final double rating;
  final String imageUrl;
  final VoidCallback onPressed;

  ProviderCard({
    required this.name,
    required this.categories,
    required this.rating,
    required this.imageUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage(imageUrl),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      categories.join(', '),
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ViewAllServiceProvidersPage(),
    theme: ThemeData(
      primaryColor: Color(0xff0F3966),
    ),
  ));
}
