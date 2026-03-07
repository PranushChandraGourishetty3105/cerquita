import '../services/api_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/common_background.dart';

class VendorProductsPage extends StatefulWidget {
final String email;

const VendorProductsPage({super.key, required this.email});

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

    setState(() {

      products = data["products"] ?? [];
      loading = false;

    });

  } else {

    setState(() => loading = false);

  }

} catch (e) {

  setState(() => loading = false);

}

}

/* ================= DELETE PRODUCT ================= */

Future<void> deleteProduct(String id) async {

try {

  await http.delete(
    Uri.parse("${ApiService.baseUrl}/product/delete/$id"),
  );

  fetchProducts();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Product deleted")),
  );

} catch (e) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Delete failed")),
  );

}

}

/* ================= UI ================= */

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
              children: [

                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(width:10),

                const Text(
                  "Manage Products",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height:20),

          Expanded(

            child: loading

                ? const Center(
                    child: CircularProgressIndicator()
                  )

                : products.isEmpty

                    ? const Center(
                        child: Text(
                          "No products added yet",
                          style: TextStyle(fontSize:16),
                        ),
                      )

                    : ListView.builder(

                        padding: const EdgeInsets.symmetric(horizontal:20),

                        itemCount: products.length,

                        itemBuilder: (context,index){

                          final product = products[index];

                          return Container(

                            margin: const EdgeInsets.only(bottom:18),

                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Row(

                              children: [

                                /// IMAGE
                                product["image"] != null &&
                                        product["image"] != ""

                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          product["image"],
                                          height:70,
                                          width:70,
                                          fit: BoxFit.cover,
                                        ),
                                      )

                                    : Container(
                                        height:70,
                                        width:70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.image),
                                      ),

                                const SizedBox(width:15),

                                /// DETAILS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        product["productName"] ?? "",
                                        style: const TextStyle(
                                          fontSize:16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height:5),

                                      Text("₹${product["price"]}"),

                                      Text(
                                        "Qty: ${product["quantity"]}",
                                        style: const TextStyle(color: Colors.grey),
                                      ),

                                    ],
                                  ),
                                ),

                                /// DELETE
                                IconButton(
                                  icon: const Icon(Icons.delete,color: Colors.red),
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