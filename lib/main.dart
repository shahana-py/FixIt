import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixit/core/shared/view/help_and_support_page.dart';
import 'package:fixit/core/shared/view/login_page.dart';
import 'package:fixit/core/shared/view/report_complaints_page.dart';
import 'package:fixit/core/shared/view/splash_page.dart';
import 'package:fixit/features/admin/view/admin_home_page.dart';
import 'package:fixit/features/admin/view/admin_tools_inventory.dart';
import 'package:fixit/features/admin/view/manage_categories_page.dart';
import 'package:fixit/features/admin/view/manage_complaints_page.dart';
import 'package:fixit/features/admin/view/manage_feedbacks_reviews.dart';
import 'package:fixit/features/admin/view/manage_notifications_page.dart';
import 'package:fixit/features/admin/view/manage_offers_page.dart';
import 'package:fixit/features/admin/view/manage_provider_approvals.dart';
import 'package:fixit/features/admin/view/manage_tools_orders.dart';
import 'package:fixit/features/admin/view/view_all_bookings.dart';
import 'package:fixit/features/admin/view/view_all_services.dart';
import 'package:fixit/features/admin/view/view_all_users.dart';
import 'package:fixit/features/admin/view/view_serviceproviders.dart';
import 'package:fixit/features/service_provider/view/provider_editprofile_page.dart';
import 'package:fixit/features/service_provider/view/provider_home_page.dart';
import 'package:fixit/features/service_provider/view/provider_jobs_page.dart';
import 'package:fixit/features/service_provider/view/provider_messages_page.dart';
import 'package:fixit/features/service_provider/view/provider_notification_page.dart';
import 'package:fixit/features/service_provider/view/provider_profile_page.dart';
import 'package:fixit/features/service_provider/view/provider_register_page.dart';
import 'package:fixit/features/service_provider/view/provider_services.dart';
import 'package:fixit/features/service_provider/view/provider_settings_page.dart';
import 'package:fixit/features/service_provider/view/sp_home.dart';
import 'package:fixit/features/service_provider/view/view_reviews.dart';
import 'package:fixit/features/user/view/favourites_page.dart';
import 'package:fixit/features/user/view/message_provider_page.dart';
import 'package:fixit/features/user/view/user_account_page.dart';
import 'package:fixit/features/user/view/user_bookings_page.dart';
import 'package:fixit/features/user/view/user_edit_profile_page.dart';
import 'package:fixit/features/user/view/user_notifications_page.dart';
import 'package:fixit/features/user/view/user_register_page.dart';
import 'package:fixit/features/user/view/user_settings_page.dart';
import 'package:fixit/features/user/view/user_welcome_page.dart';
import 'package:fixit/features/user/view/view_all_providers.dart';
import 'package:fixit/features/user/view/view_services_page.dart';
import 'package:flutter/material.dart';

import 'features/admin/models/notification_model.dart';
import 'features/user/view/user_home_page.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: "BKagOny0KF_2pCJQ3m....moL0ewzQ8rZu");
  print('-------------------------');
  print(fcmToken);
  print('-------------------------');

  runApp(const FixIt());
}
class FixIt extends StatelessWidget {
  const FixIt({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/':(context)=>SplashPage(),
        '/login':(context)=>LoginPage(),
        '/register':(context)=>UserRegisterPage(),
        '/userwelcomepage':(context)=>WelcomeScreen(),
        '/userwelcomepage2':(context)=>WelcomePage2(),
        '/userfavouritespage':(context)=>FavoritesPage(),
        '/userbookingspage':(context)=>UserBookingsPage(),


        '/home':(context)=>UserHomePage(),


        '/userviewservicespage':(context)=>ViewServicesPage(),
        '/serviceProviderRegister':(context)=>ServiceProviderRegisterPage(),
        '/serviceProviderHome':(context)=>ProviderHome(),
        '/providerAllBookingsPage':(context)=>ProviderJobsPage(),


        '/editprofileuser':(context)=>EditProfilePageUser(),
        '/adminhome':(context)=>AdminHomePage(),
        '/providerAllServicesPage':(context)=>ProviderServicesPage(),
        '/editprofileprovider':(context)=>EditProfilePageProvider(),
        '/viewalluserspage':(context)=>ViewAllUsersPage(),
        '/viewallserviceproviders':(context)=>ManageServiceProvidersPage(),
        '/manageapprovalspage':(context)=>ManageApprovalsPage(),
        '/managecategoriespage':(context)=>ManageCategoriesPage(),
        '/viewallservicespage':(context)=>ViewAllServicesPage(),
        '/viewallbookingspage':(context)=>ViewAllBookingsPage(),
        '/managetoolsinventory':(context)=>AdminToolsInventoryPage(),
        '/managetoolsorders':(context)=>AdminManageToolsOrdersPage(),
        '/manageofferspage':(context)=>AdminOfferManagementPage(),
        '/managecomplaintspage':(context)=>ManageComplaintsPage(),
        '/managenotificationspage':(context)=>ManageNotificationsPage(),
        '/managefeedbacksandreviewspage':(context)=>AdminReviewsPage(),


        '/usernotificationpage':(context)=>UserNotificationPage(),
        '/providernotificationpage':(context)=>ServiceProviderNotificationPage(),
        '/providerprofilepage':(context)=>ProviderProfilePage(),
        '/userprofilepage':(context)=>UserAccountPage(),
        '/usersettingspage':(context)=>UserSettingsPage(),
        '/providersettingspage':(context)=>ServiceProviderSettingsPage(),
        '/userhelpsupportpage':(context)=>HelpAndSupportPage(isServiceProvider: false),
        '/providerhelpsupportpage':(context)=>HelpAndSupportPage(isServiceProvider: true),
        '/providerjobspage':(context)=>ProviderJobsPage(),
        '/providermessagespage':(context)=>ProviderMessagesPage(),
        '/viewallproviderspage':(context)=>ViewAllServiceProvidersPage(),
        '/reportcomplaintspage':(context)=>ReportComplaintsPage(),

      },
      initialRoute: '/',

    );
  }
}



