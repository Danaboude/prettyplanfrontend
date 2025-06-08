import 'package:finalproject/providers/task_provider.dart';
import 'package:finalproject/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TaskService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Add more providers here if needed
      ],
      child: const PrettyPlanApp(),
    ),
  );
}

//DropdownButton<String>(
//value: Provider.of<LanguageProvider>(context).currentLocale.languageCode,
//items: const [
// DropdownMenuItem(value: 'en', child: Text('English')),
//DropdownMenuItem(value: 'ar', child: Text('العربية')),
//],
// onChanged: (value) {
//  if (value != null) {
//   Provider.of<LanguageProvider>(context, listen: false).changeLanguage(value);
//}},)

class PrettyPlanApp extends StatelessWidget {
  const PrettyPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'PrettyPlan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      locale: langProvider.currentLocale,
      home: MyCustomSplashScreen(),
    );
  }
}
