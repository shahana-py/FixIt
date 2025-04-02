import 'package:fixit/features/service_provider/view/provider_home_page.dart';
import 'package:fixit/features/service_provider/view/provider_jobs_page.dart';
import 'package:fixit/features/service_provider/view/provider_messages_page.dart';
import 'package:fixit/features/service_provider/view/provider_profile_page.dart';
import 'package:fixit/features/service_provider/view/provider_services.dart';
import 'package:fixit/features/user/view/user_account_page.dart';
import 'package:fixit/features/user/view/user_bookings_page.dart';
import 'package:fixit/features/user/view/user_home_screen.dart';
import 'package:fixit/features/user/view/user_messages_page.dart';
import 'package:fixit/features/user/view/view_services_page.dart';
import 'package:flutter/material.dart';

class ProviderHome extends StatefulWidget {
  const ProviderHome({super.key});

  @override
  State<ProviderHome> createState() => _ProviderHomeState();
}

class _ProviderHomeState extends State<ProviderHome> {
  int _selectedIndex=0;
  List<Widget> _widgetOptions=[
    ServiceProviderHomePage(),
    ProviderServicesPage(),
    ProviderJobsPage(),
    ProviderMessagesPage(),
    ProviderProfilePage(),

  ];
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),

        ),
        child: BottomNavigationBar(
            backgroundColor: Color(0xff0F3966),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white30,
            // showSelectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: (int index){
              setState(() {
                _selectedIndex=index;
              });
            },

            items:[
              BottomNavigationBarItem(
                  backgroundColor: Color(0xff0F3966),
                  icon: Icon(Icons.home),
                  label: "Home"
              ),
              BottomNavigationBarItem(
                  backgroundColor: Color(0xff0F3966),
                  icon: Icon(Icons.home_repair_service),
                  label: "Services"
              ),
              BottomNavigationBarItem(
                  backgroundColor: Color(0xff0F3966),
                  icon: Icon(Icons.today_outlined),
                  label: "jobs"
              ),
              BottomNavigationBarItem(
                  backgroundColor: Color(0xff0F3966),
                  icon: Icon(Icons.message_rounded),
                  label: "Messages"
              ),

              BottomNavigationBarItem(
                  backgroundColor: Color(0xff0F3966),
                  icon: Icon(Icons.person),
                  label: "Profile"
              )
            ]),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),

    );
  }
}
