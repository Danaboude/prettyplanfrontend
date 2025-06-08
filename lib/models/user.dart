import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final double accountBalance;


  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.accountBalance,
  });



  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'account_balance': accountBalance,
      };


  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        fullName: json['full_name'],
        email: json['email'],
        role: json['role'],
        accountBalance: (json['account_balance'] ?? 0).toDouble(),
      );



  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    await prefs.setString('full_name', fullName);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setDouble('account_balance', accountBalance);
    await prefs.setBool('isLoggedIn', true);
  }


  static Future<User?> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') == true) {
      return User(
        id: prefs.getInt('user_id') ?? 0,
        fullName: prefs.getString('full_name') ?? '',
        email: prefs.getString('email') ?? '',
        role: prefs.getString('role') ?? '',
        accountBalance: prefs.getDouble('account_balance') ?? 0.0,
      );
    }
    return null; // Return null if the user is not logged in
  }
}