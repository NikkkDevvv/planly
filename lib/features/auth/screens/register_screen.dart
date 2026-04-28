import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _name_controller = TextEditingController();
  final TextEditingController _email_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();
  final TextEditingController _confirm_password_controller = TextEditingController();
  
  final AuthService _auth_service = AuthService();
  bool _is_loading = false;

  @override
  void dispose() {
    _name_controller.dispose();
    _email_controller.dispose();
    _password_controller.dispose();
    _confirm_password_controller.dispose();
    super.dispose();
  }

  Future<void> _handle_register() async {
    final name = _name_controller.text.trim();
    final email = _email_controller.text.trim();
    final password = _password_controller.text.trim();
    final confirm_password = _confirm_password_controller.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _show_message('Please fill in all fields');
      return;
    }

    if (password != confirm_password) {
      _show_message('Passwords do not match');
      return;
    }

    setState(() => _is_loading = true);

    try {
      final success = await _auth_service.register(name, email, password);

      if (success && mounted) {
        _show_message('Registration successful! Please login.');
        Navigator.pop(context); // Kembali ke halaman Login
      } else if (mounted) {
        _show_message('Registration failed. Email might be taken.');
      }
    } catch (e) {
      if (mounted) _show_message('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _is_loading = false);
    }
  }

  void _show_message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.calendar_today, color: AppColors.primary, size: 32),
                    SizedBox(width: 8),
                    Text(
                      'Planly',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Create an Account',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _name_controller,
                        label: 'Full Name',
                        hintText: 'John Doe',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _email_controller,
                        label: 'Email',
                        hintText: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _password_controller,
                        label: 'Password',
                        hintText: '••••••••',
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirm_password_controller,
                        label: 'Confirm Password',
                        hintText: '••••••••',
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: _is_loading ? 'Registering...' : 'Register',
                        icon: _is_loading ? null : Icons.person_add,
                        onPressed: _is_loading ? null : _handle_register,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}