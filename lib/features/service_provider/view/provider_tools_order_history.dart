import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({Key? key}) : super(key: key);

  @override
  _OrdersHistoryPageState createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Confirmed',
    'Delivered',
    'Cancelled'
  ];

  Future<void> _cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order cancelled successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCancelDialog(String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Order',
            style: TextStyle(
              color: Color(0xff0F3966),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                _cancelOrder(orderId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xff0F3966),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            color: Color(0xff0F3966),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final isSelected = _selectedFilter == option;
                return Padding(
                  padding: EdgeInsets.only(right: 18),
                  child: FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xff0F3966),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = option;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: Color(0xff0F3966),
                    side: BorderSide(color: Colors.white, width: 1),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff0F3966),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading orders',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your order history will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderData = order.data() as Map<String, dynamic>;
                    return _buildOrderCard(order.id, orderData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getOrdersStream() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    Query query = _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('orderDate', descending: true);

    if (_selectedFilter != 'All') {
      query = query.where('status', isEqualTo: _selectedFilter.toLowerCase());
    }

    return query.snapshots();
  }

  Widget _buildOrderCard(String orderId, Map<String, dynamic> orderData) {
    final status = orderData['status'] ?? 'confirmed';
    final isDelivered = status.toLowerCase() == 'delivered';
    final isShipped = status.toLowerCase() == 'shipped';
    final hasRating = orderData['rating'] != null;
    final orderDate = orderData['orderDate'] as Timestamp?;
    final cancelledDate = orderData['cancelledAt'] as Timestamp?;
    final deliveredDate = orderData['deliveredAt'] as Timestamp?;
    final shippedDate = orderData['shippedAt'] as Timestamp?;
    final refundId = orderData['refundId'] != null;
    final refundedDate = orderData['refundProcessedAt'] as Timestamp?;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ${status}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F3966),
                  ),
                ),
              ],
            ),

            if (status == 'confirmed' && orderDate != null) ...[
              SizedBox(height: 4),
              Text(
                "Order placed at ${_formatDate(orderDate.toDate())}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],

            if (status == 'cancelled' && cancelledDate != null) ...[
              SizedBox(height: 4),
              Text(
                "Order cancelled at ${_formatDate(cancelledDate.toDate())}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              if (status == 'cancelled' &&
                  refundedDate != null &&
                  refundId != null) ...[
                Row(
                  children: [

                    Text(
                      "✅ Refunded",
                      style: TextStyle(color: Colors.green),
                    ),
                    Text(
                      " at ${_formatDate(refundedDate.toDate())}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

            ],

            if (status == 'delivered' && deliveredDate != null) ...[
              SizedBox(height: 4),
              Text(
                "Order delivered at ${_formatDate(deliveredDate.toDate())}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (status == 'shipped' && shippedDate != null) ...[
              SizedBox(height: 4),
              Text(
                "Order shipped at ${_formatDate(shippedDate.toDate())}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],

            SizedBox(height: 16),

            // Product Information
            Row(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: orderData['productImg'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            orderData['productImg'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image,
                                  size: 30, color: Colors.grey);
                            },
                          ),
                        )
                      : Icon(Icons.build, size: 30, color: Colors.grey),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderData['productName'] ?? 'Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Qty: ${orderData['quantity'] ?? 1}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₹${orderData['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      // SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),

            // Delivery Address
            if (orderData['deliveryAddress'] != null) ...[
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      orderData['deliveryAddress'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (!isShipped && !isDelivered && status.toLowerCase() != 'cancelled') ...[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelDialog(orderId),
                      label: Text('Cancel Order'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Rating Section for Delivered Orders
            if (isDelivered) ...[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              if (hasRating)
                _buildExistingRating(orderData['rating'], orderData['review'])
              else
                _buildRatingSection(orderId),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(String orderId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate this product:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff0F3966),
          ),
        ),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _showRatingDialog(orderId),
          icon: Icon(Icons.star_rate, size: 18),
          label: Text('Rate Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff0F3966),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingRating(dynamic rating, String? review) {
    final ratingValue = (rating is int) ? rating.toDouble() : (rating ?? 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Rating:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff0F3966),
              ),
            ),
            SizedBox(width: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < ratingValue ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            SizedBox(width: 8),
            Text(
              '(${ratingValue.toStringAsFixed(1)})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        if (review != null && review.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            "Your Review: ${review}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ],
    );
  }

  void _showRatingDialog(String orderId) {
    double rating = 0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Rate Product',
                style: TextStyle(
                  color: Color(0xff0F3966),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('How would you rate this product?'),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                        child: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      hintText: 'Write a review (optional)',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0F3966)),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: rating > 0
                      ? () {
                          _submitRating(orderId, rating, reviewController.text);
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0F3966),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating(
      String orderId, double rating, String review) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'rating': rating,
        'review': review.trim(),
        'ratedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Rating submitted successfully! Thank you for your feedback'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
