// import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// import '../../../core/shared/services/image_service.dart';
//
//
// class ProviderReviewsPage extends StatefulWidget {
//   final String providerId;
//   final ImageService imageService;
//
//   const ProviderReviewsPage({
//     Key? key,
//     required this.providerId,
//     required this.imageService,
//   }) : super(key: key);
//
//   @override
//   _ProviderReviewsPageState createState() => _ProviderReviewsPageState();
// }
//
// class _ProviderReviewsPageState extends State<ProviderReviewsPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: AppBarTitle(text: "Customer Reviews"),
//         backgroundColor: const Color(0xff0F3966),
//         elevation: 0,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('ratings')
//             .where('provider_id', isEqualTo: widget.providerId)
//             .snapshots(),
//         builder: (context, ratingsSnapshot) {
//           if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (ratingsSnapshot.hasError) {
//             return Center(child: Text('Error: ${ratingsSnapshot.error}'));
//           }
//
//           if (!ratingsSnapshot.hasData || ratingsSnapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No reviews yet'));
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: ratingsSnapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final rating = ratingsSnapshot.data!.docs[index];
//               return FutureBuilder(
//                 future: _getReviewDetails(rating),
//                 builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Card(
//                       margin: EdgeInsets.only(bottom: 16),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.grey,
//                         ),
//                         title: Text('Loading...'),
//                       ),
//                     );
//                   }
//
//                   if (snapshot.hasError) {
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       child: ListTile(
//                         title: Text('Error loading review: ${snapshot.error}'),
//                       ),
//                     );
//                   }
//
//                   final details = snapshot.data!;
//                   return _buildReviewCard(details);
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Future<Map<String, dynamic>> _getReviewDetails(DocumentSnapshot rating) async {
//     try {
//       // Get user details
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(rating['user_id'])
//           .get();
//
//       // Get service details
//       final serviceDoc = await FirebaseFirestore.instance
//           .collection('services')
//           .doc(rating['service_id'])
//           .get();
//
//       // Handle potential missing image URLs
//       String userImage = userDoc['profileImageUrl'] ?? '';
//       if (userImage.isEmpty) {
//         userImage = await widget.imageService.getPlaceholderImage();
//       }
//
//       return {
//         'userName': userDoc['name'],
//         'userPlace': userDoc['address'],
//         'userImage': userImage,
//         'serviceName': serviceDoc['name'],
//         'rating': rating['rating'],
//         'feedback': rating['feedback'],
//         'date': rating['created_at'].toDate(),
//       };
//     } catch (e) {
//       // Fallback to placeholder image if there's an error
//       return {
//         'userName': 'Unknown User',
//         'userPlace': 'Unknown Location',
//         'userImage': await widget.imageService.getPlaceholderImage(),
//         'serviceName': 'Unknown Service',
//         'rating': 0,
//         'feedback': 'No feedback available',
//         'date': DateTime.now(),
//       };
//     }
//   }
//
//   Widget _buildReviewCard(Map<String, dynamic> details) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildUserAvatar(details['userImage']),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         details['userName'],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         details['userPlace'],
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Chip(
//                   backgroundColor: const Color(0xff0F3966).withOpacity(0.1),
//                   label: Text(
//                     details['serviceName'],
//                     style: TextStyle(
//                       color: const Color(0xff0F3966),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 _buildRatingStars(details['rating']),
//                 const SizedBox(width: 8),
//                 Text(
//                   DateFormat('dd MMM yyyy').format(details['date']),
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               details['feedback'],
//               style: const TextStyle(
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserAvatar(String imageUrl) {
//     return CircleAvatar(
//       radius: 24,
//       backgroundColor: Colors.grey[200],
//       child: ClipOval(
//         child: Image.network(
//           imageUrl,
//           width: 48,
//           height: 48,
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                     loadingProgress.expectedTotalBytes!
//                     : null,
//               ),
//             );
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return Icon(
//               Icons.person,
//               size: 24,
//               color: Colors.grey[600],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRatingStars(int rating) {
//     return Row(
//       children: List.generate(5, (index) {
//         return Icon(
//           index < rating ? Icons.star : Icons.star_border,
//           color: const Color(0xff0F3966),
//           size: 18,
//         );
//       }),
//     );
//   }
// }


import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/shared/services/image_service.dart';

class ProviderReviewsPage extends StatefulWidget {
  final String providerId;
  final ImageService imageService;

  const ProviderReviewsPage({
    Key? key,
    required this.providerId,
    required this.imageService,
  }) : super(key: key);

  @override
  _ProviderReviewsPageState createState() => _ProviderReviewsPageState();
}

class _ProviderReviewsPageState extends State<ProviderReviewsPage> {
  // Map to store individual reply controllers for each review
  final Map<String, TextEditingController> _replyControllers = {};

  @override
  void dispose() {
    // Dispose all controllers
    _replyControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Get or create a controller for a specific rating
  TextEditingController _getControllerForRating(String ratingId, String? existingReply) {
    if (!_replyControllers.containsKey(ratingId)) {
      _replyControllers[ratingId] = TextEditingController(text: existingReply ?? '');
    }
    return _replyControllers[ratingId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const AppBarTitle(text: "Customer Reviews"),
        backgroundColor: const Color(0xff0F3966),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('ratings')
              .where('provider_id', isEqualTo: widget.providerId)
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, ratingsSnapshot) {
            if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ratingsSnapshot.hasError) {
              return Center(child: Text('Error: ${ratingsSnapshot.error}'));
            }

            if (!ratingsSnapshot.hasData || ratingsSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When customers leave reviews, they\'ll appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ratingsSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final rating = ratingsSnapshot.data!.docs[index];
                return FutureBuilder(
                  future: _getReviewDetails(rating),
                  builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey,
                          ),
                          title: Text('Loading...'),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      print('Error in FutureBuilder: ${snapshot.error}');
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text('Error loading review: ${snapshot.error}'),
                        ),
                      );
                    }

                    final details = snapshot.data!;
                    // Add rating ID to the details for edit functionality
                    details['ratingId'] = rating.id;

                    // Add provider_reply and reply_date if they exist in the rating document
                    if (rating.data() is Map && (rating.data() as Map).containsKey('provider_reply')) {
                      details['reply'] = rating['provider_reply'];
                      details['replyDate'] = rating['reply_date']?.toDate();
                    }

                    return _buildReviewCard(details, rating.id);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

    Future<Map<String, dynamic>> _getReviewDetails(DocumentSnapshot rating) async {
    try {
      // Get user details
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(rating['user_id'])
          .get();

      // Get service details
      final serviceDoc = await FirebaseFirestore.instance
          .collection('services')
          .doc(rating['service_id'])
          .get();

      // Handle potential missing image URLs
      String userImage = userDoc['profileImageUrl'] ?? '';
      if (userImage.isEmpty) {
        userImage = await widget.imageService.getPlaceholderImage();
      }

      return {
        'userName': userDoc['name'],
        'userPlace': userDoc['address'],
        'userImage': userImage,
        'serviceName': serviceDoc['name'],
        'rating': rating['rating'],
        'feedback': rating['feedback'],
        'date': rating['created_at'].toDate(),
      };
    } catch (e) {
      // Fallback to placeholder image if there's an error
      return {
        'userName': 'Unknown User',
        'userPlace': 'Unknown Location',
        'userImage': await widget.imageService.getPlaceholderImage(),
        'serviceName': 'Unknown Service',
        'rating': 0,
        'feedback': 'No feedback available',
        'date': DateTime.now(),
      };
    }
  }



  Widget _buildReviewCard(Map<String, dynamic> details, String ratingId) {
    final bool hasReply = details['reply'] != null && details['reply'].isNotEmpty;

    // Get or create controller for this specific rating
    final controller = _getControllerForRating(ratingId, hasReply ? details['reply'] : null);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserAvatar(details['userImage']),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details['userName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        details['userPlace'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildRatingStars(details['rating']),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM yyyy').format(details['date']),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Chip(
                  backgroundColor: const Color(0xff0F3966).withOpacity(0.1),
                  label: Text(
                    details['serviceName'],
                    style: const TextStyle(
                      color: Color(0xff0F3966),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Feedback Expansion Tile
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: const Text(
                  'Customer Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xff0F3966),
                  ),
                ),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                backgroundColor: Colors.grey[50],
                collapsedBackgroundColor: Colors.grey[50],
                iconColor: const Color(0xff0F3966),
                collapsedIconColor: const Color(0xff0F3966),
                leading: const Icon(Icons.comment, size: 18),
                children: [
                  Text(
                    details['feedback'],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Provider Reply Expansion Tile
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: Text(
                  hasReply ? 'Your Reply' : 'Reply to this review',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xff0F3966),
                  ),
                ),
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: hasReply
                      ? const Color(0xff0F3966).withOpacity(0.2)
                      : Colors.grey[300]!),
                ),
                backgroundColor: hasReply
                    ? const Color(0xff0F3966).withOpacity(0.05)
                    : Colors.grey[50],
                collapsedBackgroundColor: hasReply
                    ? const Color(0xff0F3966).withOpacity(0.05)
                    : Colors.grey[50],
                iconColor: const Color(0xff0F3966),
                collapsedIconColor: const Color(0xff0F3966),
                leading: Icon(
                  hasReply ? Icons.reply_all : Icons.reply,
                  size: 18,
                ),
                trailing: hasReply && details['replyDate'] != null
                    ? Wrap(
                  children: [
                    Text(
                      DateFormat('dd MMM').format(details['replyDate']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Icon(Icons.expand_more),
                  ],
                )
                    : null,
                children: [
                  hasReply
                      ? _buildExistingReplyContent(details, controller, ratingId)
                      : _buildReplyForm(controller, ratingId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingReplyContent(
      Map<String, dynamic> details,
      TextEditingController controller,
      String ratingId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          details['reply'],
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 12),
        // Edit button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              _showEditDialog(controller, details, ratingId);
            },
            icon: const Icon(
              Icons.edit,
              size: 16,
              color: Color(0xff0F3966),
            ),
            label: const Text(
              'Edit',
              style: TextStyle(color: Color(0xff0F3966)),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xff0F3966), width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(TextEditingController controller, Map<String, dynamic> details, String ratingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Your Reply',
          style: TextStyle(
            color: Color(0xff0F3966),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Update your response...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _updateReply(ratingId, controller);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0F3966),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyForm(TextEditingController controller, String ratingId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Write your response to this review...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _submitReply(ratingId, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0F3966),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.send, size: 16, color: Colors.white),
            label: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitReply(String ratingId, TextEditingController controller) async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a reply before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('ratings')
          .doc(ratingId)
          .update({
        'provider_reply': controller.text.trim(),
        'reply_date': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // No need to clear the controller as we want to keep showing the reply
      // Just refresh the UI
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateReply(String ratingId, TextEditingController controller) async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('ratings')
          .doc(ratingId)
          .update({
        'provider_reply': controller.text.trim(),
        'reply_date': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the UI to show the updated reply
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildUserAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 24,
              color: Colors.grey[600],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRatingStars(dynamic rating) {
    // Convert the rating to int to handle both int and double cases
    final int ratingAsInt = rating is int ? rating : rating.toInt();
    final double ratingAsDouble = rating is double ? rating : rating.toDouble();
    final bool hasHalfStar = (ratingAsDouble - ratingAsInt) >= 0.5;

    return Row(
      children: List.generate(5, (index) {
        if (index < ratingAsInt) {
          return const Icon(
            Icons.star,
            color: Color(0xFFFFB800), // Gold color for stars
            size: 18,
          );
        } else if (index == ratingAsInt && hasHalfStar) {
          return const Icon(
            Icons.star_half,
            color: Color(0xFFFFB800),
            size: 18,
          );
        } else {
          return const Icon(
            Icons.star_border,
            color: Color(0xFFFFB800),
            size: 18,
          );
        }
      }),
    );
  }
}