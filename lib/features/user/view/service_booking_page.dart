
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

  List<DateTime> bookedSlots = [];
  bool isLoadingBookedSlots = false;
  TimeOfDay? firstAvailableTime;

  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calculateTotalCost();
    _fetchBookedSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // 7. Update your _calculateTotalCost method to also refresh available slots
  void _calculateTotalCost() {
    // Get hourly rate from service data
    int hourlyRate = int.tryParse(widget.serviceData['hourly_rate']?.toString() ?? '0') ?? 0;
    totalCost = hourlyRate * selectedDuration.toDouble();

    // Check if current time is still available with new duration
    DateTime currentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (!_isTimeSlotAvailable(currentDateTime, selectedDuration)) {
      // Reset to first available time slot
      _updateSelectedTimeToAvailable();
    }

    setState(() {});
  }


  // 2. Add this method to fetch existing bookings for the provider
  Future<void> _fetchBookedSlots() async {
    setState(() {
      isLoadingBookedSlots = true;
    });

    try {
      // Get all bookings for this provider that are not cancelled
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('provider_id', isEqualTo: widget.serviceData['provider_id'])
          .where('status', whereIn: ['pending_payment', 'confirmed', 'completed', 'paid'])
          .get();

      List<DateTime> slots = [];

      for (var doc in bookingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Get booking date and duration
        Timestamp? bookingTimestamp = data['booking_date'] as Timestamp?;
        int duration = data['duration_hours'] ?? 1;

        if (bookingTimestamp != null) {
          DateTime bookingDateTime = bookingTimestamp.toDate();

          // Add all hours within the duration as booked slots
          for (int i = 0; i < duration; i++) {
            slots.add(bookingDateTime.add(Duration(hours: i)));
          }
        }
      }

      setState(() {
        bookedSlots = slots;
        isLoadingBookedSlots = false;
        _updateSelectedTimeToAvailable(); // Update selected time to available slot
      });
    } catch (e) {
      print('Error fetching booked slots: $e');
      setState(() {
        isLoadingBookedSlots = false;
      });
    }
  }
  void _updateSelectedTimeToAvailable() {
    List<TimeOfDay> availableSlots = _getAvailableTimeSlots(selectedDate);

    if (availableSlots.isNotEmpty) {
      // If current selected time is not available, use first available
      if (!availableSlots.any((slot) =>
      slot.hour == selectedTime.hour && slot.minute == selectedTime.minute)) {
        selectedTime = availableSlots.first;
      }
      firstAvailableTime = availableSlots.first;
    } else {
      // No available slots for this date
      firstAvailableTime = null;
    }
  }


  // 4. Add this method to check if a time slot is available

  bool _isTimeSlotAvailable(DateTime selectedDateTime, int duration) {
    // Check if any hour in the selected duration conflicts with existing bookings
    for (int i = 0; i < duration; i++) {
      DateTime checkDateTime = selectedDateTime.add(Duration(hours: i));

      // Check if this specific hour is already booked
      bool isBooked = bookedSlots.any((bookedSlot) {
        return bookedSlot.year == checkDateTime.year &&
            bookedSlot.month == checkDateTime.month &&
            bookedSlot.day == checkDateTime.day &&
            bookedSlot.hour == checkDateTime.hour;
      });

      if (isBooked) {
        return false;
      }
    }
    return true;
  }
// 5. Add this method to get available time slots for a selected date
  List<TimeOfDay> _getAvailableTimeSlots(DateTime selectedDate) {
    List<TimeOfDay> availableSlots = [];

    // Define business hours (you can adjust these as needed)
    for (int hour = 8; hour <= 20; hour++) {
      TimeOfDay timeSlot = TimeOfDay(hour: hour, minute: 0);

      // Create DateTime for this time slot
      DateTime slotDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        hour,
        0,
      );

      // Check if this time slot is available
      if (_isTimeSlotAvailable(slotDateTime, selectedDuration)) {
        availableSlots.add(timeSlot);
      }
    }

    return availableSlots;
  }
  List<TimeOfDay> _getBookedTimeSlots(DateTime selectedDate) {
    List<TimeOfDay> bookedTimeSlots = [];

    for (DateTime bookedSlot in bookedSlots) {
      if (bookedSlot.year == selectedDate.year &&
          bookedSlot.month == selectedDate.month &&
          bookedSlot.day == selectedDate.day) {
        bookedTimeSlots.add(TimeOfDay(hour: bookedSlot.hour, minute: bookedSlot.minute));
      }
    }

    return bookedTimeSlots;
  }


  // First, add this helper method to check if a date has any available slots
  bool _hasAvailableSlots(DateTime date) {
    List<TimeOfDay> availableSlots = [];

    // Define business hours (same as in _getAvailableTimeSlots)
    for (int hour = 8; hour <= 20; hour++) {
      // Create DateTime for this time slot
      DateTime slotDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        0,
      );

      // Check if this time slot is available
      if (_isTimeSlotAvailable(slotDateTime, selectedDuration)) {
        availableSlots.add(TimeOfDay(hour: hour, minute: 0));
      }
    }

    return availableSlots.isNotEmpty;
  }

