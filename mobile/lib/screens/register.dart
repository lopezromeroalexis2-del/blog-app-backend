import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'home.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  bool loading = false;

  void _registerUser() async {
    ApiResponse response = await register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );
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
        title: const Text('Registro'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                validator: (val) => val!.isEmpty ? 'Nombre requerido' : null,
                decoration: kInputDecoration('Nombre'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val!.isEmpty ? 'Dirección de correo inválida' : null,
                decoration: kInputDecoration('Email'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Se requieren al menos 6 caracteres' : null,
                decoration: kInputDecoration('Password'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordConfirmController,
                obscureText: true,
                validator: (val) => val != passwordController.text
                    ? 'Las contraseñas no coinciden'
                    : null,
                decoration: kInputDecoration('Confirmar Password'),
              ),
              const SizedBox(height: 20),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : kTextButton('Registrarse', () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                          _registerUser();
                        });
                      }
                    }),
              const SizedBox(height: 20),
              kLoginRegisterHint("¿Ya tienes una cuenta?", "Inicia Sesión", () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Login()),
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
