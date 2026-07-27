import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

/// Login screen representing the primary authentication entry point.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: const LoginForm()),
      ),
    );
  }
}
