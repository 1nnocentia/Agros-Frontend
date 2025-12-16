import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agros/data/repositories/agros_repository.dart';
import 'package:agros/presentation/views/basic_view.dart';
import 'package:agros/presentation/views/login_view.dart';

class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  late Future<bool> _loginCheckFuture;

  final AgrosRepository _agrosRepository = AgrosRepository();

  @override
  void initState() {
    super.initState();
    _loginCheckFuture = _agrosRepository.auth.checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loginCheckFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const BasicView();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}