import 'dart:convert';

import 'package:finalproject/models/withdraw_record.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  bool _isLoading = true;
  List<User> _users = [];
  Map<int, User> _userDetails = {};
  Map<int, List<Task>> _userTasks = {};
  Map<int, List<CheckoutRequest>> _userWithdrawals = {};
  final String _baseUrl =
      'http://192.168.161.235/finalporject'; // //تغيير ip
  bool get isLoading => _isLoading;
  List<User> get users => _users;
Future<void> approveCheckout(int checkoutId, String transactionNumber,userid) async {
updatawithdraws(userid);
  final response = await http.post(
    Uri.parse('$_baseUrl/checkout_request/$checkoutId/approve'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'transaction_number': transactionNumber}),
  );
  print(response.body);
  if (response.statusCode == 200) {
    // Optionally reload data or update UI state
    notifyListeners();
  } else {
    throw Exception('Failed to approve checkout');
  }
}

Future<void> rejectCheckout(int checkoutId,int userid) async {
  updatawithdraws(userid);

  final response = await http.post(
    Uri.parse('$_baseUrl/checkout_request/$checkoutId/reject'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    // Optionally reload data or update UI state
    notifyListeners();
  } else {
    throw Exception('Failed to reject checkout');
  }
}

  User? getUserById(int userId) => _userDetails[userId];
  List<Task> getTasksForUser(int userId) => _userTasks[userId] ?? [];
  List<CheckoutRequest> getWithdrawalsForUser(int userId) =>
      _userWithdrawals[userId] ?? [];

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);

        // ✅ Skip the first user (admin/manager), load the rest
        _users = data
            .skip(1)
            .map((userJson) => User(
                  id: int.tryParse(userJson['id'].toString()) ?? 0,
                  fullName: userJson['full_name'] ?? '',
                  email: userJson['email'] ?? '',
                  role: userJson['role'] ?? '',
                  accountBalance: double.tryParse(
                          userJson['account_balance']?.toString() ?? '') ??
                      0.0,
                ))
            .toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print("Error loading users: $e");
      _users = [];
    }

    _isLoading = false;
    notifyListeners();
  }
Future<String> getSuggestedPriority(String title, String note) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:5000/predict_priority'),//تغيير ip
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'text': "$title $note"}),
  );
    print(response.body);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['priority'];
  } else {
    throw Exception('Failed to get priority suggestion');
  }
}
 Future<void> addTaskForUser(int userId, Task newTask) async {
  final suggestedPriority = await getSuggestedPriority(newTask.title, newTask.note);
  print(suggestedPriority);
  newTask.priority=suggestedPriority;
    final url = Uri.parse('$_baseUrl/tasks');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': newTask.title,
        'category':newTask.category,
        'deadline_date': newTask.deadlineDate.toIso8601String().split('T').first,
        'deadline_time': newTask.deadlineTime,
        'note': newTask.note,
        'priority': newTask.priority,
        'status': 2,
        'cost': newTask.cost,
        'assigned_to': newTask.assignedTo,
      }),
    );
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      newTask.id = responseData['id'];

      _userTasks[userId] ??= [];
      _userTasks[userId]!.add(newTask);
      notifyListeners();
    } else {
      throw Exception('Failed to add task: ${response.body}');
    }
  }


Future<void> loadUserDetails(int userId) async {
  try {
    // Load user info
    final userRes = await http.get(Uri.parse('$_baseUrl/user/$userId'));
    final userData = json.decode(userRes.body);
    _userDetails[userId] = User(
      id: userData['id'],
      fullName: userData['full_name'],
      email: userData['email'],
      role: userData['role'],
      accountBalance: (userData['account_balance'] ?? 0).toDouble(),
    );

    // Load tasks
    final tasksRes = await http.get(Uri.parse('$_baseUrl/user/$userId/tasks'));
    final List<dynamic> taskData = json.decode(tasksRes.body);
    _userTasks[userId] = taskData.map((taskJson) => Task.fromJson(taskJson)).toList();

    // Load withdrawals
    final withdrawRes = await http.get(Uri.parse('$_baseUrl/user/$userId/withdrawals'));
    final List<dynamic> withdrawData = json.decode(withdrawRes.body);
    _userWithdrawals[userId] = withdrawData.map((wJson) => CheckoutRequest.fromJson(wJson)).toList();

    notifyListeners();
  } catch (e) {
    print("Error loading user details: $e");
  }
}
Future<void> updatawithdraws(int userId) async {
  try {
 

    // Load withdrawals
    final withdrawRes = await http.get(Uri.parse('$_baseUrl/user/$userId/withdrawals'));
    final List<dynamic> withdrawData = json.decode(withdrawRes.body);
    _userWithdrawals[userId] = withdrawData.map((wJson) => CheckoutRequest.fromJson(wJson)).toList();

    notifyListeners();
  } catch (e) {
    print("Error loading user details: $e");
  }
}


}
