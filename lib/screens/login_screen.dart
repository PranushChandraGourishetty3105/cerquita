import '../services/api_service.dart';
import 'package:flutter/material.dart';

import 'register_screen.dart';
import 'vendor_dashboard.dart';
import 'vendor_shop_page.dart';
import 'user_home_page.dart';
import 'widgets/common_background.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  /* ================= LOGIN USER ================= */

  Future<void> loginUser() async {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage("Enter email and password");
      return;
    }

    setState(() => loading = true);

    try {

      final loginData = await ApiService.login(email, password);

      if (loginData["success"] == true) {

        String role = loginData["role"];

        /// USER LOGIN
        if (role == "user") {

          setState(() => loading = false);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserHomePage(email: email),
            ),
          );

        }

        /// VENDOR LOGIN
        else if (role == "vendor") {

          final shopData = await ApiService.checkVendor(email);

          setState(() => loading = false);

          /// SHOP EXISTS → DASHBOARD
          if (shopData["exists"] == true) {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VendorDashboard(email: email),
              ),
            );

          }

          /// NEW VENDOR → CREATE SHOP
          else {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VendorShopPage(email: email),
              ),
            );

          }

        }

      } else {

        setState(() => loading = false);
        showMessage(loginData["message"] ?? "Login failed");

      }

    } catch (e) {

      setState(() => loading = false);
      showMessage("Server error. Check backend connection.");

    }

  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Container(

                width: 400,

                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      "Login as ${widget.role.toUpperCase()}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Email
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Password
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(

                        onPressed: loading ? null : loginUser,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Login"),

                      ),
                    ),

                    const SizedBox(height: 15),

                    /// REGISTER BUTTON
                    TextButton(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterScreen(role: widget.role),
                          ),
                        );

                      },

                      child: const Text(
                        "Don't have an account? Register",
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}