
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminManageToolsOrdersPage extends StatefulWidget {
  const AdminManageToolsOrdersPage({Key? key}) : super(key: key);

  @override
  State<AdminManageToolsOrdersPage> createState() => _AdminManageToolsOrdersPageState();
}

class _AdminManageToolsOrdersPageState extends State<AdminManageToolsOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color primaryColor = const Color(0xff0F3966);
  String selectedFilter = 'all';
  String selectedEarningsFilter = 'all'; // Track which earnings tab is selected

  // Analytics data
  int totalOrders = 0;
  double todayEarnings = 0.0;
  double monthEarnings = 0.0;
  double totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateAnalytics();
  }

  Future<void> _calculateAnalytics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final ordersSnapshot = await _firestore.collection('orders').get();

      int orderCount = 0;
      double todayTotal = 0.0;
      double monthTotal = 0.0;
      double allTimeTotal = 0.0;

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        final orderDate = (data['orderDate'] as Timestamp?)?.toDate();
        final deliveredAt = (data['deliveredAt'] as Timestamp?)?.toDate();
        final status = data['status'] as String?;
        final totalPrice = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

        orderCount++;

        // Only count delivered orders for earnings
        if (status == 'delivered' && deliveredAt != null) {
          allTimeTotal += totalPrice;

          if (deliveredAt.isAfter(today)) {
            todayTotal += totalPrice;
          }

          if (deliveredAt.isAfter(monthStart)) {
            monthTotal += totalPrice;
          }
        }
      }

      setState(() {
        totalOrders = orderCount;
        todayEarnings = todayTotal;
        monthEarnings = monthTotal;
        totalEarnings = allTimeTotal;
      });
    } catch (e) {
      print('Error calculating analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Orders Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune, color: Colors.white),
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
                selectedEarningsFilter = 'all'; // Reset earnings filter when changing order filter
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Orders'),
              ),
              const PopupMenuItem(
                value: 'confirmed',
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: 'shipped',
                child: Text('Shipped'),
              ),
              const PopupMenuItem(
                value: 'delivered',
                child: Text('Delivered'),
              ),
              const PopupMenuItem(
                value: 'cancelled',
                child: Text('Cancelled'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Analytics Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 250),
                  child: Text("Your Earnings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xff0F3966))),
                ),

                const SizedBox(height: 16),

                // Earnings Analytics - Now clickable
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedEarningsFilter = 'today';
                          });
                        },
                        child: _buildEarningsCard(
                          'Today\'s Earnings',
                          todayEarnings,
                          Icons.today,
                          Colors.green,
                          isSelected: selectedEarningsFilter == 'today',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedEarningsFilter = 'month';
                          });
                        },
                        child: _buildEarningsCard(
                          'This Month',
                          monthEarnings,
                          Icons.calendar_month,
                          Colors.blue,
                          isSelected: selectedEarningsFilter == 'month',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedEarningsFilter = 'total';
                          });
                        },
                        child: _buildEarningsCard(
                          'Total Earnings',
                          totalEarnings,
                          Icons.account_balance_wallet,
                          Colors.orange,
                          isSelected: selectedEarningsFilter == 'total',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Title for the list section
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedEarningsFilter == 'all' ? "Your Orders" : "Payment Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xff0F3966)),
                ),
                if (selectedEarningsFilter != 'all')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedEarningsFilter = 'all';
                      });
                    },
                    child: Text("View All Orders", style: TextStyle(color: Colors.blue)),
                  ),
              ],
            ),
          ),

          // Orders or Payments List
          Expanded(
            child: selectedEarningsFilter == 'all'
                ? _buildOrdersList()
                : _buildPaymentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(String title, double amount, IconData icon, Color color, {bool isSelected = false}) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to build the payments list based on selected filter
  Widget _buildPaymentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPaymentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
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
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading payments',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
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
                  Icons.payments_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No payments found for this period',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final paymentData = doc.data() as Map<String, dynamic>;
            return _buildPaymentItem(doc.id, paymentData);
          },
        );
      },
    );
  }

  // Method to build individual payment item
  Widget _buildPaymentItem(String orderId, Map<String, dynamic> paymentData) {
    final productName = paymentData['productName'] ?? 'Unknown Product';
    final totalPrice = paymentData['totalPrice'] ?? 0;
    final productImg = paymentData['productImg'] ?? '';
    final deliveredAt = paymentData['deliveredAt'] as Timestamp?;
    final formattedDate = deliveredAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(deliveredAt.toDate())
        : 'N/A';

    final serviceProviderInfo = paymentData['serviceProviderInfo'] as Map<String, dynamic>?;
    final providerName = serviceProviderInfo?['name'] ?? 'Unknown Provider';
    final providerImage = serviceProviderInfo?['profileImage'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: productImg.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  productImg,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image_not_supported, color: Colors.grey[400]),
                ),
              )
                  : Icon(Icons.shopping_bag, color: Colors.grey[400]),
            ),
            const SizedBox(width: 12),

            // Payment Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${orderId.substring(0, 8)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Provider Image and Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Provider Image
                CircleAvatar(
                  radius: 16,
                  backgroundImage: providerImage.isNotEmpty
                      ? NetworkImage(providerImage)
                      : null,
                  child: providerImage.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[600], size: 16)
                      : null,
                ),
                const SizedBox(height: 4),
                // Provider Name
                Text(
                  providerName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Amount
                Text(
                  '₹$totalPrice',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Original orders list
  Widget _buildOrdersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
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
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading orders',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
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
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final orderData = doc.data() as Map<String, dynamic>;
            return OrderCard(
              orderId: doc.id,
              orderData: orderData,
              primaryColor: primaryColor,
              onStatusUpdate: _updateOrderStatus,
              onRefund: _processRefund,
              onRefresh: _calculateAnalytics,
            );
          },
        );
      },
    );
  }

  // Stream for regular orders
  Stream<QuerySnapshot> _getOrdersStream() {
    Query query = _firestore.collection('orders');

    if (selectedFilter != 'all') {
      query = query.where('status', isEqualTo: selectedFilter);
    }

    return query.orderBy('orderDate', descending: true).snapshots();
  }

  // Stream for payments based on selected filter
  Stream<QuerySnapshot> _getPaymentsStream() {
    Query query = _firestore.collection('orders')
        .where('status', isEqualTo: 'delivered'); // Only show delivered orders as payments

    final now = DateTime.now();

    if (selectedEarningsFilter == 'today') {
      // Today's payments
      final today = DateTime(now.year, now.month, now.day);
      final todayTimestamp = Timestamp.fromDate(today);
      query = query.where('deliveredAt', isGreaterThanOrEqualTo: todayTimestamp);
    }
    else if (selectedEarningsFilter == 'month') {
      // This month's payments
      final monthStart = DateTime(now.year, now.month, 1);
      final monthStartTimestamp = Timestamp.fromDate(monthStart);
      query = query.where('deliveredAt', isGreaterThanOrEqualTo: monthStartTimestamp);
    }

    return query.orderBy('deliveredAt', descending: true).snapshots();
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      Map<String, dynamic> updateData = {'status': newStatus};

      if (newStatus == 'delivered') {
        updateData['deliveredAt'] = Timestamp.now();
      } else if (newStatus == 'cancelled') {
        updateData['cancelledAt'] = Timestamp.now();
      } else if (newStatus == 'shipped') {
        updateData['shippedAt'] = Timestamp.now();
      }

      // Get order data for notification
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      final orderData = orderDoc.data() as Map<String, dynamic>;

      await _firestore.collection('orders').doc(orderId).update(updateData);

      // Send notification
      await _sendNotification(orderData, newStatus);

      // Refresh analytics
      await _calculateAnalytics();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processRefund(String orderId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(width: 16),
              const Text('Processing refund...'),
            ],
          ),
        ),
      );

      // Get order data
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final totalPrice = orderData['totalPrice'] ?? 0;
      final paymentId = orderData['paymentId'] ?? '';

      // Generate refund ID
      final refundId = 'refund_${DateTime.now().millisecondsSinceEpoch}';

      // Update order with refund information
      await _firestore.collection('orders').doc(orderId).update({
        'refundStatus': 'processed',
        'refundId': refundId,
        'refundAmount': totalPrice,
        'refundProcessedAt': Timestamp.now(),
        'refundProcessedBy': 'Admin',
      });

      // Send notification to provider
      await _sendRefundNotification(orderData, refundId, totalPrice);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refund of ₹$totalPrice processed successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh analytics
      await _calculateAnalytics();

    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process refund: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _sendRefundNotification(Map<String, dynamic> orderData, String refundId, double refundAmount) async {
    try {
      final serviceProviderInfo = orderData['serviceProviderInfo'] as Map<String, dynamic>?;
      final providerId = serviceProviderInfo?['uid'];
      final productName = orderData['productName'] ?? 'Unknown Product';

      if (providerId != null) {
        // Create notification document for provider
        await _firestore.collection('notifications').add({
          'title': 'Refund Processed',
          'message': 'A refund of ₹${refundAmount.toStringAsFixed(0)} has been processed for the cancelled order of $productName. Refund ID: $refundId',
          'recipientType': 'serviceProvider',
          'recipientId': providerId,
          'createdAt': Timestamp.now(),
          'sentBy': 'Admin',
          'isRead': false,
          'type': 'refund_notification',
          'refundId': refundId,
          'refundAmount': refundAmount,
          'orderId': orderData['orderId'] ?? '',
        });

        print('Refund notification sent successfully to provider: $providerId');
      }
    } catch (e) {
      print('Error sending refund notification: $e');
    }
  }

  Future<void> _sendNotification(Map<String, dynamic> orderData, String status) async {
    try {
      final serviceProviderInfo = orderData['serviceProviderInfo'] as Map<String, dynamic>?;
      final providerId = serviceProviderInfo?['uid'];
      final productName = orderData['productName'] ?? 'Unknown Product';

      if (providerId != null) {
        String title = '';
        String message = '';

        if (status == 'delivered') {
          title = 'Order Delivered 📦';
          message = 'Your order for the product $productName has been delivered.';
        } else if (status == 'shipped') {
          title = 'Order Shipped 🚚';
          message = 'Your order for the product $productName has been shipped.';
        } else if (status == 'cancelled') {
          title = 'Order Cancelled ❌';
          message = 'Your order for the product $productName has been cancelled.';
        }

        if (title.isNotEmpty && message.isNotEmpty) {
          // Create notification document
          await _firestore.collection('notifications').add({
            'title': title,
            'message': message,
            'recipientType': 'serviceProvider',
            'recipientId': providerId,
            'createdAt': Timestamp.now(),
            'sentBy': 'Admin',
            'isRead': false,
            'type': 'order_update',
          });

          print('Notification sent successfully');
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final Color primaryColor;
  final Function(String, String) onStatusUpdate;
  final Function(String) onRefund;
  final VoidCallback onRefresh;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.orderData,
    required this.primaryColor,
    required this.onStatusUpdate,
    required this.onRefund,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = orderData['status'] ?? 'pending';
    final productName = orderData['productName'] ?? 'Unknown Product';
    final productPrice = orderData['productPrice'] ?? 0;
    final quantity = orderData['quantity'] ?? 1;
    final totalPrice = orderData['totalPrice'] ?? 0;
    final deliveryAddress = orderData['deliveryAddress'] ?? 'Not specified';
    final productImg = orderData['productImg'] ?? '';
    final paymentId = orderData['paymentId'] ?? 'N/A';

    // Refund information
    final refundStatus = orderData['refundStatus'] ?? '';
    final refundId = orderData['refundId'] ?? '';
    final refundAmount = orderData['refundAmount'] ?? 0;
    final refundProcessedAt = orderData['refundProcessedAt'] as Timestamp?;

    final serviceProviderInfo = orderData['serviceProviderInfo'] as Map<String, dynamic>?;
    final providerName = serviceProviderInfo?['name'] ?? 'Unknown Provider';
    final providerPhone = serviceProviderInfo?['phone'] ?? '';
    final providerImage = serviceProviderInfo?['profileImage'] ?? '';
    final providerAddress = serviceProviderInfo?['address'] ?? 'Not specified';

    final orderDate = orderData['orderDate'] as Timestamp?;
    final cancelledAt = orderData['cancelledAt'] as Timestamp?;
    final deliveredAt = orderData['deliveredAt'] as Timestamp?;
    final shippedAt = orderData['shippedAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: productImg.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                productImg,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, color: Colors.grey[400]),
              ),
            )
                : Icon(Icons.shopping_bag, color: Colors.grey[400]),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${orderId.substring(0, 8)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹$totalPrice',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildStatusChip(status),
                  if (refundStatus == 'processed') ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_sharp, size: 12, color: Colors.green),
                          const SizedBox(width: 2),
                          Text(
                            'REFUNDED',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Provider Section
                if (serviceProviderInfo != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Service Provider',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Provider Image
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: providerImage.isNotEmpty
                                  ? NetworkImage(providerImage)
                                  : null,
                              child: providerImage.isEmpty
                                  ? Icon(Icons.person, color: Colors.grey[600])
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    providerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    providerAddress,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Call Button
                            if (providerPhone.isNotEmpty)
                              IconButton(
                                onPressed: () => _makePhoneCall(providerPhone),
                                icon: Icon(
                                  Icons.phone,
                                  color: Colors.green[600],
                                ),
                                tooltip: 'Call Provider',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Product Details Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Product Name', productName),
                      _buildDetailRow('Quantity', quantity.toString()),
                      _buildDetailRow('Unit Price', '₹$productPrice'),
                      _buildDetailRow('Total Price', '₹$totalPrice'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Payment & Order Info Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payment, color: Colors.green[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Payment & Order Info',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Payment ID', paymentId),
                      _buildDetailRow('Payment Status', _getPaymentStatus(paymentId)),
                      if (orderDate != null)
                        _buildDetailRow('Order Date', _formatTimestamp(orderDate)),
                      if (shippedAt != null)
                        _buildDetailRow('Shipped At', _formatTimestamp(shippedAt)),
                      if (deliveredAt != null)
                        _buildDetailRow('Delivered At', _formatTimestamp(deliveredAt)),
                      if (cancelledAt != null)
                        _buildDetailRow('Cancelled At', _formatTimestamp(cancelledAt)),
                    ],
                  ),
                ),

                // Refund Information Section (if refunded)
                if (refundStatus == 'processed') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.monetization_on_rounded, color: Colors.green[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Refund Information',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('Refund ID', refundId),
                        _buildDetailRow('Refund Amount', '₹${refundAmount.toString()}'),
                        _buildDetailRow('Refund Status', 'Completed'),
                        if (refundProcessedAt != null)
                          _buildDetailRow('Processed At', _formatTimestamp(refundProcessedAt)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Delivery Address Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.orange[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Delivery Address',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[700],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          // View Directions Button
                          TextButton.icon(
                            onPressed: () => _openDirections(deliveryAddress),
                            icon: Icon(Icons.directions, size: 18, color: primaryColor),
                            label: Text(
                              'Directions',
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        deliveryAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating Section (if available)
                if (orderData['rating'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.purple[600], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Product Rating',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showRatingDialog(context, orderData),
                              child: Text(
                                'View Review',
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) => Icon(
                              index < (orderData['rating'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            )),
                            const SizedBox(width: 8),
                            Text(
                              '${orderData['rating'] ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons
                if (status != 'delivered' && status != 'cancelled') ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(context, status),
                ] else if (status == 'cancelled' && refundStatus != 'processed') ...[
                  const SizedBox(height: 16),
                  _buildRefundButton(context),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showRefundConfirmDialog(context),
        icon: const Icon(Icons.monetization_on_rounded, color: Colors.white),
        label: const Text('Process Refund'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showRefundConfirmDialog(BuildContext context) {
    final totalPrice = orderData['totalPrice'] ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.monetization_on_rounded, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Process Refund',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to process a refund for this cancelled order?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Order ID: #${orderId.substring(0, 8)}'),
                    Text('Refund Amount: ₹$totalPrice'),
                    Text('Product: ${orderData['productName'] ?? 'Unknown'}'),
                  ],
                ),
              ),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRefund(orderId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Process Refund'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, String status) {
    if (status == 'confirmed' || status == 'pending') {
      // Show Ship and Cancel buttons
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmDialog(
                context,
                'Mark as Shipped',
                'Are you sure you want to mark this order as shipped?',
                    () => onStatusUpdate(orderId, 'shipped'),
              ),
              icon: const Icon(Icons.local_shipping, color: Colors.white),
              label: const Text('Mark as Shipped', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showConfirmDialog(
                context,
                'Cancel Order',
                'Are you sure you want to cancel this order?',
                    () => onStatusUpdate(orderId, 'cancelled'),
              ),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'shipped') {
      // Show Deliver and Cancel buttons
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmDialog(
                context,
                'Mark as Delivered',
                'Are you sure you want to mark this order as delivered?',
                    () => onStatusUpdate(orderId, 'delivered'),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Mark as Delivered', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showConfirmDialog(
                context,
                'Cancel Order',
                'Are you sure you want to cancel this order?',
                    () => onStatusUpdate(orderId, 'cancelled'),
              ),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'confirmed':
        statusColor = Colors.orange;
        statusIcon = Icons.verified;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    try {
      final date = timestamp.toDate();
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getPaymentStatus(String paymentId) {
    if (paymentId == 'N/A' || paymentId.isEmpty) {
      return 'Payment Pending';
    }
    return 'Payment Completed';
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch phone call';
      }
    } catch (e) {
      print('Error making phone call: $e');
    }
  }

  void _openDirections(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open maps';
      }
    } catch (e) {
      print('Error opening directions: $e');
    }
  }

  void _showConfirmDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback onConfirm,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, Map<String, dynamic> orderData) {
    final rating = orderData['rating'] ?? 0;
    final review = orderData['review'] ?? 'No review provided';
    final ratedAt = orderData['ratedAt'] as Timestamp?;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Customer Review',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating stars
              Row(
                children: [
                  Text(
                    'Rating: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  ...List.generate(5, (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  )),
                  const SizedBox(width: 8),
                  Text(
                    '$rating/5',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Review text
              Text(
                'Review:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              // Rated at
              if (ratedAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Reviewed on: ${_formatTimestamp(ratedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}