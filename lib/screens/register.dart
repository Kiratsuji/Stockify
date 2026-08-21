import 'package:flutter/material.dart';
import 'package:stockify/screens/util/screenUtils.dart';
import 'package:stockify/services/authService.dart';

class RegisterScreen extends StatefulWidget{
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen>{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    emailController.dispose;
    passwordController.dispose;
    usernameController.dispose;
    super.dispose();
  }

  void userRegister() async{
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Preencha todos os campos')));
      return;
    }
    try{
      await _authService.userSignUp(emailController.text, passwordController.text);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Conta criada com sucesso!')));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
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
                      'Criar conta',
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

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Comece a controlar seu estoque\nde forma simples.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFFA1A1AA),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Spacer(),

                CommonTextField(controller: usernameController, labelText: 'Nome'),
                CommonTextField(controller: emailController, labelText: 'E-mail'),
                const SizedBox(height: 16),
                PasswordTextField(controller: passwordController),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: userRegister,
                      child: const Text('Criar conta')
                  ),
                )
              ],
            ),
          )
      ),
    );
  }

}