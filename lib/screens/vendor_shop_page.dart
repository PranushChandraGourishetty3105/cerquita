import '../services/api_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'vendor_dashboard.dart';
import 'widgets/common_background.dart';

class VendorShopPage extends StatefulWidget {
  final String email;

  const VendorShopPage({super.key, required this.email});

  @override
  State<VendorShopPage> createState() => _VendorShopPageState();
}

class _VendorShopPageState extends State<VendorShopPage> {

  final shopController = TextEditingController();
  final proprietorController = TextEditingController();
  final addressController = TextEditingController();
  final openController = TextEditingController();
  final closeController = TextEditingController();
  final contactController = TextEditingController();

  bool loading = false;

  double? latitude;
  double? longitude;

  File? shopImage;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchShop();
  }

  /* ================= PICK IMAGE ================= */

  Future<void> pickImage() async {

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {

      setState(() {
        shopImage = File(picked.path);
      });

    }

  }

  /* ================= FETCH EXISTING SHOP ================= */

  Future<void> fetchShop() async {

    try {

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/vendor/shop/${widget.email}"),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true && data["shop"] != null) {

        final shop = data["shop"];

        setState(() {

          shopController.text = shop["shopName"] ?? "";
          proprietorController.text = shop["proprietorName"] ?? "";
          addressController.text = shop["address"] ?? "";
          openController.text = shop["openingTime"] ?? "";
          closeController.text = shop["closingTime"] ?? "";
          contactController.text = shop["contactNumber"] ?? "";

          latitude = shop["latitude"];
          longitude = shop["longitude"];

        });

      }

    } catch (e) {
      debugPrint("Fetch shop error: $e");
    }

  }

  /* ================= LOCATION ================= */

  Future<void> getLocation() async {

    try {

      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        showMessage("Location permission denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {

        latitude = position.latitude;
        longitude = position.longitude;

        addressController.text =
            "Lat: ${latitude!.toStringAsFixed(5)}, Lng: ${longitude!.toStringAsFixed(5)}";

      });

      showMessage("Location detected");

    } catch (e) {

      showMessage("Location detection failed");

    }

  }

  /* ================= TIME PICKER ================= */

  Future<void> pickTime(TextEditingController controller) async {

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {

      controller.text = time.format(context);

    }

  }

  /* ================= SAVE SHOP ================= */

  Future<void> saveShop() async {

    if (shopController.text.isEmpty ||
        proprietorController.text.isEmpty ||
        contactController.text.isEmpty) {

      showMessage("Please fill all fields");
      return;
    }

    if (latitude == null || longitude == null) {

      showMessage("Please detect location first");
      return;

    }

    setState(() => loading = true);

    try {

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiService.baseUrl}/vendor/create"),
      );

      request.fields["email"] = widget.email;
      request.fields["shopName"] = shopController.text;
      request.fields["proprietorName"] = proprietorController.text;
      request.fields["address"] = addressController.text;
      request.fields["openingTime"] = openController.text;
      request.fields["closingTime"] = closeController.text;
      request.fields["contactNumber"] = contactController.text;
      request.fields["latitude"] = latitude!.toString();
      request.fields["longitude"] = longitude!.toString();

      if (shopImage != null) {

        request.files.add(
          await http.MultipartFile.fromPath(
            "image",
            shopImage!.path,
          ),
        );

      }

      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      final data = jsonDecode(responseData);

      if (!mounted) return;

      setState(() => loading = false);

      if (data["success"] == true) {

        showMessage(data["message"] ?? "Shop saved successfully");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VendorDashboard(email: widget.email),
          ),
        );

      } else {

        showMessage(data["message"] ?? "Failed to save shop");

      }

    } catch (e) {

      if (mounted) {
        setState(() => loading = false);
      }

      showMessage("Server connection failed");

    }

  }

  /* ================= SNACKBAR ================= */

  void showMessage(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));

  }

  @override
  void dispose() {

    shopController.dispose();
    proprietorController.dispose();
    addressController.dispose();
    openController.dispose();
    closeController.dispose();
    contactController.dispose();

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

            child: Container(

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20,
                  )
                ],
              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Shop Setup",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /* SHOP IMAGE */

                  Center(

                    child: GestureDetector(

                      onTap: pickImage,

                      child: CircleAvatar(

                        radius: 55,

                        backgroundColor: Colors.grey.shade200,

                        backgroundImage:
                            shopImage != null ? FileImage(shopImage!) : null,

                        child: shopImage == null
                            ? const Icon(Icons.camera_alt, size: 30)
                            : null,

                      ),

                    ),

                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: shopController,
                    decoration: const InputDecoration(
                      labelText: "Shop Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: proprietorController,
                    decoration: const InputDecoration(
                      labelText: "Proprietor Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: addressController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Latitude & Longitude",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: getLocation,
                    icon: const Icon(Icons.location_on),
                    label: const Text("Detect Location"),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: TextField(
                          controller: openController,
                          readOnly: true,
                          onTap: () => pickTime(openController),
                          decoration: const InputDecoration(
                            labelText: "Opening Time",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: TextField(
                          controller: closeController,
                          readOnly: true,
                          onTap: () => pickTime(closeController),
                          decoration: const InputDecoration(
                            labelText: "Closing Time",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Contact Number",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),

                      onPressed: loading ? null : saveShop,

                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Save Shop",
                              style: TextStyle(fontSize: 17),
                            ),

                    ),
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