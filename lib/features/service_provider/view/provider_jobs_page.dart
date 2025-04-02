
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';

class ProviderJobsPage extends StatefulWidget {
  const ProviderJobsPage({super.key});

  @override
  State<ProviderJobsPage> createState() => _ProviderJobsPageState();
}

class _ProviderJobsPageState extends State<ProviderJobsPage> {
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

        title: AppBarTitle(text: "My Jobs"),
        actions: [
          Icon(Icons.notifications,),
          SizedBox(width: 10),
          Icon(Icons.search,),
          SizedBox(width: 10),

        ],
      ),
      body: Text("Your Jobs"),
    );
  }
}
