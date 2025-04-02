import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit/core/utils/custom_texts/main_text.dart';
import 'package:fixit/features/user/view/user_register_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                spacing: 10,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      cursorColor: Color(0xff0F3966),
                      cursorErrorColor: Colors.red,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your Email";
                        } else {
                          return null;
                        }
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      cursorColor: Color(0xff0F3966),
                      cursorErrorColor: Colors.red,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your Password";
                        } else {
                          return null;
                        }
                      },
                      obscureText: _visible,
                      obscuringCharacter: "*",
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
                          icon: _visible == false
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
                    padding: const EdgeInsets.only(top: 20),
                    child: Material(
                      color: Colors.transparent, // To keep only the gradient visible
                      child: InkWell(
                        onTap: () async {
                          if (_loginKey.currentState!.validate() == true) {
                            UserCredential userCredential= await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email:_emailcontroller.text,
                                password: passcontroller.text);
                            if(userCredential.user!.uid != null) {
                              // Navigator.pushNamedAndRemoveUntil(context,
                              //     '/home', (Route route) => false);
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
                              }
                              else if (rolesnap['role'] == 'admin') {
                                DocumentSnapshot adminSnap = await FirebaseFirestore.instance
                                    .collection('login')
                                    .doc(userCredential.user!.uid)
                                    .get();

                                _pref.setString('uid', adminSnap['uid']!);
                                _pref.setString('email', adminSnap['email']!);
                                _pref.setString('role', rolesnap['role']!);

                                Navigator.pushNamedAndRemoveUntil(

                                    context, '/adminhome', (Route route) => false);
                              }
                              else {
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
                          }
                        },
                        borderRadius: BorderRadius.circular(
                            40), // Match the container's border radius
                        splashColor: Colors.blue, // Ripple effect color
                        child: Ink(
                          decoration: BoxDecoration(
                             color: Color(0xff0F3966),

                            borderRadius: BorderRadius.circular(40),
                          ),
                          height: 55,
                          width: 230,
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   spacing: 10,
                  //   children: [
                  //     Text("Don't have an account ?",style: TextStyle(color: Color(0xff0F3966)),),
                  //     InkWell(
                  //         onTap: () {
                  //           // to register
                  //         },
                  //         child: GestureDetector(
                  //             onTap:(){
                  //               Navigator.pushNamed(context, "/register");
                  //               // Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                  //               //   return UserRegisterPage();
                  //               // }));
                  //             },
                  //
                  //             child: Text("Register",style: TextStyle(color: Colors.blue),)))
                  //   ],
                  // ),
                  //
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   spacing: 10,
                  //   children: [
                  //     Text("New service provider ?",style: TextStyle(color: Color(0xff0F3966)),),
                  //     InkWell(
                  //         onTap: () {
                  //           // to register
                  //         },
                  //         child: GestureDetector(
                  //             onTap:(){
                  //               Navigator.pushNamed(context, "/serviceProviderRegister");
                  //               // Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                  //               //   return UserRegisterPage();
                  //               // }));
                  //             },
                  //
                  //             child: Text("Create an Account",style: TextStyle(color: Colors.blue),)))
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),

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

