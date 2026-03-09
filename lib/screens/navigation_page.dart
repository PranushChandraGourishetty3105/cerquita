import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class NavigationPage extends StatefulWidget {
  final double vendorLat;
  final double vendorLng;
  final String shopName;

  const NavigationPage({
    super.key,
    required this.vendorLat,
    required this.vendorLng,
    required this.shopName,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {

  GoogleMapController? mapController;
  Position? userPosition;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  String distance = "";
  String duration = "";

  List<String> directions = [];
  int currentStep = 0;

  String currentInstruction = "";
  String nextInstruction = "";

  bool navigationStarted = false;

  FlutterTts tts = FlutterTts();
  StreamSubscription<Position>? positionStream;

  /// Replace with your API key
  final String googleApiKey = "AIzaSyBPTPdUW3h6jPl--XF8R_CLEYd1HMsKGTs";

  @override
  void initState() {
    super.initState();
    resetNavigation();
    getUserLocation();
  }

  /* ================= RESET ================= */

  void resetNavigation() {

    directions.clear();
    polylines.clear();
    markers.clear();

    currentStep = 0;
    currentInstruction = "";
    nextInstruction = "";

    navigationStarted = false;

    positionStream?.cancel();
  }

  /* ================= TEXT TO SPEECH ================= */

  Future speak(String text) async {

    await tts.stop();
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1);
    await tts.speak(text);

  }

  /* ================= START NAVIGATION ================= */

  void startNavigation() async {

    if (userPosition == null) return;

    setState(() {
      navigationStarted = true;
    });

    await createRoute();

    speak("Navigation started");

    positionStream?.cancel();

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((Position position) {

      userPosition = position;

      updateUserMarker();
      moveCamera();
      updateInstruction();

      setState(() {});
    });
  }

  /* ================= UPDATE INSTRUCTION ================= */

  void updateInstruction() {

    if (directions.isEmpty) return;
    if (currentStep >= directions.length) return;

    currentInstruction = directions[currentStep];

    if (currentStep + 1 < directions.length) {
      nextInstruction = directions[currentStep + 1];
    }

    speak(currentInstruction);

    currentStep++;
  }

  /* ================= GET USER LOCATION ================= */

  Future<void> getUserLocation() async {

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    createMarkers();
    await createRoute();
    moveCamera();

    setState(() {});
  }

  /* ================= UPDATE USER MARKER ================= */

  void updateUserMarker() {

    if (userPosition == null) return;

    markers.removeWhere((m) => m.markerId.value == "user");

    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: LatLng(
          userPosition!.latitude,
          userPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        rotation: userPosition!.heading,
        anchor: const Offset(0.5, 0.5),
      ),
    );
  }

  /* ================= CREATE MARKERS ================= */

  void createMarkers() {

    LatLng vendorLocation = LatLng(widget.vendorLat, widget.vendorLng);

    markers.add(
      Marker(
        markerId: const MarkerId("vendor"),
        position: vendorLocation,
        infoWindow: InfoWindow(title: widget.shopName),
      ),
    );

    if (userPosition != null) {

      markers.add(
        Marker(
          markerId: const MarkerId("user"),
          position: LatLng(
            userPosition!.latitude,
            userPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }
  }

  /* ================= CREATE ROUTE ================= */

  Future<void> createRoute() async {

    if (userPosition == null) return;

    directions.clear();
    currentStep = 0;

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${userPosition!.latitude},${userPosition!.longitude}"
        "&destination=${widget.vendorLat},${widget.vendorLng}"
        "&mode=driving"
        "&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data["routes"].isEmpty) return;

    distance = data["routes"][0]["legs"][0]["distance"]["text"];
    duration = data["routes"][0]["legs"][0]["duration"]["text"];

    var steps = data["routes"][0]["legs"][0]["steps"];

    for (var step in steps) {

      String instruction = step["html_instructions"];
      instruction = instruction.replaceAll(RegExp(r'<[^>]*>'), '');

      directions.add(instruction);
    }

    if (directions.isNotEmpty) currentInstruction = directions[0];
    if (directions.length > 1) nextInstruction = directions[1];

    PolylinePoints polylinePoints = PolylinePoints();

    List<PointLatLng> points = polylinePoints.decodePolyline(
      data["routes"][0]["overview_polyline"]["points"],
    );

    List<LatLng> polylineCoordinates = [];

    for (var point in points) {
      polylineCoordinates.add(
        LatLng(point.latitude, point.longitude),
      );
    }

    polylines.clear();

    polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: polylineCoordinates,
        width: 6,
        color: Colors.blue,
      ),
    );
  }

  /* ================= MOVE CAMERA ================= */

  void moveCamera() {

    if (mapController == null || userPosition == null) return;

    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            userPosition!.latitude,
            userPosition!.longitude,
          ),
          zoom: 18,
          bearing: userPosition!.heading,
          tilt: 60,
        ),
      ),
    );
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {

    LatLng vendorLocation = LatLng(widget.vendorLat, widget.vendorLng);

    return Scaffold(

      body: Stack(

        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: vendorLocation,
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),

          if (navigationStarted)
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Column(
              children: [

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [

                      const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 28,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          currentInstruction,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [

                      const Text(
                        "Then ",
                        style: TextStyle(color: Colors.white),
                      ),

                      const Icon(
                        Icons.turn_left,
                        color: Colors.white,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          nextInstruction,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                    ],
                  ),
                )

              ],
            ),
          ),

          if (!navigationStarted)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: startNavigation,
              icon: const Icon(Icons.navigation),
              label: const Text("Start Navigation"),
            ),
          )

        ],
      ),
    );
  }
}