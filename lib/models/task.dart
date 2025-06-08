class Task {
  int _id;
  String _title;
  DateTime _deadlineDate;
  String _deadlineTime; // keep original string for storage
  DateTime _deadlineDateTime; // combined DateTime for easier use
  String _note;
  String _priority; // low, medium, high
  String _status; // pending, in_progress, completed
  double _cost;
  int _assignedTo;
  String _category;

  Task({
    required int id,
    required String category,
    required String title,
    required DateTime deadlineDate,
    required String deadlineTime,
    required String note,
    required String priority,
    required String status,
    required double cost,
    required int assignedTo,
  })  : _id = id,
        _title = title,
        _category = category,
        _deadlineDate = deadlineDate,
        _deadlineTime = deadlineTime,
        _note = note,
        _priority = priority,
        _status = status,
        _cost = cost,
        _assignedTo = assignedTo,
        _deadlineDateTime = _combineDateAndTime(deadlineDate, deadlineTime);

  // Getters
  int get id => _id;
  String get title => _title;
  String get category => _category;

  DateTime get deadlineDate => _deadlineDate;
  String get deadlineTime => _deadlineTime;
  DateTime get deadlineDateTime => _deadlineDateTime;
  String get note => _note;
  String get priority => _priority;
  String get status => _status;
  double get cost => _cost;
  int get assignedTo => _assignedTo;

  // Setters
  set id(int id) => _id = id;
  set title(String title) => _title = title;

  set category(String category) => _category= category;
  set deadlineDate(DateTime deadlineDate) => _deadlineDate = deadlineDate;
  set deadlineTime(String deadlineTime) => _deadlineTime = deadlineTime;
  set note(String note) => _note = note;
  set priority(String priority) => _priority = priority;
  set status(String status) => _status = status;
  set cost(double cost) => _cost = cost;
  set assignedTo(int assignedTo) => _assignedTo = assignedTo;

  // Helper to combine date and time strings into a single DateTime
  static DateTime _combineDateAndTime(DateTime date, String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      category:json['category'],
      title: json['title'],
      deadlineDate: DateTime.parse(json['deadline_date']),
      deadlineTime: json['deadline_time'],
      note: json['note'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      cost: (json['cost'] ?? 0).toDouble(),
      assignedTo: json['assigned_to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'deadline_date': _deadlineDate.toIso8601String().split('T')[0],
      'deadline_time': _deadlineTime,
      'note': _note,
      'category':_category,
      'priority': _priority,
      'status': _status,
      'cost': _cost,
      'assigned_to': _assignedTo,
    };
  }
}
