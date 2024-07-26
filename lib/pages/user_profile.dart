import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_hostelite/auth/auth_functions.dart';
import 'package:project_hostelite/pages/edit_profile.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _username = '';
  String _phone = '';
  String _email = '';
  String? _profileImageUrl;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _username = userData['name'] ?? '';
        _phone = userData['phone'] ?? '';
        _email = user.email ?? '';
        _profileImageUrl = userData['profileImageUrl'];
      });

      final DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc('admin-email')
          .get();
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (adminData['adminEmail'] == _email) {
        setState(() {
          _isAdmin = true;
        });
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontSize: 18),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: primaryBlue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(color: primaryBlue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: scaffoldBackgroundColor,
        leading: IconButton(
          highlightColor: primaryBlue.withOpacity(0.2),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 22,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.homeRoute);
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(100),
                    image: _profileImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_profileImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/icons/user.png'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                      _loadUserProfile();
                    },
                    child: Icon(
                      Iconsax.edit5,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Text(
                  _username,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  _phone,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  _email,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.myListingsRoute);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: primaryBlue,
                        ),
                        child: const Icon(
                          Iconsax.shop,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      const Text(
                        'My Listings',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    _showLogoutDialog();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.redAccent,
                        ),
                        child: const Icon(
                          Iconsax.logout_1,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (_isAdmin)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.reportedListingsRoute);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.orangeAccent,
                          ),
                          child: const Icon(
                            Iconsax.warning_2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        const Text(
                          'Reports',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
