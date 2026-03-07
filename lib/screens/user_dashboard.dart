import 'package:flutter/material.dart';
import 'user_profile_page.dart';
import 'widgets/common_background.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [

              /// 🔥 Header (Rapido Style)
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
                      "Cerquita",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search groceries, pet food, seafood...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.95),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Vendor List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [

                      buildVendorCard(
                        context,
                        shopName: "Fresh Pet Store",
                        product: "Dog Food 10kg",
                        price: "₹1200",
                        rating: 4.5,
                        distance: "1.2 km",
                      ),

                      buildVendorCard(
                        context,
                        shopName: "Sea Fresh Market",
                        product: "Fresh Prawns 1kg",
                        price: "₹450",
                        rating: 4.2,
                        distance: "2.5 km",
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

  Widget buildVendorCard(
    BuildContext context, {
    required String shopName,
    required String product,
    required String price,
    required double rating,
    required String distance,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
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

          /// Shop Name
          Text(
            shopName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          /// Product
          Text(
            product,
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 12),

          /// Price + Rating + Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              Row(
                children: [
                  const Icon(Icons.star,
                      size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(rating.toString()),
                ],
              ),

              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 18, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(distance),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          /// Navigate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Opening Maps..."),
                  ),
                );
              },
              child: const Text("Navigate"),
            ),
          )
        ],
      ),
    );
  }
}