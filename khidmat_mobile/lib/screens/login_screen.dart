import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/auth_storage.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String _error = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/token/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await AuthStorage.saveTokens(
          access: data['access'] as String,
          refresh: data['refresh'] as String,
      );

  // Fetch and store role info
      try {
        final meResponse = await ApiClient.get('/me/');
        final isAdmin = (meResponse['is_staff'] == true) || (meResponse['is_superuser'] == true);
        await AuthStorage.saveIsAdmin(isAdmin);
      } catch (_) {
        // Default to non-admin if this fails, safer than defaulting to admin
        await AuthStorage.saveIsAdmin(false);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/patients');
      }
    }
    
     else if (response.statusCode == 401 || response.statusCode == 400) {
        setState(() => _error = 'Invalid username or password.');
      } else if (response.statusCode == 429) {
        setState(() => _error = 'Too many attempts. Please wait and try again.');
      } else {
        setState(() => _error = 'Login failed. Please try again.');
      }
    } on TimeoutException {
      setState(() => _error = 'Connection timed out. Check your network.');
    } catch (e) {
      setState(() => _error = 'Connection error. Check your network.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => Validators.required(value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => Validators.required(value),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_error, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
