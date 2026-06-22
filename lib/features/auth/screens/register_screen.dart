import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegister(BuildContext context) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final nim = _nimController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || nim.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi semua kolom input')),
      );
      return;
    }

    // NIM must be alphanumeric
    final isAlphanumeric = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(nim);
    if (!isAlphanumeric) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIM hanya boleh berisi huruf dan angka')),
      );
      return;
    }

    context.read<AuthBloc>().add(
      RegisterRequested(name: name, email: email, password: password, nim: nim),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pendaftaran berhasil! Silakan masuk.'),
              ),
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_add_outlined,
                        color: AppColors.primary,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Buat Akun Planly',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLightPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gabung untuk mulai mengelola jadwal kuliah Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLightSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outlineLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              label: 'Nama Lengkap',
                              hintText: 'Arief Sidik',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'contoh@gmail.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _nimController,
                              label: 'NIM',
                              hintText: 'STI210000001',
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: '••••••••',
                              isPassword: true,
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: isLoading ? 'Pendaftaran...' : 'Daftar',
                              icon: isLoading
                                  ? null
                                  : Icons.check_circle_outline,
                              onPressed: isLoading
                                  ? null
                                  : () => _submitRegister(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
