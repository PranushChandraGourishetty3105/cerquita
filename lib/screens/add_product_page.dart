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

  final String baseUrl = "https://cerquita-backend.onrender.com";

  List<String> categories = [
    "Fishes",
    "Biryanis",
    "Sensors",
    "Electronics",
    "Kids Toys",
    "Sweets",
    "Sea Food",
    "Lab Equipments",
    "Utensils",
    "Imported Shirts",
    "Special Juices",
    "Pet Food",
    "Chemical Equipments",
    "Marbles",
    "Other"
  ];

  String selectedCategory = "Other";

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

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/product/add"),
      );

      request.fields["vendorEmail"] = widget.email;
      request.fields["productName"] = nameController.text.trim();
      request.fields["price"] = price.toString();
      request.fields["quantity"] = quantityController.text.trim();
      request.fields["category"] = selectedCategory;

      if (imageFile != null && await imageFile!.exists()) {

        request.files.add(
          await http.MultipartFile.fromPath(
            "image",
            imageFile!.path,
          ),
        );

      }

      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      Map data = {};

      try {
        data = jsonDecode(responseData);
      } catch (e) {
        data = {"success": false};
      }

      setState(() => loading = false);

      if (response.statusCode == 200 && data["success"] == true) {

        nameController.clear();
        priceController.clear();
        quantityController.clear();

        setState(() {
          pickedImage = null;
          imageFile = null;
          selectedCategory = "Other";
        });

        showMessage("Product added successfully");

        Navigator.pop(context);

      } else {

        showMessage(data["message"] ?? "Failed to add product");

      }

    } catch (e) {

      setState(() => loading = false);

      showMessage("Server error");

      print("PRODUCT ERROR: $e");

    }

  }

  void showMessage(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));

  }

  @override
  void dispose() {

    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();

    super.dispose();

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

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(
                  children: [

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(width:15),

                    const Text(
                      "Add Product",
                      style: TextStyle(
                        fontSize:26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height:30),

                Container(

                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0,4),
                      )
                    ],
                  ),

                  child: Column(

                    children: [

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Product Name",
                          prefixIcon: const Icon(Icons.fastfood),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height:18),

                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Price",
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height:18),

                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Quantity",
                          prefixIcon: const Icon(Icons.inventory),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height:18),

                      DropdownButtonFormField(

                        value: selectedCategory,

                        items: categories.map((cat){

                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );

                        }).toList(),

                        onChanged: (value){

                          setState(() {
                            selectedCategory = value!;
                          });

                        },

                        decoration: InputDecoration(
                          labelText: "Product Category",
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                      ),

                      const SizedBox(height:22),

                      GestureDetector(
                        onTap: pickImage,
                        child: Container(

                          width: double.infinity,
                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade50,
                          ),

                          child: const Column(

                            children: [

                              Icon(
                                Icons.image_outlined,
                                size:40,
                                color: Colors.grey,
                              ),

                              SizedBox(height:8),

                              Text(
                                "Tap to select product image",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                            ],

                          ),

                        ),
                      ),

                      const SizedBox(height:15),

                      if (pickedImage != null)

                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(
                                  pickedImage!.path,
                                  height:160,
                                  width:double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  imageFile!,
                                  height:160,
                                  width:double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),

                      const SizedBox(height:25),

                      SizedBox(

                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton(

                          onPressed: loading ? null : addProduct,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Add Product",
                                  style: TextStyle(
                                    fontSize:16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

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