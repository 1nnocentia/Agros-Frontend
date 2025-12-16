import 'package:agros/presentation/views/basic_view.dart';
import 'package:flutter/material.dart';
import 'package:agros/data/repositories/agros_repository.dart';

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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pengguna Baru?"),
        content: Text("Nomor $phone belum terdaftar. Apakah Anda ingin mendaftar sebagai Petani baru?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performLogin(phone);
            },
            child: const Text("Ya, Daftar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Masuk Agros", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Nomor HP (Contoh: 0812...)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: const Text("MASUK"),
                ),
          ],
        ),
      ),
    );
  }
}