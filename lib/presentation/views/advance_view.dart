import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:agros/presentation/widgets/auth_guard.dart';
import 'package:agros/presentation/widgets/toggle_switch.dart';

import 'package:agros/data/repositories/agros_repository.dart';

import 'package:agros/presentation/views/basic_view.dart';

class AdvanceView extends StatefulWidget {
  const AdvanceView({super.key});

  @override
  State<AdvanceView> createState() => _AdvanceViewState();
}

class _AdvanceViewState extends State<AdvanceView> {
  bool isBasicMode = false; 
  bool _isLoading = false;
  final AgrosRepository _repo = AgrosRepository();

  void _handleLogout() async {
    setState(() => _isLoading = true);

    await _repo.auth.logout();

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGuard()),
        (route) => false,
      );
    }
  }
  void _switchMode(bool value) {
    if (value == true) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const BasicView(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AGROS',
                    style: GoogleFonts.baloo2(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  ToggleSwitch(
                    value: isBasicMode,
                    onChanged: _switchMode,
                  ),
                ],
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Icon(Icons.construction, size: 48, color: colorScheme.secondary),
                    const SizedBox(height: 16),
                    Text(
                      "Mode Lanjutan",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fitur dashboard lengkap sedang dikembangkan.",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Keluar Akun"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
       