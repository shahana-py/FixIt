import 'package:fixit/features/user/view/user_account_page.dart';
import 'package:fixit/features/user/view/user_bookings_page.dart';
import 'package:fixit/features/user/view/user_home_screen.dart';
import 'package:fixit/features/user/view/user_messages_page.dart';
import 'package:fixit/features/user/view/view_services_page.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex=0;
  List<Widget> _widgetOptions=[
     HomeScreen(),
     ViewServicesPage(),
     UserBookingsPage(),
     UserMessagesPage(),
     UserAccountPage(),

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
                  icon: Icon(Icons.calendar_month),
                  label: "Bookings"
              ),
              BottomNavigationBarItem(
                  backgroundColor: Color(0xff0F3966),
                  icon: Icon(Icons.message_rounded),
                  label: "Messages"
              ),

              BottomNavigationBarItem(
                  backgroundColor: Color(0xff0F3966),
                  icon: Icon(Icons.person),
                  label: "Account"
              )
            ]),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),

    );
  }
}
