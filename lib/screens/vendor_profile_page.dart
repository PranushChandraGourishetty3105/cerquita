import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/common_background.dart';

class VendorProfilePage extends StatefulWidget {

  final String email;

  const VendorProfilePage({super.key, required this.email});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {

  Map user = {};
  Map shop = {};
  int productCount = 0;

  bool loading = true;

  final String baseUrl = "http://localhost:5000";

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  /* ================= FETCH PROFILE ================= */

  Future<void> fetchProfile() async {

    try {

      final response = await http.get(
        Uri.parse("$baseUrl/vendor/profile/${widget.email}")
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        setState(() {

          user = data["user"] ?? {};
          shop = data["shop"] ?? {};
          productCount = data["productCount"] ?? 0;

          loading = false;

        });

      } else {

        setState(() => loading = false);

      }

    } catch (e) {

      setState(() => loading = false);

    }

  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(

          child: loading
              ? const Center(child: CircularProgressIndicator())

              : Column(
                  children: [

                    /// HEADER WITH BACK BUTTON
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [

                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            "Vendor Profile",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),

                        child: Column(
                          children: [

                            /// ACCOUNT INFO
                            profileCard(
                              title: "Account Information",
                              children: [

                                infoRow("Name", user["name"] ?? ""),

                                infoRow("Email", user["email"] ?? ""),

                                infoRow("Role", "Vendor"),

                              ],
                            ),

                            const SizedBox(height: 20),

                            /// SHOP INFO
                            profileCard(
                              title: "Shop Information",
                              children: [

                                infoRow(
                                    "Shop Name",
                                    shop["shopName"] ?? "Not added"),

                                infoRow(
                                    "Address",
                                    shop["address"] ?? "Not added"),

                                infoRow(
                                    "Opening Time",
                                    shop["openingTime"] ?? "-"),

                                infoRow(
                                    "Closing Time",
                                    shop["closingTime"] ?? "-"),

                                infoRow(
                                    "Contact",
                                    shop["contactNumber"] ?? "-"),

                              ],
                            ),

                            const SizedBox(height: 20),

                            /// PRODUCT STATS
                            profileCard(
                              title: "Statistics",
                              children: [

                                infoRow(
                                  "Total Products",
                                  productCount.toString(),
                                ),

                              ],
                            ),

                          ],
                        ),
                      ),
                    ),

                  ],
                ),
        ),
      ),
    );
  }

  /* ================= PROFILE CARD ================= */

  Widget profileCard({
    required String title,
    required List<Widget> children,
  }) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...children,

        ],
      ),
    );
  }

  /* ================= INFO ROW ================= */

  Widget infoRow(String label, String value) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),

        ],
      ),
    );
  }
}