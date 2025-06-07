import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/db_helper.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    final existingUser = await DBHelper.getUserByEmail(email);
    if (existingUser != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Този email вече е регистриран.')),
      );
      return;
    }

    final uuid = const Uuid().v4();

    final user = UserModel(
      uid: uuid,
      email: email,
      name: name,
      password: password,
      createdAt: DateTime.now(),
    );

    await DBHelper.insertUser(user);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedUserUid', user.uid);

    setState(() => _isLoading = false);

    Navigator.pushReplacementNamed(context, '/home', arguments: user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Име'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Въведете име' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value == null || !value.contains('@') ? 'Невалиден email' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Парола'),
                obscureText: true,
                validator: (value) =>
                value == null || value.length < 6 ? 'Минимум 6 символа' : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: register,
                child: const Text('Регистрирай се'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Вече имаш акаунт? Влез'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
