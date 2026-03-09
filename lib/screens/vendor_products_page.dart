import '../services/api_service.dart';
import 'add_product_page.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/common_background.dart';

class VendorProductsPage extends StatefulWidget {

  final String email;
  final double vendorLat;
  final double vendorLng;
  final String shopName;
  final String role;

  final double? minPrice;
  final double? maxPrice;

  final String? category; // ⭐ NEW

  const VendorProductsPage({
    super.key,
    required this.email,
    required this.vendorLat,
    required this.vendorLng,
    required this.shopName,
    required this.role,
    this.minPrice,
    this.maxPrice,
    this.category, // ⭐ NEW
  });

  @override
  State<VendorProductsPage> createState() => _VendorProductsPageState();
}

class _VendorProductsPageState extends State<VendorProductsPage> {

  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  /* ================= FETCH PRODUCTS ================= */

  Future<void> fetchProducts() async {

    try {

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/product/list"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        List allProducts = data["products"] ?? [];

        /* ⭐ CATEGORY FILTER */

        if(widget.category != null){

          allProducts = allProducts.where((product){

            String productCategory =
                (product["category"] ?? "").toLowerCase();

            return productCategory ==
                widget.category!.toLowerCase();

          }).toList();

        }

        /* ⭐ PRICE FILTER */

        if(widget.minPrice != null && widget.maxPrice != null){

          allProducts = allProducts.where((product){

            double price =
                double.tryParse(product["price"].toString()) ?? 0;

            return price >= widget.minPrice! &&
                   price <= widget.maxPrice!;

          }).toList();

        }

        setState(() {
          products = allProducts;
          loading = false;
        });

      }

    } catch (e) {
      setState(() => loading = false);
    }
  }

  /* ================= DELETE PRODUCT ================= */

  Future<void> deleteProduct(String id) async {

    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: const Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context,false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context,true),
              child: const Text("Delete"),
            )
          ],
        );
      },
    ) ?? false;

    if(!confirm) return;

    try {

      await http.delete(
        Uri.parse("${ApiService.baseUrl}/product/delete/$id"),
      );

      fetchProducts();

    } catch (e) {}

  }

  /* ================= PRODUCT IMAGE ================= */

  Widget productImage(String? url) {

    if (url == null || url.isEmpty) {
      return Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.fastfood,size:40,color:Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        errorBuilder: (context,error,stackTrace){
          return Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.broken_image,color:Colors.grey),
          );
        },
      ),
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      /* ADD BUTTON ONLY FOR VENDOR */

      floatingActionButton: widget.role == "Vendor"
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFFF6B00),
              child: const Icon(Icons.add),
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProductPage(email: widget.email),
                  ),
                ).then((_) {
                  fetchProducts();
                });

              },
            )
          : null,

      body: CommonBackground(

        child: SafeArea(

          child: Column(

            children: [

              /* HEADER */

              Container(
                padding: const EdgeInsets.fromLTRB(16,20,16,20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B00),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),

                child: Row(

                  children: [

                    IconButton(
                      icon: const Icon(Icons.arrow_back,color:Colors.white),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(width:5),

                    const Icon(Icons.store,color: Colors.white),

                    const SizedBox(width:10),

                    Expanded(
                      child: Text(
                        widget.shopName,
                        style: const TextStyle(
                          fontSize:20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height:20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal:20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Products",
                    style: TextStyle(
                      fontSize:18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height:10),

              /* PRODUCTS LIST */

              Expanded(

                child: loading
                    ? const Center(child: CircularProgressIndicator())

                    : products.isEmpty
                        ? const Center(
                            child: Text(
                              "No products found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(

                            padding: const EdgeInsets.all(20),
                            itemCount: products.length,

                            itemBuilder: (context,index){

                              final product = products[index];

                              return Container(

                                margin: const EdgeInsets.only(bottom:15),
                                padding: const EdgeInsets.all(15),

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),

                                child: Row(

                                  children: [

                                    productImage(product["image"]),

                                    const SizedBox(width:15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            product["productName"] ?? "",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:16,
                                            ),
                                          ),

                                          const SizedBox(height:5),

                                          Text(
                                            "₹${product["price"]}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          const SizedBox(height:3),

                                          Text(
                                            "Stock: ${product["quantity"]}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),

                                          const SizedBox(height:3),

                                          Text(
                                            product["category"] ?? "",
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize:12,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),

                                    if(widget.role == "Vendor")
                                      IconButton(
                                        icon: const Icon(Icons.delete,color:Colors.red),
                                        onPressed: (){
                                          deleteProduct(product["_id"]);
                                        },
                                      )

                                  ],

                                ),

                              );

                            },

                          ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}