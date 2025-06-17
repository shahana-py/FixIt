// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fixit/features/service_provider/view/provider_service_detailed_page.dart';
// import 'package:flutter/material.dart';
// import '../../../core/utils/custom_texts/app_bar_text.dart';
// import '../../../core/utils/custom_texts/Sub_text.dart';
//
// class ProviderServicesPage extends StatefulWidget {
//   const ProviderServicesPage({super.key});
//
//   @override
//   State<ProviderServicesPage> createState() => _ProviderServicesPageState();
// }
//
// class _ProviderServicesPageState extends State<ProviderServicesPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Color(0xff0F3966),
//         iconTheme: IconThemeData(color: Colors.white, size: 24),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, '/serviceProviderHome', (Route route) => false);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//         title: AppBarTitle(text: "My Services"),
//         actions: [
//           Icon(Icons.notifications),
//           SizedBox(width: 10),
//           Icon(Icons.search),
//           SizedBox(width: 10),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: StreamBuilder(
//           stream: _firestore
//               .collection('services')
//               .where('provider_id', isEqualTo: _auth.currentUser?.uid)
//               .snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(color: Color(0xff0F3966)),
//               );
//             }
//             var services = snapshot.data!.docs;
//             return services.isEmpty
//                 ? Center(
//               child: Text("No services added yet!",
//                   style: TextStyle(
//                       fontSize: 18, color: Color(0xff0F3966))),
//             )
//                 : ListView.builder(
//               itemCount: services.length,
//               itemBuilder: (context, index) {
//                 var service = services[index];
//                 return GestureDetector(
//                   onTap: (){Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ServiceDetailsPage(serviceId: service.id),
//
//                     ),
//                   );},
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30)),
//                     child: Container(
//                       height: 300,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(30)),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Container(
//                             width: double.infinity,
//                             height: 70,
//                             decoration: BoxDecoration(
//                               color: Color(0xffC9E4CA),
//                               borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(30),
//                                   bottomRight: Radius.circular(30)),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.center,
//                                     children: [
//                                       Text(service['name'],
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               color: Color(0xff0F3966))),
//                                       Text(
//                                           "${service['experience']} years experience | ₹${service['hourly_rate']}/hr"),
//                                     ],
//                                   ),
//                                   Column(
//                                     children: [
//                                       Icon(
//                                         Icons.star,
//                                         color: Colors.amber,
//                                       ),
//                                       SubText(
//                                           text: "4.5",
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.normal)
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/features/service_provider/view/provider_service_detailed_page.dart';
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

  // Method to fetch average ratings for each service
  Future<Map<String, double>> _getServiceRatings() async {
    final ratings = <String, double>{};
    try {
      // Get all services for this provider
      final services = await _firestore
          .collection('services')
          .where('provider_id', isEqualTo: _auth.currentUser?.uid)
          .get();

      for (final service in services.docs) {
        // Get all ratings for this service
        final ratingsSnapshot = await _firestore
            .collection('ratings')
            .where('service_id', isEqualTo: service.id)
            .get();

        if (ratingsSnapshot.docs.isNotEmpty) {
          double totalRating = 0;
          for (final ratingDoc in ratingsSnapshot.docs) {
            totalRating += (ratingDoc['rating'] as num).toDouble();
          }
          final averageRating = totalRating / ratingsSnapshot.docs.length;
          ratings[service.id] = double.parse(averageRating.toStringAsFixed(1));
        } else {
          ratings[service.id] = 0.0;
        }
      }
    } catch (e) {
      print('Error fetching ratings: $e');
    }
    return ratings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: AppBarTitle(text: "My Services"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: FutureBuilder<Map<String, double>>(
          future: _getServiceRatings(),
          builder: (context, ratingsSnapshot) {
            if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xff0F3966)),
              );
            }

            return StreamBuilder(
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
                    final data = service.data() as Map<String, dynamic>;
                    final workSampleUrl = data['work_sample'];
                    final hasImage = workSampleUrl != null;

                    // Get the average rating from our ratings map
                    final avgRating = ratingsSnapshot.hasData
                        ? ratingsSnapshot.data![service.id] ?? 0.0
                        : 0.0;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ServiceDetailsPage(serviceId: service.id),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: hasImage ? null : Colors.blue,
                            image: hasImage
                                ? DecorationImage(
                              image: NetworkImage(workSampleUrl),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[100],
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
                                              "${service['experience']} years experience | ₹${service['hourly_rate']}/hr"),
                                        ],
                                      ),
                                      // Enhanced Rating Section
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            SizedBox(width: 4),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  avgRating.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff0F3966),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
