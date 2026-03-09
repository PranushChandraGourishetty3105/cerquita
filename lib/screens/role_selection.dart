import 'package:flutter/material.dart';
import 'login_screen.dart';

class RoleSelection extends StatelessWidget {
  const RoleSelection({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(

              children: [

                const SizedBox(height: 20),

                const Icon(
                  Icons.storefront,
                  size: 60,
                  color: Color(0xFFFF6B00),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Welcome to Cerquita",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Select how you want to explore the community",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                buildCard(
                  context,
                  title: "I'm a Customer",
                  description:
                      "Discover nearby vendors, explore products and support local businesses.",
                  button: "Select User",
                  role: "user",
                  icon: Icons.person_search,
                ),

                const SizedBox(height: 20),

                buildCard(
                  context,
                  title: "I'm a Vendor",
                  description:
                      "Manage your shop, list products and reach customers nearby.",
                  button: "Select Vendor",
                  role: "vendor",
                  icon: Icons.store,
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text("Already have an account? "),

                    GestureDetector(

                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(role: "user"),
                          ),
                        );

                      },

                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFFFF6B00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    )

                  ],
                ),

                const SizedBox(height: 20)

              ],

            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard(
    BuildContext context, {
    required String title,
    required String description,
    required String button,
    required String role,
    required IconData icon,
  }) {

    return Container(

      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E8),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              size: 32,
              color: const Color(0xFFFF6B00),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(role: role),
                  ),
                );

              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              child: Text(
                button,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ),

          ),

        ],

      ),

    );
  }
}