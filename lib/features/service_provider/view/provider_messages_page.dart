import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/core/utils/custom_texts/main_text.dart';
import 'package:flutter/material.dart';

class ProviderMessagesPage extends StatefulWidget {
  const ProviderMessagesPage({super.key});

  @override
  State<ProviderMessagesPage> createState() => _ProviderMessagesPageState();
}

class _ProviderMessagesPageState extends State<ProviderMessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white,size: 24),
        leading: IconButton(
          onPressed: (){
            Navigator.pushNamedAndRemoveUntil(context, '/serviceProviderHome', (Route route)=>false);
          },
          icon: Icon(Icons.arrow_back),
        ),

        title: AppBarTitle(text: "Messages"),
        actions: [
          Icon(Icons.notifications,),
          SizedBox(width: 10),
          Icon(Icons.search,),
          SizedBox(width: 10),

        ],
      ),
      body: Text("All Messages"),
    );
  }
}
