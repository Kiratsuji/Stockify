import 'package:flutter/material.dart';
import 'package:stockify/screens/dashboard.dart';
import '../services/authService.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen>{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool loading = false;

  void login() async{
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!'),
        ),
      );
      return;
    }
    setState(() {
      loading = true;
    }); //inicia o loading
    try{
      await _authService.login(emailController.text, passwordController.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    setState(() {
      loading = false;
    }); //finaliza o loading
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),

              //--superior section--
              Column(
                children: [
                  Icon(
                    Icons.view_in_ar_rounded,
                    size: 90,
                    color: const Color(0xFF8B5CF6)
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bem vindo de volta',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  )
                ],
              ),

              const Spacer(),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-Mail', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: loading ? null : login,
                    child: loading ? const CircularProgressIndicator() : const Text('Entrar')
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}