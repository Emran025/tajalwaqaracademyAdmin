import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';

import '../../../../../shared/widgets/custom_button.dart';
import '../../bloc/auth_bloc.dart';
// import '../../../../../core/constants/app_colors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isPasswordVisible = false;

  void _submitForgetPassword(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ForgetPasswordRequested(email: emailController.text.trim()),
      );
    }
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.lightCream70),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.lightCream70,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            )
          : null,
      filled: true,
      fillColor: AppColors.lightCream.withOpacity(0.1),
      labelStyle: const TextStyle(color: AppColors.lightCream),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightCream26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightCream),
      ),
      errorStyle: const TextStyle(color: Colors.amber),
    );
  }

  bool isPasswordType = true;

  bool isEmail(String text) {
    const pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(text);
  }

  bool isDidNotUploded = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.ltr,
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
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.lightCream12,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.lightCream26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBackground26,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Hero(
                            tag: 'logo',
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.lightCream,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: size.width * 0.30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppColors.lightCream),
                            validator: (val) =>
                                val!.trim().contains('@') ||
                                    val.trim().length >= 7
                                ? null
                                : 'بريد أو رقم هاتف غير صالح',
                            decoration: _inputDecoration(
                              "رقم الهاتف أو البريد الإلكتروني",
                              Icons.email,
                            ),
                          ),
                          const SizedBox(height: 16),

                          const SizedBox(height: 24),
                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state.forgetPasswordStatus ==
                                  ForgetPasswordStatus.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم ارسال رابط تعيين كلمة السر الى الإيميل',
                                    ),
                                  ),
                                );
                                context.go('/logIn');
                              } else if (state.forgetPasswordStatus ==
                                  ForgetPasswordStatus.failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.forgetPasswordFailure!.message,
                                    ),
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              return state.forgetPasswordStatus ==
                                      ForgetPasswordStatus.submitting
                                  ? const CircularProgressIndicator(
                                      color: AppColors.lightCream,
                                    )
                                  : CustomButton(
                                      text: 'تعيين',
                                      onPressed: () =>
                                          _submitForgetPassword(context),
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
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
