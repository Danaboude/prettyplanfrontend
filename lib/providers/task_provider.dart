import 'dart:convert';
import 'package:finalproject/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService extends ChangeNotifier {
  List<Task> allTasks = [];
  List<Task> filteredTasks = [];
  SortOption selectedSort = SortOption.date;
  bool isLoading = true;
  List<bool> expandedStates = [];
  Map<int, bool> isUpdatingStatus = {};

  static const String baseUrl = 'http://192.168.161.235/finalporject'; //تغيير ip

  TaskService() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    isLoading = true;
    //notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final tasks = await fetchTasksForUser(userId);
      allTasks = tasks;
      expandedStates = List.filled(tasks.length, false);
      filterAndSortTasks();
    } catch (e) {
      print('❌ Failed to load tasks: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterTasksByCategory(String categoryKey) {
    if (categoryKey == 'category_all') {
      filteredTasks = [...allTasks];
    } else {
      filteredTasks = allTasks
          .where((task) =>
              task.category.toLowerCase() == _mapCategoryKeyToName(categoryKey))
          .toList();
    }
    notifyListeners();
  }

  String _mapCategoryKeyToName(String key) {
    // Map keys to actual category names stored in DB (adjust if needed)
    switch (key) {
      case 'category_family':
        return 'family';
      case 'category_personal':
        return 'personal';
      case 'category_job':
        return 'job';
      case 'category_another':
        return 'another';
      default:
        return '';
    }
  }

  void filterAndSortTasks() {
    filteredTasks = List.from(allTasks);

    if (selectedSort == SortOption.date) {
      filteredTasks
          .sort((a, b) => a.deadlineDateTime.compareTo(b.deadlineDateTime));
    } else if (selectedSort == SortOption.priority) {
      Map<String, int> priorityRank = {
        'high': 0,
        'medium': 1,
        'low': 2,
      };
      filteredTasks.sort((a, b) => priorityRank[a.priority.toLowerCase()]!
          .compareTo(priorityRank[b.priority.toLowerCase()]!));
    }

    notifyListeners();
  }

  Future<void> toggleTaskStatus(int taskId, String currentStatus) async {
    if (currentStatus.toLowerCase() == 'in_progress') {
      isUpdatingStatus[taskId] = true;
      notifyListeners();

      bool updated = await updateTaskStatus(taskId, 'pending');
      if (updated) {
        await loadTasks();
      }

      isUpdatingStatus[taskId] = false;
      notifyListeners();
    }
  }

  void setSortOption(SortOption option) {
    selectedSort = option;
    filterAndSortTasks();
    notifyListeners();
  }

  void toggleExpanded(int index) {
    expandedStates[index] = !expandedStates[index];
    notifyListeners();
  }

  static Future<List<Task>> fetchTasksForUser(int userId) async {
    final url = Uri.parse('$baseUrl/user/$userId/tasks');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Task.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to load tasks from server: ${response.statusCode}');
    }
  }

  Future<bool> updateTaskStatus(int taskId, String newStatus) async {
    final response = await http.post(
      Uri.parse('$baseUrl/task/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'status': newStatus,
        "task_id": taskId,
      }),
    );

    print(response.body);

    return response.statusCode == 200;
  }
}
