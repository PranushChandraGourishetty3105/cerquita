import '../services/api_service.dart';
import 'profile_page.dart';
import 'vendor_products_page.dart';
import 'navigation_page.dart';
import 'dart:convert';
import 'dart:async';
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
  List filteredVendors = [];

  bool loading = false;

  Position? userPosition;
  String userAddress = "Detecting location...";

  final PageController bannerController = PageController();
  int currentBanner = 0;

  /* BROCHURES */

  List<String> banners = [
    "https://res.cloudinary.com/dktefvikk/image/upload/v1773078190/b8_knkq77.jpg",
    "https://res.cloudinary.com/dktefvikk/image/upload/v1773078191/b4_jjgtxo.jpg",
    "https://res.cloudinary.com/dktefvikk/image/upload/v1773078190/b3_c9wpfi.jpg",
    "https://res.cloudinary.com/dktefvikk/image/upload/v1773078190/b7_iszbjn.jpg",
    "https://res.cloudinary.com/dktefvikk/image/upload/v1773078189/b2_dmcoiw.jpg"
  ];

  /* CATEGORY ICONS */

  Map<String, IconData> categoryIcons = {
    "All": Icons.store,
    "Fishes": Icons.set_meal,
    "Biryanis": Icons.rice_bowl,
    "Electronics": Icons.electrical_services,
    "Kids Toys": Icons.toys,
    "Sweets": Icons.cake,
    "Sea Food": Icons.restaurant,
    "Utensils": Icons.kitchen,
    "Pet Food": Icons.pets,
    "Juices": Icons.local_drink,
  };

  List<String> categories = [
    "All",
    "Fishes",
    "Biryanis",
    "Electronics",
    "Kids Toys",
    "Sweets",
    "Sea Food",
    "Utensils",
    "Pet Food",
    "Juices",
  ];

  String selectedCategory = "All";

  /* LOCATION */

  Future<void> requestLocation() async {

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission required")),
      );

      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    userPosition = position;

    setState(() {
      userAddress =
          "Lat: ${position.latitude.toStringAsFixed(3)}, Lng: ${position.longitude.toStringAsFixed(3)}";
    });

    fetchVendors();
  }

  /* FETCH VENDORS */

  Future<void> fetchVendors() async {

    setState(() => loading = true);

    try {

      final response =
          await http.get(Uri.parse("${ApiService.baseUrl}/vendors"));

      final data = jsonDecode(response.body);

      List allVendors = data["vendors"] ?? [];

      List nearby = [];

      for (var vendor in allVendors) {

        double lat = double.parse(vendor["latitude"].toString());
        double lng = double.parse(vendor["longitude"].toString());

        double distance = Geolocator.distanceBetween(
          userPosition!.latitude,
          userPosition!.longitude,
          lat,
          lng,
        );

        if (distance <= 15000) {
          nearby.add(vendor);
        }

      }

      vendors = nearby;
      filteredVendors = nearby;

    } catch (e) {}

    setState(() => loading = false);

  }

  /* SEARCH */

  void searchVendor(String text) {

    if (text.isEmpty) {
      setState(() => filteredVendors = vendors);
      return;
    }

    setState(() {
      filteredVendors = vendors.where((vendor) {
        String name = (vendor["shopName"] ?? "").toLowerCase();
        return name.contains(text.toLowerCase());
      }).toList();
    });

  }

  /* CATEGORY FILTER */

  void filterCategory(String category) async {

    setState(() {
      selectedCategory = category;
      loading = true;
    });

    if (category == "All") {
      setState(() {
        filteredVendors = vendors;
        loading = false;
      });
      return;
    }

    List result = [];

    try {

      for (var vendor in vendors) {

        final response = await http.post(
          Uri.parse("${ApiService.baseUrl}/product/list"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": vendor["email"]}),
        );

        final data = jsonDecode(response.body);
        List products = data["products"] ?? [];

        bool hasCategory = products.any((p) =>
            (p["category"] ?? "")
                .toLowerCase()
                .contains(category.toLowerCase()));

        if (hasCategory) {
          result.add(vendor);
        }

      }

    } catch (e) {}

    setState(() {
      filteredVendors = result;
      loading = false;
    });

  }

  /* BANNER AUTO SCROLL */

  void startBannerAutoScroll() {

    Timer.periodic(const Duration(seconds: 3), (timer) {

      if (!bannerController.hasClients) return;

      currentBanner++;

      if (currentBanner >= banners.length) {
        currentBanner = 0;
      }

      bannerController.animateToPage(
        currentBanner,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );

    });

  }

  @override
  void initState() {
    super.initState();
    requestLocation();
    startBannerAutoScroll();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Nearby Stores"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(
                    name: "User",
                    email: widget.email,
                    role: "User",
                  ),
                ),
              );
            },
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(

        child: Column(

          children: [

            const SizedBox(height:10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:16),
              child: Row(
                children: [
                  const Icon(Icons.location_on,color:Colors.orange),
                  const SizedBox(width:5),
                  Expanded(child: Text(userAddress)),
                ],
              ),
            ),

            const SizedBox(height:10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search vendors",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: searchVendor,
              ),
            ),

            const SizedBox(height:15),

            /* BROCHURES */

            SizedBox(
              height:160,
              child: PageView.builder(
                controller: bannerController,
                itemCount: banners.length,
                itemBuilder:(context,index){
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal:16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        banners[index],
                        fit:BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height:15),

            /* CATEGORY SCROLL */

            SizedBox(
              height:90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal:16),
                itemCount: categories.length,
                itemBuilder:(context,index){

                  final category = categories[index];

                  return GestureDetector(

                    onTap: ()=>filterCategory(category),

                    child: Container(

                      width:110,
                      margin: const EdgeInsets.only(right:12),

                      decoration: BoxDecoration(
                        color: selectedCategory==category
                            ? Colors.blue
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Icon(
                            categoryIcons[category],
                            size:22,
                            color:selectedCategory==category
                                ? Colors.white
                                : Colors.black,
                          ),

                          const SizedBox(height:5),

                          Text(
                            category,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:11,
                              fontWeight: FontWeight.bold,
                              color:selectedCategory==category
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),

                        ],
                      ),

                    ),

                  );

                },
              ),
            ),

            const SizedBox(height:20),

            /* VENDOR LIST */

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal:16),
              itemCount: filteredVendors.length,
              itemBuilder:(context,index){

                final vendor = filteredVendors[index];

                double lat = double.parse(vendor["latitude"].toString());
                double lng = double.parse(vendor["longitude"].toString());

                return storeCard(vendor,lat,lng);

              },
            )

          ],
        ),
      ),
    );
  }

  Widget storeCard(dynamic vendor,double lat,double lng){

    double distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      lat,
      lng,
    );

    double km = distance/1000;

    return Container(

      margin: const EdgeInsets.only(bottom:20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(

        children: [

          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              vendor["shopImage"] ?? "https://via.placeholder.com/300",
              height:160,
              width:double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(

            padding: const EdgeInsets.all(14),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  vendor["shopName"] ?? "",
                  style: const TextStyle(
                      fontSize:18,fontWeight:FontWeight.bold),
                ),

                const SizedBox(height:6),

                Text("${km.toStringAsFixed(1)} km away"),

                const SizedBox(height:12),

                Row(

                  children: [

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                        ),
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VendorProductsPage(
                                email: vendor["email"],
                                vendorLat: lat,
                                vendorLng: lng,
                                shopName: vendor["shopName"] ?? "Shop",
                                role:"User",
                              ),
                            ),
                          );
                        },
                        child: const Text("View Products"),
                      ),
                    ),

                    const SizedBox(width:10),

                    IconButton(
                      icon: const Icon(Icons.navigation),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NavigationPage(
                              vendorLat: lat,
                              vendorLng: lng,
                              shopName: vendor["shopName"] ?? "Shop",
                            ),
                          ),
                        );
                      },
                    )

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