import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProviderEarningsPage extends StatefulWidget {
  final String providerId;

  const ProviderEarningsPage({Key? key, required this.providerId}) : super(key: key);

  @override
  _ProviderEarningsPageState createState() => _ProviderEarningsPageState();
}

class _ProviderEarningsPageState extends State<ProviderEarningsPage> {
  double totalEarnings = 0.0;
  double todayEarnings = 0.0;
  double monthEarnings = 0.0;
  int completedServices = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> recentPayments = [];
  List<ChartData> weeklyEarnings = [];
  List<ChartData> monthlyEarnings = [];
  List<ChartData> yearlyEarnings = [];
  int _currentChartView = 0; // 0=Weekly, 1=Monthly, 2=Yearly

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }

  Future<void> _loadEarningsData() async {
    setState(() {
      isLoading = true;
      recentPayments.clear();
      weeklyEarnings.clear();
      monthlyEarnings.clear();
      yearlyEarnings.clear();
    });

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);

    try {
      // Query bookings for completed services count
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('provider_id', isEqualTo: widget.providerId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Query payments for earnings data
      final paymentsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('provider_id', isEqualTo: widget.providerId)
          .where('payment_status', isEqualTo: 'paid')
          .get();

      double total = 0.0;
      double today = 0.0;
      double month = 0.0;
      Map<String, double> weeklyData = {};
      Map<String, double> monthlyData = {};
      Map<String, double> yearlyData = {};

      // Initialize weekly data (last 7 days)
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        weeklyData[DateFormat('EEE').format(date)] = 0.0;
      }

      // Initialize monthly data (current year months)
      for (int i = 0; i < 12; i++) {
        final date = DateTime(now.year, i + 1, 1);
        monthlyData[DateFormat('MMM').format(date)] = 0.0;
      }

      // Initialize yearly data (last 7 years)
      for (int i = 6; i >= 0; i--) {
        final year = now.year - i;
        yearlyData[year.toString()] = 0.0;
      }

      // Process payments
      for (var doc in paymentsQuery.docs) {
        final data = doc.data();
        final amount = (data['total_cost'] is String)
            ? double.tryParse(data['total_cost']) ?? 0.0
            : (data['total_cost']?.toDouble() ?? 0.0);
        final paymentDate = (data['payment_date'] as Timestamp).toDate();

        total += amount;

        // Today's earnings
        if (paymentDate.isAfter(todayStart)) {
          today += amount;
        }

        // This month's earnings
        if (paymentDate.isAfter(monthStart)) {
          month += amount;
        }

        // Weekly earnings (last 7 days)
        if (paymentDate.isAfter(now.subtract(Duration(days: 7)))) {
          final day = DateFormat('EEE').format(paymentDate);
          weeklyData[day] = (weeklyData[day] ?? 0) + amount;
        }

        // Monthly earnings (current year)
        if (paymentDate.year == now.year) {
          final monthName = DateFormat('MMM').format(paymentDate);
          monthlyData[monthName] = (monthlyData[monthName] ?? 0) + amount;
        }

        // Yearly earnings (last 7 years)
        if (paymentDate.isAfter(DateTime(now.year - 7, 1, 1))) {
          final year = paymentDate.year.toString();
          yearlyData[year] = (yearlyData[year] ?? 0) + amount;
        }

        // Recent payments (last 5)
        if (recentPayments.length < 5) {
          recentPayments.add({
            'service_name': data['service_name'],
            'amount': amount,
            'date': paymentDate,
            'user_name': data['user_name'] ?? 'Customer',
          });
        }
      }

      // Prepare chart data - sort by chronological order
      weeklyEarnings = _sortWeeklyData(weeklyData);
      monthlyEarnings = _sortMonthlyData(monthlyData);
      yearlyEarnings = _sortYearlyData(yearlyData);

      setState(() {
        totalEarnings = total;
        todayEarnings = today;
        monthEarnings = month;
        completedServices = bookingsQuery.size;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading earnings data: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load earnings data')),
      );
    }
  }

  List<ChartData> _sortWeeklyData(Map<String, double> data) {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDayIndex = now.weekday - 1; // Monday is 1 in DateTime

    // Reorder days starting from today
    final orderedDays = [
      ...days.sublist(currentDayIndex + 1),
      ...days.sublist(0, currentDayIndex + 1)
    ].reversed.toList();

    return orderedDays.map((day) => ChartData(day, data[day] ?? 0.0)).toList();
  }

  List<ChartData> _sortMonthlyData(Map<String, double> data) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months.map((month) => ChartData(month, data[month] ?? 0.0)).toList();
  }

  List<ChartData> _sortYearlyData(Map<String, double> data) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final year = now.year - 6 + index;
      return ChartData(year.toString(), data[year.toString()] ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "My Earnings"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEarningsData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Cards
            _buildSummaryCards(),
            SizedBox(height: 24),

            // Earnings Analysis Section
            Text(
              'Earning Analysis',
              style: TextStyle(
                color: Color(0xff0F3966),
                fontSize: 23,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            _buildChartSelector(),
            SizedBox(height: 16),
            _buildCurrentChart(),
            SizedBox(height: 24),

            // Recent Payments
            Text(
              'Recent Payments',
              style: TextStyle(
                color: Color(0xff0F3966),
                fontSize: 23,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            _buildRecentPaymentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSelector() {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('Weekly')),
        ButtonSegment(value: 1, label: Text('Monthly')),

      ],
      selected: {_currentChartView},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          _currentChartView = newSelection.first;
        });
      },
    );
  }

  Widget _buildCurrentChart() {
    final currentData = _currentChartView == 0
        ? weeklyEarnings
        : _currentChartView == 1
        ? monthlyEarnings
        : yearlyEarnings;

    return Container(
      height: 300,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelRotation: _currentChartView == 1 ? -45 : 0,
          labelIntersectAction: _currentChartView == 1
              ? AxisLabelIntersectAction.rotate45
              : AxisLabelIntersectAction.none,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Amount (₹)'),
          numberFormat: NumberFormat.compactCurrency(symbol: '₹'),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x : ₹point.y',
        ),
        series: <ChartSeries<ChartData, String>>[
          ColumnSeries<ChartData, String>(
            dataSource: currentData,
            xValueMapper: (ChartData data, _) => data.day,
            yValueMapper: (ChartData data, _) => data.amount,
            color: Color(0xff0F3966),
            width: 0.6,
            spacing: 0.2,
            dataLabelSettings: DataLabelSettings(
              isVisible: false, // Disabled as requested
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          title: 'Total Earnings',
          value: totalEarnings,
          icon: Icons.attach_money,
          color: Colors.blue,
        ),
        _buildSummaryCard(
          title: "Today's Earnings",
          value: todayEarnings,
          icon: Icons.today,
          color: Colors.green,
        ),
        _buildSummaryCard(
          title: 'This Month',
          value: monthEarnings,
          icon: Icons.calendar_month,
          color: Colors.amber,
        ),
        _buildSummaryCard(
          title: 'Completed Services',
          value: completedServices.toDouble(),
          icon: Icons.check_circle,
          color: Colors.pink,
          isCount: true,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    bool isCount = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),

            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3),
            Text(
              isCount ? value.toInt().toString() : '₹${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPaymentsList() {
    if (recentPayments.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No recent payments found'),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        children: recentPayments.map((payment) {
          return ListTile(
            leading: Icon(Icons.payment, color: Colors.green),
            title: Text(payment['service_name']),
            subtitle: Text(
              '${DateFormat('MMM dd, yyyy').format(payment['date'])} - ${payment['user_name']}',
            ),
            trailing: Text(
              '₹${payment['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ChartData {
  final String day;
  final double amount;

  ChartData(this.day, this.amount);
}