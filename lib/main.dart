import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home/home_screen.dart';

void main() => runApp(const OurMomentApp());

class OurMomentApp extends StatelessWidget {
  const OurMomentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our Moment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.createAccount: (_) => const CreateAccountScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
      },
    );
  }
}
