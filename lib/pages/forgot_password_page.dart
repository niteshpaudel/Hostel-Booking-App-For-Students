import 'package:flutter/material.dart';
import 'package:project_hostelite/auth/auth_functions.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:project_hostelite/widgets/signup_login_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
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
                  height: 25,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headingText('Forgot Your Password?', 25.0),
                      const SizedBox(
                        height: 5,
                      ),
                      subHeadingText('Let\'s reset it!', 15.0),
                      const SizedBox(
                        height: 25,
                      ),
                      subHeadingText(
                        'Please enter the e-mail address that is linked to your account.',
                        15.0,
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                    ],
                  ),
                ),
                textField(
                  'Email',
                  false,
                  Icons.email_outlined,
                  _emailController,
                ),
                const SizedBox(
                  height: 35,
                ),
                actionButton(
                  'GET RESET LINK',
                  () {
                    resetPassword(context, email: _emailController.text.trim());
                  },
                ),
                const SizedBox(
                  height: 35,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
