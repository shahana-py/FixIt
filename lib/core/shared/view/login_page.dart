
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/core/utils/custom_texts/main_text.dart';
import 'package:fixit/features/user/view/user_register_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();

  final _loginKey = GlobalKey<FormState>();
  bool _visible = false;
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email validation regex pattern
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // // Google Sign In Method
  // Future<void> _signInWithGoogle() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     // Trigger the Google Sign In flow
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //
  //     if (googleUser == null) {
  //       // User cancelled the sign-in flow
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return;
  //     }
  //
  //     // Obtain auth details from the request
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //
  //     // Create a new credential
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     // Sign in to Firebase with the Google credential
  //     UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     if (userCredential.user != null) {
  //       String? token = await userCredential.user!.getIdToken();
  //       SharedPreferences _pref = await SharedPreferences.getInstance();
  //       _pref.setString('token', token!);
  //
  //       // Check if this is a new user
  //       if (userCredential.additionalUserInfo?.isNewUser ?? false) {
  //         // Create entry in login collection
  //         await FirebaseFirestore.instance
  //             .collection('login')
  //             .doc(userCredential.user!.uid)
  //             .set({
  //           'uid': userCredential.user!.uid,
  //           'email': userCredential.user!.email,
  //           'role': 'user', // Default role for Google sign-in users
  //         });
  //
  //         // Create entry in users collection
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(userCredential.user!.uid)
  //             .set({
  //           'uid': userCredential.user!.uid,
  //           'email': userCredential.user!.email,
  //           'name': userCredential.user!.displayName ?? '',
  //           'phone': userCredential.user!.phoneNumber ?? '',
  //         });
  //
  //         // Save user details to SharedPreferences
  //         _pref.setString('name', userCredential.user!.displayName ?? '');
  //         _pref.setString('uid', userCredential.user!.uid);
  //         _pref.setString('email', userCredential.user!.email ?? '');
  //         _pref.setString('phone', userCredential.user!.phoneNumber ?? '');
  //         _pref.setString('role', 'user');
  //
  //         // Navigate to home
  //         Navigator.pushNamedAndRemoveUntil(
  //             context, '/home', (Route route) => false);
  //       } else {
  //         // Existing user, fetch role and then navigate
  //         DocumentSnapshot rolesnap = await FirebaseFirestore.instance
  //             .collection('login')
  //             .doc(userCredential.user!.uid)
  //             .get();
  //
  //         // If document doesn't exist (should be rare), create it
  //         if (!rolesnap.exists) {
  //           await FirebaseFirestore.instance
  //               .collection('login')
  //               .doc(userCredential.user!.uid)
  //               .set({
  //             'uid': userCredential.user!.uid,
  //             'email': userCredential.user!.email,
  //             'role': 'user',
  //           });
  //
  //           await FirebaseFirestore.instance
  //               .collection('users')
  //               .doc(userCredential.user!.uid)
  //               .set({
  //             'uid': userCredential.user!.uid,
  //             'email': userCredential.user!.email,
  //             'name': userCredential.user!.displayName ?? '',
  //             'phone': userCredential.user!.phoneNumber ?? '',
  //           });
  //
  //           _pref.setString('name', userCredential.user!.displayName ?? '');
  //           _pref.setString('uid', userCredential.user!.uid);
  //           _pref.setString('email', userCredential.user!.email ?? '');
  //           _pref.setString('phone', userCredential.user!.phoneNumber ?? '');
  //           _pref.setString('role', 'user');
  //
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, '/home', (Route route) => false);
  //           return;
  //         }
  //
  //         String role = rolesnap['role'] ?? 'user';
  //         _pref.setString('role', role);
  //
  //         if (role == 'user') {
  //           DocumentSnapshot snap = await FirebaseFirestore.instance
  //               .collection('users')
  //               .doc(userCredential.user!.uid)
  //               .get();
  //
  //           if (snap.exists) {
  //             _pref.setString('name', snap['name'] ?? '');
  //             _pref.setString('uid', snap['uid']);
  //             _pref.setString('email', snap['email']);
  //             _pref.setString('phone', snap['phone'] ?? '');
  //           } else {
  //             _pref.setString('name', userCredential.user!.displayName ?? '');
  //             _pref.setString('uid', userCredential.user!.uid);
  //             _pref.setString('email', userCredential.user!.email ?? '');
  //             _pref.setString('phone', userCredential.user!.phoneNumber ?? '');
  //           }
  //
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, '/home', (Route route) => false);
  //         } else if (role == 'admin') {
  //           DocumentSnapshot adminSnap = await FirebaseFirestore.instance
  //               .collection('login')
  //               .doc(userCredential.user!.uid)
  //               .get();
  //
  //           _pref.setString('uid', adminSnap['uid']);
  //           _pref.setString('email', adminSnap['email']);
  //
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, '/adminhome', (Route route) => false);
  //         } else {
  //           // Service provider role
  //           DocumentSnapshot snap = await FirebaseFirestore.instance
  //               .collection('service provider')
  //               .doc(userCredential.user!.uid)
  //               .get();
  //
  //           if (snap.exists) {
  //             _pref.setString('name', snap['name']);
  //             _pref.setString('uid', snap['uid']);
  //             _pref.setString('email', snap['email']);
  //             _pref.setString('phone', snap['phone']);
  //           } else {
  //             _pref.setString('name', userCredential.user!.displayName ?? '');
  //             _pref.setString('uid', userCredential.user!.uid);
  //             _pref.setString('email', userCredential.user!.email ?? '');
  //             _pref.setString('phone', userCredential.user!.phoneNumber ?? '');
  //           }
  //
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, '/serviceProviderHome', (Route route) => false);
  //         }
  //       }
  //     }
  //   } catch (error) {
  //     print('Error during Google sign in: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to sign in with Google')),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  // Regular email/password login
  Future<void> _signInWithEmailPassword() async {
    if (_loginKey.currentState!.validate() == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailcontroller.text,
            password: passcontroller.text);

        if (userCredential.user?.uid != null) {
          String? token = await userCredential.user!.getIdToken();
          SharedPreferences _pref = await SharedPreferences.getInstance();
          _pref.setString('token', token!);

          DocumentSnapshot rolesnap = await FirebaseFirestore.instance
              .collection('login')
              .doc(userCredential.user!.uid)
              .get();

          if (rolesnap['role'] == 'user') {
            DocumentSnapshot snap = await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

            _pref.setString('name', snap['name']!);
            _pref.setString('uid', snap['uid']!);
            _pref.setString('email', snap['email']!);
            _pref.setString('phone', snap['phone']!);
            _pref.setString('role', rolesnap['role']!);
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (Route route) => false);
          } else if (rolesnap['role'] == 'admin') {
            DocumentSnapshot adminSnap = await FirebaseFirestore.instance
                .collection('login')
                .doc(userCredential.user!.uid)
                .get();

            _pref.setString('uid', adminSnap['uid']!);
            _pref.setString('email', adminSnap['email']!);
            _pref.setString('role', rolesnap['role']!);

            Navigator.pushNamedAndRemoveUntil(
                context, '/adminhome', (Route route) => false);
          } else {
            DocumentSnapshot snap = await FirebaseFirestore.instance
                .collection('service provider')
                .doc(userCredential.user!.uid)
                .get();

            _pref.setString('name', snap['name']!);
            _pref.setString('uid', snap['uid']!);
            _pref.setString('email', snap['email']!);
            _pref.setString('phone', snap['phone']!);
            _pref.setString('role', rolesnap['role']!);

            Navigator.pushNamedAndRemoveUntil(
                context, '/serviceProviderHome', (Route route) => false);
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Invalid Email or Password';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email format';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'This account has been disabled';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffC9E4CA),
      body: Container(
          child: Form(
            key: _loginKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text("Welcome Back", style: TextStyle(fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F3966),

                    ),),
                  ),
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/login_bg.png")),
                    ),
                  ),
                  // Container(
                  //   width: double.infinity,
                  //   height: 300,
                  //   child: Lottie.asset(
                  //       'assets/json/login animation.json',
                  //       fit: BoxFit.contain,),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      cursorColor: Color(0xff0F3966),
                      cursorErrorColor: Colors.red,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your Email";
                        } else if (!emailRegex.hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red)),
                        hintText: "Enter your Email",
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      cursorColor: Color(0xff0F3966),
                      cursorErrorColor: Colors.red,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your Password";
                        }
                        return null;
                      },
                      obscureText: !_visible,
                      obscuringCharacter: "●",
                      controller: passcontroller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _visible = !_visible;
                            });
                          },
                          icon: _visible == true
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red)),
                        hintText: "Enter Your Password",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 290),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: Text("Forgot password?", style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:3),
                    child: Material(
                      color: Colors.transparent, // To keep only the gradient visible
                      child: InkWell(
                        onTap: _isLoading ? null : _signInWithEmailPassword,
                        borderRadius: BorderRadius.circular(40), // Match the container's border radius
                        splashColor: Colors.blue, // Ripple effect color
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Color(0xff0F3966),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          height: 55,
                          width: 230,
                          child: Center(
                            child: _isLoading
                                ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            )
                                : Text(
                              "Login",
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // // Google Sign In Button
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20),
                  //   child: Material(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(40),
                  //     child: InkWell(
                  //       onTap: _isLoading ? null : _signInWithGoogle,
                  //       borderRadius: BorderRadius.circular(40),
                  //       splashColor: Colors.grey.shade200,
                  //       child: Ink(
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(40),
                  //           border: Border.all(color: Colors.grey.shade300),
                  //         ),
                  //         height: 55,
                  //         width: 230,
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Image.asset(
                  //               'assets/images/google_logo.png',
                  //               height: 24,
                  //               width: 24,
                  //             ),
                  //             SizedBox(width: 12),
                  //             Text(
                  //               "Sign in with Google",
                  //               style: TextStyle(
                  //                 color: Colors.black87,
                  //                 fontWeight: FontWeight.w500,
                  //                 fontSize: 16,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Divider(
                            color: Color(0xff0F3966), // Line color
                            thickness: 1, // Line thickness
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8), // Space around the text
                        child: Text(
                          "Register As",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff0F3966),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Divider(
                            color: Color(0xff0F3966),
                            thickness: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Material(
                              color: Colors.blue[300], // Button color
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/register', (Route route) => false);
                                },
                                borderRadius: BorderRadius.circular(10),

                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Customer",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Material(
                              color: Colors.blue[300], // Button color
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/serviceProviderRegister', (Route route) => false);
                                },
                                borderRadius: BorderRadius.circular(10),

                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Service Provider",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}
