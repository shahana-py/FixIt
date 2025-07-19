import 'dart:convert';

import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({Key? key}) : super(key: key);

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  // Settings variables
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricLoginEnabled = false;
  String _languagePreference = 'English';

  // User data
  Map<String, dynamic>? userData;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchUserDetails();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _biometricLoginEnabled = prefs.getBool('biometric_login_enabled') ?? false;
      _languagePreference = prefs.getString('language_preference') ?? 'English';
    });
  }

  Future<void> _fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setBool('biometric_login_enabled', _biometricLoginEnabled);
    await prefs.setString('language_preference', _languagePreference);
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: SingleChildScrollView(
            child: ListBody(
              children: languages.map((language) => RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _languagePreference,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _languagePreference = value;
                    });
                    _saveSettings();
                    Navigator.of(context).pop();
                  }
                },
              )).toList(),
            ),
          ),
        );
      },
    );
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordPage()),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Text(
              'Our privacy policy explains how we collect, use, and protect your personal information. '
                  'We are committed to protecting your privacy and ensuring the security of your data.'
                  '\n\nKey points:\n'
                  '- We collect only necessary information\n'
                  '- Your data is encrypted and secured\n'
                  '- We do not sell your personal information\n'
                  '- You can request data deletion at any time',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Settings"),
        backgroundColor: Color(0xff0F3966),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // User Profile Section
          Card(
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: userData != null && userData!['profileImage'] != null
                    ? MemoryImage(base64Decode(userData!['profileImage']))
                    : null,
                child: userData == null || userData!['profileImage'] == null
                    ? Icon(Icons.person,color: Colors.blue,)
                    : null,
              ),
              title: Text(
                userData?['name'] ?? 'User Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(userData?['email'] ?? 'user@example.com'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(context, '/editprofileuser');
                },
              ),
            ),
          ),

          SizedBox(height: 16),

          // Notification Settings
          SwitchListTile(
            title: Text('Notifications'),
            subtitle: Text('Receive app notifications'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSettings();
            },
            activeColor: Color(0xff0F3966),
          ),

          // Dark Mode Settings
          SwitchListTile(
            title: Text('Dark Mode'),
            subtitle: Text('Switch between light and dark themes'),
            value: _darkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
              });
              _saveSettings();
              // TODO: Implement theme switching logic
            },
            activeColor: Color(0xff0F3966),
          ),



          // Language Preference
          ListTile(
            title: Text('Language'),
            subtitle: Text(_languagePreference),
            trailing: Icon(Icons.language),
            onTap: _showLanguageDialog,
          ),

          // Change Password
          ListTile(
            title: Text('Change Password'),
            trailing: Icon(Icons.lock_outline),
            onTap: _changePassword,
          ),

          // Privacy Policy
          ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.policy),
            onTap: _showPrivacyPolicyDialog,
          ),

          // Logout
          ListTile(
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            trailing: Icon(Icons.logout, color: Colors.red),
            onTap: () {
              // Reuse the logout logic from UserSideDrawer
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('Logout', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          await _auth.signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Change Password Page
class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isObscured = true;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Reauthenticate user
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // Reauthenticate with current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Change password
        await user.updatePassword(_newPasswordController.text);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );

        // Clear text controllers
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Pop the page
        Navigator.of(context).pop();
      } catch (error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: ${error.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: AppBarTitle(text: "Change Password"),
        backgroundColor: Color(0xff0F3966),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(

                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',

                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(

                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                obscureText: _isObscured,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                obscureText: _isObscured,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                obscureText: _isObscured,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0F3966),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}