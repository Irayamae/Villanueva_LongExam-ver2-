// lib/screens/signin_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_textformfield.dart';
import 'home_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController(
    text: 'emilys',
  );

  final _passwordController = TextEditingController(
    text: 'emilyspass',
  );

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } else {
      await CustomDialogs.showError(
        context,
        title: 'Sign In Failed',
        message: authProvider.error ??
            'Unable to sign in. Please check your credentials and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    // --------------------------------------------
                    // Logo
                    // --------------------------------------------
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        padding:
                            const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/images/NUCCITLogo_White.png',
                          fit: BoxFit.contain,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.people_alt_rounded,
                              color: Colors.white,
                              size: 50,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue to your feed',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --------------------------------------------
                    // Username
                    // --------------------------------------------
                    CustomTextFormField(
                      controller: _usernameController,
                      label: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icons.person_outline,
                      textInputAction:
                          TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your username.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // --------------------------------------------
                    // Password
                    // --------------------------------------------
                    CustomTextFormField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons
                              .visibility_off_outlined,
                      onSuffixTap: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                      obscureText: _obscurePassword,
                      textInputAction:
                          TextInputAction.done,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter your password.';
                        }

                        return null;
                      },
                      onChanged: (_) {
                        if (context
                            .read<AuthProvider>()
                            .error !=
                            null) {
                          context
                              .read<AuthProvider>()
                              .clearError();
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // --------------------------------------------
                    // Sign In
                    // --------------------------------------------
                    Consumer<AuthProvider>(
                      builder: (
                        context,
                        authProvider,
                        child,
                      ) {
                        return CustomButton(
                          text: 'Sign In',
                          icon: Icons.login,
                          isLoading:
                              authProvider.isLoading,
                          onPressed: _signIn,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}