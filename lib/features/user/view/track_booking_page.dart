
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../service_provider/models/booking_model.dart';

class TrackBookingPage extends StatefulWidget {
  final BookingModel booking;

  const TrackBookingPage({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<TrackBookingPage> createState() => _TrackBookingPageState();
}

class _TrackBookingPageState extends State<TrackBookingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentStatus;
  bool _isLoading = false;
  bool _isCancelling = false;
  String? _serviceImageUrl;
  String? _providerImageUrl;
  Map<String, dynamic>? _providerData;
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _hasRated = false;
  Map<String, dynamic>? _existingRating;
  String? _refundStatus; // Add this line

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.status;
    _fetchRefundStatus();
    _fetchServiceAndProviderDetails();
    _checkExistingRating();
  }
  Future<void> _fetchRefundStatus() async {
    try {
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(widget.booking.id)
          .get();

      if (bookingDoc.exists && bookingDoc.data()!.containsKey('refund_status')) {
        setState(() {
          _refundStatus = bookingDoc.data()!['refund_status'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching refund status: $e');
    }
  }

  Future<void> _checkExistingRating() async {
    if (_currentStatus == 'completed') {
      setState(() {
        _isLoading = true;
      });

      try {
        final ratingsSnapshot = await _firestore
            .collection('ratings')
            .where('booking_id', isEqualTo: widget.booking.id)
            .limit(1)
            .get();

        if (ratingsSnapshot.docs.isNotEmpty) {
          setState(() {
            _hasRated = true;
            _existingRating = ratingsSnapshot.docs.first.data();
            _rating = (_existingRating!['rating'] as num).toDouble();
            if (_existingRating!['feedback'] != null) {
              _reviewController.text = _existingRating!['feedback'];
            }
          });
        }
      } catch (e) {
        debugPrint('Error checking existing rating: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchServiceAndProviderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch service details
      final serviceDoc = await _firestore
          .collection('services')
          .doc(widget.booking.serviceId)
          .get();

      if (serviceDoc.exists && serviceDoc.data()!.containsKey('work_sample')) {
        setState(() {
          _serviceImageUrl = serviceDoc.data()!['work_sample'] as String;
        });
      }

      // Fetch provider details
      final providerDoc = await _firestore
          .collection('service_providers')
          .doc(widget.booking.providerId)
          .get();

      if (providerDoc.exists) {
        setState(() {
          _providerData = providerDoc.data();
          _providerImageUrl = _providerData?['profileImage'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // New method to cancel booking
  Future<void> _cancelBooking() async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('YES', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      // Update booking status in Firestore
      await _firestore.collection('bookings').doc(widget.booking.id).update({
        'status': 'cancelled',
        'cancellation_reason': 'Cancelled by user',
        'cancelled_at': FieldValue.serverTimestamp(),
        'cancelled_by': 'user',
      });

      // Update local status
      setState(() {
        _currentStatus = 'cancelled';
        _isCancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking has been cancelled'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error cancelling booking: $e');

      setState(() {
        _isCancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final timestamp = FieldValue.serverTimestamp();

      await _firestore.collection('ratings').add({
        'booking_id': widget.booking.id,
        'provider_id': widget.booking.providerId,
        'service_id': widget.booking.serviceId,
        'user_id': widget.booking.userId,
        'rating': _rating,
        'feedback': _reviewController.text.trim(),
        'created_at': timestamp,
      });

      // Update service rating
      final serviceDoc = await _firestore
          .collection('services')
          .doc(widget.booking.serviceId)
          .get();

      if (serviceDoc.exists) {
        double currentRating = serviceDoc.data()!['rating'] as double? ?? 0;
        int ratingCount = serviceDoc.data()!['rating_count'] as int? ?? 0;

        double newRating = ((currentRating * ratingCount) + _rating) / (ratingCount + 1);

        await _firestore.collection('services').doc(widget.booking.serviceId).update({
          'rating': newRating,
          'rating_count': ratingCount + 1,
        });
      }

      // Update provider ratings
      final providerDoc = await _firestore
          .collection('service_providers')
          .doc(widget.booking.providerId)
          .get();

      if (providerDoc.exists) {
        double providerRating = providerDoc.data()!['rating'] as double? ?? 0;
        int providerRatingCount = providerDoc.data()!['rating_count'] as int? ?? 0;

        double newProviderRating = ((providerRating * providerRatingCount) + _rating) / (providerRatingCount + 1);

        await _firestore.collection('service_providers').doc(widget.booking.providerId).update({
          'rating': newProviderRating,
          'rating_count': providerRatingCount + 1,
        });
      }

      setState(() {
        _hasRated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Failed to submit rating: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to submit rating: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch phone dialer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getDirections(String address) async {
    final Uri mapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(mapsUrl)) {
      await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
  }

  IconData _getServiceIcon(String serviceName) {
    final String serviceNameLower = serviceName.toLowerCase();

    if (serviceNameLower.contains('cleaning')) {
      return Icons.cleaning_services;
    } else if (serviceNameLower.contains('plumb')) {
      return Icons.plumbing;
    } else if (serviceNameLower.contains('electric')) {
      return Icons.electrical_services;
    } else if (serviceNameLower.contains('paint')) {
      return Icons.format_paint;
    } else if (serviceNameLower.contains('carpenter') || serviceNameLower.contains('furniture')) {
      return Icons.handyman;
    } else if (serviceNameLower.contains('pest')) {
      return Icons.pest_control;
    } else if (serviceNameLower.contains('beauty') || serviceNameLower.contains('salon')) {
      return Icons.spa;
    } else if (serviceNameLower.contains('ac') || serviceNameLower.contains('air')) {
      return Icons.air;
    } else if (serviceNameLower.contains('appliance')) {
      return Icons.home_repair_service;
    } else {
      return Icons.miscellaneous_services;
    }
  }

  int _getStatusStep(String status) {
    switch (status) {
      case 'pending':
      case 'pending_payment':
        return 0;
      case 'confirmed':
        return 1;
      case 'dispatched':
        return 2;
      case 'arrived':
        return 3;
      case 'in_progress':
        return 4;
      case 'completed':
        return 5;
      case 'declined':
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  // Check if booking can be cancelled
  bool _canCancelBooking() {
    // Booking can be cancelled if status is pending, pending_payment, or confirmed
    return _currentStatus == 'pending' ||
        _currentStatus == 'pending_payment' ||
        _currentStatus == 'confirmed';
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(booking.bookingDate);
    final formattedTime = '${DateFormat('hh:mm a').format(booking.bookingDate)} - ${DateFormat('hh:mm a').format(booking.bookingDate.add(Duration(hours: booking.durationHours)))}';
    final statusStep = _getStatusStep(_currentStatus);
    final isDeclinedOrCancelled = _currentStatus == 'declined' || _currentStatus == 'cancelled';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const AppBarTitle(text: "Track Booking"),
        elevation: 0,
        backgroundColor: const Color(0xff0F3966),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading || _isCancelling
            ? const Center(child: CircularProgressIndicator(color: Color(0xff0F3966)))
            : RefreshIndicator(
          onRefresh: () async {
            _fetchServiceAndProviderDetails();
            _checkExistingRating();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(),
                const SizedBox(height: 24),
                _buildServiceCard(booking, formattedDate, formattedTime),
                // const SizedBox(height: 24),
                // _buildProviderInfoCard(),
                // const SizedBox(height: 24),



                const SizedBox(height: 24),
                isDeclinedOrCancelled
                    ? _buildCancelledCard()
                    : _buildStatusTimeline(statusStep),
                const SizedBox(height: 24),

                // Add cancel button if booking can be cancelled
                if (_canCancelBooking())
                  _buildCancelButton(),
                const SizedBox(height: 24),
                if (_currentStatus == 'completed')
                  _hasRated ? _buildExistingRatingCard() : _buildRatingCard(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New widget for cancel button
  Widget _buildCancelButton() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cancel Booking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'If you wish to cancel this booking, please click the button below. Note that you can only cancel bookings before the service provider is dispatched.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cancelBooking,
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;
    String statusText = _formatStatus(_currentStatus);

    switch (_currentStatus) {
      case 'confirmed':
        backgroundColor = Colors.teal;
        icon = Icons.check_circle;
        break;
      case 'pending_payment':
        backgroundColor = Colors.amberAccent;
        icon = Icons.payment;
        break;
      case 'dispatched':
        backgroundColor = Colors.blue;
        icon = Icons.local_shipping;
        break;
      case 'arrived':
        backgroundColor = Colors.cyan;
        icon = Icons.location_on;
        break;
      case 'in_progress':
        backgroundColor = Colors.indigo;
        icon = Icons.engineering;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        icon = Icons.task_alt;
        break;
      case 'declined':
      case 'cancelled':
        backgroundColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey;
        icon = Icons.hourglass_empty;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Text(
            'Status: $statusText',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [


                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(
                          _currentStatus == 'declined'
                              ? 'This booking has been declined by the service provider'
                              : 'This booking has been cancelled by you.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if(_refundStatus=='processed')
                          Text("✅ Service provider processed the refund",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),),
                        const SizedBox(height: 8),
                        Text(
                          'You can book another service from the home screen',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (Route route) => false);
                },
                icon: const Icon(Icons.home,color: Colors.white,),
                label: const Text('Go to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0F3966),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(int currentStep) {
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'Booking Submitted',
        'subtitle': 'Your request has been received',
        'icon': Icons.calendar_month,
      },
      {
        'title': 'Booking Confirmed',
        'subtitle': 'Provider has accepted your booking',
        'icon': Icons.check_circle,
      },
      {
        'title': 'Provider Dispatched',
        'subtitle': 'Provider is on the way',
        'icon': Icons.directions_car,
      },
      {
        'title': 'Provider Arrived',
        'subtitle': 'Provider has reached your location',
        'icon': Icons.location_on,
      },
      {
        'title': 'Service In Progress',
        'subtitle': 'Work has started',
        'icon': Icons.engineering,
      },
      {
        'title': 'Service Completed',
        'subtitle': 'Work has been completed successfully',
        'icon': Icons.library_add_check,
      },
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < steps.length; i++)
              _buildTimelineStep(
                steps[i]['title'] as String,
                steps[i]['subtitle'] as String,
                steps[i]['icon'] as IconData,
                i <= currentStep,
                i < steps.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
      String title,
      String subtitle,
      IconData icon,
      bool isCompleted,
      bool showConnector) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? const Color(0xff0F3966) : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isCompleted ? Colors.black : Colors.grey[600],
                      fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BookingModel booking, String formattedDate, String formattedTime) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _serviceImageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _serviceImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getServiceIcon(booking.serviceName),
                          size: 34,
                          color: const Color(0xff0F3966),
                        );
                      },
                    ),
                  )
                      : Icon(
                    _getServiceIcon(booking.serviceName),
                    size: 34,
                    color: const Color(0xff0F3966),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking ID: ${booking.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Date',
                    formattedDate,
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Time',
                    formattedTime,
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Duration',
                    '${booking.durationHours} hour${booking.durationHours > 1 ? 's' : ''}',
                    Icons.hourglass_empty,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Total Cost',
                    '₹${booking.totalCost}',
                    Icons.currency_rupee,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Payment Status',
                    booking.paymentStatus == 'paid' ? 'Paid' : 'Pending Payment',
                    booking.paymentStatus == 'paid' ? Icons.payment : Icons.payment_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xff0F3966),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildProviderInfoCard() {
    if (_providerData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("Provider information not available"),
        ),
      );
    }

    final providerName = _providerData!['name'] as String? ?? widget.booking.providerName;
    final providerPhone = _providerData!['phone'] as String? ?? '';
    final providerEmail = _providerData!['email'] as String? ?? '';
    final experience = _providerData!['experience'] as String? ?? '0';
    final services = _providerData!['services'] as List<dynamic>? ?? [];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Provider',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _providerImageUrl != null && _providerImageUrl!.isNotEmpty
                      ? NetworkImage(_providerImageUrl!)
                      : null,
                  child: (_providerImageUrl == null || _providerImageUrl!.isEmpty)
                      ? Text(
                    providerName.isNotEmpty ? providerName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F3966),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$experience years of experience',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (providerEmail.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          providerEmail,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (providerPhone.isNotEmpty && (_currentStatus == 'confirmed' ||
                    _currentStatus == 'dispatched' || _currentStatus == 'arrived' ||
                    _currentStatus == 'in_progress'))
                  IconButton(
                    onPressed: () => _makePhoneCall(providerPhone),
                    icon: const Icon(Icons.phone, color: Color(0xff0F3966)),
                    tooltip: 'Call Provider',
                  ),
              ],
            ),

            // Display services offered
            if (services.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Services Offered:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  services.length,
                      (index) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Text(
                      services[index].toString(),
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            if (widget.booking.address.isNotEmpty && (_currentStatus == 'confirmed' ||
                _currentStatus == 'dispatched' || _currentStatus == 'arrived' ||
                _currentStatus == 'in_progress'))
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _getDirections(widget.booking.address),
                  icon: const Icon(Icons.directions),
                  label: const Text('View Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildExistingRatingCard() {
  //   String ratingDate = '';
  //   if (_existingRating != null && _existingRating!['created_at'] != null) {
  //     final timestamp = _existingRating!['created_at'] as Timestamp;
  //     ratingDate = DateFormat('MMM d, y').format(timestamp.toDate());
  //   }
  //
  //   return Card(
  //     elevation: 3,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Text(
  //                 'Your Rating',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               if (ratingDate.isNotEmpty)
  //                 Text(
  //                   'Submitted on $ratingDate',
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Row(
  //             children: [
  //               RatingBar.builder(
  //                 initialRating: _rating,
  //                 minRating: 0,
  //                 direction: Axis.horizontal,
  //                 allowHalfRating: true,
  //                 itemCount: 5,
  //                 itemSize: 20,
  //                 ignoreGestures: true,
  //                 itemBuilder: (context, _) => const Icon(
  //                   Icons.star,
  //                   color: Colors.amber,
  //                 ),
  //                 onRatingUpdate: (_) {},
  //               ),
  //               const SizedBox(width: 8),
  //               Text(
  //                 '$_rating/5',
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           if (_reviewController.text.isNotEmpty) ...[
  //             const SizedBox(height: 16),
  //             const Text(
  //               'Your Feedback:',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[50],
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: Colors.grey[200]!),
  //               ),
  //               child: Text(
  //                 _reviewController.text,
  //                 style: TextStyle(
  //                   color: Colors.grey[800],
  //                   fontSize: 14,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }


  Widget _buildExistingRatingCard() {
    String ratingDate = '';
    String providerReplyDate = '';

    if (_existingRating != null && _existingRating!['created_at'] != null) {
      final timestamp = _existingRating!['created_at'] as Timestamp;
      ratingDate = DateFormat('MMM d, y').format(timestamp.toDate());
    }

    // Get provider reply date if available
    if (_existingRating != null && _existingRating!['reply_date'] != null) {
      final replyTimestamp = _existingRating!['reply_date'] as Timestamp;
      providerReplyDate = DateFormat('MMM d, y').format(replyTimestamp.toDate());
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Rating',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ratingDate.isNotEmpty)
                  Text(
                    'Submitted on $ratingDate',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 20,
                  ignoreGestures: true,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (_) {},
                ),
                const SizedBox(width: 8),
                Text(
                  '$_rating/5',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (_reviewController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Your Feedback:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  _reviewController.text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            // Provider reply section
            if (_existingRating != null &&
                _existingRating!['provider_reply'] != null &&
                _existingRating!['provider_reply'].toString().isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Provider Response:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (providerReplyDate.isNotEmpty)
                    Text(
                      'Replied on $providerReplyDate',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  _existingRating!['provider_reply'].toString(),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate Your Experience',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How was your service experience?',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your feedback (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xff0F3966),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0F3966),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Rating',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}