import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1F44),
        title: const Text("My Profile"),
      ),
      body: const Center(
        child: Text(
          "User Profile Page",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}