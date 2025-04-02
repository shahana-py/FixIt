import 'package:cloud_firestore/cloud_firestore.dart';


import '../models/service_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //getall

  Stream<List<ServiceModel>> getServices(String userId) {
    return _firestore
        .collection('services')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ServiceModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList())
        .handleError((error) {
      print('Error fetching services: $error');
      return <ServiceModel>[]; // Return an empty list on error
    });
  }

  // Future<List<ServiceModel>?> getServices(String userId) async {
  //   try{
  //     final snapshot = await _firestore
  //         .collection('services')
  //         .where('userId', isEqualTo: userId).where('isActive',isEqualTo: false)
  //         .orderBy('createdAt')
  //         .get();
  //
  //     return snapshot.docs
  //         .map((doc) => ServiceModel.fromMap(doc.data() as Map<String, dynamic>))
  //         .toList();
  //   }catch(e){
  //     print(e);
  //   }
  //   return null;
  // }

  // create

  Future<bool?> createService(ServiceModel service) async {
    try {
      await _firestore
          .collection('services')
          .doc(service.id)
          .set(service.toMap())
          .then((vlaue) {
        return true;
      });
    } catch (e) {
      print(e);
    }
  }

  // edit
  Future<void> updateService(ServiceModel service) async {
    await _firestore.collection('services').doc(service.id).update({
      'serviceName': service.name,
      'description': service.description,
      // Add other fields as needed
    });
  }
//delete
}
