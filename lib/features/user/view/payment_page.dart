import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentPage extends StatefulWidget {
  final String bookingId;
  final double totalAmount;
  final String serviceName;
  final String providerName;
  final DateTime bookingDate;
  final List<String>? serviceImages;

  const PaymentPage({
    Key? key,
    required this.bookingId,
    required this.totalAmount,
    required this.serviceName,
    required this.providerName,
    required this.bookingDate,
    this.serviceImages,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Razorpay _razorpay;

  // Theme colors
  final Color primaryColor = Color(0xFF2563EB); // Modern blue
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
    if (widget.serviceImages != null && widget.serviceImages!.isNotEmpty) {
      setState(() {
        serviceImageUrl = widget.serviceImages![0];
      });
      return;
    }

    try {
      // Try to fetch service image from Firestore if not provided
      DocumentSnapshot serviceDoc = await _firestore
          .collection('services')
          .doc(widget.bookingId)
          .get();

      if (serviceDoc.exists) {
        Map<String, dynamic> data = serviceDoc.data() as Map<String, dynamic>;
        List<String> images = List<String>.from(data['images'] ?? []);

        if (images.isNotEmpty) {
          setState(() {
            serviceImageUrl = images[0];
          });
        }
      }
    } catch (e) {
      print('Error fetching service image: $e');
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
        'key': 'rzp_test_YOUR_ACTUAL_KEY_HERE', // Replace with your actual Razorpay key
        'amount': (widget.totalAmount * 100).toInt(), // Amount in paisa
        'name': 'FixIt App',
        'description': widget.serviceName,
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

      _razorpay.open(options);
    } catch (e) {
      _showMessage('Error initiating payment: $e', isError: true);
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Update the booking document with payment details
      await _firestore.collection('bookings').doc(widget.bookingId).update({
        'payment_status': 'paid',
        'status': 'confirmed',
        'payment_id': response.paymentId,
        'payment_date': FieldValue.serverTimestamp(),
        'confirmed_address': userAddress,
      });

      // Show success message
      _showMessage("Payment completed successfully!", isError: false);

      // Navigate to success page or back to home
      Navigator.of(context).popUntil((route) => route.isFirst); // Goes back to the first route in stack

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
          "Checkout",
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

                      // Payment Summary
                      _sectionTitle('Payment Summary', Icons.receipt_long_rounded),
                      SizedBox(height: 12),
                      _buildPaymentSummary(),

                      SizedBox(height: 24),

                      // Payment Methods
                      _sectionTitle('Payment Methods', Icons.payment_rounded),
                      SizedBox(height: 12),
                      _buildPaymentMethods(),

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
          _stepCircle(2, true, "Address"),
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
              child: serviceImageUrl != null
                  ? Image.network(
                serviceImageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: accentColor,
                    child: Icon(Icons.home_repair_service, color: primaryColor),
                  );
                },
              )
                  : Container(
                width: 80,
                height: 80,
                color: accentColor,
                child: Icon(Icons.home_repair_service, color: primaryColor),
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
            _paymentRow('Service Fee', '₹${widget.totalAmount.toStringAsFixed(0)}'),
            SizedBox(height: 10),
            _paymentRow('Convenience Fee', '₹0', isSecondary: true),
            SizedBox(height: 10),
            _paymentRow('Tax', 'Included', isSecondary: true),

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
              isSelected: true,
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            _paymentMethodOption(
              icon: Icons.account_balance,
              title: 'UPI',
              subtitle: 'Google Pay, PhonePe, BHIM & more',
              isSelected: false,
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            _paymentMethodOption(
              icon: Icons.account_balance_wallet,
              title: 'Wallets',
              subtitle: 'Paytm, PhonePe & more',
              isSelected: false,
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
  }) {
    return Padding(
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
            onChanged: (value) {},
            activeColor: primaryColor,
          ),
        ],
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

  Widget _paymentRow(String title, String amount, {bool isTotal = false, bool isSecondary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isSecondary ? secondaryColor : Colors.black87,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? primaryColor : (isSecondary ? secondaryColor : Colors.black87),
          ),
        ),
      ],
    );
  }
}