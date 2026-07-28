import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'home.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Home()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: ListView(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: txtEmail,
                validator: (val) =>
                    val!.isEmpty ? 'Dirección de correo inválida' : null,
                decoration: kInputDecoration('Email'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: txtPassword,
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Se requieren al menos 6 caracteres' : null,
                decoration: kInputDecoration('Password'),
              ),
              const SizedBox(height: 20),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : kTextButton('Login', () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                          _loginUser();
                        });
                      }
                    }),
              const SizedBox(height: 20),
              kLoginRegisterHint("¿No tienes una cuenta?", "Regístrate", () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Register()),
                  (route) => false,
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
