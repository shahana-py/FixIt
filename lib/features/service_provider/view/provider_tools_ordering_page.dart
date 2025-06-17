import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class OrderToolsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const OrderToolsPage({Key? key, required this.product}) : super(key: key);

  @override
  _OrderToolsPageState createState() => _OrderToolsPageState();
}

class _OrderToolsPageState extends State<OrderToolsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Razorpay _razorpay;

  int _quantity = 1;
  String _selectedAddress = '';
  String _customAddress = '';
  bool _useCurrentLocation = false;
  bool _isLoadingLocation = false;
  String _currentLocationText = '';

  Map<String, dynamic>? _serviceProviderData;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _fetchServiceProviderData();
    _calculateTotalPrice();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _fetchServiceProviderData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('service provider')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _serviceProviderData = doc.data() as Map<String, dynamic>;
            _selectedAddress = _serviceProviderData?['address'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching service provider data: $e');
    }
  }

  void _calculateTotalPrice() {
    double price = (widget.product['price'] ?? 0).toDouble();
    setState(() {
      _totalPrice = price * _quantity;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';

        setState(() {
          _currentLocationText = address;
          _useCurrentLocation = true;
          _selectedAddress = address;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _openRazorpay() {
    var options = {
      'key': 'rzp_test_xwcE99NTPVZiHX', // Replace with your Razorpay key
      'amount': (_totalPrice * 100).toInt(), // Amount in paise
      'name': 'FixIt',
      'description': '${widget.product['name']} - Quantity: $_quantity',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': _serviceProviderData?['phone'] ?? '',
        'email': _serviceProviderData?['email'] ?? '',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _saveOrderToFirestore(response.paymentId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful! Order placed.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  Future<void> _saveOrderToFirestore(String? paymentId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('orders').add({
          'userId': user.uid,
          'productId': widget.product['id'],
          'productName': widget.product['name'],
          'productImg': widget.product['imageUrl'],
          'productPrice': widget.product['price'],
          'quantity': _quantity,
          'totalPrice': _totalPrice,
          'deliveryAddress': _selectedAddress,
          'paymentId': paymentId,
          'orderDate': FieldValue.serverTimestamp(),
          'status': 'confirmed',
          'serviceProviderInfo': _serviceProviderData,
        });
      }
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  void _placeOrder() {
    if (_selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _openRazorpay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Order'),
        backgroundColor: Color(0xff0F3966),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Information
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F3966),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: widget.product['imageUrl'] != null
                              ? Image.network(
                            widget.product['imageUrl'],
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.image, size: 40),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product['name'] ?? 'Product Name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),
                              Text(
                                '₹${widget.product['price'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Quantity Selection
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F3966),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () {
                            setState(() {
                              _quantity--;
                            });
                            _calculateTotalPrice();
                          }
                              : null,
                          icon: Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                            _calculateTotalPrice();
                          },
                          icon: Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Address Selection
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F3966),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Current Location Option
                    ListTile(
                      title: Text('Use Current Location'),
                      subtitle: _currentLocationText.isNotEmpty
                          ? Text(_currentLocationText)
                          : Text('Tap to get your current location'),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: _useCurrentLocation,
                        onChanged: (value) {
                          if (value == true) {
                            _getCurrentLocation();
                          }
                        },
                      ),
                      trailing: _isLoadingLocation
                          ? CircularProgressIndicator()
                          : IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                      ),
                    ),

                    Divider(),

                    // Saved Address Option
                    if (_serviceProviderData?['address'] != null)
                      ListTile(
                        title: Text('Saved Address'),
                        subtitle: Text(_serviceProviderData!['address']),
                        leading: Radio<bool>(
                          value: false,
                          groupValue: _useCurrentLocation,
                          onChanged: (value) {
                            setState(() {
                              _useCurrentLocation = false;
                              _selectedAddress = _serviceProviderData!['address'];
                            });
                          },
                        ),
                      ),

                    Divider(),

                    // Custom Address Input
                    Text(
                      'Or enter new address:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your new delivery address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        setState(() {
                          _customAddress = value;
                          _selectedAddress = value;
                          _useCurrentLocation = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Order Summary
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F3966),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Price:'),
                        Text('₹${widget.product['price'] ?? 0}'),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quantity:'),
                        Text('$_quantity'),
                      ],
                    ),

                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${_totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0F3966),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Place Order - ₹${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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


