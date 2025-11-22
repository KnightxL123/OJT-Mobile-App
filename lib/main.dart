import 'package:flutter/material.dart';
import 'screens/login_register/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/main_features/upload_document_screen.dart';
import 'screens/main_features/dtr_screen.dart';
import 'screens/main_features/daily_journal_screen.dart';
import 'screens/dashboard/notifications_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OJT Student Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return DashboardScreen(user: args ?? <String, dynamic>{});
        },
        UploadDocumentScreen.routeName: (context) => const UploadDocumentScreen(),
        DtrScreen.routeName: (context) => const DtrScreen(),
        DailyJournalScreen.routeName: (context) => const DailyJournalScreen(),
        NotificationsScreen.routeName: (context) => const NotificationsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}