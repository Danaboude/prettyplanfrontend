import 'package:finalproject/models/task.dart';
import 'package:finalproject/providers/task_provider.dart';
import 'package:finalproject/screens/auth_screen.dart';
import 'package:finalproject/screens/withdraw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class PageTransition extends PageRouteBuilder {
  final Widget page;

  PageTransition(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: Duration(milliseconds: 2000),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
              curve: Curves.fastLinearToSlowEaseIn,
              parent: animation,
            );
            return Align(
              alignment: Alignment.bottomCenter,
              child: SizeTransition(
                sizeFactor: animation,
                child: page,
                axisAlignment: 0,
              ),
            );
          },
        );
}

enum SortOption { date, priority }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> allTasks = [];
  List<Task> filteredTasks = [];
  SortOption selectedSort = SortOption.date;
  bool isLoading = true;
  List<bool> expandedStates = [];
  Map<int, bool> isUpdatingStatus = {};

  @override
  void initState() {
    super.initState();
    Provider.of<TaskService>(context, listen: false).loadTasks();
    // _loadTasks();
  }

  String _getStatusActionText(BuildContext context, String status) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    switch (status.toLowerCase()) {
      case 'in_progress':
        return languageProvider.translate('status_in_progress');
      case 'pending':
        return languageProvider.translate('status_pending');
      case 'completed':
        return languageProvider.translate('status_completed');
      default:
        return languageProvider.translate('status_unknown');
    }
  }

  Widget _getPriorityStars(String priority) {
    int starCount = 0;
    switch (priority.toLowerCase()) {
      case 'high':
        starCount = 3;
        break;
      case 'medium':
        starCount = 2;
        break;
      case 'low':
        starCount = 1;
        break;
    }
    return Row(
      children: List.generate(
          3,
          (index) => Icon(
                index < starCount ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              )),
    );
  }

  final List<Map<String, dynamic>> categories = [
    {'key': 'category_all', 'icon': Icons.apps},
    {'key': 'category_family', 'icon': Icons.family_restroom},
    {'key': 'category_personal', 'icon': Icons.person},
    {'key': 'category_job', 'icon': Icons.work},
    {'key': 'category_another', 'icon': Icons.more_horiz},
  ];

  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.05;
    allTasks = Provider.of<TaskService>(context).allTasks;
    filteredTasks = Provider.of<TaskService>(context).filteredTasks;
    isLoading = Provider.of<TaskService>(context).isLoading;
    expandedStates = Provider.of<TaskService>(context).expandedStates;
    isUpdatingStatus = Provider.of<TaskService>(context).isUpdatingStatus;
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: AppTheme.roseGold,
            tooltip: lang.translate('logout'),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(context, PageTransition(AuthScreen()));
            },
          ),
        ],
        leading: IconButton(
          icon: Text(
            lang.currentLocale.languageCode == 'en' ? 'ع' : 'EN',
            style: const TextStyle(
              color: AppTheme.roseGold,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onPressed: () {
            final newLang =
                lang.currentLocale.languageCode == 'en' ? 'ar' : 'en';
            lang.changeLanguage(newLang);
          },
        ),
        centerTitle: true,
        title: Text(
          lang.translate('pretty_plan'),
          style: TextStyle(
            color: AppTheme.roseGold,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.roseGold,
          onRefresh: () async =>
              Provider.of<TaskService>(context, listen: false).loadTasks(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              children: [
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: categories.map((category) {
                      return ChoiceChip(
                        avatar: Icon(
                          category['icon'],
                          size: 18,
                          color: selectedCategory == category['key']
                              ? Colors.white
                              : Colors.black,
                        ),
                        label: Text(lang.translate(category['key'])),
                        selected: selectedCategory == category['key'],
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = category['key'];

                            // Notify the TaskService to filter tasks
                            Provider.of<TaskService>(context, listen: false)
                                .filterTasksByCategory(selectedCategory);
                          });
                        },
                        selectedColor: Colors.purple[200],
                        backgroundColor: Colors.purple[100],
                        labelStyle: TextStyle(
                          color: selectedCategory == category['key']
                              ? Colors.white
                              : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
                const SizedBox(height: 16),

                // Sort Dropdown with elegant styling
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.blushPink),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.roseGold.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang.translate('sort_by') + ':',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          color: AppTheme.roseGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      PopupMenuButton<SortOption>(
                        icon: Icon(Icons.sort, color: AppTheme.roseGold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onSelected: (SortOption newSort) {
                          Provider.of<TaskService>(context, listen: false)
                              .setSortOption(newSort);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: SortOption.date,
                            child: Text(lang.translate('date'),
                                style:
                                    TextStyle(fontFamily: 'PlayfairDisplay')),
                          ),
                          PopupMenuItem(
                            value: SortOption.priority,
                            child: Text(lang.translate('priority'),
                                style:
                                    TextStyle(fontFamily: 'PlayfairDisplay')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.roseGold,
                          ),
                        )
                      : filteredTasks.isEmpty
                          ? Center(
                              child: Text(
                                lang.translate('no_tasks_found'),
                                style: TextStyle(
                                  color: AppTheme.roseGold,
                                  fontFamily: 'PlayfairDisplay',
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                final isExpanded = expandedStates[index];
                                final deadlineDateTime = task.deadlineDateTime;
                                final deadlineStr =
                                    '${deadlineDateTime.day}/${deadlineDateTime.month}/${deadlineDateTime.year} ${deadlineDateTime.hour.toString().padLeft(2, '0')}:${deadlineDateTime.minute.toString().padLeft(2, '0')}';

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      expandedStates[index] =
                                          !expandedStates[index];
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            AppTheme.blushPink.withOpacity(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.roseGold
                                              .withOpacity(0.1),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: isUpdatingStatus[task.id] ==
                                                  true
                                              ? SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: AppTheme.roseGold,
                                                  ),
                                                )
                                              : TextButton(
                                                  onPressed: task.status
                                                              .toLowerCase() ==
                                                          'in_progress'
                                                      ? () {
                                                          Provider.of<TaskService>(
                                                                  context,
                                                                  listen: false)
                                                              .toggleTaskStatus(
                                                                  task.id,
                                                                  task.status);
                                                        }
                                                      : null,
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        AppTheme.roseGold,
                                                    textStyle: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  child: Text(
                                                      _getStatusActionText(
                                                          context,
                                                          task.status)),
                                                ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.roseGold,
                                                fontFamily: 'PlayfairDisplay',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Text(
                                                  lang.translate('priority_'),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontFamily:
                                                        'PlayfairDisplay',
                                                  ),
                                                ),
                                                _getPriorityStars(
                                                    task.priority),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${lang.translate('deadline')}: $deadlineStr',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'PlayfairDisplay',
                                              ),
                                            ),
                                            if (task.note.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.blushPink
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: AnimatedCrossFade(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    crossFadeState: isExpanded
                                                        ? CrossFadeState
                                                            .showFirst
                                                        : CrossFadeState
                                                            .showSecond,
                                                    firstChild: Text(
                                                      task.note,
                                                      style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors.grey[700],
                                                        fontFamily:
                                                            'PlayfairDisplay',
                                                      ),
                                                    ),
                                                    secondChild: Text(
                                                      '${task.note.length > 50 ? task.note.substring(0, 50) + '...' : task.note}',
                                                      style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors.grey[700],
                                                        fontFamily:
                                                            'PlayfairDisplay',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                '${lang.translate('reward')}: \$${task.cost.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: AppTheme.roseGold,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'PlayfairDisplay',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(Provider.of<AuthProvider>(context, listen: false).userId);
          int userid = Provider.of<AuthProvider>(context, listen: false).userId;

          Navigator.push(
              context, PageTransition(WithdrawScreen(userId: userid)));
        },
        backgroundColor: AppTheme.roseGold,
        child: Icon(Icons.account_balance_wallet_sharp, color: Colors.white),
        elevation: 4,
      ),
    );
  }
}
