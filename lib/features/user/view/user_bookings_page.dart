
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';

class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({super.key});

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white,size: 24),
        leading: IconButton(
          onPressed: (){
            Navigator.pushNamedAndRemoveUntil(context, '/home', (Route route)=>false);
          },
          icon: Icon(Icons.arrow_back),
        ),

        title: AppBarTitle(text: "Bookings"),

      ),
      body: Text("Bookings"),
    );
  }
}
