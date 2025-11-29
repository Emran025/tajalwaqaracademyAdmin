import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/error/failures.dart';
import '../../bloc/auth_bloc.dart';

class LogoutConfirmationDialog extends StatefulWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  State<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _deleteCredentials = false;
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // إعادة تعيين حالة التحميل عندما تتغير حالة المصادقة
        if (state.authStatus == AuthStatus.unauthenticated) {
          setState(() {
            _isLoggingOut = false;
          });
          Navigator.of(
            context,
          ).pop({'success': true, 'deleteCredentials': _deleteCredentials});
        } else if (state.logOutFailure != null) {
          setState(() {
            _isLoggingOut = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.logOutFailure?.message ?? 'فشل تسجيل الخروج',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Text(
                'تسجيل الخروج',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // الرسالة
              Text(
                'هل تريد تسجيل الخروج من التطبيق؟',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.87),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _deleteCredentials,
                    onChanged: _isLoggingOut
                        ? null
                        : (value) {
                            setState(() {
                              _deleteCredentials = value ?? false;
                            });
                          },
                    activeColor: Theme.of(context).colorScheme.primary,
                    checkColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Expanded(
                    child: Text(
                      'حذف بيانات التسجيل المخزنة',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.87),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  'سيتم حذف اسم المستخدم وكلمة المرور المحفوظة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.54),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoggingOut
                          ? null
                          : () => Navigator.of(context).pop({
                              'success': false,
                              'deleteCredentials': false,
                            }),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onBackground,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.26),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'البقاء',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // زر تسجيل الخروج
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoggingOut
                          ? null
                          : () {
                              setState(() {
                                _isLoggingOut = true;
                              });
                              context.read<AuthBloc>().add(
                                LogOutRequested(
                                  deleteCredentials: _deleteCredentials,
                                  message: _deleteCredentials
                                      ? 'تم تسجيل الخروج وحذف بيانات الاعتماد'
                                      : 'تم تسجيل الخروج',
                                ),
                              );

                              _setupLogoutListener();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoggingOut
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'تسجيل الخروج',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setupLogoutListener() {
    context.read<AuthBloc>().stream.listen((state) {
      if (state.authStatus == AuthStatus.unauthenticated) {
        _onLogoutSuccess();
      }
      if (state.logOutFailure != null) {
        _onLogoutFailure(state.logOutFailure!);
      }
    });
  }

  void _onLogoutSuccess() {
    debugPrint('تم تسجيل الخروج بنجاح');
    _navigateToLoginScreen();
  }

  void _onLogoutFailure(Failure failure) {
    final String errorMessage = failure.message;
    debugPrint('فشل تسجيل الخروج: $errorMessage');

    if (errorMessage.contains('Token is invalid') ||
        errorMessage.contains('already revoked')) {
      debugPrint('التوكن غير صالح - تنظيف البيانات المحلية');
      _navigateToLoginScreen();
    } else {
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showErrorSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToLoginScreen() {
    context.go('/welcome');
  }
}
