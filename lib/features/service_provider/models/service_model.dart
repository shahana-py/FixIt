import 'package:cloud_firestore/cloud_firestore.dart';


class ServiceModel {
  final String name;
  final String description;
  final String experience;
  final String hourlyRate;
  final String sampleWork;
  bool isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  final String id;
  String? userId;  // Store user ID instead of full user model

  ServiceModel({
    required this.name,
    required this.id,
    required this.description,
    required this.experience,
    required this.hourlyRate,
    required this.sampleWork,
    this.createdAt,
    this.isActive = true,
    this.updatedAt,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "serviceName": name,
      "description": description,
      "experience": experience,
      "hourlyRate": hourlyRate,
      "sampleWork": sampleWork,
      "isActive": isActive,
      "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      "updatedAt": updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      "userId": userId,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      name: map['serviceName'] ?? '',
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      experience: map['experience'] ?? '',
      hourlyRate: map['hourlyRate'] ?? '',
      sampleWork: map['sampleWork'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      userId: map['userId'],
    );
  }
}