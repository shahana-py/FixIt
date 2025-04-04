
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

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    var usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    var providersSnapshot = await FirebaseFirestore.instance.collection('service provider').get();

    setState(() {
      totalUsers = usersSnapshot.size;
      totalProviders = providersSnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        iconTheme: IconThemeData(color: Colors.white),
        leading:Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image(image: AssetImage("assets/images/splash_logo.png"),width: 30,height: 30,),
        ) ,
        title: AppBarTitle(text: "Admin Dashboard"),
        backgroundColor: Color(0xff0F3966),
        actions: [
          IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (Route route)=>false);
          }, icon: Icon(Icons.logout,color: Colors.white,size: 24)),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DashboardCard(title: 'Users', count: totalUsers, icon: Icons.people, iconColor: Colors.cyan,),
                  DashboardCard(title: 'Providers', count: totalProviders, icon: Icons.business, iconColor: Colors.redAccent,),

                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DashboardCard(title: 'Bookings', count: 5, icon: Icons.calendar_month,iconColor: Colors.lime,),
                DashboardCard(title: 'Categories', count: 5, icon: Icons.category,iconColor: Colors.lightGreen,),

              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  AdminOption(
                      title: 'View All Users',
                      icon: Icons.person,
                      onTap: () {
                    Navigator.pushNamed(context, '/viewalluserspage');
                      }),

                  AdminOption(
                      title: 'View Service Providers',
                      icon: Icons.business,
                      onTap: () {
                        Navigator.pushNamed(context, '/viewallserviceproviders');
                      }),
                  AdminOption(
                      title: 'Manage Provider Approvals',
                      icon: Icons.verified_user,
                      onTap: () {
                        Navigator.pushNamed(context, '/manageapprovalspage');
                      }),
                  AdminOption(
                      title: 'Manage Categories',
                      icon: Icons.category,
                      onTap: () {
                        Navigator.pushNamed(context, '/managecategoriespage');
                      }),
                  AdminOption(
                      title: 'Manage Offers',
                      icon: Icons.discount,
                      onTap: () {
                        Navigator.pushNamed(context, '/manageofferspage');
                      }),
                  AdminOption(
                      title: 'Manage Notifications',
                      icon: Icons.notifications,
                      onTap: () {
                        Navigator.pushNamed(context, '/managenotificationspage');
                      }),
                  AdminOption(
                      title: 'Manage Feedbacks & Reviews',
                      icon: Icons.reviews,
                      onTap: () {
                        Navigator.pushNamed(context, '/managefeedbackspage');
                      }),
                  AdminOption(
                      title: 'Manage Complaints',
                      icon: Icons.feedback,
                      onTap: () {
                        Navigator.pushNamed(context, '/managecomplaintspage');
                      }),

                ],
              ),
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
        padding: const EdgeInsets.all(16),
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

class AdminOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  AdminOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Card(
        elevation: 5,
        child: ListTile(

          tileColor: Colors.blue[100],
          leading: Icon(icon, color: Color(0xff0F3966)),
          title: Text(title, style: TextStyle(fontSize: 16,color: Color(0xff0F3966) )),
          trailing: Icon(Icons.arrow_forward_ios, size: 16,color: Color(0xff0F3966),),
          onTap: onTap,
        ),
      ),
    );
  }
}
