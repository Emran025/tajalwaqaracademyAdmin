import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/bloc/settings_bloc.dart';

class SubmitTicketDialog extends StatefulWidget {
  const SubmitTicketDialog({super.key});

  @override
  State<SubmitTicketDialog> createState() => _SubmitTicketDialogState();
}

class _SubmitTicketDialogState extends State<SubmitTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsBloc>().add(
            SubmitSupportTicket(
              subject: _subjectController.text,
              body: _bodyController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoadSuccess) {
          if (state.actionStatus == ActionStatus.success) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم إرسال طلبك بنجاح',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state.actionStatus == ActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error?.message ?? 'فشل إرسال الطلب',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onError,
                      ),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
      child: Dialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'إرسال طلب جديد',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'الموضوع',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.87),
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _subjectController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'أدخل موضوع الطلب',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.54),
                        ),
                    prefixIcon: Icon(
                      Icons.subject,
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.54),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الموضوع';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'الرسالة',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.87),
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bodyController,
                  textInputAction: TextInputAction.done,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'أدخل تفاصيل الطلب',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.54),
                        ),
                    prefixIcon: Icon(
                      Icons.message,
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.54),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الرسالة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    final isLoading = state is SettingsLoadSuccess &&
                        state.actionStatus == ActionStatus.loading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
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
                                'إرسال',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onBackground,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.26),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
