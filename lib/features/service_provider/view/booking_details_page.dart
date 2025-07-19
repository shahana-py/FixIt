

import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../core/shared/services/image_service.dart';
import '../models/booking_model.dart';
import 'chat_with_client.dart';

class BookingDetailsPage extends StatefulWidget {
  final BookingModel booking;
  final String profileImageUrl;

  const BookingDetailsPage({
    Key? key,
    required this.booking,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  String _currentStatus = 'pending';
  bool _isLoading = false;
  String? _workSampleImageUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  bool _isProcessingRefund = false;
  String? _refundStatus;

  // Add variables for user location
  Map<String, dynamic>? _userLocation;
  String? _formattedAddress;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.status;
    _fetchRefundStatus();
    _fetchWorkSampleImage();
    _fetchUserLocation();
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

  Future<void> _fetchWorkSampleImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final serviceDoc = await _firestore
          .collection('services')
          .doc(widget.booking.serviceId)
          .get();

      if (serviceDoc.exists && serviceDoc.data()!.containsKey('work_sample')) {
        setState(() {
          _workSampleImageUrl = serviceDoc.data()!['work_sample'] as String;
        });
      }
    } catch (e) {
      debugPrint('Error fetching work sample image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _processRefund({
    required String reason,
    required String refundType,
  }) async {
    setState(() {
      _isProcessingRefund = true;
    });

    try {
      double refundAmount = widget.booking.totalCost;
      String refundId = 'refund_${DateTime.now().millisecondsSinceEpoch}';

      // FIXED: Set status based on refund type
      String bookingStatus = refundType == 'user_cancelled' ? 'cancelled' : 'declined';

      await _firestore.collection('bookings').doc(widget.booking.id).update({
        'status': bookingStatus, // Changed: Use conditional status
        'refund_status': 'processed',
        'refund_amount': refundAmount,
        'refund_id': refundId,
        'refund_reason': reason,
        'refund_type': refundType,
        'refund_date': FieldValue.serverTimestamp(),
        'refund_method': widget.booking.paymentMethod,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await _sendRefundNotification(refundAmount, refundId, reason);

      setState(() {
        _currentStatus = bookingStatus; // Changed: Use conditional status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refund of ₹${refundAmount.toStringAsFixed(2)} has been processed successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process refund: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isProcessingRefund = false;
      });
    }
  }
  // Future<void> _processRefund({
  //   required String reason,
  //   required String refundType,
  // }) async {
  //   setState(() {
  //     _isProcessingRefund = true;
  //   });
  //
  //   try {
  //     double refundAmount = widget.booking.totalCost;
  //     String refundId = 'refund_${DateTime.now().millisecondsSinceEpoch}';
  //
  //     await _firestore.collection('bookings').doc(widget.booking.id).update({
  //       'status': 'declined',
  //       'refund_status': 'processed',
  //       'refund_amount': refundAmount,
  //       'refund_id': refundId,
  //       'refund_reason': reason,
  //       'refund_type': refundType,
  //       'refund_date': FieldValue.serverTimestamp(),
  //       'refund_method': widget.booking.paymentMethod,
  //       'updated_at': FieldValue.serverTimestamp(),
  //     });
  //
  //     await _sendRefundNotification(refundAmount, refundId, reason);
  //
  //     setState(() {
  //       _currentStatus = 'declined';
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Refund of ₹${refundAmount.toStringAsFixed(2)} has been processed successfully'),
  //         backgroundColor: Colors.green,
  //         duration: const Duration(seconds: 4),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to process refund: $e'),
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 4),
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       _isProcessingRefund = false;
  //     });
  //   }
  // }

  Future<void> _sendRefundNotification(double refundAmount, String refundId, String reason) async {
    try {
      await _firestore.collection('notifications').add({
        'title': 'Refund Processed 💰',
        'message': 'Your refund of ₹${refundAmount.toStringAsFixed(2)} for ${widget.booking.serviceName} has been processed successfully. Refund ID: $refundId. Reason: $reason',
        'type': 'refund_processed',
        'recipientUid': widget.booking.userId,
        'recipientType': 'user',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'action': '/bookings/${widget.booking.id}',
        'bookingId': widget.booking.id,
        'refundId': refundId,
        'refundAmount': refundAmount,
      });

      debugPrint('Refund notification sent successfully');
    } catch (e) {
      debugPrint('Error sending refund notification: $e');
    }
  }

  Future<void> _showUserCancelledRefundDialog() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The customer has cancelled this booking. Process a full refund?'),
            const SizedBox(height: 16),
            Text(
              'Refund Amount: ₹${widget.booking.totalCost.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: _isProcessingRefund ? null : () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0F3966),
            ),
            child: _isProcessingRefund
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Process Refund', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _processRefund(
        reason: 'Customer cancelled the booking',
        refundType: 'user_cancelled',
      );
    }
  }
  // MODIFIED: New method for user-cancelled refund without asking for reason
  // Future<void> _showUserCancelledRefundDialog() async {
  //   final bool? confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Process Refund'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text('The customer has cancelled this booking. Process a full refund?'),
  //           const SizedBox(height: 16),
  //           Text(
  //             'Refund Amount: ₹${widget.booking.totalCost.toStringAsFixed(2)}',
  //             style: const TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 16,
  //               color: Colors.green,
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
  //         ),
  //         ElevatedButton(
  //           onPressed: _isProcessingRefund ? null : () => Navigator.pop(context, true),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Color(0xff0F3966),
  //           ),
  //           child: _isProcessingRefund
  //               ? const SizedBox(
  //             width: 20,
  //             height: 20,
  //             child: CircularProgressIndicator(strokeWidth: 2),
  //           )
  //               : const Text('Process Refund', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (confirm == true) {
  //     await _processRefund(
  //       reason: 'Customer cancelled the booking',
  //       refundType: 'user_cancelled',
  //     );
  //   }
  // }

  Future<void> _showRefundDialog({required String refundType}) async {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String dialogTitle = refundType == 'user_cancelled'
        ? 'Cancel Booking & Process Refund'
        : 'Cancel Booking & Refund Customer';

    String dialogMessage = refundType == 'user_cancelled'
        ? 'This will cancel the booking and process a full refund to the customer.'
        : 'This will cancel the booking on behalf of the service provider and process a full refund to the customer.';

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dialogMessage),
              const SizedBox(height: 16),
              Text(
                'Refund Amount: ₹${widget.booking.totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Please provide reason for cancellation...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a cancellation reason';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: _isProcessingRefund ? null : () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0F3966),
            ),
            child: _isProcessingRefund
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Process Refund', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _processRefund(
        reason: reasonController.text.trim(),
        refundType: refundType,
      );
    }
  }

  Future<void> _showDeclineDialog() async {
    bool showRefundOption = widget.booking.paymentStatus == 'paid';

    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final String? action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Booking'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for declining this booking:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
              ),
              if (showRefundOption) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[800], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Customer has paid ₹${widget.booking.totalCost}. A refund will be processed.',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('CANCEL'),
          ),
          if (showRefundOption)
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, 'decline_with_refund');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('DECLINE & REFUND', style: TextStyle(color: Colors.white)),
            ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, 'decline_only');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('DECLINE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (action != null) {
      final declineReason = reasonController.text.trim();

      if (action == 'decline_with_refund') {
        await _processRefund(
          reason: declineReason,
          refundType: 'provider_cancelled',
        );
      } else {
        try {
          await _firestore.collection('bookings').doc(widget.booking.id).update({
            'status': 'declined',
            'decline_reason': declineReason,
            'updated_at': FieldValue.serverTimestamp(),
          });

          await _sendNotification(
            title: 'Booking Declined 😔',
            message: 'Your booking for ${widget.booking.serviceName} has been declined. Reason: $declineReason',
            type: 'booking_declined',
            actionId: widget.booking.id,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking declined successfully'),
              backgroundColor: Colors.redAccent,
            ),
          );

          setState(() {
            _currentStatus = 'declined';
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to decline booking: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildRefundDetailsCard() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('bookings').doc(widget.booking.id).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final bookingData = snapshot.data!.data() as Map<String, dynamic>;
        final refundStatus = bookingData['refund_status'] as String?;

        if (refundStatus != 'processed') {
          return const SizedBox.shrink();
        }

        final refundAmount = bookingData['refund_amount'] as double?;
        final refundId = bookingData['refund_id'] as String?;
        final refundReason = bookingData['refund_reason'] as String?;
        final refundDate = bookingData['refund_date'] as Timestamp?;
        final refundMethod = bookingData['refund_method'] as String?;

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
                    Icon(Icons.check_circle_sharp, size: 18, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text(
                      'Refund Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (refundAmount != null)
                  _buildInfoItem(
                    'Refund Amount',
                    '₹${refundAmount.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                const SizedBox(height: 12),
                if (refundId != null)
                  _buildInfoItem(
                    'Refund ID',
                    refundId,
                    Icons.receipt,
                  ),
                const SizedBox(height: 12),
                if (refundDate != null)
                  _buildInfoItem(
                    'Refund Date',
                    DateFormat('dd MMM yyyy, hh:mm a').format(refundDate.toDate()),
                    Icons.calendar_today,
                  ),
                const SizedBox(height: 12),
                if (refundReason != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.blue[800]),
                          const SizedBox(width: 8),
                          const Text(
                            'Reason',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Text(
                          refundReason,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchUserLocation() async {
    try {
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(widget.booking.id)
          .get();

      if (bookingDoc.exists && bookingDoc.data()!.containsKey('user_location')) {
        setState(() {
          _userLocation = bookingDoc.data()!['user_location'] as Map<String, dynamic>;
          if (_userLocation != null && _userLocation!.containsKey('address')) {
            _formattedAddress = _userLocation!['address'] as String;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching user location: $e');
    }
  }

  Future<void> _sendNotification({
    required String title,
    required String message,
    required String type,
    String? actionId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'type': type,
        'recipientUid': widget.booking.userId,
        'recipientType': 'user',
        'senderName': 'Service Provider',
        'senderEmail': '',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'action': actionId != null ? '/bookings/$actionId' : null,
        'bookingId': widget.booking.id,
      });

      debugPrint('Notification sent successfully');
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('bookings').doc(widget.booking.id).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        _currentStatus = newStatus;
      });

      await _sendStatusChangeNotification(newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking status updated to ${_formatStatus(newStatus)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendStatusChangeNotification(String status) async {
    String title = '';
    String message = '';
    String type = '';

    switch (status) {
      case 'confirmed':
        title = 'Booking Confirmed 👍';
        message = 'Your booking for ${widget.booking.serviceName} has been confirmed by the service provider.';
        type = 'booking_confirmed';
        break;
      case 'dispatched':
        title = 'Service Provider dispatched 🚖';
        message = 'Your service provider for ${widget.booking.serviceName} is on the way to your location.';
        type = 'booking_dispatched';
        break;
      case 'arrived':
        title = 'Service Provider Arrived 🤩';
        message = 'Your service provider for ${widget.booking.serviceName} has arrived at your location.';
        type = 'booking_arrived';
        break;
      case 'completed':
        title = 'Service Completed ✅';
        message = 'Your ${widget.booking.serviceName} service has been completed. Thank you for using our service! Please give us your valuable feedback';
        type = 'booking_completed';
        break;
      default:
        return;
    }

    await _sendNotification(
      title: title,
      message: message,
      type: type,
      actionId: widget.booking.id,
    );
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
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
    String query;
    if (_userLocation != null &&
        _userLocation!.containsKey('latitude') &&
        _userLocation!.containsKey('longitude')) {
      final latitude = _userLocation!['latitude'];
      final longitude = _userLocation!['longitude'];
      query = '$latitude,$longitude';
    } else {
      query = Uri.encodeComponent(address);
    }

    final Uri mapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
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

  Future<void> _showRescheduleDialog() async {
    DateTime selectedDate = widget.booking.bookingDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(widget.booking.bookingDate);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[800]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        selectedDate.hour,
        selectedDate.minute,
      );

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue[800]!,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Reschedule'),
            content: Text(
                'Reschedule booking to ${DateFormat('EEEE, MMMM d, y').format(selectedDate)} at ${DateFormat('hh:mm a').format(selectedDate)}?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                ),
                child: const Text('CONFIRM', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          try {
            await _firestore.collection('bookings').doc(widget.booking.id).update({
              'booking_date': Timestamp.fromDate(selectedDate),
              'status': 'rescheduled',
              'updated_at': FieldValue.serverTimestamp(),
            });

            final formattedDate = DateFormat('EEEE, MMMM d, y').format(selectedDate);
            final formattedTime = DateFormat('hh:mm a').format(selectedDate);

            await _sendNotification(
              title: 'Booking Rescheduled 📅',
              message: 'Your booking for ${widget.booking.serviceName} has been rescheduled to $formattedDate at $formattedTime.',
              type: 'booking_rescheduled',
              actionId: widget.booking.id,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking rescheduled successfully to ${DateFormat('EEEE, MMMM d, y').format(selectedDate)} at ${DateFormat('hh:mm a').format(selectedDate)}'),
                backgroundColor: Colors.green,
              ),
            );

            setState(() {
              _currentStatus = 'rescheduled';
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to reschedule booking: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(booking.bookingDate);
    final formattedTime = '${DateFormat('hh:mm a').format(booking.bookingDate)} - ${DateFormat('hh:mm a').format(booking.bookingDate.add(Duration(hours: booking.durationHours)))}';

    final displayAddress = _formattedAddress ?? booking.address;
    final addressParts = displayAddress.split(',');
    final mainAddress = addressParts.isNotEmpty ? addressParts[0] : '';
    final secondaryAddress = addressParts.length > 1 ? addressParts.sublist(1).join(',') : '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Booking Details"),
        elevation: 0,
        backgroundColor: Color(0xff0F3966),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff0F3966)))
          : RefreshIndicator(
        onRefresh: () async {
          _fetchWorkSampleImage();
          _fetchUserLocation();
          _fetchRefundStatus();
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
              const SizedBox(height: 24),
              _buildCustomerInfoCard(),
              const SizedBox(height: 24),
              if (booking.paymentStatus == 'paid')
                _buildPaymentDetailsCard(),
              if (booking.paymentStatus == 'paid')
                const SizedBox(height: 24),
              if (_currentStatus == 'declined' && _refundStatus == 'processed' || _currentStatus == 'cancelled' && _refundStatus == 'processed')
                _buildRefundDetailsCard(),
              if (_currentStatus == 'declined' && _refundStatus == 'processed')
                const SizedBox(height: 24),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _buildNotesCard(),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                const SizedBox(height: 24),
              if (_currentStatus != 'declined' && _refundStatus != 'processed')
                _buildAddressCard(mainAddress, secondaryAddress),
              const SizedBox(height: 24),
              if (_refundStatus != 'processed')
                 _buildActionButtons(),
              const SizedBox(height: 24),
              _buildStatusTimeline(),
              const SizedBox(height: 24),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionButton(),
    );
  }

  Widget _buildStatusBanner() {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;
    String statusText = _formatStatus(_currentStatus);

    switch (_currentStatus) {
      case 'confirmed':
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending_payment':
        backgroundColor = Colors.orange;
        icon = Icons.pending_actions;
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
        backgroundColor = Colors.teal;
        icon = Icons.task_alt;
        break;
      case 'rescheduled':
        backgroundColor = Colors.amber[700]!;
        icon = Icons.event_repeat;
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

  Widget _buildPaymentDetailsCard() {
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
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Payment ID',
                    widget.booking.paymentId ?? 'N/A',
                    Icons.receipt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Payment Method',
                    widget.booking.paymentMethod != null
                        ? widget.booking.paymentMethod!.toUpperCase()
                        : 'N/A',
                    Icons.payment,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Status',
                    widget.booking.paymentStatus != null
                        ? _formatStatus(widget.booking.paymentStatus!)
                        : 'N/A',
                    Icons.check_circle_sharp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.booking.paymentDate != null)
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Payment Date',
                      DateFormat('dd MMM yyyy, hh:mm a').format(widget.booking.paymentDate!),
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // MODIFIED: Updated action buttons logic to use the new refund dialog for cancelled bookings
  Widget _buildActionButtons() {
    // Only show action buttons for certain statuses
    if (_currentStatus == 'completed' ||
        _currentStatus == 'declined' ||
        _currentStatus == 'refunded' ||
        _currentStatus == 'in_progress') {
      return const SizedBox.shrink();
    }

    // If booking is cancelled, show only refund button
    if (_currentStatus == 'cancelled') {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Only show refund button for cancelled bookings
              if (widget.booking.paymentStatus == 'paid')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessingRefund ? null : () => _showUserCancelledRefundDialog(),
                    icon: _isProcessingRefund
                        ? const SizedBox(
                      width: 20,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.monetization_on, color: Colors.white),
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
                ),
            ],
          ),
        ),
      );
    }

    // For other statuses, show the original buttons (excluding reschedule and accept for cancelled)
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.booking.paymentStatus == 'paid' &&
                    !['completed', 'declined', 'cancelled'].contains(_currentStatus))
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessingRefund ? null : () => _showRefundDialog(refundType: 'provider_cancelled'),
                      icon: _isProcessingRefund
                          ? const SizedBox(
                        width: 20,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.cancel, color: Colors.white),
                      label: const Text('Cancel & Refund', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (widget.booking.paymentStatus == 'paid' &&
                    !['completed', 'declined', 'cancelled'].contains(_currentStatus))
                  const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_currentStatus == 'rescheduled')
                        ? null
                        : () => _showRescheduleDialog(),
                    icon: const Icon(Icons.event_repeat, color: Colors.white),
                    label: const Text('Reschedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_currentStatus == 'confirmed')
                        ? null
                        : () => _updateBookingStatus('confirmed'),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
          ],
        ),
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
                  child: _workSampleImageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _workSampleImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getServiceIcon(booking.serviceName),
                          size: 34,
                          color: Colors.blue[800],
                        );
                      },
                    ),
                  )
                      : Icon(
                    _getServiceIcon(booking.serviceName),
                    size: 34,
                    color: Colors.blue[800],
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
                        'Booking ID: ${booking.id.substring(0, 8)}',
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
                    'Earnings',
                    '₹${booking.totalCost}',
                    Icons.monetization_on_rounded,
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
          color: Colors.blue[800],
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

  Widget _buildCustomerInfoCard() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.booking.userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Customer information not available');
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final phoneNumber = userData['phone'] as String? ?? 'No phone number';
        final userName = userData['name'] as String? ?? widget.booking.userName;
        final profileImageUrl = userData['profileImageUrl'] as String? ?? widget.profileImageUrl;

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
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: profileImageUrl.isNotEmpty
                          ? Image.network(
                        profileImageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildUserInitials(userName);
                        },
                      )
                          : _buildUserInitials(userName),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customer since ${DateFormat('MMMM yyyy').format((userData['createdAt'] as Timestamp).toDate())}',
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(phoneNumber),
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Call', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageClientPage(
                                clientId: widget.booking.userId,
                                clientName: userName,
                                clientImage: profileImageUrl,
                                serviceId: widget.booking.serviceId,
                                serviceName: widget.booking.serviceName,
                                clientPhone: phoneNumber,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text('Message', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInitials(String name) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
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
              'Additional Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                widget.booking.notes ?? '',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String mainAddress, String secondaryAddress) {
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
              'Service Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        secondaryAddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _getDirections(_formattedAddress ?? widget.booking.address),
              icon: const Icon(Icons.directions, color: Colors.white),
              label: const Text('Get Directions', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final List<Map<String, dynamic>> statusSteps = [
      {
        'status': 'pending',
        'title': 'Request Received',
        'description': 'Customer has requested this service',
        'icon': Icons.receipt_long,
        'color': Colors.lightGreen,
        'isCompleted': true,
      },
      {
        'status': 'confirmed',
        'title': 'Booking Confirmed',
        'description': 'Service provider has confirmed the booking',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'isCompleted': _isStatusCompleted('confirmed'),
      },
      {
        'status': 'dispatched',
        'title': 'dispatched',
        'description': 'Service provider is on the way to your location',
        'icon': Icons.local_shipping,
        'color': Colors.blue,
        'isCompleted': _isStatusCompleted('dispatched'),
      },
      {
        'status': 'arrived',
        'title': 'Arrived',
        'description': 'Service provider has arrived at your location',
        'icon': Icons.location_on,
        'color': Colors.cyan,
        'isCompleted': _isStatusCompleted('arrived'),
      },
      {
        'status': 'in_progress',
        'title': 'Service In Progress',
        'description': 'Service is currently being performed',
        'icon': Icons.engineering,
        'color': Colors.indigo,
        'isCompleted': _isStatusCompleted('in_progress'),
      },
      {
        'status': 'completed',
        'title': 'Service Completed',
        'description': 'Service has been successfully completed',
        'icon': Icons.task_alt,
        'color': Colors.teal,
        'isCompleted': _isStatusCompleted('completed'),
      },
    ];

    if (_currentStatus == 'rescheduled') {
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
                'Booking Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_repeat,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Rescheduled',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The service appointment has been rescheduled',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
      );
    } else if (_currentStatus == 'declined' || _currentStatus == 'cancelled') {
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
                'Booking Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentStatus == 'cancelled' ? 'Booking Cancelled' : 'Booking Declined',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentStatus == 'cancelled'
                              ? 'This service request has been cancelled by the customer'
                              : 'This service request has been declined by you',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if(_refundStatus=='processed')
                          Text("✅ refunded successfully",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
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
                'Booking Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statusSteps.length,
                itemBuilder: (context, index) {
                  final step = statusSteps[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: step['isCompleted'] ? step['color'] : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step['icon'],
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          if (index < statusSteps.length - 1)
                            Container(
                              width: 2,
                              height: 40,
                              color: statusSteps[index]['isCompleted'] && statusSteps[index + 1]['isCompleted']
                                  ? Colors.blue[800]
                                  : Colors.grey[300],
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: step['isCompleted'] ? Colors.black : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  bool _isStatusCompleted(String status) {
    final statusRank = {
      'pending': 0,
      'confirmed': 1,
      'dispatched': 2,
      'arrived': 3,
      'in_progress': 4,
      'completed': 5,
    };

    final currentRank = statusRank[_currentStatus] ?? -1;
    final checkRank = statusRank[status] ?? -1;

    return checkRank <= currentRank;
  }

  Widget? _buildBottomActionButton() {
    if (_currentStatus == 'pending' || _currentStatus == 'declined' || _currentStatus == 'rescheduled' || _currentStatus == 'cancelled') {
      return null;
    }

    String buttonText;
    IconData buttonIcon;
    Color buttonColor;
    Function()? onPressed;

    switch (_currentStatus) {
      case 'confirmed':
        buttonText = 'Start Travel to Location';
        buttonIcon = Icons.directions_car;
        buttonColor = Colors.blue;
        onPressed = () => _updateBookingStatus('dispatched');
        break;
      case 'dispatched':
        buttonText = 'Mark as Arrived';
        buttonIcon = Icons.location_on;
        buttonColor = Colors.cyan;
        onPressed = () => _updateBookingStatus('arrived');
        break;
      case 'arrived':
        buttonText = 'Start Service';
        buttonIcon = Icons.engineering;
        buttonColor = Colors.indigo;
        onPressed = () => _updateBookingStatus('in_progress');
        break;
      case 'in_progress':
        buttonText = 'Complete Service';
        buttonIcon = Icons.task_alt;
        buttonColor = Colors.teal;
        onPressed = () => _updateBookingStatus('completed');
        break;
      case 'completed':
        return null;
      default:
        return null;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : onPressed,
          icon: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Icon(buttonIcon, color: Colors.white70),
          label: Text(buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    final serviceName = widget.booking.serviceName.toLowerCase();
    if (serviceName.contains('plumb')) {
      return Icons.plumbing;
    } else if (serviceName.contains('electric')) {
      return Icons.electrical_services;
    } else if (serviceName.contains('clean')) {
      return Icons.cleaning_services;
    } else if (serviceName.contains('paint')) {
      return Icons.format_paint;
    } else if (serviceName.contains('repair')) {
      return Icons.build;
    } else if (serviceName.contains('install')) {
      return Icons.handyman;
    } else if (serviceName.contains('appliance')) {
      return Icons.kitchen;
    } else if (serviceName.contains('ac') ||
        serviceName.contains('air') ||
        serviceName.contains('conditioning')) {
      return Icons.ac_unit;
    } else if (serviceName.contains('pest')) {
      return Icons.pest_control;
    } else if (serviceName.contains('garden')) {
      return Icons.yard;
    } else {
      return Icons.home_repair_service;
    }
  }
}

