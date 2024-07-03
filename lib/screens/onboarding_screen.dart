import 'package:flutter/material.dart';
import 'package:project_hostelite/data/onboarding_data.dart';
import 'package:project_hostelite/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController? _controller;
  int currentIndex = 0;
  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

 void completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  
  if (!mounted) return;
  Navigator.pushReplacementNamed(context, AppRoutes.authRoute);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentList[currentIndex].backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _controller,
                itemCount: contentList.length,
                onPageChanged: (index) {
                  if (index >= currentIndex) {
                    setState(() {
                      currentIndex = index;
                    });
                  } else {
                    setState(() {
                      currentIndex = index;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Image.asset(
                              contentList[index].imagePath,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              contentList[index].title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 28.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              contentList[index].description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.0,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        completeOnboarding();
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: List.generate(
                            contentList.length,
                            (index) => buildDot(index, context),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<CircleBorder>(
                          const CircleBorder(),
                        ),
                        minimumSize: WidgetStateProperty.all<Size>(
                          const Size(50, 50),
                        ),
                      ),
                      onPressed: () {
                        if (currentIndex == contentList.length - 1) {}
                        _controller!.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        if (currentIndex == contentList.length - 1) {
                          completeOnboarding();
                        }
                      },
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: contentList[currentIndex].backgroundColor,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 8,
      width: currentIndex == index ? 20 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? Colors.white : Colors.white38,
      ),
    );
  }
}
