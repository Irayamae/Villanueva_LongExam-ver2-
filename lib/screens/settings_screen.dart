// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_dialogs.dart';
import 'signin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(
    BuildContext context,
  ) async {
    final confirmed =
        await CustomDialogs.showConfirmation(
      context,
      title: 'Sign Out',
      message:
          'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    await context.read<AuthProvider>().signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const SigninScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    final user = authProvider.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --------------------------------------------------------
        // Account section
        // --------------------------------------------------------
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage:
                  user != null &&
                          user.image.isNotEmpty
                      ? NetworkImage(user.image)
                      : null,
              child: user == null ||
                      user.image.isEmpty
                  ? Text(
                      user != null &&
                              user.firstName
                                  .isNotEmpty
                          ? user.firstName[0]
                              .toUpperCase()
                          : '?',
                    )
                  : null,
            ),
            title: Text(
              user?.fullName ?? 'User',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              user?.email ?? '',
            ),
          ),
        ),

        const SizedBox(height: 24),

        // --------------------------------------------------------
        // Preferences
        // --------------------------------------------------------
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: Consumer<ThemeProvider>(
            builder: (
              context,
              themeProvider,
              child,
            ) {
              return SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: const Text(
                  'Dark Mode',
                ),
                subtitle: Text(
                  themeProvider.isDarkMode
                      ? 'Dark theme is enabled'
                      : 'Light theme is enabled',
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(
                    value,
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // --------------------------------------------------------
        // Sign out
        // --------------------------------------------------------
        const Text(
          'Session',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .error,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Remove your saved login session',
            ),
            onTap: () => _signOut(context),
          ),
        ),

        const SizedBox(height: 32),

        Center(
          child: Text(
            'Facebook Replication • Long Exam 1',
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ),
      ],
    );
  }
}