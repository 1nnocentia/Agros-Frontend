import 'package:agros/presentation/views/basic_view.dart';
import 'package:flutter/material.dart';
import 'package:agros/data/repositories/agros_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final AgrosRepository _repo = AgrosRepository();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi nomor HP dulu")));
      setState(() => _isLoading = false);
      return;
    }

    bool isUserExists = await _repo.auth.checkUserExists(phone);

    setState(() => _isLoading = false);

    if (isUserExists) {
      _performLogin(phone);
    } else {
      if (mounted) {
        _showRegisterDialog(phone);
      }
    }
  }

  void _performLogin(String phone) async {
    setState(() => _isLoading = true);
    
    bool success = await _repo.auth.login(phone);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const BasicView()),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Gagal. Pastikan nomor terdaftar sebagai Petani.")),
        );
      }
    }
  }

  void _showRegisterDialog(String phone) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Pengguna Baru?",
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          "Nomor $phone belum terdaftar. Apakah Anda ingin mendaftar sebagai Petani baru?",
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performLogin(phone);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Ya, Daftar"),
          ),
        ],
      ),
    );
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
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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