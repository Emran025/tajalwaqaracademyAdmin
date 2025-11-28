// lib/features/auth/presentation/ui/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tajalwaqaracademy/features/auth/presentation/ui/widgets/log_in_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigate to the home screen
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is Unauthenticated) {
            return Column(
              children: [
                if (state.deviceAccounts.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.deviceAccounts.length,
                      itemBuilder: (context, index) {
                        final account = state.deviceAccounts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: account.avatar != null
                                ? NetworkImage(account.avatar!)
                                : null,
                            child: account.avatar == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(account.name),
                          subtitle: Text(account.email),
                          onTap: () {
                            context.read<AuthBloc>().add(
                                  LogInWithDeviceAccount(userId: account.id),
                                );
                          },
                        );
                      },
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const LogInDialog(),
                    );
                  },
                  child: const Text('Log in with another account'),
                ),
              ],
            );
          }
          return const Center(
            child: Text('Something went wrong.'),
          );
        },
      ),
    );
  }
}
