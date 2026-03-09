import 'package:flutter/material.dart';
import 'role_selection.dart';

class ProfilePage extends StatelessWidget {

  final String name;
  final String email;
  final String role;

  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFFFF6B00),
      ),

      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              /* PROFILE IMAGE */

              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange.shade200,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /* USER DETAILS */

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Name"),
                  subtitle: Text(name),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(email),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("Role"),
                  subtitle: Text(role),
                ),
              ),

              const SizedBox(height: 30),

              /* HELP SECTION */

              const Text(
                "Help & Support",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const ListTile(
                  leading: Icon(Icons.support_agent),
                  title: Text("Customer Care"),
                  subtitle: Text("Cerquita Support Team"),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const ListTile(
                  leading: Icon(Icons.phone),
                  title: Text("Contact"),
                  subtitle: Text("+91 9876543210"),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const ListTile(
                  leading: Icon(Icons.language),
                  title: Text("Website"),
                  subtitle: Text("www.cerquita.com"),
                ),
              ),

              const SizedBox(height: 40),

              /* LOGOUT BUTTON */

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () {

                    Navigator.pushAndRemoveUntil(

                      context,

                      MaterialPageRoute(
                        builder: (context) => const RoleSelection(),
                      ),

                      (route) => false,

                    );

                  },

                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ),
              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}