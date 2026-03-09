import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'vendor_products_page.dart';
import 'vendor_shop_page.dart';
import 'profile_page.dart';

class VendorDashboard extends StatefulWidget {

  final String email;

  const VendorDashboard({super.key, required this.email});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {

  Map? shop;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchShop();
  }

  /* ================= FETCH SHOP ================= */

  Future<void> fetchShop() async {

    try {

      final data = await ApiService.getShop(widget.email);

      print("SHOP API RESPONSE: $data");

      if (!mounted) return;

      if (data != null && data["success"] == true) {

        if (data["shop"] == null) {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VendorShopPage(email: widget.email),
            ),
          );

          return;
        }

        setState(() {
          shop = data["shop"];
          loading = false;
        });

      } else {

        setState(() => loading = false);

      }

    } catch (e) {

      print("SHOP ERROR: $e");
      setState(() => loading = false);

    }

  }

  /* ================= SHOP IMAGE ================= */

  Widget shopImageWidget() {

    if (shop == null || shop!["shopImage"] == null || shop!["shopImage"] == "") {

      return Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.store, size: 35, color: Colors.grey),
      );

    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        shop!["shopImage"],
        height: 70,
        width: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.store, color: Colors.grey),
          );
        },
      ),
    );

  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Vendor Dashboard"),

        actions: [

          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(
                    name: shop?["proprietorName"] ?? "Vendor",
                    email: widget.email,
                    role: "Vendor",
                  ),
                ),
              );

            },
          )

        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(

              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  /* ================= SHOP CARD ================= */

                  Card(

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Padding(

                      padding: const EdgeInsets.all(20),

                      child: Row(

                        children: [

                          shopImageWidget(),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  shop != null
                                      ? shop!["shopName"] ?? "My Shop"
                                      : "My Shop",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  "Open: ${shop?["openingTime"] ?? "Not set"}",
                                  style: const TextStyle(
                                      color: Colors.grey),
                                ),

                                Text(
                                  "Close: ${shop?["closingTime"] ?? "Not set"}",
                                  style: const TextStyle(
                                      color: Colors.grey),
                                ),

                              ],
                            ),
                          )

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /* ================= ADD PRODUCT ================= */

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                      ),

                      child: const Text("Add Product"),

                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VendorProductsPage(
                              email: widget.email,
                              vendorLat: 0,
                              vendorLng: 0,
                              shopName: shop?["shopName"] ?? "Shop",
                              role: "Vendor",
                            ),
                          ),
                        );

                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  /* ================= MANAGE PRODUCTS ================= */

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),

                      child: const Text("Manage Products"),

                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VendorProductsPage(
                              email: widget.email,
                              vendorLat: 0,
                              vendorLng: 0,
                              shopName: shop?["shopName"] ?? "Shop",
                              role: "Vendor",
                            ),
                          ),
                        );

                      },
                    ),
                  )

                ],
              ),
            ),

    );
  }
}