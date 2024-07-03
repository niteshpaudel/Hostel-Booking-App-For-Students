import 'package:flutter/material.dart';
import 'package:project_hostelite/auth/auth_functions.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:project_hostelite/widgets/general_widgets.dart';
import 'package:project_hostelite/widgets/signup_login_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/3d-login.png',
                    width: 250,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  headingText('Welcome Back!', 30.0),
                  const SizedBox(
                    height: 5,
                  ),
                  subHeadingText(
                      'Login to your existing Hostelite account', 15.0),
                  const SizedBox(
                    height: 35,
                  ),
                  textField(
                    'Email',
                    false,
                    Icons.email_outlined,
                    _emailController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  textField(
                    'Password',
                    true,
                    Icons.lock_outlined,
                    _passwordController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  textButton('Forgot Password?', primaryBlue, () {
                    Navigator.pushNamed(context, AppRoutes.forgotPasswordRoute);
                  }),
                  const SizedBox(
                    height: 20,
                  ),
                  actionButton(
                    'LOG IN',
                    () {
                      login(
                        context,
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      );
                    },
                  ),
                  // const SizedBox(
                  //   height: 25,
                  // ),
                  // const Row(
                  //   children: [
                  //     Expanded(
                  //       child: Divider(),
                  //     ),
                  //     Text(
                  //       '   or continue with   ',
                  //       style: TextStyle(fontSize: 15, color: Colors.black38),
                  //     ),
                  //     Expanded(
                  //       child: Divider(),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 25,
                  // ),
                  // GestureDetector(
                  //   onTap: () {
                  //     authenticateWithGoogle();
                  //   },
                  //   child: Container(
                  //     height: 50,
                  //     width: 50,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       boxShadow: [
                  //         BoxShadow(
                  //             color: primaryBlue.withOpacity(0.5),
                  //             offset: const Offset(0, 5),
                  //             spreadRadius: -15,
                  //             blurRadius: 20),
                  //       ],
                  //       borderRadius: BorderRadius.circular(100),
                  //     ),
                  //     child: Image.asset(
                  //       'assets/icons/google-icon.png',
                  //       scale: 1.4,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      text(text: 'Don\'t have an account? ', fontSize: 15),
                      textButton(
                        'Sign Up',
                        primaryBlue,
                        () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.signupRoute,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
