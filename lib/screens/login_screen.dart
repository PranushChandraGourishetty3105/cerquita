import 'package:flutter/material.dart';
import '../services/api_service.dart';

import 'register_screen.dart';
import 'vendor_dashboard.dart';
import 'vendor_shop_page.dart';
import 'user_home_page.dart';

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
  bool hidePassword = true;

  /* ================= LOGIN ================= */

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

      if (!mounted) return;

      if (loginData == null) {
        showMessage("Server not responding");
        setState(() => loading = false);
        return;
      }

      if (loginData["success"] == true) {

        String role = loginData["role"] ?? "";

        /* ================= USER LOGIN ================= */

        if (role == "user") {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserHomePage(email: email),
            ),
          );

          return;
        }

        /* ================= VENDOR LOGIN ================= */

        if (role == "vendor") {

          final shopData = await ApiService.checkVendor(email);

          print("SHOP DATA: $shopData");

          if (shopData != null && shopData["exists"] == true) {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VendorDashboard(email: email),
              ),
            );

          } else {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VendorShopPage(email: email),
              ),
            );

          }

          return;
        }

        showMessage("Invalid account role");

      } 
      else {

        showMessage(loginData["message"] ?? "Login failed");

      }

    } catch (e) {

      showMessage("Server error");

    }

    if (mounted) {
      setState(() => loading = false);
    }

  }

  /* ================= SNACKBAR ================= */

  void showMessage(String msg) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );

  }

  @override
  void dispose() {

    emailController.dispose();
    passwordController.dispose();

    super.dispose();

  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(24),

            child: Container(

              width: 420,

              padding: const EdgeInsets.all(30),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  )
                ],
              ),

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2E8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 36,
                      color: Color(0xFFFF6B00),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Log in to your account to continue",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email address",
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(

                      onPressed: loading ? null : loginUser,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Log In →",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text("Don't have an account? "),

                      GestureDetector(

                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterScreen(role: widget.role),
                            ),
                          );

                        },

                        child: const Text(
                          "Register now",
                          style: TextStyle(
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      )

                    ],
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}