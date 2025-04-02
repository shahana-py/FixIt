import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/custom_texts/app_bar_text.dart';
import '../../../core/utils/custom_texts/Sub_text.dart';

class ProviderServicesPage extends StatefulWidget {
  const ProviderServicesPage({super.key});

  @override
  State<ProviderServicesPage> createState() => _ProviderServicesPageState();
}

class _ProviderServicesPageState extends State<ProviderServicesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white, size: 24),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/serviceProviderHome', (Route route) => false);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: AppBarTitle(text: "Your Services"),
        actions: [
          Icon(Icons.notifications),
          SizedBox(width: 10),
          Icon(Icons.search),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: StreamBuilder(
          stream: _firestore
              .collection('services')
              .where('provider_id', isEqualTo: _auth.currentUser?.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xff0F3966)),
              );
            }
            var services = snapshot.data!.docs;
            return services.isEmpty
                ? Center(
              child: Text("No services added yet!",
                  style: TextStyle(
                      fontSize: 18, color: Color(0xff0F3966))),
            )
                : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                var service = services[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Color(0xffC9E4CA),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(service['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff0F3966))),
                                    Text(
                                        "${service['experience']} years experience | \$${service['hourly_rate']}/hr"),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    SubText(
                                        text: "4.5",
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal)
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
