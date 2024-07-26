import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:project_hostelite/pages/home_page.dart';
import 'package:project_hostelite/pages/login_page.dart';
import 'package:project_hostelite/screens/onboarding_screen.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/widgets/signup_login_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticateUser extends StatefulWidget {
  const AuthenticateUser({super.key});

  @override
  State<AuthenticateUser> createState() => _AuthenticateUserState();
}

class _AuthenticateUserState extends State<AuthenticateUser> {
  bool _isLoggedIn = false;
  bool isConnectedToInternet = true;
  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _checkInitialInternetConnection();
    _internetConnectionStreamSubscription =
        InternetConnection().onStatusChange.listen((event) {
      _updateInternetStatus(event);
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> _checkInitialInternetConnection() async {
    bool initialConnection = await InternetConnection().hasInternetAccess;
    setState(() {
      isConnectedToInternet = initialConnection;
    });
  }

  void _updateInternetStatus(InternetStatus status) {
    setState(() {
      isConnectedToInternet = status == InternetStatus.connected;
    });
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!isConnectedToInternet) {
            return Scaffold(
              backgroundColor: scaffoldBackgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    headingText('Ooops!', 30),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(
                        'It seems that there is something wrong with your internet connection. Check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Image.asset('assets/images/no-internet.png'),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.transparent,
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return _isLoggedIn? const LoginPage() : const OnboardingScreen();
          }
        },
      ),
    );
  }
}
