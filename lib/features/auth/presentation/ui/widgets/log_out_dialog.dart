// lib/features/auth/presentation/ui/widgets/log_out_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/auth/presentation/bloc/auth_bloc.dart';

class LogOutDialog extends StatefulWidget {
  final int userId;
  const LogOutDialog({super.key, required this.userId});

  @override
  State<LogOutDialog> createState() => _LogOutDialogState();
}

class _LogOutDialogState extends State<LogOutDialog> {
  bool _keepLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Out'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Are you sure you want to log out?'),
          Row(
            children: [
              Checkbox(
                value: _keepLoggedIn,
                onChanged: (value) {
                  setState(() {
                    _keepLoggedIn = value!;
                  });
                },
              ),
              const Text('Keep me logged in'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (!_keepLoggedIn) {
              context
                  .read<AuthBloc>()
                  .add(RemoveDeviceAccount(userId: widget.userId));
            }
            context.read<AuthBloc>().add(LoggedOut(userId: widget.userId));
            Navigator.of(context).pop();
          },
          child: const Text('Log Out'),
        ),
      ],
    );
  }
}
