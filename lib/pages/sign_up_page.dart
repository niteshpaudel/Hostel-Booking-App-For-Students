import 'package:flutter/material.dart';
import 'package:project_hostelite/auth/auth_functions.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:project_hostelite/widgets/general_widgets.dart';
import 'package:project_hostelite/widgets/signup_login_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.loginRoute,
                        );
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  headingText('Let\'s Get Started!', 30.0),
                  const SizedBox(
                    height: 5,
                  ),
                  subHeadingText('Create Hostelite account', 15.0),
                  const SizedBox(
                    height: 35,
                  ),
                  textField(
                    'Full Name',
                    false,
                    Icons.person_2_outlined,
                    _usernameController,
                  ),
                  const SizedBox(
                    height: 20,
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
                    'Phone',
                    false,
                    Icons.phone_android,
                    _phoneController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  textField(
                    'Password',
                    true,
                    Icons.lock_outline_rounded,
                    _passwordController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  textField(
                    'Confirm Password',
                    true,
                    Icons.lock_outline_rounded,
                    _confirmPasswordController,
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  actionButton('CREATE', () {
                    signUp(
                      context,
                      username: _usernameController.text.trim(),
                      email: _emailController.text,
                      phone: _phoneController.text.trim(),
                      password: _passwordController.text,
                      confirmPassword: _confirmPasswordController.text,
                    );

                  }),
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      text(text: 'Already have an account? ', fontSize: 15),
                      textButton(
                        'Login Here',
                        primaryBlue,
                        () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.loginRoute,
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