// Now modify your _selectDate method - replace the existing selectableDayPredicate
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
        bool isAvailableDay = availableDayNumbers.contains(date.weekday);

        // If it's not an available day, return false
        if (!isAvailableDay) return false;

        // If it's an available day, check if it has any available time slots
        return _hasAvailableSlots(date);
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
        _updateSelectedTimeToAvailable(); // Update time for new date
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    List<TimeOfDay> availableSlots = _getAvailableTimeSlots(selectedDate);
    List<TimeOfDay> bookedTimeSlots = _getBookedTimeSlots(selectedDate);

    if (availableSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No available time slots for the selected date and duration'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Show custom time picker dialog with availability indicators
    TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Time',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                // Show availability info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryColor, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Green: Available • Red: Booked',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Time slots grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 13, // 8 AM to 8 PM (13 hours)
                    itemBuilder: (context, index) {
                      int hour = 8 + index;
                      TimeOfDay timeSlot = TimeOfDay(hour: hour, minute: 0);

                      bool isAvailable = availableSlots.any((slot) =>
                      slot.hour == hour && slot.minute == 0);
                      bool isBooked = bookedTimeSlots.any((slot) =>
                      slot.hour == hour && slot.minute == 0);
                      bool isSelected = selectedTime.hour == hour && selectedTime.minute == 0;

                      return InkWell(
                        onTap: isAvailable ? () {
                          Navigator.of(context).pop(timeSlot);
                        } : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : isAvailable
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : isAvailable
                                  ? Colors.green
                                  : Colors.red,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  timeSlot.format(context),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : isAvailable
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                                if (isBooked && !isAvailable)
                                  Icon(
                                    Icons.block,
                                    size: 12,
                                    color: Colors.red[700],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );

    if (picked != null) {
      // Verify the selected time is still available
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      if (_isTimeSlotAvailable(selectedDateTime, selectedDuration)) {
        setState(() {
          selectedTime = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected time slot is no longer available'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
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

    // Final validation before booking
    final DateTime bookingDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (!_isTimeSlotAvailable(bookingDateTime, selectedDuration)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected time slot is no longer available. Please choose another time.'),
          backgroundColor: Colors.red,
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
        'status': 'pending_payment',
        'notes': bookingNotes,
        'created_at': FieldValue.serverTimestamp(),
        'hourly_rate': widget.serviceData['hourly_rate'],
        'payment_status': 'unpaid',
      });

      // Get the booking ID
      String bookingId = bookingRef.id;

      // Send notification to service provider
      await _sendNotificationToProvider(bookingId, bookingDateTime, 'unpaid');

      // Navigate to PaymentPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            providerId: widget.serviceData['provider_id'],
            serviceId: widget.serviceId,
            bookingId: bookingId,
            hourlyRate: double.parse(widget.serviceData['hourly_rate'].toString()),
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
  Widget _buildTimeSelection() {
    List<TimeOfDay> availableSlots = _getAvailableTimeSlots(selectedDate);
    bool hasAvailableSlots = availableSlots.isNotEmpty;

    return InkWell(
      onTap: isLoadingBookedSlots ? null : (hasAvailableSlots ? () => _selectTime(context) : null),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasAvailableSlots ? Colors.grey[300]! : Colors.red[300]!,
          ),
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              hasAvailableSlots ? Colors.grey[50]! : Colors.red[50]!
            ],
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
                color: hasAvailableSlots ? lightBlue : Colors.red[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasAvailableSlots ? Icons.access_time : Icons.schedule_rounded,
                color: hasAvailableSlots ? primaryColor : Colors.red[700],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  if (isLoadingBookedSlots)
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  else if (hasAvailableSlots)
                    Text(
                      selectedTime.format(context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  else
                    Text(
                      'No available slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  if (!hasAvailableSlots && !isLoadingBookedSlots)
                    Text(
                      'Try different date/duration',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                ],
              ),
            ),
            if (hasAvailableSlots)
              Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor)
            else
              Icon(Icons.warning, size: 16, color: Colors.red[700]),
          ],
        ),
      ),
    );
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
                  _buildTimeSelection(),

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


