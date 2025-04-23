import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  TextEditingController _confirmpasscontroller = TextEditingController();
  TextEditingController _phonecontroller = TextEditingController();
  TextEditingController _addresscontroller = TextEditingController();

  final _registerKey = GlobalKey<FormState>();
  bool _visible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffC9E4CA),
      body: Container(

          child: Form(
        key: _registerKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Text(
                    "Create An Account",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F3966),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/register_bg.png")),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: TextFormField(
                  cursorColor: Color(0xff0F3966),
                  cursorErrorColor: Colors.red,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter your Name";
                    } else {
                      return null;
                    }
                  },
                  controller: _namecontroller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    prefixIcon: Icon(Icons.person),
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
                    hintText: "Name",
                  ),
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
                      return "Enter your Email";
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
                    hintText: "Email",
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
                      return "Enter your Password";
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
                    hintText: "Password",
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
                      return "confirm Password";
                    } else {
                      return null;
                    }
                  },
                  obscureText: _visible,
                  obscuringCharacter: "*",
                  controller: _confirmpasscontroller,
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
                    hintText: "Confirm Password",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  cursorColor: Color(0xff0F3966),
                  cursorErrorColor: Colors.red,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter your Phone number";
                    } else {
                      return null;
                    }
                  },
                  controller: _phonecontroller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    prefixIcon: Icon(Icons.phone),
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
                    hintText: "Phone number",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  cursorColor: Color(0xff0F3966),
                  cursorErrorColor: Colors.red,
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter your Address";
                    } else {
                      return null;
                    }
                  },
                  controller: _addresscontroller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    prefixIcon: Icon(Icons.location_on),
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
                    hintText: "Address",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Material(
                  color:
                      Colors.transparent, // To keep only the gradient visible
                  child: InkWell(
                    onTap: () async {
                      if (_registerKey.currentState!.validate()) {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                                email: _emailcontroller.text,
                                password: passcontroller.text);
                        if (userCredential.user!.uid != null) {
                          FirebaseFirestore.instance
                              .collection('login')
                              .doc(userCredential.user!.uid)
                              .set({
                            "uid": userCredential.user!.uid,
                            'email': userCredential.user!.email,
                            'createdAt': DateTime.now(),
                            'status': 1,
                            'role': "user"
                          });

                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userCredential.user!.uid)
                              .set({
                            "uid": userCredential.user!.uid,
                            'name': _namecontroller.text,
                            'email': userCredential.user!.email,
                            'phone': _phonecontroller.text,
                            'address': _addresscontroller.text,
                            'createdAt': DateTime.now(),
                            'status': 1,
                            'role': "user"
                          }).then((value) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/userwelcomepage', (Route route) => false);
                          });
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
                          "Register",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20,bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      "Already have an account ? ",
                      style: TextStyle(color: Color(0xff0F3966)),
                    ),
                    InkWell(
                        onTap: () {
                          // to register
                        },
                        child: GestureDetector(
                            onTap: () {

                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (Route route) => false);
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(color: Colors.blue),
                            )))
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
