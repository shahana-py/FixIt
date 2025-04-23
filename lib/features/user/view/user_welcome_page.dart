import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              WelcomePage1(),
              WelcomePage2(),
            ],
          ),
          Positioned(
            top: 30,
            right: 30,
            child: Material(
              elevation: 3,
              color: Colors.white70, // Button color
              borderRadius: BorderRadius.circular(40),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (Route route) => false);
                },
                hoverColor: Colors.blue[100],
                borderRadius: BorderRadius.circular(40),

                child: Container(
                  height: 40,
                  width: 80,

                  alignment: Alignment.center,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xFF0F3966),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F3966),
      //   body: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.only(top: 40,right:45,left:45,bottom: 20),
      //         child: Container(
      //           width: 400,
      //           height: 350,
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(20),
      //                   image: DecorationImage(
      //                       image: AssetImage(
      //                           "assets/images/welcome_image.png"),
      //                       fit: BoxFit.cover)),
      //
      //         ),
      //
      //
      //
      //       ),
      // Text(
      //           "Fix It, Forget It!",
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 40,
      //             fontWeight: FontWeight.bold,
      //             shadows: [
      //               Shadow(
      //                 blurRadius: 4,
      //                 color: Colors.black45,
      //                 offset: Offset(2, 2),
      //               ),
      //             ],
      //           ),
      //         ),
      // SizedBox(
      //   height: 20,
      // ),
      // Center(
      //   child: Text("Life's too short for leaky faucets and creaky doors.\nFixIt connects you with trusted service providers\nwho get the job done.Book, track, and relax \nwe've got this!",
      //
      //         style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 18,
      //             fontWeight: FontWeight.w500),
      //   textAlign: TextAlign.center,),
      // ),
      //
      //
      //     ],
      //   ),

      body: Stack(
        children: [
          Positioned(
            top: 0, // Adjust vertical positioning
            left: 0,
            right: 0,

            child: Align(
              child: Container(
                width: 1800,
                height: 1800,
                decoration: BoxDecoration(
                  color: Color(0xFF0F3966), // Dark Blue
                ),
              ),
            ),
          ),
          // Light Blue Section (Top)
          Positioned(
            top: -200,
            left: 0,
            right: 1,
            bottom: 350,
            child: Container(
              // width: 800,
              // height: 800,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(250),
              width: 1500,
              height: 1500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(350),
                image: DecorationImage(
                    image: AssetImage("assets/images/img.png"),
                    fit: BoxFit.fitHeight),
              ),
            ),
          ),
          // Text inside the dark blue area under the image

          Positioned(
            top: 250,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Fix it,\nForget\nIt!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 90,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: Color(0xFF0F3966),
                    shadows: [
                      Shadow(
                        offset: Offset(3, 3),
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 100),
                Text(
                  "Life's too short for leaky faucets\nand creaky doors.FixIt connects you\nwith trusted service providers who get\nthe job done.Book, track, and relax.\nwe've got this!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePage2 extends StatelessWidget {
  const WelcomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0, // Adjust vertical positioning
            left: 0,
            right: 0,

            child: Align(
              child: Container(
                width: 1800,
                height: 1800,
                decoration: BoxDecoration(
                  color: Color(0xFF0F3966), // Dark Blue
                ),
              ),
            ),
          ),
          // Light Blue Section (Top)
          Positioned(

            top: -200,
            left: 0,
            right: 1,
            bottom: 350,
            child: Container(
              // width: 800,
              // height: 800,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(250),
              width: 1500,
              height: 1500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(350),
                image: DecorationImage(
                    image: AssetImage("assets/images/welcomeimg1.png"),
                    fit: BoxFit.cover),
              ),
            ),

          ),
          // Text inside the dark blue area under the image

          Positioned(
            top: 170,
            left: 40,
            right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Enjoy a\nHassle-Free\nService\nExperience",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(3, 3),
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 230,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.library_add_check,size: 70,color:Colors.white70 ,),
                        SizedBox(height: 10,),
                        Text("Approved &\nExperienced\nProfessionals",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,

                            ),)
                        
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.security,size: 70,color:Colors.white70 ,),
                        SizedBox(height: 10,),
                        Text("Best In-class\nSafety\nMeasures",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,

                          ),)

                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.watch_later_outlined,size: 70,color:Colors.white70 ,),
                        SizedBox(height: 10,),
                        Text("End-to-End\nService\nExperience",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,

                          ),)

                      ],
                    ),

                  ],
                ),
                SizedBox(height: 40,),
                Material(
                  color: Colors.white, // Button color
                  borderRadius: BorderRadius.circular(40),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (Route route) => false);
                    },
                    borderRadius: BorderRadius.circular(40),

                    child: Container(
                      height: 50,
                      width: 400,

                      alignment: Alignment.center,
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          color: Color(0xFF0F3966),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),




              ],
            ),
          ),


        ],
      ),
    );
  }
}