import '../services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'vendor_products_page.dart';
import 'navigation_page.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class UserHomePage extends StatefulWidget {
final String email;

const UserHomePage({super.key, required this.email});

@override
State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

List vendors = [];
Position? userPosition;

bool loading = false;
bool locationDetected = false;

String locationName = "Tap to detect location";

/* ================= LOCATION ================= */

Future<void> getLocation() async {

setState(() {
  loading = true;
});

try {

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  userPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

} catch (e) {

  userPosition = Position(
    latitude: 17.3850,
    longitude: 78.4867,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );

}

try {

  List<Placemark> placemarks = await placemarkFromCoordinates(
    userPosition!.latitude,
    userPosition!.longitude,
  );

  Placemark place = placemarks.first;

  setState(() {

    locationName =
        "${place.locality ?? "Hyderabad"}, ${place.administrativeArea ?? ""}";

    locationDetected = true;

  });

} catch (e) {

  locationName = "Hyderabad";
  locationDetected = true;

}

fetchVendors();

}

/* ================= FETCH VENDORS ================= */

Future<void> fetchVendors() async {

try {

  final response = await http.get(
    Uri.parse("${ApiService.baseUrl}/vendors"),
  );

  final data = jsonDecode(response.body);

  List allVendors = data["vendors"] ?? [];

  List nearby = [];

  for (var vendor in allVendors) {

    if (userPosition == null) continue;

    double lat = double.parse(vendor["latitude"].toString());
    double lng = double.parse(vendor["longitude"].toString());

    double distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      lat,
      lng,
    );

    if (distance <= 10000) {
      nearby.add(vendor);
    }

  }

  setState(() {

    vendors = nearby;
    loading = false;

  });

} catch (e) {

  print("Vendor fetch error: $e");

  setState(() {
    loading = false;
  });

}

}

/* ================= UI ================= */

@override
Widget build(BuildContext context) {

return Scaffold(

  backgroundColor: Colors.grey[100],

  appBar: AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Row(
          children: [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 5),
            Text(
              "Home",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.black)
          ],
        ),

        Text(
          locationName,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        )

      ],
    ),

    actions: [
      IconButton(
        icon: const Icon(Icons.account_circle, color: Colors.black),
        onPressed: () {},
      )
    ],
  ),

  body: !locationDetected
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.location_on, size: 60, color: Colors.red),

              const SizedBox(height: 20),

              const Text(
                "Detect your location to see nearby vendors",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: getLocation,
                child: const Text("Detect Location"),
              )

            ],
          ),
        )
      : loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search nearby stores",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Nearby Stores",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  GridView.builder(

                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    padding: const EdgeInsets.symmetric(horizontal: 10),

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),

                    itemCount: vendors.length,

                    itemBuilder: (context, index) {

                      return storeCard(vendors[index]);

                    },

                  ),

                  const SizedBox(height: 20)

                ],

              ),

            ),
);

}

/* ================= STORE CARD ================= */

Widget storeCard(dynamic vendor) {

if (userPosition == null) return const SizedBox();

double lat = double.parse(vendor["latitude"].toString());
double lng = double.parse(vendor["longitude"].toString());

double distance = Geolocator.distanceBetween(
  userPosition!.latitude,
  userPosition!.longitude,
  lat,
  lng,
);

double km = distance / 1000;

return Container(

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
      )
    ],
  ),

  child: Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Image.network(
          "https://source.unsplash.com/400x300/?shop,store",
          height: 100,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              vendor["shopName"] ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 3),

            Text(
              "${km.toStringAsFixed(1)} km away",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VendorProductsPage(
                            email: vendor["email"],
                          ),
                        ),
                      );

                    },

                    child: const Text("View", style: TextStyle(fontSize: 12)),
                  ),
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NavigationPage(
                            vendorLat: lat,
                            vendorLng: lng,
                            shopName: vendor["shopName"],
                          ),
                        ),
                      );

                    },

                    child: const Text("Navigate", style: TextStyle(fontSize: 12)),
                  ),
                ),

              ],
            )

          ],
        ),
      )

    ],

  ),

);

}

}