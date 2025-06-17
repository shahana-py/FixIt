import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';

class HelpAndSupportPage extends StatefulWidget {
  final bool isServiceProvider;

  const HelpAndSupportPage({Key? key, required this.isServiceProvider}) : super(key: key);

  @override
  _HelpAndSupportPageState createState() => _HelpAndSupportPageState();
}

class _HelpAndSupportPageState extends State<HelpAndSupportPage> {
  final List<HelpCategory> _userHelpCategories = [
    HelpCategory(
        title: 'Booking Services',
        items: [
          HelpItem(
              question: 'How do I book a service?',
              answer: 'You can book a service by following these steps:\n1. Select the service category\n2. Choose a service provider\n3. Pick a convenient date and time\n4. Confirm your booking'
          ),
          HelpItem(
              question: 'Can I cancel or reschedule a booking?',
              answer: 'Yes, you can cancel or reschedule a booking up to 24 hours before the scheduled service time. Go to "My Bookings" and select the option to cancel or reschedule.'
          ),
        ]
    ),
    HelpCategory(
        title: 'Payments',
        items: [
          HelpItem(
              question: 'What payment methods are accepted?',
              answer: 'We accept credit/debit cards, digital wallets, and online banking transfers. Cash payments are also accepted for some services.'
          ),
          HelpItem(
              question: 'How are service charges calculated?',
              answer: 'Service charges are based on the type of service, duration, and complexity. The total cost will be displayed before you confirm the booking.'
          ),
        ]
    ),
  ];

  final List<HelpCategory> _providerHelpCategories = [
    HelpCategory(
        title: 'Profile Management',
        items: [
          HelpItem(
              question: 'How do I update my service offerings?',
              answer: 'Go to "My Profile" > "Services" and click on "Edit Services" to add, modify, or remove service offerings.'
          ),
          HelpItem(
              question: 'How can I manage my availability?',
              answer: 'Navigate to "My Schedule" to set your working hours, block specific dates, and manage your availability for bookings.'
          ),
        ]
    ),
    HelpCategory(
        title: 'Earnings and Payments',
        items: [
          HelpItem(
              question: 'How and when do I get paid?',
              answer: 'Payments are processed weekly. Earnings are transferred to your linked bank account or digital wallet. Minimum payout threshold is \$50.'
          ),
          HelpItem(
              question: 'How are service ratings calculated?',
              answer: 'Your overall rating is an average of all customer ratings. Maintain high-quality service to improve your rating and attract more customers.'
          ),
        ]
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<HelpCategory> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.isServiceProvider ? _providerHelpCategories : _userHelpCategories;
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = (widget.isServiceProvider ? _providerHelpCategories : _userHelpCategories)
          .where((category) =>
      category.title.toLowerCase().contains(query.toLowerCase()) ||
          category.items.any((item) =>
          item.question.toLowerCase().contains(query.toLowerCase()) ||
              item.answer.toLowerCase().contains(query.toLowerCase())
          )
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff0F3966),
        title:AppBarTitle(text: 'Help & Support ${widget.isServiceProvider ? 'for Service Providers' : 'for Users'}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search help topics...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterCategories,
            ),
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
              child: Text(
                'No help topics found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _filteredCategories.length,
              itemBuilder: (context, categoryIndex) {
                final category = _filteredCategories[categoryIndex];
                return ExpansionTile(
                  title: Text(
                    category.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  children: category.items.map((item) {
                    return ListTile(
                      title: Text(
                        item.question,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(item.answer),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _showContactSupportDialog(context);
              },
              icon: Icon(Icons.contact_support,color: Color(0xff0F3966),),
              label: Text('Contact Support',style: TextStyle(color: Color(0xff0F3966)),),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Need further assistance? Reach out to us:'),
              SizedBox(height: 16),
              Text('Email: admin@gmail.com'),
              Text('Phone: 7135767886'),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class HelpCategory {
  final String title;
  final List<HelpItem> items;

  HelpCategory({required this.title, required this.items});
}

class HelpItem {
  final String question;
  final String answer;

  HelpItem({required this.question, required this.answer});
}

// Example of how to use the HelpAndSupportPage
class ExampleUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpAndSupportPage(isServiceProvider: false),
                  ),
                );
              },
              child: Text('User Help & Support'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpAndSupportPage(isServiceProvider: true),
                  ),
                );
              },
              child: Text('Service Provider Help & Support'),
            ),
          ],
        ),
      ),
    );
  }
}