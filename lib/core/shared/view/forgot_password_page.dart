import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _forgotPasswordKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _resetEmailSent = false;

  // Email validation regex pattern
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // Send password reset email
  Future<void> _sendPasswordResetEmail() async {
    if (_forgotPasswordKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        // Show success message
        setState(() {
          _resetEmailSent = true;
          _isLoading = false;
        });
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Failed to send password reset email';

        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email format';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffC9E4CA),
      appBar: AppBar(
        backgroundColor: Color(0xffC9E4CA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff0F3966)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _forgotPasswordKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F3966),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 250,
                  child: _resetEmailSent
                      ? Lottie.asset(
                    'assets/json/Animation - forgot_password.json',
                    fit: BoxFit.contain,
                  )
                      : Lottie.asset(
                    'assets/json/Animation - forgot_password.json',
                    fit: BoxFit.contain,
                  ),
                ),
                // Container(
                //   width: double.infinity,
                //   height: 300,
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage("assets/images/forgotPassword.png"),
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                if (!_resetEmailSent)
                  Text(
                    "Enter your registered email below to receive password reset instructions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff0F3966),
                    ),
                  )
                else
                  Text(
                    "Password reset link sent!\nPlease check your email inbox and follow the instructions to reset your password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 30),
                if (!_resetEmailSent)
                  Column(
                    children: [
                      TextFormField(
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                          prefixIcon: Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color(0xff0F3966)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          hintText: "Enter your Email",
                        ),
                      ),
                      SizedBox(height: 40),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _sendPasswordResetEmail,
                          borderRadius: BorderRadius.circular(40),
                          splashColor: Colors.blue,
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
                                "Reset Password",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_resetEmailSent)
                  Column(
                    children: [
                      SizedBox(height: 20),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (Route route) => false);
                          },
                          borderRadius: BorderRadius.circular(40),
                          splashColor: Colors.blue,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Color(0xff0F3966),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            height: 55,
                            width: 230,
                            child: Center(
                              child: Text(
                                "Back to Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: _isLoading ? null : _sendPasswordResetEmail,
                        child: Text(
                          "Resend Email",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}