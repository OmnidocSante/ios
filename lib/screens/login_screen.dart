import 'package:flutter/material.dart';
import '../services/methods/login_methods.dart';
import '../widgets/home/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return LoginWidgets.buildLoginScreen(
      loginForm: LoginWidgets.buildLoginForm(
        emailController: _emailController,
        passwordController: _passwordController,
        obscurePassword: _obscurePassword,
        onTogglePassword: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        onLogin: () {
          String email = _emailController.text;
          String password = _passwordController.text;
          LoginMethods.login(email, password, context);
        },
        isLoading: _isLoading,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
