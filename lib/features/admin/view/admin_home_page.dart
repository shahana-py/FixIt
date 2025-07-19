

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int totalUsers = 0;
  int totalProviders = 0;
  int totalBookings = 0;
  int totalCategories = 0;
  int totalTools = 0;
  int totalOrders = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    var usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    var providersSnapshot = await FirebaseFirestore.instance.collection('service provider').get();
    var bookingSnapshot = await FirebaseFirestore.instance.collection('bookings').get();
    var categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
    var ToolsSnapshot = await FirebaseFirestore.instance.collection('products').get();
    var OrdersSnapshot = await FirebaseFirestore.instance.collection('orders').get();

    setState(() {
      totalUsers = usersSnapshot.size;
      totalProviders = providersSnapshot.size;
      totalBookings = bookingSnapshot.size;
      totalCategories = categoriesSnapshot.size;
      totalTools = ToolsSnapshot.size;
      totalOrders = OrdersSnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image(
            image: AssetImage("assets/images/splash_logo.png"),
            width: 30,
            height: 30,
          ),
        ),
        title: AppBarTitle(text: "Admin Dashboard"),
        backgroundColor: Color(0xff0F3966),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (Route route) => false);
            },
            icon: Icon(Icons.logout, color: Colors.white, size: 24),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Statistics Section
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F3966),
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 5,
                    mainAxisSpacing:5,
                    childAspectRatio: 1.2,
                    children: [
                      DashboardCard(
                        title: 'Users',
                        count: totalUsers,
                        icon: Icons.people,
                        iconColor: Colors.cyan,
                      ),
                      DashboardCard(
                        title: 'Providers',
                        count: totalProviders,
                        icon: Icons.business,
                        iconColor: Colors.redAccent,
                      ),
                      DashboardCard(
                        title: 'Service Bookings',
                        count: totalBookings,
                        icon: Icons.calendar_month,
                        iconColor: Colors.lime,
                      ),
                      DashboardCard(
                        title: 'Categories',
                        count: totalCategories,
                        icon: Icons.category,
                        iconColor: Colors.lightGreen,
                      ),
                      DashboardCard(
                        title: 'Tools',
                        count: totalTools,
                        icon: Icons.construction,
                        iconColor: Colors.blue,
                      ),
                      DashboardCard(
                        title: 'Tools Orders',
                        count: totalOrders,
                        icon: Icons.shopping_cart_rounded,
                        iconColor: Colors.orangeAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // User & Provider Management Section
            AdminSection(
              title: 'User & Provider Management',
              icon: Icons.people_alt,
              children: [
                AdminOption(
                  title: 'View All Users',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewalluserspage');
                  },
                ),
                AdminOption(
                  title: 'View Service Providers',
                  icon: Icons.business,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewallserviceproviders');
                  },
                ),
                AdminOption(
                  title: 'Manage Provider Approvals',
                  icon: Icons.verified_user,
                  onTap: () {
                    Navigator.pushNamed(context, '/manageapprovalspage');
                  },
                ),
              ],
            ),

            // Service & Booking Management Section
            AdminSection(
              title: 'Service & Booking Management',
              icon: Icons.home_repair_service,
              children: [
                AdminOption(
                  title: 'View all services',
                  icon: Icons.home_repair_service,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewallservicespage');
                  },
                ),
                AdminOption(
                  title: 'View all Bookings',
                  icon: Icons.calendar_month,
                  onTap: () {
                    Navigator.pushNamed(context, '/viewallbookingspage');
                  },
                ),
                AdminOption(
                  title: 'Manage Categories',
                  icon: Icons.category,
                  onTap: () {
                    Navigator.pushNamed(context, '/managecategoriespage');
                  },
                ),
              ],
            ),

            // Tools & Inventory Management Section
            AdminSection(
              title: 'Tools & Inventory Management',
              icon: Icons.construction,
              children: [
                AdminOption(
                  title: 'Manage tools inventory',
                  icon: Icons.cleaning_services,
                  onTap: () {
                    Navigator.pushNamed(context, '/managetoolsinventory');
                  },
                ),
                AdminOption(
                  title: 'Manage tools Orders',
                  icon: Icons.shopping_cart,
                  onTap: () {
                    Navigator.pushNamed(context, '/managetoolsorders');
                  },
                ),
              ],
            ),

            // Customer Relations Section
            AdminSection(
              title: 'Customer Relations',
              icon: Icons.support_agent,
              children: [
                AdminOption(
                  title: 'Manage Feedbacks & Reviews',
                  icon: Icons.reviews,
                  onTap: () {
                    Navigator.pushNamed(context, '/managefeedbacksandreviewspage');
                  },
                ),
                AdminOption(
                  title: 'Manage Complaints',
                  icon: Icons.feedback,
                  onTap: () {
                    Navigator.pushNamed(context, '/managecomplaintspage');
                  },
                ),
              ],
            ),

            // Marketing & Communications Section
            AdminSection(
              title: 'Marketing & Communications',
              icon: Icons.campaign,
              children: [
                AdminOption(
                  title: 'Manage Offers',
                  icon: Icons.discount,
                  onTap: () {
                    Navigator.pushNamed(context, '/manageofferspage');
                  },
                ),
                AdminOption(
                  title: 'Manage Notifications',
                  icon: Icons.notifications,
                  onTap: () {
                    Navigator.pushNamed(context, '/managenotificationspage');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color iconColor;

  DashboardCard({
    required this.title,
    required this.count,
    required this.icon,
    this.iconColor = const Color(0xff0F3966), // Default color if none provided
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        color: Colors.white60,
        padding: const EdgeInsets.all(23),
        width: 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xff0F3966),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                color: const Color(0xff0F3966),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  AdminSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xff0F3966).withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Color(0xff0F3966), size: 24),
                    SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F3966),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  AdminOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          tileColor: Colors.blue[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xff0F3966).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xff0F3966), size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff0F3966),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xff0F3966).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xff0F3966),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}


