
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  List<Animation<double>> _letterAnimations = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Faster animation
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    for (int i = 0; i < 5; i++) {
      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(i * 0.15, 1.0, curve: Curves.easeInOut), // Faster delay
          ),
        ),
      );
    }

    _controller.forward();

    Future.delayed(Duration(seconds: 4), () {
      checkLoginStatus();
    });
  }

  checkLoginStatus() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String? token = _pref.getString('token');
    String? role = _pref.getString('role');

    if (token != null) {
      if (role == 'user') {
        Navigator.pushNamed(context, '/home');
      } else if (role == 'service provider') {
        Navigator.pushNamed(context, '/serviceProviderHome');
      }
      else if (role == 'admin') {
        Navigator.pushNamed(context, '/adminhome');
      }
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo fades in smoothly
            FadeTransition(
              opacity: _fadeAnimation,
              child: CircleAvatar(
                radius: 50,

                backgroundImage: AssetImage("assets/images/splash.png")
                // child: Container(
                //   width: 100,
                //   height: 100,
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage("assets/images/splash_logo_blue.png"),
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
              ),
            ),
            SizedBox(height: 20),

            // "FixIt" appears letter by letter with smooth effect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return FadeTransition(
                  opacity: _letterAnimations[index],
                  child: Text(
                    "FixIt"[index],
                    style: TextStyle(
                      fontSize: 40,
                      color: Color(0xff0F3966),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}


