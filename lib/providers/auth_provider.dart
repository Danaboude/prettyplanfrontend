import 'dart:convert';
import 'package:finalproject/models/user.dart';
import 'package:finalproject/models/withdraw_record.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  int? _userId;
  String? _fullName;
  String? _email;
  String? _role;
   double _accountBalance=0.0;
     double get accountBalance => _accountBalance ;

  int get userId => _userId ?? 0;
  String get fullName => _fullName ?? '';
  String get email => _email ?? '';
  String get role => _role ?? '';

  final String _baseUrl =
      'http://192.168.161.235/finalporject';//تغيير ip
    Future<List<CheckoutRequest>> getWithdrawals(int userId) async {
    final url = Uri.parse('$_baseUrl/user/$userId/withdrawals');
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CheckoutRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load withdrawal history');
    }
  }
  // Add this function:
  Future<bool> submitWithdrawRequest(double amount) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/checkout_requests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'amount': amount,
        'transfer_number': '', // optional or placeholder if required
        'status': 'pending',
      }),
    );

    if (response.statusCode == 200) {
      // Optionally subtract from balance immediately
      _accountBalance -= amount;
      notifyListeners();
      return true;
    } else {
      print("Withdrawal failed: ${response.body}");
      return false;
    }
  }
  Future<void> register(String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': name,
        'email': email,
        'password': password,
        // Do NOT send role anymore
      }),
    );
     print(json.decode(response.body));
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['id'] != null) {
      await login(email, password); // Auto-login after register
    } else {
      throw Exception(data['error'] ?? 'Failed to register');
    }
  }

 Future<void> login(String email, String password) async {
  final url = Uri.parse('$_baseUrl/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email, 'password': password}),
  );
  print(response.body);
  final data = json.decode(response.body);
  print(data);
  if (response.statusCode == 200 && data['id'] != null) {
    _userId = data['id'];
    _fullName = data['full_name'];
    _email = data['email'];
    _role = data['role'];
    _accountBalance = (data['account_balance'] ?? 0).toDouble();
    notifyListeners();
  } else {
    throw Exception(data['error'] ?? 'Login failed');
  }
}


Future<void> logout() async {
  _userId = null;
  _fullName = null;
  _email = null;
  _role = null;

  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  notifyListeners();
}
  Future<void> readStoreData() async {
    User? userStoreData = await User.loadFromPrefs();
    if (userStoreData != null && userStoreData.id != 0) {
      _userId = userStoreData.id;
      _fullName = userStoreData.fullName;
      _email = userStoreData.email;
      _role = userStoreData.role;
      _accountBalance = userStoreData.accountBalance;
    }


    notifyListeners();
  }

  bool get isAuthenticated => _userId != null;
}
