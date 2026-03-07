import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  /// NGROK URL (keep ngrok running)
  static const String baseUrl = "https://ungrand-stormy-agonizedly.ngrok-free.dev";

  static const headers = {
    "Content-Type": "application/json"
  };

  /* ================= LOGIN ================= */

  static Future login(String email, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    return jsonDecode(response.body);

  }

  /* ================= REGISTER ================= */

  static Future register(Map data) async {

    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: headers,
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);

  }

  /* ================= CHECK VENDOR ================= */

  static Future checkVendor(String email) async {

    final response = await http.post(
      Uri.parse("$baseUrl/vendor/check"),
      headers: headers,
      body: jsonEncode({
        "email": email
      }),
    );

    return jsonDecode(response.body);

  }

  /* ================= CREATE SHOP ================= */

  static Future createShop(Map data) async {

    final response = await http.post(
      Uri.parse("$baseUrl/vendor/create"),
      headers: headers,
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);

  }

  /* ================= GET SHOP ================= */

  static Future getShop(String email) async {

    final response = await http.get(
      Uri.parse("$baseUrl/vendor/shop/$email"),
    );

    return jsonDecode(response.body);

  }

  /* ================= GET ALL VENDORS ================= */

  static Future getVendors() async {

    final response = await http.get(
      Uri.parse("$baseUrl/vendors"),
    );

    return jsonDecode(response.body);

  }

  /* ================= ADD PRODUCT ================= */

  static Future addProduct(Map data) async {

    final response = await http.post(
      Uri.parse("$baseUrl/product/add"),
      headers: headers,
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);

  }

  /* ================= GET PRODUCTS ================= */

  static Future getProducts(String email) async {

    final response = await http.post(
      Uri.parse("$baseUrl/product/list"),
      headers: headers,
      body: jsonEncode({
        "email": email
      }),
    );

    return jsonDecode(response.body);

  }

  /* ================= DELETE PRODUCT ================= */

  static Future deleteProduct(String id) async {

    final response = await http.delete(
      Uri.parse("$baseUrl/product/delete/$id"),
    );

    return jsonDecode(response.body);

  }

}