import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/task.dart';
import '../providers/user_provider.dart';
import '../providers/language_provider.dart'; // ✅ Add this

class AddTaskDialog extends StatefulWidget {
  final int userId;

  const AddTaskDialog({Key? key, required this.userId}) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _costController = TextEditingController();
  String _category = 'all';

  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay(hour: 17, minute: 0);
  String _priority = 'medium';
  bool _isLoading = false; // <-- loader flag
 Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  @override
Widget build(BuildContext context) {
  final lang = Provider.of<LanguageProvider>(context);

  return Directionality(
    textDirection: lang.textDirection,
    child: Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.translate('add_task'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.roseGold,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: lang.translate('task_title'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return lang.translate('enter_title');
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(
                        labelText: lang.translate('category'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      items: ['all', 'family', 'personal', 'job', 'another']
                          .map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(lang.translate(category)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: lang.translate('note'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: lang.translate('reward_amount'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return lang.translate('enter_amount');
                        if (double.tryParse(value!) == null)
                          return lang.translate('invalid_amount');
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                          '${lang.translate('deadline_date')}: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: _isLoading ? null : _pickDate,
                    ),
                    ListTile(
                      title: Text(
                          '${lang.translate('deadline_time')}: ${_selectedTime.format(context)}'),
                      trailing: Icon(Icons.access_time),
                      onTap: _isLoading ? null : _pickTime,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          child: Text(lang.translate('cancel'),
                              style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.roseGold,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(lang.translate('add_task')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    ),
  );
}

void _submitTask() async {
  final lang = Provider.of<LanguageProvider>(context, listen: false);

  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  final deadlineTimeString =
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  final newTask = Task(
    id: 0,
    title: _titleController.text.trim(),
    deadlineDate: _selectedDate,
    deadlineTime: deadlineTimeString,
    note: _noteController.text.trim(),
    priority: _priority,
    category: _category,
    status: "pending",
    cost: double.parse(_costController.text),
    assignedTo: widget.userId,
  );

  final userProvider = Provider.of<UserProvider>(context, listen: false);

  try {
    await userProvider.addTaskForUser(widget.userId, newTask);
    if (mounted) Navigator.pop(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lang.translate('task_added')}'),
          backgroundColor: AppTheme.roseGold,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lang.translate('task_failed')}: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


 

  }

