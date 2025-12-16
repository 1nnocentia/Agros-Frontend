import 'package:agros/presentation/views/basic_view.dart';
import 'package:flutter/material.dart';
import 'package:agros/data/repositories/agros_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final Logger _logger = Logger('LoginView');
  final TextEditingController _phoneController = TextEditingController();
  final AgrosRepository _repo = AgrosRepository();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mohon isi nomor HP terlebih dahulu")),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    _logger.info('Starting login process for: $phone');

    _performLogin(phone);
  }

  void _performLogin(String phone) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    _logger.info('Attempting login...');
    bool success = await _repo.auth.login(phone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _logger.info('Login successful, navigating to BasicView');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BasicView()),
      );
    } else {
      _logger.warning('Login failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Login gagal. Periksa nomor HP atau koneksi internet Anda.",
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                Text(
                  'AGROS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 48),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Masuk',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: "Nomor HP",
                            hintText: "Contoh: 0812...",
                            prefixIcon: Icon(
                              Icons.phone_android_rounded,
                              color: colorScheme.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  'MASUK',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Dengan masuk, Anda menyetujui kebijakan privasi kami',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 12,
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
