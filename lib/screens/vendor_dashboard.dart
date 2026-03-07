import '../services/api_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'vendor_shop_page.dart';
import 'vendor_products_page.dart';
import 'vendor_profile_page.dart';
import 'add_product_page.dart';
import 'login_screen.dart';
import 'widgets/common_background.dart';

class VendorDashboard extends StatefulWidget {
  final String email;

  const VendorDashboard({super.key, required this.email});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {

  Map? shop;

  @override
  void initState() {
    super.initState();
    fetchShop();
  }

  /* ================= FETCH SHOP ================= */

  Future<void> fetchShop() async {

    try {

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/vendor/shop/${widget.email}"),
      );

      final data = jsonDecode(response.body);

      setState(() {
        shop = data["shop"];
      });

    } catch (e) {
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [

              /// HEADER
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "Vendor Panel",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,color: Colors.white),

                      onSelected: (value){

                        if(value == "profile"){

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VendorProfilePage(email: widget.email),
                            ),
                          );

                        }

                        if(value == "logout"){

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LoginScreen(role: "vendor"),
                            ),
                            (route) => false,
                          );

                        }

                      },

                      itemBuilder: (context)=>const[
                        PopupMenuItem(
                          value: "profile",
                          child: Text("Profile"),
                        ),
                        PopupMenuItem(
                          value: "logout",
                          child: Text("Logout"),
                        )
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height:20),

              /// SHOP CARD
              if(shop != null)

              Padding(
                padding: const EdgeInsets.symmetric(horizontal:20),

                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff141E30), Color(0xff243B55)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    borderRadius: BorderRadius.circular(22),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0,6),
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// SHOP NAME
                      Text(
                        shop!["shopName"] ?? "",
                        style: const TextStyle(
                          fontSize:26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height:10),

                      /// ADDRESS
                      Row(
                        children: [

                          const Icon(Icons.location_on,color: Colors.white),

                          const SizedBox(width:6),

                          Expanded(
                            child: Text(
                              shop!["address"] ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height:6),

                      /// TIME
                      Row(
                        children: [

                          const Icon(Icons.access_time,color: Colors.white),

                          const SizedBox(width:6),

                          Text(
                            "${shop!["openingTime"]} - ${shop!["closingTime"]}",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )

                        ],
                      ),

                      const SizedBox(height:6),

                      /// CONTACT
                      Row(
                        children: [

                          const Icon(Icons.phone,color: Colors.white),

                          const SizedBox(width:6),

                          Text(
                            shop!["contactNumber"] ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )

                        ],
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height:25),

              /// DASHBOARD OPTIONS

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal:20),

                  child: Column(
                    children: [

                      dashboardCard(
                        context,
                        Icons.store,
                        "Edit Shop Details",
                        "Update shop info",
                        VendorShopPage(email: widget.email),
                      ),

                      const SizedBox(height:20),

                      dashboardCard(
                        context,
                        Icons.add_box,
                        "Add Product",
                        "Add new products",
                        AddProductPage(email: widget.email),
                      ),

                      const SizedBox(height:20),

                      dashboardCard(
                        context,
                        Icons.inventory,
                        "Manage Products",
                        "Edit price & quantity",
                        VendorProductsPage(email: widget.email),
                      ),

                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      Widget page
      ){

    return InkWell(

      borderRadius: BorderRadius.circular(20),

      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0,5),
            )
          ],
        ),

        child: Row(
          children: [

            Icon(icon,size:40,color: Colors.black),

            const SizedBox(width:20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize:18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height:5),

                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  )

                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}