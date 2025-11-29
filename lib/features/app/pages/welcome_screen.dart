import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tajalwaqaracademy/features/app/pages/app_navigation_manager.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.mediumDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // محتوى الشاشة
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // الشعار
                      Hero(
                        tag: 'logo',
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.lightCream,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: size.width * 0.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'مرحبًا بك في \nأكاديمية تاج الوقار',
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
                      const SizedBox(height: 16),
                      const Text(
                        'منصة تعليمية متكاملة لتعليم ومتابعة طلاب القرآن الكريم، للمعلمين والمشرفين عن بُعد.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.lightCream70,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () async {
                          final appNavigationManager = AppNavigationManager();
                          await appNavigationManager.setHasSeenWelcomeScreen();
                          context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.accent38,
                        ),
                        child: Text(
                          'ابدأ الآن',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
