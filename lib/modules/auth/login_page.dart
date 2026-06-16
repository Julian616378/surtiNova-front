import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _formKey     = GlobalKey<FormState>();
  bool  _loading     = false;
  bool  _obscurePass = true;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final response = await ApiService.post(ApiConstants.login, {
        'correo':    _emailCtrl.text.trim(),
        'password': _passCtrl.text,
      });

      final token = response.data['token'] as String;
      await StorageService.saveToken(token);

      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data['message'] ?? 'Error de conexión';
      });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícono
                const Icon(Icons.storefront_rounded, size: 72, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text('Bienvenido', style: AppTextStyles.heading, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Ingresa tus credenciales', style: AppTextStyles.subheading, textAlign: TextAlign.center),
                const SizedBox(height: 36),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo';
                    if (!v.contains('@'))       return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),

                // Contraseña
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                    if (v.length < 6)           return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),

                // Error de API
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                    child: Text(_error!, style: AppTextStyles.error, textAlign: TextAlign.center),
                  ),

                const SizedBox(height: AppDimensions.paddingL),

                // Botón
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Iniciar sesión', style: AppTextStyles.button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}