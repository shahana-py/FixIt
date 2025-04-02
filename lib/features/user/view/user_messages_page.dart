import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/core/utils/custom_texts/main_text.dart';
import 'package:flutter/material.dart';

class UserMessagesPage extends StatefulWidget {
  const UserMessagesPage({super.key});

  @override
  State<UserMessagesPage> createState() => _UserMessagesPageState();
}

class _UserMessagesPageState extends State<UserMessagesPage> {
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

        title: AppBarTitle(text: "Messages"),

      ),
      body: Text("All Messages"),
    );
  }
}
