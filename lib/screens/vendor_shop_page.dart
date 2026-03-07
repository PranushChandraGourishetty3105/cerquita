import '../services/api_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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
  print(e);
}

}

/* ================= GET LOCATION ================= */

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

  showMessage("Failed to detect location");

}

}

/* ================= TIME PICKER ================= */

Future<void> pickTime(TextEditingController controller) async {

TimeOfDay? time = await showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
);

if (time != null) {

  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);

  final formattedTime =
      TimeOfDay.fromDateTime(dt).format(context);

  controller.text = formattedTime;

}

}

/* ================= SAVE SHOP ================= */

Future<void> saveShop() async {

if (shopController.text.isEmpty ||
    proprietorController.text.isEmpty ||
    addressController.text.isEmpty ||
    contactController.text.isEmpty) {

  showMessage("Please fill all fields");
  return;
}

setState(() => loading = true);

try {

  final response = await http.post(
    Uri.parse("${ApiService.baseUrl}/vendor/create"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({

      "email": widget.email,
      "shopName": shopController.text,
      "proprietorName": proprietorController.text,
      "address": addressController.text,
      "openingTime": openController.text,
      "closingTime": closeController.text,
      "contactNumber": contactController.text,
      "latitude": latitude,
      "longitude": longitude

    }),
  );

  final data =
      response.body.isNotEmpty ? jsonDecode(response.body) : {};

  setState(() => loading = false);

  if (response.statusCode == 200 && data["success"] == true) {

    showMessage("Shop saved successfully");

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
      child: Column(
        children: [

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
                  icon: const Icon(Icons.arrow_back,color: Colors.white),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(width:10),

                const Text(
                  "Shop Setup",
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
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [

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

                    TextField(
                      controller: openController,
                      readOnly: true,
                      onTap: () => pickTime(openController),
                      decoration: const InputDecoration(
                        labelText: "Opening Time",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: closeController,
                      readOnly: true,
                      onTap: () => pickTime(closeController),
                      decoration: const InputDecoration(
                        labelText: "Closing Time",
                        border: OutlineInputBorder(),
                      ),
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

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : saveShop,
                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text("Save Shop"),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    ),
  ),
);

}
}