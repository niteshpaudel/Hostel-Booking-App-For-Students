import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_hostelite/auth/auth_checker.dart';
import 'package:project_hostelite/services/firestore_service.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:project_hostelite/widgets/general_widgets.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';


final _auth = FirebaseAuth.instance;

//sign in with google (currently not in use)
// class SignInWithGoogle {
//   static Future<UserCredential> signInWithGoogle() async {
//     final googleAccount = await GoogleSignIn().signIn();
//     final googleAuth = await googleAccount?.authentication;
//     final auth = FirebaseAuth.instance;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth?.accessToken,
//       idToken: googleAuth?.idToken,
//     );

//     final userCredential = await auth.signInWithCredential(credential);

//     return userCredential;
//   }
// }

//login with email and password
Future<void> login(
  BuildContext context, {
  required String email,
  required String password,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryBlue,
        ),
      );
    },
  );
  try {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (!context.mounted) return;
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, AppRoutes.authRoute);
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context);
    if (e.code == 'channel-error') {
      showSnackBar(context, 'Fields cannot be empty!');
      return;
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Login Failed!',
        text: 'Invalid E-mail & Password Combination',
        showConfirmBtn: false,
      );
    }
  }
}

// Future<void> authenticateWithGoogle(BuildContext context) async {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return Center(
//         child: CircularProgressIndicator(
//           color: primaryBlue,
//         ),
//       );
//     },
//   );
//   await GoogleSignIn().signOut();
//   try {
//     await SignInWithGoogle.signInWithGoogle();
//     if (!context.mounted) return;
//     Navigator.pop(context);
//   } catch (e) {
//     if (!context.mounted) return;
//     showSnackBar(context, 'An error occured!');
//     return;
//   }
// }

Future<void> resetPassword(BuildContext context,
    {required String email}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryBlue,
        ),
      );
    },
  );
  try {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
    if (!context.mounted) return;
    Navigator.pop(context);
    showSuccessMessage(context);
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context);
    if (e.code == 'channel-error') {
      showSnackBar(context, 'E-mail is required!');
      return;
    }
    if (e.code == 'invalid-email') {
      showSnackBar(context, 'E-mail address is badly formatted!');
      return;
    }
    if (e.code == 'user-not-found') {
      showSnackBar(context, 'E-mail is not registered!');
      return;
    } else {
      showSnackBar(context, 'An error occured!');
      return;
    }
  }
}

void showSuccessMessage(BuildContext context) {
  QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    text: 'We have sent the password reset link to your e-mail',
    title: 'Check Your Email',
    confirmBtnColor: primaryBlue,
    confirmBtnText: 'OK',
    onConfirmBtnTap: () {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.loginRoute,
      );
    },
  );
}

Future<void> signUp(BuildContext context,
    {required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword}) async {
  if (username.isEmpty ||
      email.isEmpty ||
      phone.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty) {
    showSnackBar(context, 'Fields cannot be empty!');
    return;
  } else if (phone.length < 10 || int.tryParse(phone) == null) {
    showSnackBar(context, 'Please enter a valid phone number!');
    return;
  } else {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryBlue,
            ),
          );
        },
      );
      if (password == confirmPassword) {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;
        await addUserDetails(
            username: username.trim(), phone: phone.trim(), user: user);

        if (!context.mounted) return;
        Navigator.pop(context);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success!',
          text: 'Try logging into your Hostelite account',
          confirmBtnColor: primaryBlue,
          confirmBtnText: 'LOG IN',
          onConfirmBtnTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthenticateUser()),
              (Route<dynamic> route) => false,
            );
          },
        );
      } else {
        if (!context.mounted) return;
        Navigator.pop(context);
        showSnackBar(context, 'Passwords do not match!');
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        showSnackBar(context, 'Password too weak!');
        return;
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, 'E-mail address is already in use!');
        return;
      } else if (e.code == 'channel-error') {
        showSnackBar(context, 'Fields cannot be empty!');
        return;
      } else if (e.code == 'invalid-email') {
        showSnackBar(context, 'E-mail address is badly formatted!');
        return;
      }
    }
  }
}

//logout user

Future<void> logout(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryBlue,
        ),
      );
    },
  );
  try {
    await FirebaseAuth.instance.signOut();
    // await GoogleSignIn().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, AppRoutes.authRoute);
  } catch (e) {
    Navigator.of(context).pop();
    if (!context.mounted) return;
    showSnackBar(context, 'Error signing out!');
    return;
  }
}
