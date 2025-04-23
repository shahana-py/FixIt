// import 'package:flutter/material.dart';
//
// class ServiceCard extends StatelessWidget {
//   final String imagePath;
//   final String serviceName;
//   final VoidCallback onTap;
//
//   const ServiceCard({
//     Key? key,
//     required this.imagePath,
//     required this.serviceName,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10),
//       child: GestureDetector(
//         onTap: () => onTap(),
//         child: Card(
//           elevation: 5,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//
//                 child: Image.asset(
//                   imagePath,
//                   // width: 255,
//                   // height: 120,
//                   width: 80,
//                   height: 60,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Container(
//                 // width: 255,
//                 // height: 49,
//                 width: 80,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
//                   color: Colors.white,
//                 ),
//                 child: Center(
//                   child: Text(
//                     serviceName,
//                     style: TextStyle(color:Color(0xff0F3966),fontSize: 10,fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String? imagePath;
  final String serviceName;
  final String? networkImage;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    this.imagePath,
    required this.serviceName,
    this.networkImage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic width for 3 cards per row with padding
    double cardWidth = MediaQuery.of(context).size.width / 3 - 24;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: networkImage != null && networkImage!.isNotEmpty
                    ? Image.network(
                  networkImage!,
                  width: cardWidth,
                  height: 103,
                  fit: BoxFit.cover,
                  // Fallback for network image loading failure
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset(
                        imagePath ?? 'assets/images/placeholder.jpg',
                        width: cardWidth,
                        height: 103,
                        fit: BoxFit.cover,
                      ),
                )
                    : Image.asset(
                  imagePath ?? 'assets/images/placeholder.jpg',
                  width: cardWidth,
                  height: 103,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: cardWidth,
                height: 40,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    serviceName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff0F3966),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

