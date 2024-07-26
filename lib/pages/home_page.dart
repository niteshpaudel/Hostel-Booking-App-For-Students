import 'package:flutter/material.dart';
import 'package:project_hostelite/pages/all_listings.dart';
import 'package:project_hostelite/pages/chat_list.dart';
import 'package:project_hostelite/pages/user_profile.dart';
import 'package:project_hostelite/screens/home_screen.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_hostelite/utils/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentScreen = 0;
  List<Widget> screens = const [
    HomeScreen(),
    AllListingsPage(),
    ChatListPage(),
    UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        color: Colors.white,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  currentScreen = 0;
                });
              },
              child: Column(
                children: [
                  Icon(
                    currentScreen == 0 ? Iconsax.home5 : Iconsax.home,
                    color: currentScreen == 0 ? primaryBlue : Colors.grey,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 14,
                      color: currentScreen == 0 ? primaryBlue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentScreen = 1;
                });
              },
              child: Column(
                children: [
                  Icon(
                    currentScreen == 1 ? Iconsax.location5 : Iconsax.location,
                    color: currentScreen == 1 ? primaryBlue : Colors.grey,
                  ),
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 14,
                      color: currentScreen == 1 ? primaryBlue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentScreen = 2;
                });
              },
              child: Column(
                children: [
                  Icon(
                    currentScreen == 2 ? Iconsax.message5 : Iconsax.message,
                    color: currentScreen == 2 ? primaryBlue : Colors.grey,
                  ),
                  Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 14,
                      color: currentScreen == 2 ? primaryBlue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  currentScreen = 3;
                });
              },
              child: Column(
                children: [
                  Icon(
                    currentScreen == 3
                        ? Iconsax.profile_circle5
                        : Iconsax.profile_circle,
                    color: currentScreen == 3 ? primaryBlue : Colors.grey,
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 14,
                      color: currentScreen == 3 ? primaryBlue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: screens[currentScreen],
      floatingActionButton: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
        child: FloatingActionButton(
          elevation: 0,
          tooltip: 'List Room',
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.uploadPageRoute);
          },
          backgroundColor: primaryBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          splashColor: primaryBlue,
          highlightElevation: 0,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Iconsax.add,
              color: primaryBlue,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
