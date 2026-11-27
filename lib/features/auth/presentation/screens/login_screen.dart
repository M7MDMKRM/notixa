import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../../core/design_system/notixa_button.dart';
import '../../../../core/design_system/notixa_text_field.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onLoginSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background decorative glow from extracted assets
          Positioned(
            top: -50,
            right: -50,
            child: Image.asset(
              'assets/auth/reg-upper-glow.png',
              width: 250,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // App Logo
                  Center(
                    child: Image.asset(
                      'assets/Logo.png',
                      height: 72,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: NotixaPalette.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your AI voice notes, meetings and expenses.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email
                  NotixaTextField(
                    controller: _emailController,
                    hintText: 'name@example.com',
                    labelText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: NotixaPalette.primary),
                  ),
                  const SizedBox(height: 18),

                  // Password
                  NotixaTextField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    labelText: 'Password',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline, color: NotixaPalette.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  NotixaButton(
                    label: 'Sign In',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 24),

                  // Social Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
                      ),
                      onPressed: widget.onLoginSuccess,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/auth/google_logo.svg', width: 22, height: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Sign In with Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RegistrationScreen(onRegisterSuccess: widget.onLoginSuccess),
                            ),
                          );
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: NotixaPalette.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
