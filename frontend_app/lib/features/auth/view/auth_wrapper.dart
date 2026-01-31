import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../view/login_screen.dart';
import '../../navigation/main_navigation.dart';

class AuthWrapper extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const AuthWrapper({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authController = AuthController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await _authController.checkAuthStatus();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _authController,
      builder: (context, _) {
        if (_authController.isLoggedIn) {
          return MainNavigation(
            onThemeToggle: widget.onThemeToggle,
            isDarkMode: widget.isDarkMode,
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}