import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpm_fp/models/feedback_model.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:tpm_fp/models/user_model.dart';
import 'package:tpm_fp/network/notification_service.dart';
import 'package:tpm_fp/views/feedback_screen.dart';
import 'package:tpm_fp/views/login_screen.dart';
import 'package:tpm_fp/views/register_screen.dart';
import 'package:tpm_fp/views/home_screen.dart';
import 'package:tpm_fp/views/compass_screen.dart';
import 'package:tpm_fp/views/currency_screen.dart';
import 'package:tpm_fp/views/time_convert_screen.dart';
import 'package:tpm_fp/views/map_screen.dart';
import 'package:tpm_fp/views/schedule_screen.dart';
import 'package:tpm_fp/views/profile_screen.dart';
import 'package:tpm_fp/network/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(FeedbackModelAdapter());

  // Initialize services
  final authService = AuthService();
  await authService.init();

  // Initialize notifications
  await NotificationService().init();

  // Cek apakah user sudah login
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.containsKey('current_username');

  runApp(MyApp(initialRoute: isLoggedIn ? '/home' : '/login'));
}


class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MotoTrack',
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/compass', page: () => CompassScreen()),
        GetPage(name: '/currency', page: () => CurrencyScreen()),
        GetPage(name: '/time', page: () => TimeConverterScreen()),
        GetPage(name: '/map', page: () => MapScreen()),
        GetPage(name: '/schedule', page: () => ScheduleScreen()),
        GetPage(name: '/feedback', page: () => FeedbackScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
