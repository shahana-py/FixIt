// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// class PaymentPage extends StatefulWidget {
//   final String bookingId;
//   final double totalAmount;
//   final String serviceName;
//   final String providerName;
//   final DateTime bookingDate;
//   final List<String>? serviceImages;
//
//   const PaymentPage({
//     Key? key,
//     required this.bookingId,
//     required this.totalAmount,
//     required this.serviceName,
//     required this.providerName,
//     required this.bookingDate,
//     this.serviceImages,
//   }) : super(key: key);
//
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late Razorpay _razorpay;
//
//   // Theme colors
//   final Color primaryColor = Color(0xff0F3966); // Modern blue
//   final Color secondaryColor = Color(0xFF6B7280); // Neutral gray
//   final Color accentColor = Color(0xFFECF2FF); // Light blue bg
//   final Color surfaceColor = Colors.white;
//   final Color errorColor = Color(0xFFEF4444); // Error red
//   final Color successColor = Color(0xFF10B981); // Success green
//
//   bool isLoading = true;
//   bool isProcessingPayment = false;
//   Map<String, dynamic> userData = {};
//   String userAddress = '';
//   String? serviceImageUrl;
//
//   // For manual address input if user wants to change
//   final TextEditingController _addressController = TextEditingController();
//   bool editingAddress = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//
//     _fetchUserData();
//     _fetchServiceImage();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchUserData() async {
//     try {
//       String? userId = _auth.currentUser?.uid;
//       if (userId != null) {
//         DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
//
//         if (userDoc.exists) {
//           Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
//           setState(() {
//             userData = data;
//             userAddress = data['address'] ?? '';
//             _addressController.text = userAddress;
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           _showMessage('User data not found.', isError: true);
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         _showMessage('User not authenticated.', isError: true);
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       _showMessage('Error fetching user data: $e', isError: true);
//     }
//   }
//
//   Future<void> _fetchServiceImage() async {
//     if (widget.serviceImages != null && widget.serviceImages!.isNotEmpty) {
//       setState(() {
//         serviceImageUrl = widget.serviceImages![0];
//       });
//       return;
//     }
//
//     try {
//       // Try to fetch service image from Firestore if not provided
//       DocumentSnapshot serviceDoc = await _firestore
//           .collection('services')
//           .doc(widget.bookingId)
//           .get();
//
//       if (serviceDoc.exists) {
//         Map<String, dynamic> data = serviceDoc.data() as Map<String, dynamic>;
//         List<String> images = List<String>.from(data['images'] ?? []);
//
//         if (images.isNotEmpty) {
//           setState(() {
//             serviceImageUrl = images[0];
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching service image: $e');
//     }
//   }
//
//   void _startPayment() {
//     if (userAddress.isEmpty) {
//       _showMessage('Please provide your address before proceeding to payment.', isError: true);
//       return;
//     }
//
//     setState(() {
//       isProcessingPayment = true;
//     });
//
//     try {
//       var options = {
//         'key': 'rzp_test_xwcE99NTPVZiHX', // Razorpay test key
//         'amount': (widget.totalAmount * 100).toInt(), // Amount in paisa
//         'name': 'FixIt App',
//         'description': widget.serviceName,
//         'prefill': {
//           'contact': userData['phone'] ?? '',
//           'email': userData['email'] ?? '',
//         },
//         'theme': {
//           'color': '#2563EB',
//         },
//         'external': {
//           'wallets': ['paytm']
//         }
//       };
//
//       _razorpay.open(options);
//     } catch (e) {
//       _showMessage('Error initiating payment: $e', isError: true);
//       setState(() {
//         isProcessingPayment = false;
//       });
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     try {
//       // Update the booking document with payment details
//       await _firestore.collection('bookings').doc(widget.bookingId).update({
//         'payment_status': 'paid',
//         'status': 'confirmed',
//         'payment_id': response.paymentId,
//         'payment_date': FieldValue.serverTimestamp(),
//         'confirmed_address': userAddress,
//       });
//
//       // Show success message
//       _showMessage("Payment completed successfully!", isError: false);
//
//       // Navigate to success page or back to home
//       Navigator.of(context).popUntil((route) => route.isFirst); // Goes back to the first route in stack
//
//     } catch (e) {
//       _showMessage('Error updating payment status: $e', isError: true);
//     } finally {
//       setState(() {
//         isProcessingPayment = false;
//       });
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     _showMessage('Payment failed: ${response.message}', isError: true);
//     setState(() {
//       isProcessingPayment = false;
//     });
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     _showMessage("External wallet selected: ${response.walletName}", isError: false);
//     setState(() {
//       isProcessingPayment = false;
//     });
//   }
//
//   void _showMessage(String message, {required bool isError}) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 2,
//       backgroundColor: isError ? errorColor : successColor,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.white),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Checkout",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: isLoading
//           ? Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//         ),
//       )
//           : SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: BouncingScrollPhysics(),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 20),
//
//                       // Order Steps
//                       _buildOrderStepper(),
//
//                       SizedBox(height: 24),
//
//                       // Service Summary Card
//                       _buildServiceSummaryCard(),
//
//                       SizedBox(height: 24),
//
//                       // Booking Date & Time
//                       _sectionTitle('Booking Details', Icons.calendar_today_rounded),
//                       SizedBox(height: 12),
//                       _buildBookingDetails(),
//
//                       SizedBox(height: 24),
//
//                       // Address Confirmation
//                       _sectionTitle('Service Address', Icons.location_on_rounded),
//                       SizedBox(height: 12),
//                       _buildAddressSection(),
//
//                       SizedBox(height: 24),
//
//                       // Payment Summary
//                       _sectionTitle('Payment Summary', Icons.receipt_long_rounded),
//                       SizedBox(height: 12),
//                       _buildPaymentSummary(),
//
//                       SizedBox(height: 24),
//
//                       // Payment Methods
//                       _sectionTitle('Payment Methods', Icons.payment_rounded),
//                       SizedBox(height: 12),
//                       _buildPaymentMethods(),
//
//                       SizedBox(height: 100), // Space for bottom button
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomSheet: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               spreadRadius: 1,
//               blurRadius: 10,
//               offset: Offset(0, -4),
//             ),
//           ],
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         child: SafeArea(
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Total Amount',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: secondaryColor,
//                       ),
//                     ),
//                     Text(
//                       '₹${widget.totalAmount.toStringAsFixed(0)}',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: isProcessingPayment ? null : _startPayment,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor: secondaryColor.withOpacity(0.5),
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                   ),
//                   child: isProcessingPayment
//                       ? SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                       : Text(
//                     'Pay Now',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderStepper() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           _stepCircle(1, true, "Cart"),
//           _stepLine(true),
//           _stepCircle(2, true, "Address"),
//           _stepLine(false),
//           _stepCircle(3, false, "Payment"),
//         ],
//       ),
//     );
//   }
//
//   Widget _stepCircle(int step, bool isCompleted, String label) {
//     return Expanded(
//       child: Column(
//         children: [
//           Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: isCompleted ? primaryColor : Colors.grey[300],
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Icon(
//                 isCompleted ? Icons.check : null,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: isCompleted ? primaryColor : secondaryColor,
//               fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _stepLine(bool isCompleted) {
//     return Expanded(
//       child: Container(
//         height: 2,
//         color: isCompleted ? primaryColor : Colors.grey[300],
//       ),
//     );
//   }
//
//   Widget _buildServiceSummaryCard() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Service Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: serviceImageUrl != null
//                   ? Image.network(
//                 serviceImageUrl!,
//                 width: 80,
//                 height: 80,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     width: 80,
//                     height: 80,
//                     color: accentColor,
//                     child: Icon(Icons.home_repair_service, color: primaryColor),
//                   );
//                 },
//               )
//                   : Container(
//                 width: 80,
//                 height: 80,
//                 color: accentColor,
//                 child: Icon(Icons.home_repair_service, color: primaryColor),
//               ),
//             ),
//             SizedBox(width: 16),
//             // Service Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.serviceName,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Provider: ${widget.providerName}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: secondaryColor,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: accentColor,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           'Home Service',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: primaryColor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookingDetails() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(Icons.event_available_rounded, color: primaryColor),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     DateFormat('EEEE, MMM d, yyyy').format(widget.bookingDate),
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     DateFormat('h:mm a').format(widget.bookingDate),
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: secondaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddressSection() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.location_on_rounded, color: primaryColor),
//                     SizedBox(width: 12),
//                     Text(
//                       editingAddress ? 'Enter New Address' : 'Service Address',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       if (editingAddress) {
//                         // Save the new address
//                         userAddress = _addressController.text;
//                         editingAddress = false;
//                       } else {
//                         editingAddress = true;
//                       }
//                     });
//                   },
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     minimumSize: Size(60, 30),
//                     foregroundColor: primaryColor,
//                   ),
//                   child: Text(
//                     editingAddress ? 'Save' : 'Edit',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             editingAddress
//                 ? TextField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 hintText: 'Enter your full address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: primaryColor, width: 1.5),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//               ),
//               maxLines: 3,
//             )
//                 : Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: accentColor,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 userAddress.isEmpty
//                     ? 'No address found. Please add your address.'
//                     : userAddress,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentSummary() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _paymentRow('Service Fee', '₹${widget.totalAmount.toStringAsFixed(0)}'),
//             SizedBox(height: 10),
//             _paymentRow('Convenience Fee', '₹0', isSecondary: true),
//             SizedBox(height: 10),
//             _paymentRow('Tax', 'Included', isSecondary: true),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
//             ),
//
//             _paymentRow(
//               'Total Amount',
//               '₹${widget.totalAmount.toStringAsFixed(0)}',
//               isTotal: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethods() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _paymentMethodOption(
//               icon: Icons.credit_card,
//               title: 'Credit / Debit Card',
//               subtitle: 'Visa, Mastercard, RuPay & more',
//               isSelected: true,
//             ),
//             Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
//             _paymentMethodOption(
//               icon: Icons.account_balance,
//               title: 'UPI',
//               subtitle: 'Google Pay, PhonePe, BHIM & more',
//               isSelected: false,
//             ),
//             Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
//             _paymentMethodOption(
//               icon: Icons.account_balance_wallet,
//               title: 'Wallets',
//               subtitle: 'Paytm, PhonePe & more',
//               isSelected: false,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _paymentMethodOption({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool isSelected,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12.0),
//       child: Row(
//         children: [
//           Icon(icon, color: primaryColor),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: secondaryColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Radio(
//             value: true,
//             groupValue: isSelected,
//             onChanged: (value) {},
//             activeColor: primaryColor,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionTitle(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, color: primaryColor, size: 20),
//         SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _paymentRow(String title, String amount, {bool isTotal = false, bool isSecondary = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: isTotal ? 16 : 14,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             color: isSecondary ? secondaryColor : Colors.black87,
//           ),
//         ),
//         Text(
//           amount,
//           style: TextStyle(
//             fontSize: isTotal ? 18 : 14,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//             color: isTotal ? primaryColor : (isSecondary ? secondaryColor : Colors.black87),
//           ),
//         ),
//       ],
//     );
//   }
// }


//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// class PaymentPage extends StatefulWidget {
//   final String bookingId;
//   final double totalAmount;
//   final String serviceName;
//   final String providerName;
//   final DateTime bookingDate;
//   final int hours;
//   final double hourlyRate;
//   final List<String>? serviceImages;
//
//   const PaymentPage({
//     Key? key,
//     required this.bookingId,
//     required this.totalAmount,
//     required this.serviceName,
//     required this.providerName,
//     required this.bookingDate,
//     required this.hours,
//     required this.hourlyRate,
//     this.serviceImages,
//   }) : super(key: key);
//
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late Razorpay _razorpay;
//   // Add these variables
//   bool isLocationShared = false;
//   Map<String, dynamic>? userLocation;
//   bool isLoadingLocation = false;
//
//   // Theme colors
//   final Color primaryColor = Color(0xff0F3966); // Modern blue
//   final Color secondaryColor = Color(0xFF6B7280); // Neutral gray
//   final Color accentColor = Color(0xFFECF2FF); // Light blue bg
//   final Color surfaceColor = Colors.white;
//   final Color errorColor = Color(0xFFEF4444); // Error red
//   final Color successColor = Color(0xFF10B981); // Success green
//
//   bool isLoading = true;
//   bool isProcessingPayment = false;
//   Map<String, dynamic> userData = {};
//   String userAddress = '';
//   String? serviceImageUrl;
//   String selectedPaymentMethod = 'card'; // 'card', 'upi', 'wallet'
//
//   // For manual address input if user wants to change
//   final TextEditingController _addressController = TextEditingController();
//   bool editingAddress = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//
//     _fetchUserData();
//     _fetchServiceImage();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchUserData() async {
//     try {
//       String? userId = _auth.currentUser?.uid;
//       if (userId != null) {
//         DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
//
//         if (userDoc.exists) {
//           Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
//           setState(() {
//             userData = data;
//             userAddress = data['address'] ?? '';
//             _addressController.text = userAddress;
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           _showMessage('User data not found.', isError: true);
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         _showMessage('User not authenticated.', isError: true);
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       _showMessage('Error fetching user data: $e', isError: true);
//     }
//   }
//
//   Future<void> _fetchServiceImage() async {
//     try {
//       // First try to get from serviceImages if provided
//       if (widget.serviceImages != null && widget.serviceImages!.isNotEmpty) {
//         setState(() {
//           serviceImageUrl = widget.serviceImages![0];
//         });
//         return;
//       }
//
//       // If not provided, try to fetch from services collection
//       DocumentSnapshot serviceDoc = await _firestore
//           .collection('services')
//           .where('provider_id', isEqualTo: widget.providerName) // Assuming providerName is the provider_id
//           .where('name', isEqualTo: widget.serviceName)
//           .limit(1)
//           .get()
//           .then((snapshot) => snapshot.docs.first);
//
//       if (serviceDoc.exists) {
//         Map<String, dynamic> data = serviceDoc.data() as Map<String, dynamic>;
//         if (data.containsKey('work_sample')) {
//           setState(() {
//             serviceImageUrl = data['work_sample'];
//           });
//         } else if (data.containsKey('images') && (data['images'] as List).isNotEmpty) {
//           setState(() {
//             serviceImageUrl = data['images'][0];
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching service image: $e');
//       // If all fails, set a default image
//       setState(() {
//         serviceImageUrl = 'https://via.placeholder.com/150?text=No+Image';
//       });
//     }
//   }
//
//   void _startPayment() {
//     if (userAddress.isEmpty) {
//       _showMessage('Please provide your address before proceeding to payment.', isError: true);
//       return;
//     }
//
//     setState(() {
//       isProcessingPayment = true;
//     });
//
//     try {
//       var options = {
//         'key': 'rzp_test_xwcE99NTPVZiHX', // Razorpay test key
//         'amount': (widget.totalAmount * 100).toInt(), // Amount in paisa
//         'name': 'FixIt App',
//         'description': '${widget.serviceName} for ${widget.hours} hours',
//         'prefill': {
//           'contact': userData['phone'] ?? '',
//           'email': userData['email'] ?? '',
//         },
//         'theme': {
//           'color': '#2563EB',
//         },
//         'external': {
//           'wallets': ['paytm']
//         }
//       };
//
//       // Add payment method specific options
//       if (selectedPaymentMethod == 'upi') {
//         options['method'] = {'netbanking': true, 'upi': true};
//       } else if (selectedPaymentMethod == 'wallet') {
//         options['method'] = {'wallet': true};
//       }
//
//       _razorpay.open(options);
//     } catch (e) {
//       _showMessage('Error initiating payment: $e', isError: true);
//       setState(() {
//         isProcessingPayment = false;
//       });
//     }
//   }
//
//   // Add this method to get current location
//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       isLoadingLocation = true;
//     });
//
//     try {
//       // Check if location services are enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _showMessage('Location services are disabled. Please enable them.', isError: true);
//         setState(() {
//           isLoadingLocation = false;
//         });
//         return;
//       }
//
//       // Check for location permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showMessage('Location permissions are denied', isError: true);
//           setState(() {
//             isLoadingLocation = false;
//           });
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         _showMessage('Location permissions are permanently denied, we cannot request permissions.', isError: true);
//         setState(() {
//           isLoadingLocation = false;
//         });
//         return;
//       }
//
//       // Get current position
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high
//       );
//
//       // Get address from coordinates
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//           position.latitude,
//           position.longitude
//       );
//
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         String address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
//
//         setState(() {
//           userLocation = {
//             'latitude': position.latitude,
//             'longitude': position.longitude,
//             'address': address,
//             'timestamp': FieldValue.serverTimestamp(),
//           };
//           isLocationShared = true;
//           isLoadingLocation = false;
//         });
//
//         _showMessage('Location shared successfully!', isError: false);
//       }
//     } catch (e) {
//       print('Error getting location: $e');
//       _showMessage('Failed to get location: $e', isError: true);
//       setState(() {
//         isLoadingLocation = false;
//       });
//     }
//   }
//
//   // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//   //   try {
//   //     // Update the booking document with payment details
//   //     await _firestore.collection('bookings').doc(widget.bookingId).update({
//   //       'payment_status': 'paid',
//   //       'status': 'confirmed',
//   //       'payment_id': response.paymentId,
//   //       'payment_date': FieldValue.serverTimestamp(),
//   //       'confirmed_address': userAddress,
//   //       'payment_method': selectedPaymentMethod,
//   //     });
//   //
//   //     // Show success message
//   //     _showMessage("Payment completed successfully!", isError: false);
//   //
//   //     // Navigate to success page or back to home
//   //     Navigator.of(context).popUntil((route) => route.isFirst); // Goes back to the first route in stack
//   //
//   //   } catch (e) {
//   //     _showMessage('Error updating payment status: $e', isError: true);
//   //   } finally {
//   //     setState(() {
//   //       isProcessingPayment = false;
//   //     });
//   //   }
//   // }
//
//   // Modify your _handlePaymentSuccess method to include location
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     try {
//       // Create update data map
//       Map<String, dynamic> updateData = {
//         'payment_status': 'paid',
//         'status': 'confirmed',
//         'payment_id': response.paymentId,
//         'payment_date': FieldValue.serverTimestamp(),
//         'confirmed_address': userAddress,
//         'payment_method': selectedPaymentMethod,
//       };
//
//       // Add location data if available
//       if (userLocation != null) {
//         updateData['user_location'] = userLocation;
//       }
//
//       // Update the booking document with payment details
//       await _firestore.collection('bookings').doc(widget.bookingId).update(updateData);
//
//       // Show success message
//       _showMessage("Payment completed successfully!", isError: false);
//
//       // Navigate to success page or back to home
//       Navigator.of(context).popUntil((route) => route.isFirst);
//
//     } catch (e) {
//       _showMessage('Error updating payment status: $e', isError: true);
//     } finally {
//       setState(() {
//         isProcessingPayment = false;
//       });
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     _showMessage('Payment failed: ${response.message}', isError: true);
//     setState(() {
//       isProcessingPayment = false;
//     });
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     _showMessage("External wallet selected: ${response.walletName}", isError: false);
//     setState(() {
//       isProcessingPayment = false;
//     });
//   }
//
//   void _showMessage(String message, {required bool isError}) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 2,
//       backgroundColor: isError ? errorColor : successColor,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.white),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Review Booking",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: isLoading
//           ? Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//         ),
//       )
//           : SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: BouncingScrollPhysics(),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 20),
//
//                       // Order Steps
//                       _buildOrderStepper(),
//
//                       SizedBox(height: 24),
//
//                       // Service Summary Card
//                       _buildServiceSummaryCard(),
//
//                       SizedBox(height: 24),
//
//                       // Booking Date & Time
//                       _sectionTitle('Booking Details', Icons.calendar_today_rounded),
//                       SizedBox(height: 12),
//                       _buildBookingDetails(),
//
//                       SizedBox(height: 24),
//
//                       // Address Confirmation
//                       _sectionTitle('Service Address', Icons.location_on_rounded),
//                       SizedBox(height: 12),
//                       _buildAddressSection(),
//
//                       SizedBox(height: 24),
//
//                       // _sectionTitle('Location Sharing', Icons.share_location),
//                       // SizedBox(height: 12),
//                       // _buildLocationSharingSection(),
//
//                       // Payment Summary
//                       _sectionTitle('Payment Summary', Icons.receipt_long_rounded),
//                       SizedBox(height: 12),
//                       _buildPaymentSummary(),
//
//                       // SizedBox(height: 24),
//                       //
//                       // // Payment Methods
//                       // _sectionTitle('Payment Methods', Icons.payment_rounded),
//                       // SizedBox(height: 12),
//                       // _buildPaymentMethods(),
//
//                       SizedBox(height: 100), // Space for bottom button
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomSheet: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               spreadRadius: 1,
//               blurRadius: 10,
//               offset: Offset(0, -4),
//             ),
//           ],
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         child: SafeArea(
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Total Amount',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: secondaryColor,
//                       ),
//                     ),
//                     Text(
//                       '₹${widget.totalAmount.toStringAsFixed(0)}',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: isProcessingPayment ? null : _startPayment,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor: secondaryColor.withOpacity(0.5),
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                   ),
//                   child: isProcessingPayment
//                       ? SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                       : Text(
//                     'Pay Now',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderStepper() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           _stepCircle(1, true, "Cart"),
//           _stepLine(true),
//           _stepCircle(2, true, "Review"),
//           _stepLine(false),
//           _stepCircle(3, false, "Payment"),
//         ],
//       ),
//     );
//   }
//
//   Widget _stepCircle(int step, bool isCompleted, String label) {
//     return Expanded(
//       child: Column(
//         children: [
//           Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: isCompleted ? primaryColor : Colors.grey[300],
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Icon(
//                 isCompleted ? Icons.check : null,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: isCompleted ? primaryColor : secondaryColor,
//               fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _stepLine(bool isCompleted) {
//     return Expanded(
//       child: Container(
//         height: 2,
//         color: isCompleted ? primaryColor : Colors.grey[300],
//       ),
//     );
//   }
//
//   Widget _buildServiceSummaryCard() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Service Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 child: serviceImageUrl != null
//                     ? Image.network(
//                   serviceImageUrl!,
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       color: accentColor,
//                       child: Icon(Icons.home_repair_service, color: primaryColor),
//                     );
//                   },
//                   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Center(
//                       child: CircularProgressIndicator(
//                         value: loadingProgress.expectedTotalBytes != null
//                             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                             : null,
//                       ),
//                     );
//                   },
//                 )
//                     : Container(
//                   color: accentColor,
//                   child: Icon(Icons.home_repair_service, color: primaryColor),
//                 ),
//               ),
//             ),
//             SizedBox(width: 16),
//             // Service Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.serviceName,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Provider: ${widget.providerName}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: secondaryColor,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: accentColor,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           'Home Service',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: primaryColor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookingDetails() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(Icons.event_available_rounded, color: primaryColor),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     DateFormat('EEEE, MMM d, yyyy').format(widget.bookingDate),
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     DateFormat('h:mm a').format(widget.bookingDate),
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: secondaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddressSection() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.location_on_rounded, color: primaryColor),
//                     SizedBox(width: 12),
//                     Text(
//                       editingAddress ? 'Enter New Address' : 'Service Address',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       if (editingAddress) {
//                         // Save the new address
//                         userAddress = _addressController.text;
//                         editingAddress = false;
//                       } else {
//                         editingAddress = true;
//                       }
//                     });
//                   },
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     minimumSize: Size(60, 30),
//                     foregroundColor: primaryColor,
//                   ),
//                   child: Text(
//                     editingAddress ? 'Save' : 'Edit',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             editingAddress
//                 ? TextField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 hintText: 'Enter your full address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: primaryColor, width: 1.5),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//               ),
//               maxLines: 3,
//             )
//                 : Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: accentColor,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 userAddress.isEmpty
//                     ? 'No address found. Please add your address.'
//                     : userAddress,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentSummary() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _paymentRow('Service Fee', '₹${widget.hourlyRate}/hr'),
//             SizedBox(height: 10),
//             _paymentRow('Service Duration', '${widget.hours} hrs', isSecondary: true),
//             SizedBox(height: 10),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
//             ),
//
//             _paymentRow(
//               'Total Amount',
//               '₹${widget.totalAmount.toStringAsFixed(0)}',
//               isTotal: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethods() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _paymentMethodOption(
//               icon: Icons.credit_card,
//               title: 'Credit / Debit Card',
//               subtitle: 'Visa, Mastercard, RuPay & more',
//               isSelected: selectedPaymentMethod == 'card',
//               onTap: () {
//                 setState(() {
//                   selectedPaymentMethod = 'card';
//                 });
//               },
//             ),
//             Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
//             _paymentMethodOption(
//               icon: Icons.account_balance,
//               title: 'UPI',
//               subtitle: 'Google Pay, PhonePe, BHIM & more',
//               isSelected: selectedPaymentMethod == 'upi',
//               onTap: () {
//                 setState(() {
//                   selectedPaymentMethod = 'upi';
//                 });
//               },
//             ),
//             Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
//             _paymentMethodOption(
//               icon: Icons.account_balance_wallet,
//               title: 'Wallets',
//               subtitle: 'Paytm, PhonePe & more',
//               isSelected: selectedPaymentMethod == 'wallet',
//               onTap: () {
//                 setState(() {
//                   selectedPaymentMethod = 'wallet';
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _paymentMethodOption({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12.0),
//         child: Row(
//           children: [
//             Icon(icon, color: primaryColor),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: secondaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Radio(
//               value: true,
//               groupValue: isSelected,
//               onChanged: (value) => onTap(),
//               activeColor: primaryColor,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _sectionTitle(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, color: primaryColor, size: 20),
//         SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _paymentRow(String title, String amount, {bool isTotal = false, bool isSecondary = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: isTotal ? 16 : 14,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             color: isSecondary ? secondaryColor : Colors.black87,
//           ),
//         ),
//         Text(
//           amount,
//           style: TextStyle(
//             fontSize: isTotal ? 18 : 14,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//             color: isTotal ? primaryColor : (isSecondary ? secondaryColor : Colors.black87),
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildLocationSharingSection() {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.my_location, color: primaryColor),
//                 SizedBox(width: 12),
//                 Text(
//                   'Share Your Location',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Text(
//               'Sharing your precise location helps the service provider find your address easily.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: secondaryColor,
//               ),
//             ),
//             SizedBox(height: 16),
//             isLocationShared
//                 ? Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: successColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: successColor.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.check_circle, color: successColor),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Location shared successfully! The service provider will be able to see your exact location.',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : ElevatedButton.icon(
//               onPressed: isLoadingLocation ? null : _getCurrentLocation,
//               icon: isLoadingLocation
//                   ? SizedBox(
//                 height: 16,
//                 width: 16,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//                   : Icon(Icons.location_on),
//               label: Text(isLoadingLocation ? 'Getting Location...' : 'Share My Location'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 minimumSize: Size(double.infinity, 50),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentPage extends StatefulWidget {
  final String bookingId;
  final double totalAmount;
  final String serviceName;
  final String providerName;
  final DateTime bookingDate;
  final int hours;
  final double hourlyRate;
  final List<String>? serviceImages;

  // Add provider ID for payments collection
  final String providerId;
  final String serviceId;

  const PaymentPage({
    Key? key,
    required this.bookingId,
    required this.totalAmount,
    required this.serviceName,
    required this.providerName,
    required this.bookingDate,
    required this.hours,
    required this.hourlyRate,
    this.serviceImages,
    required this.providerId,
    required this.serviceId,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Razorpay _razorpay;

  // Location variables
  bool isLocationShared = false;
  Map<String, dynamic>? userLocation;
  bool isLoadingLocation = false;

  // Theme colors
  final Color primaryColor = Color(0xff0F3966); // Modern blue
  final Color secondaryColor = Color(0xFF6B7280); // Neutral gray
  final Color accentColor = Color(0xFFECF2FF); // Light blue bg
  final Color surfaceColor = Colors.white;
  final Color errorColor = Color(0xFFEF4444); // Error red
  final Color successColor = Color(0xFF10B981); // Success green

  bool isLoading = true;
  bool isProcessingPayment = false;
  Map<String, dynamic> userData = {};
  String userAddress = '';
  String? serviceImageUrl;
  String selectedPaymentMethod = 'card'; // 'card', 'upi', 'wallet'

  // For manual address input if user wants to change
  final TextEditingController _addressController = TextEditingController();
  bool editingAddress = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _fetchUserData();
    _fetchServiceImage();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            userData = data;
            userAddress = data['address'] ?? '';
            _addressController.text = userAddress;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showMessage('User data not found.', isError: true);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showMessage('User not authenticated.', isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showMessage('Error fetching user data: $e', isError: true);
    }
  }

  Future<void> _fetchServiceImage() async {
    try {
      // First try to get from serviceImages if provided
      if (widget.serviceImages != null && widget.serviceImages!.isNotEmpty) {
        setState(() {
          serviceImageUrl = widget.serviceImages![0];
        });
        return;
      }

      // If not provided, try to fetch from services collection
      DocumentSnapshot serviceDoc = await _firestore
          .collection('services')
          .where('provider_id', isEqualTo: widget.providerId) // Using providerId instead of providerName
          .where('name', isEqualTo: widget.serviceName)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      if (serviceDoc.exists) {
        Map<String, dynamic> data = serviceDoc.data() as Map<String, dynamic>;
        if (data.containsKey('work_sample')) {
          setState(() {
            serviceImageUrl = data['work_sample'];
          });
        } else if (data.containsKey('images') && (data['images'] as List).isNotEmpty) {
          setState(() {
            serviceImageUrl = data['images'][0];
          });
        }
      }
    } catch (e) {
      print('Error fetching service image: $e');
      // If all fails, set a default image
      setState(() {
        serviceImageUrl = 'https://via.placeholder.com/150?text=No+Image';
      });
    }
  }

  void _startPayment() {
    if (userAddress.isEmpty) {
      _showMessage('Please provide your address before proceeding to payment.', isError: true);
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    try {
      var options = {
        'key': 'rzp_test_xwcE99NTPVZiHX', // Razorpay test key
        'amount': (widget.totalAmount * 100).toInt(), // Amount in paisa
        'name': 'FixIt',
        'description': '${widget.serviceName} for ${widget.hours} hours',
        'prefill': {
          'contact': userData['phone'] ?? '',
          'email': userData['email'] ?? '',
        },
        'theme': {
          'color': '#2563EB',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      // Add payment method specific options
      if (selectedPaymentMethod == 'upi') {
        options['method'] = {'netbanking': true, 'upi': true};
      } else if (selectedPaymentMethod == 'wallet') {
        options['method'] = {'wallet': true};
      }

      _razorpay.open(options);
    } catch (e) {
      _showMessage('Error initiating payment: $e', isError: true);
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  // Location sharing functionality
  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('Location services are disabled. Please enable them.', isError: true);
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('Location permissions are denied', isError: true);
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage('Location permissions are permanently denied, we cannot request permissions.', isError: true);
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

        setState(() {
          userLocation = {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'address': address,
            'timestamp': FieldValue.serverTimestamp(),
          };
          isLocationShared = true;
          isLoadingLocation = false;
        });

        _showMessage('Location shared successfully!', isError: false);
      }
    } catch (e) {
      print('Error getting location: $e');
      _showMessage('Failed to get location: $e', isError: true);
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  // Updated payment success handler that creates a payment record
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        _showMessage('User not authenticated.', isError: true);
        return;
      }

      // Get user name from userData
      String userName = userData['name'] ?? 'Unknown User';

      // Create update data map for bookings
      Map<String, dynamic> bookingUpdateData = {
        'payment_status': 'paid',
        'status': 'confirmed',
        'payment_id': response.paymentId,
        'payment_date': FieldValue.serverTimestamp(),
        'confirmed_address': userAddress,
        'payment_method': selectedPaymentMethod,
      };

      // Add location data if available
      if (userLocation != null) {
        bookingUpdateData['user_location'] = userLocation;
      }

      // 1. Update the booking document with payment details
      await _firestore.collection('bookings').doc(widget.bookingId).update(bookingUpdateData);

      // 2. Create a new payment record in the payments collection
      await _firestore.collection('payments').add({
        'user_id': userId,
        'user_name': userName,
        'provider_id': widget.providerId,
        'provider_name': widget.providerName,
        'service_id': widget.serviceId,
        'service_name': widget.serviceName,
        'booking_id': widget.bookingId,
        'payment_id': response.paymentId,
        'amount': widget.totalAmount,
        'payment_method': selectedPaymentMethod,
        'payment_date': FieldValue.serverTimestamp(),
        'hours': widget.hours,
        'hourly_rate': widget.hourlyRate,
        'booking_date': widget.bookingDate,
        'address': userAddress,
        'location': userLocation,
        'status': 'completed'
      });

      // Show success message
      _showMessage("Payment completed successfully!", isError: false);

      // Navigate to success page or back to home
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      _showMessage('Error updating payment status: $e', isError: true);
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showMessage('Payment failed: ${response.message}', isError: true);
    setState(() {
      isProcessingPayment = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showMessage("External wallet selected: ${response.walletName}", isError: false);
    setState(() {
      isProcessingPayment = false;
    });
  }

  void _showMessage(String message, {required bool isError}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: isError ? errorColor : successColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Review Booking",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                      // Order Steps
                      _buildOrderStepper(),

                      SizedBox(height: 24),

                      // Service Summary Card
                      _buildServiceSummaryCard(),

                      SizedBox(height: 24),

                      // Booking Date & Time
                      _sectionTitle('Booking Details', Icons.calendar_today_rounded),
                      SizedBox(height: 12),
                      _buildBookingDetails(),

                      SizedBox(height: 24),

                      // Address Confirmation
                      _sectionTitle('Service Address', Icons.location_on_rounded),
                      SizedBox(height: 12),
                      _buildAddressSection(),

                      SizedBox(height: 24),

                      // Location Sharing section (uncommented)
                      _sectionTitle('Location Sharing', Icons.share_location),
                      SizedBox(height: 12),
                      _buildLocationSharingSection(),

                      SizedBox(height: 24),

                      // Payment Summary
                      _sectionTitle('Payment Summary', Icons.receipt_long_rounded),
                      SizedBox(height: 12),
                      _buildPaymentSummary(),

                      SizedBox(height: 24),

                      // // Payment Methods
                      // _sectionTitle('Payment Methods', Icons.payment_rounded),
                      // SizedBox(height: 12),
                      // _buildPaymentMethods(),

                      SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                      ),
                    ),
                    Text(
                      '₹${widget.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isProcessingPayment ? null : _startPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: secondaryColor.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: isProcessingPayment
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStepper() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _stepCircle(1, true, "Cart"),
          _stepLine(true),
          _stepCircle(2, true, "Review"),
          _stepLine(false),
          _stepCircle(3, false, "Payment"),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, bool isCompleted, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCompleted ? primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : null,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isCompleted ? primaryColor : secondaryColor,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? primaryColor : Colors.grey[300],
      ),
    );
  }

  Widget _buildServiceSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                child: serviceImageUrl != null
                    ? Image.network(
                  serviceImageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: accentColor,
                      child: Icon(Icons.home_repair_service, color: primaryColor),
                    );
                  },
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
                    : Container(
                  color: accentColor,
                  child: Icon(Icons.home_repair_service, color: primaryColor),
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
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Provider: ${widget.providerName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Home Service',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.event_available_rounded, color: primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(widget.bookingDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(widget.bookingDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: primaryColor),
                    SizedBox(width: 12),
                    Text(
                      editingAddress ? 'Enter New Address' : 'Service Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (editingAddress) {
                        // Save the new address
                        userAddress = _addressController.text;
                        editingAddress = false;
                      } else {
                        editingAddress = true;
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(60, 30),
                    foregroundColor: primaryColor,
                  ),
                  child: Text(
                    editingAddress ? 'Save' : 'Edit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            editingAddress
                ? TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter your full address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              maxLines: 3,
            )
                : Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userAddress.isEmpty
                    ? 'No address found. Please add your address.'
                    : userAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _paymentRow('Service Fee', '₹${widget.hourlyRate}/hr'),
            SizedBox(height: 10),
            _paymentRow('Service Duration', '${widget.hours} hrs', isSecondary: true),
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            ),

            _paymentRow(
              'Total Amount',
              '₹${widget.totalAmount.toStringAsFixed(0)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _paymentMethodOption(
              icon: Icons.credit_card,
              title: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard, RuPay & more',
              isSelected: selectedPaymentMethod == 'card',
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'card';
                });
              },
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            _paymentMethodOption(
              icon: Icons.account_balance,
              title: 'UPI',
              subtitle: 'Google Pay, PhonePe, BHIM & more',
              isSelected: selectedPaymentMethod == 'upi',
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'upi';
                });
              },
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            _paymentMethodOption(
              icon: Icons.account_balance_wallet,
              title: 'Wallets',
              subtitle: 'Paytm, PhonePe & more',
              isSelected: selectedPaymentMethod == 'wallet',
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'wallet';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (value) => onTap(),
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _paymentRow(String label, String value, {bool isTotal = false, bool isSecondary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isSecondary ? secondaryColor : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? primaryColor : (isSecondary ? secondaryColor : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSharingSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLocationShared ? Icons.check_circle : Icons.location_searching,
                  color: isLocationShared ? successColor : secondaryColor,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLocationShared
                            ? 'Location Shared'
                            : 'Share Precise Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isLocationShared
                            ? 'Your location coordinates have been shared with the service provider'
                            : 'Help the service provider find your address exactly',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (isLocationShared && userLocation != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pin_drop, color: primaryColor, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userLocation!['address'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: isLocationShared ? 16 : 0),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: isLoadingLocation ? null : _getCurrentLocation,
                icon: isLoadingLocation
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(
                  isLocationShared ? Icons.refresh : Icons.share_location,
                  color: Colors.green,
                  size: 18,
                ),
                label: Text(
                  isLocationShared ? 'Update Location' : 'Share My Location',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLocationShared ? Colors.transparent : primaryColor,
                  foregroundColor: isLocationShared ? primaryColor : Colors.white,
                  elevation: isLocationShared ? 0 : 0,
                  side: isLocationShared
                      ? BorderSide(color: primaryColor, width: 1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}