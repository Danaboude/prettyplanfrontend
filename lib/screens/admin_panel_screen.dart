import 'package:finalproject/providers/auth_provider.dart';
import 'package:finalproject/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../providers/user_provider.dart';
import 'auth_screen.dart';
import 'user_details_screen.dart';
import '../providers/language_provider.dart'; // ✅ NEW import

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<UserProvider>(context, listen: false).loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final lang =
        Provider.of<LanguageProvider>(context); // ✅ Get language provider
    final userProvider = Provider.of<UserProvider>(context);
    final isLoading = userProvider.isLoading;
    final users = userProvider.users;

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(
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
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: AppTheme.roseGold,
            tooltip: lang.translate('logout'), // ✅ Translated
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(context, PageTransition(AuthScreen()));
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        title: Text(
          lang.translate('admin_panel'), // ✅ Translated
          style: TextStyle(
            color: AppTheme.roseGold,
            fontWeight: FontWeight.w600,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.roseGold),
            )
          : Directionality(
              textDirection: lang.textDirection,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
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
                    child: ListTile(
                      onTap: () {
                        Navigator.push(context,
                            PageTransition(UserDetailsScreen(userId: user.id)));
                      },
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.blushPink,
                        child: Text(
                          user.fullName[0].toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.roseGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PlayfairDisplay',
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(user.email),
                          SizedBox(height: 4),
                          Text(
                            '${lang.translate('balance')}: \$${user.accountBalance}', // ✅ Translated
                            style: TextStyle(
                              color: AppTheme.roseGold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.roseGold,
                        size: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
