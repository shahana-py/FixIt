
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/core/utils/custom_texts/Sub_text.dart';
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/features/service_provider/view/provider_side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ServiceProviderHomePage extends StatefulWidget {
  const ServiceProviderHomePage({super.key});

  @override
  State<ServiceProviderHomePage> createState() =>
      _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState extends State<ServiceProviderHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<File> _workSamples = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String providerName = "Provider"; // Default name

  @override
  void initState() {
    super.initState();
    _fetchProviderName();
  }

  Future<void> _fetchProviderName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('service provider').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          providerName = userDoc['name'] ?? "Provider";
        });
      }
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _workSamples = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController serviceNameController = TextEditingController();
        TextEditingController experienceController = TextEditingController();
        TextEditingController hourlyRateController = TextEditingController();

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add Service",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xff0F3966))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(serviceNameController, "Service Name"),
                _buildTextField(experienceController, "Years of Experience",
                    TextInputType.number),
                _buildTextField(
                    hourlyRateController, "Hourly Rate", TextInputType.number),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.photo_library,color: Colors.white,),
                  label: Text(
                    "Add Work Samples",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0F3966)),
                ),
                Wrap(
                  spacing: 8.0,
                  children: _workSamples
                      .map((image) => Image.file(image, width: 50, height: 50))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user != null) {
                  DocumentSnapshot userDoc = await _firestore
                      .collection('service provider')
                      .doc(user.uid)
                      .get();

                  if (userDoc.exists) {
                    _firestore.collection('services').add({
                      'name': serviceNameController.text,
                      'experience': experienceController.text,
                      'hourly_rate': hourlyRateController.text,
                      'provider_id': user.uid, // Store the service provider's UID
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: Service provider not found")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0F3966),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),

          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProviderSideDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.yellowAccent[600],
              child: IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.person, color: Colors.blue),
              ),
            ),
          ),
        ),
        title: AppBarTitle(text: "$providerName"),
        actions: [
          IconButton(onPressed: (){
            Navigator.pushNamed(context, '/providernotificationpage');
          }, icon: Icon(Icons.notifications,color: Colors.white,size: 24,)),
          SizedBox(width: 10),
          IconButton(
            onPressed: () async {
              SharedPreferences _pref = await SharedPreferences.getInstance();
              _pref.clear();
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route route) => false);
              });
            },
            icon: Icon(Icons.logout, color: Colors.white, size: 24),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [

          Card(
            shadowColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Container(
              height: 300,
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                        "assets/images/service provider home banner.png")),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10,left: 5),
                    child: Text(
                      "Be the Expert Everyone’s Looking For!",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff444444),
                        fontFamily: 'Raleway',
                        letterSpacing: 0.7,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SubText(text: "My Services",fontSize: 20,),
                GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, "/providerAllServicesPage");
                    },
                    child: SubText(text: "View All",color: Colors.blue,fontSize: 18,fontWeight: FontWeight.normal,))
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('services').where('provider_id', isEqualTo: _auth.currentUser?.uid).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: Color(0xff0F3966)));
                }
                var services = snapshot.data!.docs;
                return services.isEmpty
                    ? Center(
                        child: GestureDetector(
                          onTap: _showAddServiceDialog,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle,
                                  size: 80, color: Color(0xff0F3966)),
                              SizedBox(height: 10),
                              Text("Add a Service",
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0xff0F3966))),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        children: services.map((service) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                            color: Color(0xffC9E4CA),
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12),
                              title: Text(service['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff0F3966))),
                              subtitle: Text(
                                  "${service['experience']} years experience | \$${service['hourly_rate']}/hr"),
                              leading:
                                  Icon(Icons.build, color: Color(0xff0F3966)),
                              trailing:
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Column(
                                  children: [
                                    Icon(Icons.star,color: Colors.amber,),
                                    SubText(text: "4.5",fontSize: 15,fontWeight: FontWeight.normal,)
                                  ],
                                ),
                              ),


                            ),
                          );
                        }).toList(),
                      );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SubText(text: "New Requests",fontSize: 20,),
                GestureDetector(
                    onTap: (){
                      // Navigator.pushNamed(context, "/providerAllServicesPage");
                    },
                    child: SubText(text: "View All",color: Colors.blue,fontSize: 18,fontWeight: FontWeight.normal,))
              ],
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,

              physics: NeverScrollableScrollPhysics(), // Prevents conflicts in scrolling
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  color: Color(0xffC9E4CA),
                  margin: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 10),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    child: ListTile(


                      contentPadding: EdgeInsets.all(10),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text("Leaky Faucet",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0F3966))),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month),
                                SizedBox(width: 5),
                                Text("30 March 2024")
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.watch_later_outlined),
                                SizedBox(width: 5),
                                Text("10:00 AM")
                              ],
                            ),
                          ],
                        ),
                      ),
                      leading:  Container(
                        height: 150,
                        width: 150,

                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        backgroundColor: Color(0xff0F3966),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


