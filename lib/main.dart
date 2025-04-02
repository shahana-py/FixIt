import 'package:firebase_core/firebase_core.dart';
import 'package:fixit/core/shared/view/help_and_support_page.dart';
import 'package:fixit/core/shared/view/login_page.dart';
import 'package:fixit/core/shared/view/splash_page.dart';
import 'package:fixit/features/admin/view/admin_home_page.dart';
import 'package:fixit/features/admin/view/manage_categories_page.dart';
import 'package:fixit/features/admin/view/manage_feedbacks_complaints.dart';
import 'package:fixit/features/admin/view/manage_notifications_page.dart';
import 'package:fixit/features/admin/view/manage_offers_page.dart';
import 'package:fixit/features/admin/view/manage_provider_approvals.dart';
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
import 'package:fixit/features/user/view/user_account_page.dart';
import 'package:fixit/features/user/view/user_edit_profile_page.dart';
import 'package:fixit/features/user/view/user_notifications_page.dart';
import 'package:fixit/features/user/view/user_register_page.dart';
import 'package:fixit/features/user/view/user_settings_page.dart';
import 'package:fixit/features/user/view/view_all_providers.dart';
import 'package:flutter/material.dart';

import 'features/user/view/user_home_page.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/home':(context)=>UserHomePage(),
        '/serviceProviderRegister':(context)=>ServiceProviderRegisterPage(),
        '/serviceProviderHome':(context)=>ProviderHome(),
        '/editprofileuser':(context)=>EditProfilePageUser(),
        '/adminhome':(context)=>AdminHomePage(),
        '/providerAllServicesPage':(context)=>ProviderServicesPage(),
        '/editprofileprovider':(context)=>EditProfilePageProvider(),
        '/viewalluserspage':(context)=>ViewAllUsersPage(),
        '/viewallserviceproviders':(context)=>ManageServiceProvidersPage(),
        '/manageapprovalspage':(context)=>ManageApprovalsPage(),
        '/managecategoriespage':(context)=>ManageCategoriesPage(),
        '/manageofferspage':(context)=>AdminOfferManagementPage(),
        '/managefeedbackscomplaintspage':(context)=>ManageFeedbackComplaintsPage(),
        '/managenotificationspage':(context)=>ManageNotificationsPage(),
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

      },
      initialRoute: '/',

    );
  }
}
