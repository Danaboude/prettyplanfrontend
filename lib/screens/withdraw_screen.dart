import 'package:finalproject/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../providers/auth_provider.dart';
import 'withdraw_history_screen.dart';

class WithdrawScreen extends StatefulWidget {
  final int userId;

  const WithdrawScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  bool _isSubmitting = false;
  double userAccountBalance = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitWithdrawRequest() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    setState(() => _isSubmitting = true);

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .submitWithdrawRequest(amount);

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${lang.translate('withdraw_success')} \$${amount.toStringAsFixed(2)}'),
          backgroundColor: AppTheme.roseGold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _amountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('withdraw_failed')),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    userAccountBalance = Provider.of<AuthProvider>(context).accountBalance;

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: AppTheme.roseGold),
            tooltip: lang.translate('history'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WithdrawHistoryScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
        title: Text(
          lang.translate('withdraw'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.roseGold.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.blushPink,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: AppTheme.roseGold,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      lang.translate('enter_withdrawal_amount'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.roseGold,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${lang.translate('your_current_balance')}: \$${userAccountBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: lang.translate('amount'),
                          prefixIcon: Icon(Icons.attach_money,
                              color: AppTheme.roseGold),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: AppTheme.blushPink),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: AppTheme.roseGold, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red.shade300),
                          ),
                          filled: true,
                          fillColor: AppTheme.ivoryWhite,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return lang.translate('please_enter_amount');
                          }
                          final numValue = double.tryParse(value);
                          if (numValue == null) {
                            return lang.translate('invalid_number');
                          }
                          if (numValue <= 0) {
                            return lang.translate('amount_greater_than_zero');
                          }
                          if (numValue > userAccountBalance) {
                            return lang.translate('amount_exceeds_balance');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : () => _submitWithdrawRequest(),
                  child: _isSubmitting
                      ? CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Text(
                          lang.translate('withdraw_now'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'PlayfairDisplay',
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.roseGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
