import 'package:finalproject/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/withdraw_record.dart';
import '../providers/language_provider.dart';

class WithdrawHistoryScreen extends StatefulWidget {
  final int userId;

  const WithdrawHistoryScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _WithdrawHistoryScreenState createState() => _WithdrawHistoryScreenState();
}

class _WithdrawHistoryScreenState extends State<WithdrawHistoryScreen> {
  bool _isLoading = true;
  List<CheckoutRequest> _records = [];

  @override
  void initState() {
    super.initState();
    _loadWithdrawHistory();
  }

  Future<void> _loadWithdrawHistory() async {
    try {
      print(widget.userId);
      final records = await Provider.of<AuthProvider>(context, listen: false)
          .getWithdrawals(widget.userId);
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading history: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context); // ✅ Add this

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          lang.translate('withdrawal_history'),
          style: TextStyle(
            color: AppTheme.roseGold,
            fontWeight: FontWeight.w600,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.roseGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.roseGold,
              ),
            )
          : _records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: AppTheme.roseGold.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        lang.translate('no_withdrawal_history'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontFamily: 'PlayfairDisplay',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.roseGold.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${record.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.roseGold,
                                    fontFamily: 'PlayfairDisplay',
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(record.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    record.status.toLowerCase() == 'approved'
                                        ? lang.translate('Approved')
                                        : record.status.toLowerCase() == 'rejected'
                                            ? lang
                                                .translate('Rejected')
                                            : lang.translate(
                                                'pending'),
                                    style: TextStyle(
                                      color: _getStatusColor(record.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            if (record.transferNumber != null) ...[
                              Text(
                                lang.translate('transfer_number'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                record.transferNumber!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                            Text(
                              '${lang.translate('requested_on')}: ${_formatDate(record.createdAt)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
