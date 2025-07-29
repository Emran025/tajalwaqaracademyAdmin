// import 'dart:async';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
// import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // void logOut() {
  //   setState() {
  //     loggedInAccount = CacheHelper().loggedInAccount();
  //   }
  // }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2000), () {
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: AppColors.accent,
          gradient: const LinearGradient(
            colors: [
              AppColors.accent,
              AppColors.mediumDark,
              AppColors.darkBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.accent70,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: size.width * 0.70,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'أكاديمية تاج الوقار',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.lightCream,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
