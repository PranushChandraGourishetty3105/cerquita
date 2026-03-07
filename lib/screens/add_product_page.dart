import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'widgets/common_background.dart';

class AddProductPage extends StatefulWidget {
  final String email;

  const AddProductPage({super.key, required this.email});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  XFile? pickedImage;
  File? imageFile;

  bool loading = false;

  final String baseUrl = "https://ungrand-stormy-agonizedly.ngrok-free.dev";
  /* ================= PICK IMAGE ================= */

  Future<void> pickImage() async {

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {

        pickedImage = image;

        if (!kIsWeb) {
          imageFile = File(image.path);
        }

      });

    }

  }

  /* ================= ADD PRODUCT ================= */

  Future<void> addProduct() async {

    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        quantityController.text.isEmpty) {

      showMessage("Fill all fields");
      return;

    }

    int price = int.tryParse(priceController.text) ?? 0;

    if (price <= 0) {
      showMessage("Enter valid price");
      return;
    }

    setState(() => loading = true);

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/product/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({

          "vendorEmail": widget.email,
          "productName": nameController.text,
          "price": price,
          "quantity": quantityController.text

        }),
      );

      final data = jsonDecode(response.body);

      setState(() => loading = false);

      if (data["success"] == true) {

        nameController.clear();
        priceController.clear();
        quantityController.clear();

        setState(() {
          pickedImage = null;
        });

        showMessage("Product added successfully");

        Navigator.pop(context);

      } else {

        showMessage("Failed to add product");

      }

    } catch (e) {

      setState(() => loading = false);
      showMessage("Server error");

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                /// HEADER
                Row(
                  children: [

                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      "Add Product",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [

                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Product Name",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Quantity",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Select Product Image"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 15),

                      if (pickedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  pickedImage!.path,
                                  height: 150,
                                )
                              : Image.file(
                                  imageFile!,
                                  height: 150,
                                ),
                        ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(

                          onPressed: loading ? null : addProduct,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),

                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Add Product"),

                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}