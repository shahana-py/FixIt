
import 'package:fixit/core/utils/custom_texts/app_bar_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/shared/services/image_service.dart';


class ViewAllUsersPage extends StatefulWidget {
  const ViewAllUsersPage({Key? key}) : super(key: key);

  @override
  State<ViewAllUsersPage> createState() => _ViewAllUsersPageState();
}

class _ViewAllUsersPageState extends State<ViewAllUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isSearching = false;

  Widget _buildUserAvatar(String? profileImageUrl, String name) {
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(profileImageUrl),
        child: profileImageUrl.isEmpty
            ? Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      );
    } else {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xff0F3966),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search by name, email, or phone",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        )
            : AppBarTitle(text: "All Users"),
        backgroundColor: Color(0xff0F3966),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          _isSearching
              ? IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchQuery = "";
                _searchController.clear();
              });
            },
          )
              : IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No users found"));
          }

          var users = snapshot.data!.docs.where((doc) {
            var user = doc.data() as Map<String, dynamic>;
            return user['name'].toString().toLowerCase().contains(_searchQuery) ||
                user['email'].toString().toLowerCase().contains(_searchQuery) ||
                user['phone'].toString().toLowerCase().contains(_searchQuery);
          }).toList();

          if (users.isEmpty) {
            return Center(
              child: Text(
                "No users found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index].data() as Map<String, dynamic>;
              String name = user['name'] ?? "Unknown";
              String? profileImageUrl = user['profileImageUrl'];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: _buildUserAvatar(profileImageUrl, name),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0F3966),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${user['email'] ?? 'N/A'}"),
                      Text("Phone: ${user['phone'] ?? 'N/A'}"),
                      Text("Address: ${user['address'] ?? 'N/A'}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}