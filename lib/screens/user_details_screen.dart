import 'package:finalproject/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/task.dart';
import '../models/withdraw_record.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import 'add_task_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;

  const UserDetailsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false)
          .loadUserDetails(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context); // ✅ Add this

    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUserById(widget.userId);
    final tasks = userProvider.getTasksForUser(widget.userId);
    final checkouts = userProvider.getWithdrawalsForUser(widget.userId);
    final isLoading = user == null;

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isLoading ? lang.translate('loading') : user.fullName,
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.roseGold,
          labelColor: AppTheme.roseGold,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: lang.translate("tab_tasks")),
            Tab(text: lang.translate('tab_withdrawals')),
          ],
        ),
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              onPressed: _showAddTaskDialog,
              backgroundColor: AppTheme.roseGold,
              child: Icon(Icons.add),
            ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.roseGold))
          :  Directionality(
      textDirection: lang.textDirection,
            child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTasksList(tasks, user.id),
                  _buildWithdrawalsList(checkouts),
                ],
              ),
          ),
    );
  }

  Widget _buildTasksList(List<Task> tasks, int userid) {
    final lang = Provider.of<LanguageProvider>(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return GestureDetector(
          onTap: () {
            if (task.status == 'pending') {
              final outerContext = context; // Save the outer context

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(lang.translate("dialog_mark_completed_title")),
                  content:
                      Text(lang.translate('dialog_mark_completed_content')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(lang.translate('button_cancel')),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        // Delay to allow the widget tree to stabilize
                        await Future.delayed(Duration(milliseconds: 50));

                        // Use a stable outer context here (passed in via closure)
                        final taskService = Provider.of<TaskService>(
                            outerContext,
                            listen: false);

                        // Show animation feedback
                        final overlay = Overlay.of(outerContext);
                        final entry = OverlayEntry(
                          builder: (context) => Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Icon(Icons.check_circle,
                                    color: AppTheme.roseGold, size: 80),
                              ),
                            ),
                          ),
                        );
                        overlay.insert(entry);

                        await Future.delayed(const Duration(milliseconds: 600));
                        entry.remove();

                        // Update status
                        bool success = await taskService.updateTaskStatus(
                            task.id, 'completed');
                        if (success) {
                          await Provider.of<UserProvider>(outerContext,
                                  listen: false)
                              .loadUserDetails(userid);
                        }
                      },
                      child: Text(lang.translate('button_yes')),
                    ),
                  ],
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 16),
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
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip(
                          task.priority, _getPriorityColor(task.priority),'priority'),
                      const SizedBox(width: 8),
                      _buildChip(task.status, _getStatusColor(task.status),'statuss'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${lang.translate('label_deadline')}: ${_formatDate(task.deadlineDate)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '${lang.translate('label_reward')}: \$${task.cost.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppTheme.roseGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalsList(List<CheckoutRequest> checkouts) {
    final lang = Provider.of<LanguageProvider>(context); // ✅ Add this

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: checkouts.length,
      itemBuilder: (context, index) {
        final checkout = checkouts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              '\$${checkout.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'PlayfairDisplay',
                color: AppTheme.roseGold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildChip(
                    checkout.status, _getCheckoutStatusColor(checkout.status),'status'),
                const SizedBox(height: 8),
                Text(
                  '${lang.translate('label_requested')}: ${_formatDate(checkout.createdAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: checkout.status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _handleCheckoutAction(
                            checkout.id, true, widget.userId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _handleCheckoutAction(
                            checkout.id, false, widget.userId),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

Widget _buildChip(String label, Color color, String keyPrefix) {
  final lang = Provider.of<LanguageProvider>(context, listen: false);

  final translatedLabel = lang.translate('${keyPrefix}_${label.toLowerCase()}');

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      translatedLabel.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}


  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getCheckoutStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleCheckoutAction(
      int checkoutId, bool approved, int userid) async {
    final lang = Provider.of<LanguageProvider>(context,listen: false); // ✅ Add this

    if (approved) {
      final TextEditingController _transactionController =
          TextEditingController();

      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.translate('Enter Transaction Number')),
            content: TextField(
              controller: _transactionController,
              decoration:
                  InputDecoration(hintText: lang.translate('Transaction #')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(lang.translate('button_cancel')),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(_transactionController.text),
                child: Text(lang.translate('button_yes')),
              ),
            ],
          );
        },
      );

      if (result != null && result.isNotEmpty) {
        await Provider.of<UserProvider>(context, listen: false)
            .approveCheckout(checkoutId, result, userid);
      }
    } else {
      await Provider.of<UserProvider>(context, listen: false)
          .rejectCheckout(checkoutId, userid);
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(userId: widget.userId),
    );
  }
}
