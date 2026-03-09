import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {

  /* ================= BASE URL ================= */

  static const String baseUrl = "https://cerquita-backend.onrender.com";

  static const headers = {
    "Content-Type": "application/json"
  };

  /* ================= LOGIN ================= */

  static Future login(String email, String password) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: headers,
        body: jsonEncode({
          "email": email,
          "password": password
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {"success": false, "message": "Server error"};

    } catch (e) {

      return {"success": false, "message": "Connection failed"};

    }

  }

  /* ================= REGISTER ================= */

  static Future register(Map data) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: headers,
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return {"success": false, "message": "Connection failed"};

    }

  }

  /* ================= CHECK VENDOR ================= */

  static Future checkVendor(String email) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/vendor/check"),
        headers: headers,
        body: jsonEncode({
          "email": email
        }),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return null;

    }

  }

  /* ================= CREATE SHOP ================= */

  static Future createShop(Map data) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/vendor/create"),
        headers: headers,
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return {"success": false};

    }

  }

  /* ================= GET SHOP ================= */

  static Future getShop(String email) async {

    try {

      final response = await http.get(
        Uri.parse("$baseUrl/vendor/shop/$email"),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return {"success": false};

    }

  }

  /* ================= GET ALL VENDORS ================= */

  static Future getVendors() async {

    try {

      final response = await http.get(
        Uri.parse("$baseUrl/vendors"),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return {"vendors": []};

    }

  }

  /* ================= ADD PRODUCT WITH IMAGE ================= */

  static Future addProduct({
    required String vendorEmail,
    required String productName,
    required String price,
    required String quantity,
    required String category,
    File? imageFile,
  }) async {

    try {

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/product/add"),
      );

      request.fields["vendorEmail"] = vendorEmail;
      request.fields["productName"] = productName;
      request.fields["price"] = price;
      request.fields["quantity"] = quantity;
      request.fields["category"] = category;

      if (imageFile != null) {

        request.files.add(
          await http.MultipartFile.fromPath(
            "image",
            imageFile.path,
          ),
        );

      }

      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      return jsonDecode(responseData);

    } catch (e) {

      return {"success": false};

    }

  }

  /* ================= GET PRODUCTS ================= */

  static Future getProducts(String email) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/product/list"),
        headers: headers,
        body: jsonEncode({
          "email": email
        }),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return {"products": []};

    }

  }

  /* ================= DELETE PRODUCT ================= */

  static Future deleteProduct(String id) async {

    try {

      final response = await http.delete(
        Uri.parse("$baseUrl/product/delete/$id"),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return {"success": false};

    }

  }

}