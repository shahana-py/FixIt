// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:fixit/features/user/view/payment_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class BookingPage extends StatefulWidget {
//   final String serviceId;
//   final Map<String, dynamic> serviceData;
//   final Map<String, dynamic> providerData;
//   final List<String> serviceImages;
//
//   const BookingPage({
//     Key? key,
//     required this.serviceId,
//     required this.serviceData,
//     required this.providerData,
//     required this.serviceImages,
//   }) : super(key: key);
//
//   @override
//   _BookingPageState createState() => _BookingPageState();
// }
//
// class _BookingPageState extends State<BookingPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final Color primaryColor = Color(0xff0F3966);
//   final Color accentColor = Color(0xff3A8FD8); // Lighter blue for accents
//   final Color lightBlue = Color(0xffD0E6FF); // Very light blue for backgrounds
//
//   DateTime selectedDate = DateTime.now().add(Duration(days: 1));
//   TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 0);
//   int selectedDuration = 1; // Default duration in hours
//   double totalCost = 0;
//   String bookingNotes = '';
//   bool isBooking = false;
//
//   final TextEditingController _notesController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _calculateTotalCost();
//   }
//
//   @override
//   void dispose() {
//     _notesController.dispose();
//     super.dispose();
//   }
//
//   void _calculateTotalCost() {
//     // Get hourly rate from service data
//     int hourlyRate = int.tryParse(widget.serviceData['hourly_rate']?.toString() ?? '0') ?? 0;
//     totalCost = hourlyRate * selectedDuration.toDouble();
//     setState(() {});
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     // Get available days from service data
//     List<String> availableDays = List<String>.from(widget.serviceData['available_days'] ?? []);
//
//     // Map day names to integers where Monday = 1, Sunday = 7
//     Map<String, int> dayToNumber = {
//       'Monday': 1,
//       'Tuesday': 2,
//       'Wednesday': 3,
//       'Thursday': 4,
//       'Friday': 5,
//       'Saturday': 6,
//       'Sunday': 7,
//     };
//
//     // Convert available days to numbers
//     List<int> availableDayNumbers = availableDays
//         .map((day) => dayToNumber[day] ?? 0)
//         .where((number) => number > 0)
//         .toList();
//
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(Duration(days: 90)),
//       selectableDayPredicate: (DateTime date) {
//         // Check if the weekday is in available days
//         return availableDayNumbers.contains(date.weekday);
//       },
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//               secondary: accentColor,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: primaryColor,
//               ),
//             ),
//             dialogBackgroundColor: Colors.white,
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }
//
//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//               secondary: accentColor,
//             ),
//             timePickerTheme: TimePickerThemeData(
//               backgroundColor: Colors.white,
//               hourMinuteTextColor: Colors.white,
//               hourMinuteColor: primaryColor,
//               dialHandColor: primaryColor,
//               dialBackgroundColor: lightBlue,
//               dayPeriodTextColor: primaryColor,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null && picked != selectedTime) {
//       setState(() {
//         selectedTime = picked;
//       });
//     }
//   }
//
//
//   Future<void> _createBooking() async {
//     if (_auth.currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please login to book a service'),
//           backgroundColor: primaryColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       isBooking = true;
//     });
//
//     try {
//       // Format date and time for Firestore
//       final DateTime bookingDateTime = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//         selectedTime.hour,
//         selectedTime.minute,
//       );
//
//       // Create booking document
//       DocumentReference bookingRef = await _firestore.collection('bookings').add({
//         'service_id': widget.serviceId,
//         'provider_id': widget.serviceData['provider_id'],
//         'user_id': _auth.currentUser!.uid,
//         'service_name': widget.serviceData['name'] ?? 'Service',
//         'provider_name': widget.providerData['name'] ?? 'Service Provider',
//         'booking_date': Timestamp.fromDate(bookingDateTime),
//         'duration_hours': selectedDuration,
//         'total_cost': totalCost,
//         'status': 'pending_payment', // Changed to indicate payment is needed
//         'notes': bookingNotes,
//         'created_at': FieldValue.serverTimestamp(),
//         'hourly_rate': widget.serviceData['hourly_rate'],
//         'payment_status': 'unpaid', // Add payment status field
//       });
//
//       // Get the booking ID
//       String bookingId = bookingRef.id;
//
//       // Navigate to PaymentPage instead of showing success message
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentPage(
//             providerId:widget.serviceData['provider_id'] ,
//             serviceId: widget.serviceId,
//
//             bookingId: bookingId,
//             hourlyRate: double.parse(widget.serviceData['hourly_rate'].toString()), // Convert to double
//             hours: selectedDuration,
//             totalAmount: totalCost,
//             serviceName: widget.serviceData['name'] ?? 'Service',
//             providerName: widget.providerData['name'] ?? 'Service Provider',
//             bookingDate: bookingDateTime,
//           ),
//         ),
//       );
//
//     } catch (e) {
//       print('Error creating booking: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(Icons.error_outline, color: Colors.white),
//               SizedBox(width: 8),
//               Text('Failed to create booking. Please try again.'),
//             ],
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     } finally {
//       setState(() {
//         isBooking = false;
//       });
//     }
//   }
//
//   // Future<void> _createBooking() async {
//   //   if (_auth.currentUser == null) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('Please login to book a service'),
//   //         backgroundColor: primaryColor,
//   //         behavior: SnackBarBehavior.floating,
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(10),
//   //         ),
//   //       ),
//   //     );
//   //     return;
//   //   }
//   //
//   //   setState(() {
//   //     isBooking = true;
//   //   });
//   //
//   //   try {
//   //     // Format date and time for Firestore
//   //     final DateTime bookingDateTime = DateTime(
//   //       selectedDate.year,
//   //       selectedDate.month,
//   //       selectedDate.day,
//   //       selectedTime.hour,
//   //       selectedTime.minute,
//   //     );
//   //
//   //     // Create booking document
//   //     DocumentReference bookingRef = await _firestore.collection('bookings').add({
//   //       'service_id': widget.serviceId,
//   //       'provider_id': widget.serviceData['provider_id'],
//   //       'user_id': _auth.currentUser!.uid,
//   //       'service_name': widget.serviceData['name'] ?? 'Service',
//   //       'provider_name': widget.providerData['name'] ?? 'Service Provider',
//   //       'booking_date': Timestamp.fromDate(bookingDateTime),
//   //       'duration_hours': selectedDuration,
//   //       'total_cost': totalCost,
//   //       'status': 'pending', // initial status: pending, confirmed, completed, canceled
//   //       'notes': bookingNotes,
//   //       'created_at': FieldValue.serverTimestamp(),
//   //       'hourly_rate': widget.serviceData['hourly_rate'],
//   //     });
//   //
//   //     // Show success message
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Row(
//   //           children: [
//   //             Icon(Icons.check_circle, color: Colors.white),
//   //             SizedBox(width: 8),
//   //             Text('Booking request sent successfully!'),
//   //           ],
//   //         ),
//   //         backgroundColor: Colors.green,
//   //         behavior: SnackBarBehavior.floating,
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(10),
//   //         ),
//   //       ),
//   //     );
//   //
//   //     // Navigate back to previous screen
//   //     Navigator.pop(context);
//   //
//   //   } catch (e) {
//   //     print('Error creating booking: $e');
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Row(
//   //           children: [
//   //             Icon(Icons.error_outline, color: Colors.white),
//   //             SizedBox(width: 8),
//   //             Text('Failed to create booking. Please try again.'),
//   //           ],
//   //         ),
//   //         backgroundColor: Colors.red,
//   //         behavior: SnackBarBehavior.floating,
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(10),
//   //         ),
//   //       ),
//   //     );
//   //   } finally {
//   //     setState(() {
//   //       isBooking = false;
//   //     });
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     String providerName = widget.providerData['name'] ?? 'Service Provider';
//     String serviceName = widget.serviceData['name'] ?? 'Service';
//     String hourlyRate = widget.serviceData['hourly_rate']?.toString() ?? '0';
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: AppBarTitle(text: "Book Service"),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(20),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Decorative curve
//           Container(
//             height: 20,
//             color: Colors.transparent,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.vertical(
//                   bottom: Radius.circular(100),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Service Summary Card
//                   Card(
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15),
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Colors.white,
//                             lightBlue,
//                           ],
//                         ),
//                       ),
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Service Image
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     spreadRadius: 1,
//                                     blurRadius: 3,
//                                     offset: Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: widget.serviceImages.isNotEmpty
//                                   ? Image.network(
//                                 widget.serviceImages[0],
//                                 width: 100,
//                                 height: 100,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Container(
//                                     width: 100,
//                                     height: 100,
//                                     color: Colors.grey[300],
//                                     child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
//                                   );
//                                 },
//                               )
//                                   : Container(
//                                 width: 100,
//                                 height: 100,
//                                 color: Colors.grey[300],
//                                 child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           // Service Details
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   serviceName,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: primaryColor,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.person, size: 14, color: accentColor),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       'by $providerName',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 12),
//                                 Container(
//                                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: primaryColor,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     '₹$hourlyRate/hr',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 24),
//                   _sectionTitle('Select Date & Time', Icons.event),
//                   SizedBox(height: 16),
//
//                   // Date Selection
//                   InkWell(
//                     onTap: () => _selectDate(context),
//                     child: Container(
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(15),
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [Colors.white, Colors.grey[50]!],
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 2,
//                             offset: Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: lightBlue,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Icon(Icons.calendar_today, color: primaryColor),
//                           ),
//                           SizedBox(width: 16),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Date',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Spacer(),
//                           Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 16),
//
//                   // Time Selection
//                   InkWell(
//                     onTap: () => _selectTime(context),
//                     child: Container(
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(15),
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [Colors.white, Colors.grey[50]!],
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 2,
//                             offset: Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: lightBlue,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Icon(Icons.access_time, color: primaryColor),
//                           ),
//                           SizedBox(width: 16),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Time',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 selectedTime.format(context),
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Spacer(),
//                           Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 24),
//                   _sectionTitle('Service Duration', Icons.timer),
//                   SizedBox(height: 16),
//
//                   // Duration Selection
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!),
//                       borderRadius: BorderRadius.circular(15),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [Colors.white, Colors.grey[50]!],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.1),
//                           spreadRadius: 1,
//                           blurRadius: 2,
//                           offset: Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: lightBlue,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Icon(Icons.hourglass_bottom, color: primaryColor),
//                             ),
//                             SizedBox(width: 16),
//                             Text(
//                               'Hours',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             InkWell(
//                               onTap: selectedDuration > 1
//                                   ? () {
//                                 setState(() {
//                                   selectedDuration--;
//                                   _calculateTotalCost();
//                                 });
//                               }
//                                   : null,
//                               child: Container(
//                                 padding: EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: selectedDuration > 1 ? primaryColor : Colors.grey[300],
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   Icons.remove,
//                                   color: Colors.white,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               width: 50,
//                               alignment: Alignment.center,
//                               child: Text(
//                                 '$selectedDuration',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                             ),
//                             InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   selectedDuration++;
//                                   _calculateTotalCost();
//                                 });
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: primaryColor,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   Icons.add,
//                                   color: Colors.white,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: 24),
//                   _sectionTitle('Notes for Service Provider', Icons.note_alt),
//                   SizedBox(height: 16),
//
//                   // Notes TextField
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.1),
//                           spreadRadius: 1,
//                           blurRadius: 2,
//                           offset: Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: TextField(
//                       controller: _notesController,
//                       decoration: InputDecoration(
//                         hintText: 'Add any specific requirements or instructions',
//                         hintStyle: TextStyle(color: Colors.grey[400]),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide(color: primaryColor, width: 2),
//                         ),
//                         contentPadding: EdgeInsets.all(16),
//                         filled: true,
//                         fillColor: Colors.white,
//                         prefixIcon: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Icon(Icons.edit_note, color: primaryColor),
//                         ),
//                       ),
//                       maxLines: 3,
//                       onChanged: (value) {
//                         setState(() {
//                           bookingNotes = value;
//                         });
//                       },
//                     ),
//                   ),
//
//                   SizedBox(height: 30), // Extra space before the bottom container
//                 ],
//               ),
//             ),
//           ),
//
//           // Bottom booking summary and action button
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 10,
//                   offset: Offset(0, -3),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: lightBlue.withOpacity(0.7),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Total Cost',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: primaryColor,
//                         ),
//                       ),
//                       Text(
//                         '₹${totalCost.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: isBooking ? null : _createBooking,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       foregroundColor: Colors.white,
//                       elevation: 5,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       disabledBackgroundColor: Colors.grey,
//                     ),
//                     child: isBooking
//                         ? SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.5,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                         : Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.check_circle_outline, size: 24,color: Colors.green,),
//                         SizedBox(width: 10),
//                         Text(
//                           'Confirm Booking',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionTitle(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, color: primaryColor, size: 22),
//         SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: primaryColor,
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:fixit/features/user/view/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../admin/models/notification_model.dart';
// Import the notification model and service


