import 'package:flutter/material.dart';

class ViewServicesPage extends StatefulWidget {
  const ViewServicesPage({super.key});

  @override
  State<ViewServicesPage> createState() => _ViewServicesPageState();
}

class _ViewServicesPageState extends State<ViewServicesPage> {
  String? selectedCategory; // To track selected category

  // Define categories and their corresponding sub-services
  final Map<String, List<Map<String, String>>> serviceCategories = {
    'Maintenance Services': [
      {'name': 'Plumbing works', 'image': 'assets/images/Plumbing.jpg'},
      {'name': 'Electrical Works', 'image': 'assets/images/electrical work.jpg'},
      {'name': 'AC Repairing', 'image': 'assets/images/AC repair.jpg'},
      {'name': 'Painting', 'image': 'assets/images/painting.jpeg'},
    ],
    'Cleaning Services': [
      {'name': 'Cleaning', 'image': 'assets/images/cleaning.jpeg'},
      {'name': 'Car Wash', 'image': 'assets/images/car wash.jpeg'},
      {'name': 'Laundry', 'image': 'assets/images/laundry.jpg'},
    ],
    'Beauty Services': [
      {'name': "Men's Grooming", 'image': 'assets/images/mens grooming.png'},
      {'name': "Women's Grooming", 'image': 'assets/images/womens grooming.jpg'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Determine the services to show based on selected category
    List<Map<String, String>> displayedServices = selectedCategory == null
        ? serviceCategories.values.expand((services) => services).toList()
        : serviceCategories[selectedCategory!] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white, size: 24),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (Route route) => false);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("All Services", style: TextStyle(color: Colors.white)),
        actions: [
          Icon(Icons.bookmark,),
          SizedBox(width: 10),
          Icon(Icons.notifications,),
          SizedBox(width: 10),
          Icon(Icons.search,),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color(0xff0F3966)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: serviceCategories.keys.map((category) {
                bool isSelected = category == selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = (selectedCategory == category) ? null : category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blue[700]! : Colors.grey[500]!,

                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xff0F3966),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Services Grid Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: displayedServices.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1, // Keep cards square
                ),
                itemBuilder: (context, index) {
                  return ServiceCard(
                    serviceImage: displayedServices[index]['image']!,
                    serviceName: displayedServices[index]['name']!,
                    onTap: () {
                      Navigator.pushNamed(context, "/viewallproviderspage");
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Service Card Widget
class ServiceCard extends StatelessWidget {
  final String serviceImage;
  final String serviceName;
  final VoidCallback onTap;


  const ServiceCard({required this.serviceImage, required this.serviceName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(

        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  serviceImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  serviceName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }
}
