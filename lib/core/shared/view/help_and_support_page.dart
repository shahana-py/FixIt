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
    HelpCategory(
        title: 'Service Providers',
        items: [

          HelpItem(
              question: 'Can I choose a specific service provider?',
              answer: 'Yes, you can view provider profiles, ratings, and reviews before selecting your preferred professional.'
          ),

          HelpItem(
              question: 'How do I rate my service provider?',
              answer: 'After service completion, you\'ll receive a rating prompt. You can rate on a 5-star scale and provide written feedback.'
          ),
        ]
    ),
    HelpCategory(
        title: 'Account & Security',
        items: [
          HelpItem(
              question: 'How do I reset my password?',
              answer: 'Go to "Settings" > "Change password" . You can reset your password from there.'
          ),
          HelpItem(
              question: 'Can I change my registered phone number?',
              answer: 'Yes, visit "My Profile" > Click on edit button. Then you can change your number from there.'
          ),

        ]
    ),
    HelpCategory(
        title: 'Technical Support',
        items: [
          HelpItem(
              question: 'The app keeps crashing. What should I do?',
              answer: 'Try these steps:\n1. Clear app cache\n2. Restart your device\nIf issues persist, contact our support team.'
          ),
          HelpItem(
              question: 'I\'m not receiving notifications. How to fix?',
              answer: 'Check your device notification settings for our app and ensure you haven\'t disabled notifications.'
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
              answer: 'Go to My services section under that all of your services will be listed, from there you can update your services'
          ),
          HelpItem(
              question: 'How can I manage my availability?',
              answer: 'If you are unavailable temporarly for then you can off your service by clicking the on/off button at the top of your service'
          ),
        ]
    ),
    HelpCategory(
        title: 'Earnings and Payments',
        items: [
          HelpItem(
              question: 'How can i check my earnings report',
              answer: 'You can check it by clicking the wallet icon in the home page.You can see your daily,monthly and total earnings analysis from there'
          ),
          HelpItem(
              question: 'How are service ratings calculated?',
              answer: 'Your overall rating is an average of all customer ratings. Maintain high-quality service to improve your rating and attract more customers.'
          ),
        ]
    ),
    HelpCategory(
        title: 'Customer Interactions',
        items: [
          HelpItem(
              question: 'How should I communicate with customers?',
              answer: 'Use our in-app messaging for all communications. This ensures records are kept for dispute resolution if needed.'
          ),
          HelpItem(
              question: 'What if a customer is unsatisfied with my service?',
              answer: 'Try to resolve issues professionally. If unresolved, contact our support team who will mediate and find a solution.'
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
        title:AppBarTitle(text: 'Help & Support'),

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