import 'package:flutter/material.dart';
import 'package:project_hostelite/auth/auth_checker.dart';
import 'package:project_hostelite/pages/forgot_password_page.dart';
import 'package:project_hostelite/pages/home_page.dart';
import 'package:project_hostelite/pages/login_page.dart';
import 'package:project_hostelite/pages/my_listings.dart';
import 'package:project_hostelite/pages/sign_up_page.dart';
import 'package:project_hostelite/pages/upload_page.dart';
import 'package:project_hostelite/screens/onboarding_screen.dart';
import 'package:project_hostelite/screens/splash_screen.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      initialRoute: AppRoutes.splashRoute,
      routes: {
        AppRoutes.splashRoute: (context) => const SplashScreen(),
        AppRoutes.onboardingRoute: (context) => const OnboardingScreen(),
        AppRoutes.loginRoute: (context) => const LoginPage(),
        AppRoutes.signupRoute: (context) => const SignUpPage(),
        AppRoutes.authRoute: (context) => const AuthenticateUser(),
        AppRoutes.forgotPasswordRoute: (context) => const ForgotPasswordPage(),
        AppRoutes.uploadPageRoute: (context) => const UploadPage(),
        AppRoutes.homeRoute: (context) => const HomePage(),
        AppRoutes.myListingsRoute: (context) => const MyListingsPage(),
      },
    );
  }
}