class BookingPage extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic> serviceData;
  final Map<String, dynamic> providerData;
  final List<String> serviceImages;

  const BookingPage({
    Key? key,
    required this.serviceId,
    required this.serviceData,
    required this.providerData,
    required this.serviceImages,
  }) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Color primaryColor = Color(0xff0F3966);
  final Color accentColor = Color(0xff3A8FD8); // Lighter blue for accents
  final Color lightBlue = Color(0xffD0E6FF); // Very light blue for backgrounds

  // Notification service
  final NotificationService _notificationService = NotificationService();

  DateTime selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 0);
  int selectedDuration = 1; // Default duration in hours
  double totalCost = 0;
  String bookingNotes = '';
  bool isBooking = false;

  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calculateTotalCost();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    // Get hourly rate from service data
    int hourlyRate = int.tryParse(widget.serviceData['hourly_rate']?.toString() ?? '0') ?? 0;
    totalCost = hourlyRate * selectedDuration.toDouble();
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    // Get available days from service data
    List<String> availableDays = List<String>.from(widget.serviceData['available_days'] ?? []);

    // Map day names to integers where Monday = 1, Sunday = 7
    Map<String, int> dayToNumber = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    // Convert available days to numbers
    List<int> availableDayNumbers = availableDays
        .map((day) => dayToNumber[day] ?? 0)
        .where((number) => number > 0)
        .toList();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
      selectableDayPredicate: (DateTime date) {
        // Check if the weekday is in available days
        return availableDayNumbers.contains(date.weekday);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              secondary: accentColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              secondary: accentColor,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.white,
              hourMinuteColor: primaryColor,
              dialHandColor: primaryColor,
              dialBackgroundColor: lightBlue,
              dayPeriodTextColor: primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Modified method to send notification to service provider
  Future<void> _sendNotificationToProvider(String bookingId, DateTime bookingDateTime, String paymentStatus) async {
    try {
      // Get current user data
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Get provider ID from serviceData
      String providerId = widget.serviceData['provider_id'] ?? '';

      if (providerId.isEmpty) {
        print('Error: Provider ID is empty');
        return;
      }

      // Fetch user's name from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      String userName = 'A customer';

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['name'] ?? userData['displayName'] ?? 'A customer';
      }

      // Format date and time
      String formattedDate = DateFormat('EEEE, MMMM d').format(bookingDateTime);
      String formattedTime = DateFormat('h:mm a').format(bookingDateTime);

      // Generate creative notification title
      String title = "New Booking Alert! 🎉";

      // Generate creative notification message
      String message = _createBookingNotificationMessage(
          userName: userName,
          serviceName: widget.serviceData['name'] ?? 'your service',
          formattedDate: formattedDate,
          formattedTime: formattedTime,
          duration: selectedDuration,
          totalCost: totalCost,
          paymentStatus: paymentStatus,
          notes: bookingNotes.isNotEmpty ? bookingNotes : "No special instructions"
      );

      // Send notification to the service provider with recipientId
      await _notificationService.sendNotification(
        title: title,
        message: message,
        recipientType: NotificationRecipientType.serviceProvider,
        recipientId: providerId, // Add the provider ID here
        sentBy: currentUser.uid,
        type: 'booking',
      );

      print('Notification sent to provider successfully');

    } catch (e) {
      print('Error sending notification to provider: $e');
    }
  }

  // Helper method to create a creative and descriptive notification message
  String _createBookingNotificationMessage({
    required String userName,
    required String serviceName,
    required String formattedDate,
    required String formattedTime,
    required int duration,
    required double totalCost,
    required String paymentStatus,
    required String notes
  }) {
    // Choose a random greeting from a list
    List<String> greetings = [
      "Great news!",
      "Exciting update!",
      "Hooray!",
      "Congratulations!",
      "Fantastic news!"
    ];

    // Get a random emoji set
    List<List<String>> emojiSets = [
      ["✨", "📆", "⏰", "💰"],
      ["🌟", "📅", "🕒", "💸"],
      ["🎉", "📌", "⌚", "💵"],
      ["🔔", "🗓️", "⏱️", "💼"],
      ["✅", "📋", "🕰️", "💎"]
    ];

    List<String> emojis = emojiSets[DateTime.now().millisecond % emojiSets.length];

    // Create the notification message with a conversational and engaging tone
    String message = "${greetings[DateTime.now().second % greetings.length]} $userName has booked  $serviceName service ${emojis[0]}\n\n";

    message += "${emojis[1]} Date: $formattedDate at $formattedTime\n";
    message += "Duration: $duration ${duration > 1 ? 'hours' : 'hour'}\n\n";



    // Add a random closing message
    List<String> closings = [
      "Get ready for another satisfied customer!",
      "We hope you're excited for this booking!",
      "Your expertise is in demand!",
      "Another opportunity to showcase your fantastic service!",
      "Time to shine with your excellent service!"
    ];

    message += closings[DateTime.now().minute % closings.length];

    return message;
  }

  // // New method to send notification to service provider
  // Future<void> _sendNotificationToProvider(String bookingId, DateTime bookingDateTime, String paymentStatus) async {
  //   try {
  //     // Get current user data
  //     User? currentUser = _auth.currentUser;
  //     if (currentUser == null) return;
  //
  //     // Fetch user's name from Firestore
  //     DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
  //     String userName = 'A customer';
  //
  //     if (userDoc.exists && userDoc.data() != null) {
  //       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
  //       userName = userData['name'] ?? userData['displayName'] ?? 'A customer';
  //     }
  //
  //     // Format date and time
  //     String formattedDate = DateFormat('EEEE, MMMM d').format(bookingDateTime);
  //     String formattedTime = DateFormat('h:mm a').format(bookingDateTime);
  //
  //     // Generate creative notification title
  //     String title = "New Booking Alert! 🎉";
  //
  //     // Generate creative notification message
  //     String message = _createBookingNotificationMessage(
  //         userName: userName,
  //         serviceName: widget.serviceData['name'] ?? 'your service',
  //         formattedDate: formattedDate,
  //         formattedTime: formattedTime,
  //         duration: selectedDuration,
  //         totalCost: totalCost,
  //         paymentStatus: paymentStatus,
  //         notes: bookingNotes.isNotEmpty ? bookingNotes : "No special instructions"
  //     );
  //
  //     // Send notification to the service provider
  //     await _notificationService.sendNotification(
  //       title: title,
  //       message: message,
  //       recipientType: NotificationRecipientType.serviceProvider,
  //       sentBy: currentUser.uid,
  //       type: 'booking',
  //     );
  //
  //     print('Notification sent to provider successfully');
  //
  //   } catch (e) {
  //     print('Error sending notification to provider: $e');
  //   }
  // }
  //
  // // Helper method to create a creative and descriptive notification message
  // String _createBookingNotificationMessage({
  //   required String userName,
  //   required String serviceName,
  //   required String formattedDate,
  //   required String formattedTime,
  //   required int duration,
  //   required double totalCost,
  //   required String paymentStatus,
  //   required String notes
  // }) {
  //   // Choose a random greeting from a list
  //   List<String> greetings = [
  //     "Great news!",
  //     "Exciting update!",
  //     "Hooray!",
  //     "Congratulations!",
  //     "Fantastic news!"
  //   ];
  //
  //   // Get a random emoji set
  //   List<List<String>> emojiSets = [
  //     ["✨", "📆", "⏰", "💰"],
  //     ["🌟", "📅", "🕒", "💸"],
  //     ["🎉", "📌", "⌚", "💵"],
  //     ["🔔", "🗓️", "⏱️", "💼"],
  //     ["✅", "📋", "🕰️", "💎"]
  //   ];
  //
  //   List<String> emojis = emojiSets[DateTime.now().millisecond % emojiSets.length];
  //
  //   // Create the notification message with a conversational and engaging tone
  //   String message = "${greetings[DateTime.now().second % greetings.length]} $userName has booked  $serviceName service ${emojis[0]}\n\n";
  //
  //   message += "${emojis[1]} Date: $formattedDate at $formattedTime\n";
  //   message += "Duration: $duration ${duration > 1 ? 'hours' : 'hour'}\n\n";
  //
  //
  //
  //   // Add a random closing message
  //   List<String> closings = [
  //     "Get ready for another satisfied customer!",
  //     "We hope you're excited for this booking!",
  //     "Your expertise is in demand!",
  //     "Another opportunity to showcase your fantastic service!",
  //     "Time to shine with your excellent service!"
  //   ];
  //
  //   message += closings[DateTime.now().minute % closings.length];
  //
  //   return message;
  // }

  Future<void> _createBooking() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to book a service'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      isBooking = true;
    });

    try {
      // Format date and time for Firestore
      final DateTime bookingDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Create booking document
      DocumentReference bookingRef = await _firestore.collection('bookings').add({
        'service_id': widget.serviceId,
        'provider_id': widget.serviceData['provider_id'],
        'user_id': _auth.currentUser!.uid,
        'service_name': widget.serviceData['name'] ?? 'Service',
        'provider_name': widget.providerData['name'] ?? 'Service Provider',
        'booking_date': Timestamp.fromDate(bookingDateTime),
        'duration_hours': selectedDuration,
        'total_cost': totalCost,
        'status': 'pending_payment', // Changed to indicate payment is needed
        'notes': bookingNotes,
        'created_at': FieldValue.serverTimestamp(),
        'hourly_rate': widget.serviceData['hourly_rate'],
        'payment_status': 'unpaid', // Add payment status field
      });

      // Get the booking ID
      String bookingId = bookingRef.id;

      // Send notification to service provider
      await _sendNotificationToProvider(bookingId, bookingDateTime, 'unpaid');

      // Navigate to PaymentPage instead of showing success message
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            providerId: widget.serviceData['provider_id'],
            serviceId: widget.serviceId,
            bookingId: bookingId,
            hourlyRate: double.parse(widget.serviceData['hourly_rate'].toString()), // Convert to double
            hours: selectedDuration,
            totalAmount: totalCost,
            serviceName: widget.serviceData['name'] ?? 'Service',
            providerName: widget.providerData['name'] ?? 'Service Provider',
            bookingDate: bookingDateTime,
          ),
        ),
      );

    } catch (e) {
      print('Error creating booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to create booking. Please try again.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        isBooking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String providerName = widget.providerData['name'] ?? 'Service Provider';
    String serviceName = widget.serviceData['name'] ?? 'Service';
    String hourlyRate = widget.serviceData['hourly_rate']?.toString() ?? '0';

    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
    leading: IconButton(
    icon: Icon(Icons.arrow_back_ios_new),
    onPressed: () => Navigator.pop(context),
    ),
    title: AppBarTitle(text: "Book Service"),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
    bottom: Radius.circular(20),
    ),
    ),
    ),
    body: Column(
    children: [
    // Decorative curve
    Container(
    height: 20,
    color: Colors.transparent,
    child: Container(
    decoration: BoxDecoration(
    color: primaryColor.withOpacity(0.1),
    borderRadius: BorderRadius.vertical(
    bottom: Radius.circular(100),
    ),
    ),
    ),
    ),
    Expanded(
    child: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Service Summary Card
    Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    ),
    child: Container(
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    Colors.white,
    lightBlue,
    ],
    ),
    ),
    padding: const EdgeInsets.all(16.0),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Service Image
    ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
    decoration: BoxDecoration(
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.2),
    spreadRadius: 1,
    blurRadius: 3,
    offset: Offset(0, 2),
    ),
    ],
    ),
    child: widget.serviceImages.isNotEmpty
    ? Image.network(
    widget.serviceImages[0],
    width: 100,
    height: 100,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
    return Container(
    width: 100,
    height: 100,
    color: Colors.grey[300],
    child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
    );
    },
    )
        : Container(
    width: 100,
    height: 100,
    color: Colors.grey[300],
    child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
    ),
    ),
    ),
    SizedBox(width: 16),
    // Service Details
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    serviceName,
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    ),
    ),
    SizedBox(height: 4),
    Row(
    children: [
    Icon(Icons.person, size: 14, color: accentColor),
    SizedBox(width: 4),
    Text(
    'by $providerName',
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
    ),
    ),
    ],
    ),
    SizedBox(height: 12),
    Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
    '₹$hourlyRate/hr',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),

    SizedBox(height: 24),
    _sectionTitle('Select Date & Time', Icons.event),
    SizedBox(height: 16),

    // Date Selection
    InkWell(
    onTap: () => _selectDate(context),
    child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
    border: Border.all(color: Colors.grey[300]!),
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Colors.grey[50]!],
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.1),
    spreadRadius: 1,
    blurRadius: 2,
    offset: Offset(0, 1),
    ),
    ],
    ),
    child: Row(
    children: [
    Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: lightBlue,
    borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(Icons.calendar_today, color: primaryColor),
    ),
    SizedBox(width: 16),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Date',
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
    ),
    ),
    SizedBox(height: 4),
    Text(
    DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    ],
    ),
    Spacer(),
    Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
    ],
    ),
    ),
    ),

    SizedBox(height: 16),

    // Time Selection
    InkWell(
    onTap: () => _selectTime(context),
    child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
    border: Border.all(color: Colors.grey[300]!),
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Colors.grey[50]!],
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.1),
    spreadRadius: 1,
    blurRadius: 2,
    offset: Offset(0, 1),
    ),
    ],
    ),
    child: Row(
    children: [
    Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: lightBlue,
    borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(Icons.access_time, color: primaryColor),
    ),
    SizedBox(width: 16),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Time',
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
    ),
    ),
    SizedBox(height: 4),
    Text(
    selectedTime.format(context),
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    ],
    ),
    Spacer(),
    Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
    ],
    ),
    ),
    ),

    SizedBox(height: 24),
    _sectionTitle('Service Duration', Icons.timer),
    SizedBox(height: 16),

    // Duration Selection
    Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
    border: Border.all(color: Colors.grey[300]!),
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Colors.grey[50]!],
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.1),
    spreadRadius: 1,
    blurRadius: 2,
    offset: Offset(0, 1),
    ),
    ],
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Row(
    children: [
    Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: lightBlue,
    borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(Icons.hourglass_bottom, color: primaryColor),
    ),
    SizedBox(width: 16),
    Text(
    'Hours',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    ],
    ),
    Row(
    children: [
    InkWell(
    onTap: selectedDuration > 1
    ? () {
    setState(() {
    selectedDuration--;
    _calculateTotalCost();
    });
    }
        : null,
    child: Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: selectedDuration > 1 ? primaryColor : Colors.grey[300],
    shape: BoxShape.circle,
    ),
    child: Icon(
    Icons.remove,
    color: Colors.white,
    size: 18,
    ),
    ),
    ),
    Container(
    width: 50,
    alignment: Alignment.center,
    child: Text(
    '$selectedDuration',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    ),
    ),
    ),
    InkWell(
    onTap: () {
    setState(() {
    selectedDuration++;
    _calculateTotalCost();
    });
    },
    child: Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: primaryColor,
    shape: BoxShape.circle,
    ),
    child: Icon(
    Icons.add,
    color: Colors.white,
    size: 18,
    ),
    ),
    ),
    ],
    ),
    ],
    ),
    ),

    SizedBox(height: 24),
    _sectionTitle('Notes for Service Provider', Icons.note_alt),
    SizedBox(height: 16),

    // Notes TextField
    Container(
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.1),
    spreadRadius: 1,
    blurRadius: 2,
    offset: Offset(0, 1),
    ),
    ],
    ),
    child: TextField(
    controller: _notesController,
    decoration: InputDecoration(
    hintText: 'Add any specific requirements or instructions',
    hintStyle: TextStyle(color: Colors.grey[400]),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    contentPadding: EdgeInsets.all(16),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Icon(Icons.edit_note, color: primaryColor),
    ),
    ),
    maxLines: 3,
    onChanged: (value) {
    setState(() {
    bookingNotes = value;
    });
    },
    ),
    ),

    SizedBox(height: 30), // Extra space before the bottom container
    ],
    ),
    ),
    ),

    // Bottom booking summary and action button
    Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.3),
    spreadRadius: 1,
    blurRadius: 10,
    offset: Offset(0, -3),
    ),
    ],
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: lightBlue.withOpacity(0.7),
    borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Total Cost',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    ),
    ),
    Text(
    '₹${totalCost.toStringAsFixed(0)}',
    style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    ),
    ),
    ],
    ),
    ),
    SizedBox(height: 20),
    SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
    onPressed: isBooking ? null : _createBooking,
    style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 5,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
    ),
    disabledBackgroundColor: Colors.grey,
    ),
    child: isBooking
    ? SizedBox(
    height: 24,
    width: 24,
    child: CircularProgressIndicator(
    strokeWidth: 2.5,
    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ),
    )
        : Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.check_circle_outline, size: 24, color: Colors.green),
    SizedBox(width: 8),
    Text(
    'Proceed to Payment',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    ),
      SizedBox(height: 12),
      // Add a note about payment
      Text(
        'You will be directed to payment after booking',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    ],
    ),
    ),
    ],
    ),
    );
  }

  // Helper method to create section titles
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}

