class CheckoutRequest {
  int _id;
  double _amount;
  String _status;
  String? _transferNumber;
  DateTime _createdAt;

  CheckoutRequest({
    required int id,
    required double amount,
    required String status,
    String? transferNumber,
    required DateTime createdAt,
  })  : _id = id,
        _amount = amount,
        _status = status,
        _transferNumber = transferNumber,
        _createdAt = createdAt;

  // Getters
  int get id => _id;
  double get amount => _amount;
  String get status => _status;
  String? get transferNumber => _transferNumber;
  DateTime get createdAt => _createdAt;

  // Setters
  set id(int id) => _id = id;
  set amount(double amount) => _amount = amount;
  set status(String status) => _status = status;
  set transferNumber(String? transferNumber) => _transferNumber = transferNumber;
  set createdAt(DateTime createdAt) => _createdAt = createdAt;

  // Deserialize from JSON
  factory CheckoutRequest.fromJson(Map<String, dynamic> json) {
    return CheckoutRequest(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      transferNumber: json['transfer_number'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'amount': _amount,
      'status': _status,
      'transferNumber': _transferNumber,
      'createdAt': _createdAt.toIso8601String(),
    };
  }
}
