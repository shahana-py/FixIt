// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class BookingModel {
//   final String id;
//   final String userId;
//   final String providerId;
//   final String providerName;
//   final String serviceId;
//   final String serviceName;
//   final DateTime bookingDate;
//   final int durationHours;
//   final double hourlyRate;
//   final double totalCost;
//   final String status;
//   final String paymentStatus;
//   final String notes;
//   final DateTime createdAt;
//   final String userName;
//   final String address;
//
//   BookingModel({
//     required this.id,
//     required this.userId,
//     required this.providerId,
//     required this.providerName,
//     required this.serviceId,
//     required this.serviceName,
//     required this.bookingDate,
//     required this.durationHours,
//     required this.hourlyRate,
//     required this.totalCost,
//     required this.status,
//     required this.paymentStatus,
//     required this.notes,
//     required this.createdAt,
//     required this.userName,
//     required this.address,
//   });
//
//   factory BookingModel.fromJson(Map<String, dynamic> json) {
//     return BookingModel(
//       id: json['id'],
//       userId: json['userId'],
//       providerId: json['providerId'],
//       providerName: json['providerName'],
//       serviceId: json['serviceId'],
//       serviceName: json['serviceName'],
//       bookingDate: DateTime.parse(json['bookingDate']),
//       durationHours: json['durationHours'],
//       hourlyRate: (json['hourlyRate'] as num).toDouble(),
//       totalCost: (json['totalCost'] as num).toDouble(),
//       status: json['status'],
//       paymentStatus: json['paymentStatus'],
//       notes: json['notes'],
//       createdAt: DateTime.parse(json['createdAt']),
//       userName: json['userName'],
//       address: json['address'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'providerId': providerId,
//       'providerName': providerName,
//       'serviceId': serviceId,
//       'serviceName': serviceName,
//       'bookingDate': bookingDate.toIso8601String(),
//       'durationHours': durationHours,
//       'hourlyRate': hourlyRate,
//       'totalCost': totalCost,
//       'status': status,
//       'paymentStatus': paymentStatus,
//       'notes': notes,
//       'createdAt': createdAt.toIso8601String(),
//       'userName': userName,
//       'address': address,
//     };
//   }
//
//   factory BookingModel.fromFirestore(Map<String, dynamic> data) {
//     return BookingModel(
//       id: data['id'] ?? '',
//       userId: data['user_id'] ?? '',
//       providerId: data['provider_id'] ?? '',
//       providerName: data['provider_name'] ?? '',
//       serviceId: data['service_id'] ?? '',
//       serviceName: data['service_name'] ?? '',
//       bookingDate: data['booking_date']?.toDate() ?? DateTime.now(),
//       durationHours: data['duration_hours'] ?? 1,
//       hourlyRate: double.parse((data['hourly_rate'] ?? '0').toString()),
//       totalCost: (data['total_cost'] ?? 0).toDouble(),
//       status: data['status'] ?? 'pending',
//       paymentStatus: data['payment_status'] ?? 'unpaid',
//       notes: data['notes'] ?? '',
//       createdAt: data['created_at']?.toDate() ?? DateTime.now(),
//       userName: data['user_name'] ?? 'Unknown User',
//       address: data['address'] ?? 'Unknown Location',
//     );
//   }
//
//   // Add a copyWith method to update specific fields
//   BookingModel copyWith({
//     String? id,
//     String? userId,
//     String? providerId,
//     String? providerName,
//     String? serviceId,
//     String? serviceName,
//     DateTime? bookingDate,
//     int? durationHours,
//     double? hourlyRate,
//     double? totalCost,
//     String? status,
//     String? paymentStatus,
//     String? notes,
//     DateTime? createdAt,
//     String? userName,
//     String? address,
//   }) {
//     return BookingModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       providerId: providerId ?? this.providerId,
//       providerName: providerName ?? this.providerName,
//       serviceId: serviceId ?? this.serviceId,
//       serviceName: serviceName ?? this.serviceName,
//       bookingDate: bookingDate ?? this.bookingDate,
//       durationHours: durationHours ?? this.durationHours,
//       hourlyRate: hourlyRate ?? this.hourlyRate,
//       totalCost: totalCost ?? this.totalCost,
//       status: status ?? this.status,
//       paymentStatus: paymentStatus ?? this.paymentStatus,
//       notes: notes ?? this.notes,
//       createdAt: createdAt ?? this.createdAt,
//       userName: userName ?? this.userName,
//       address: address ?? this.address,
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceName;
  final DateTime bookingDate;
  final int durationHours;
  final double hourlyRate;
  final double totalCost;
  final String status;
  final String paymentStatus;
  final String notes;
  final DateTime createdAt;
  final String userName;
  final String address;
  // Added the missing fields
  final String paymentId;
  final String paymentMethod;
  final DateTime? paymentDate;
  final String displayAddress;
  final String declineReason;
  final Map<String, dynamic>? userLocation;

  BookingModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.bookingDate,
    required this.durationHours,
    required this.hourlyRate,
    required this.totalCost,
    required this.status,
    required this.paymentStatus,
    required this.notes,
    required this.createdAt,
    required this.userName,
    required this.address,
    this.paymentId = '',
    this.paymentMethod = '',
    this.paymentDate,
    this.displayAddress = '',
    this.declineReason = '',
    this.userLocation,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['userId'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      bookingDate: DateTime.parse(json['bookingDate']),
      durationHours: json['durationHours'],
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['userName'],
      address: json['address'],
      paymentId: json['paymentId'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate']) : null,
      displayAddress: json['displayAddress'] ?? '',
      declineReason: json['declineReason'] ?? '',
      userLocation: json['userLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'providerName': providerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'bookingDate': bookingDate.toIso8601String(),
      'durationHours': durationHours,
      'hourlyRate': hourlyRate,
      'totalCost': totalCost,
      'status': status,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'address': address,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate?.toIso8601String(),
      'displayAddress': displayAddress,
      'declineReason': declineReason,
      'userLocation': userLocation,
    };
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Extract user location
    Map<String, dynamic>? userLocation;
    if (data['user_location'] != null) {
      userLocation = Map<String, dynamic>.from(data['user_location']);
    }

    // Get display address - check for confirmed_address first, then user_location.address
    String displayAddress = '';
    if (data.containsKey('confirmed_address')) {
      displayAddress = data['confirmed_address'] ?? '';
    } else if (userLocation != null && userLocation['address'] != null) {
      displayAddress = userLocation['address'] ?? '';
    }

    return BookingModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      providerId: data['provider_id'] ?? '',
      providerName: data['provider_name'] ?? '',
      serviceId: data['service_id'] ?? '',
      serviceName: data['service_name'] ?? '',
      bookingDate: (data['booking_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationHours: data['duration_hours'] ?? 1,
      hourlyRate: double.tryParse(data['hourly_rate']?.toString() ?? '0.0') ?? 0.0,
      totalCost: (data['total_cost'] is num) ? (data['total_cost'] as num).toDouble() : 0.0,
      status: data['status'] ?? 'pending',
      paymentStatus: data['payment_status'] ?? 'unpaid',
      notes: data['notes'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userName: data['user_name'] ?? 'Unknown User',
      address: userLocation?['address'] ?? 'Unknown Location', // Use user_location.address
      paymentId: data['payment_id'] ?? '',
      paymentMethod: data['payment_method'] ?? '',
      paymentDate: (data['payment_date'] as Timestamp?)?.toDate(),
      displayAddress: displayAddress,
      declineReason: data['decline_reason'] ?? '',
      userLocation: userLocation,
    );
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? providerName,
    String? serviceId,
    String? serviceName,
    DateTime? bookingDate,
    int? durationHours,
    double? hourlyRate,
    double? totalCost,
    String? status,
    String? paymentStatus,
    String? notes,
    DateTime? createdAt,
    String? userName,
    String? address,
    String? paymentId,
    String? paymentMethod,
    DateTime? paymentDate,
    String? displayAddress,
    String? declineReason,
    Map<String, dynamic>? userLocation,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      bookingDate: bookingDate ?? this.bookingDate,
      durationHours: durationHours ?? this.durationHours,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      address: address ?? this.address,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      displayAddress: displayAddress ?? this.displayAddress,
      declineReason: declineReason ?? this.declineReason,
      userLocation: userLocation ?? this.userLocation,
    );
  }
}
