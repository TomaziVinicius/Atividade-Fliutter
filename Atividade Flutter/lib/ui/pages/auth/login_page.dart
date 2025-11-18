import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import 'package:zapizapi/ui/widgets/custom_button.dart';
import 'package:zapizapi/ui/widgets/custom_input.dart';
import 'package:zapizapi/ui/widgets/custom_text_button.dart';
import '../home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insira seu email e senha')),
        );
        return;
      }

      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.session != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de autenticação: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: constraints.maxWidth > 768
                      ? 768
                      : constraints.maxWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logos/logo_login.png', height: 180),
                      const SizedBox(height: 24),
                      const Text('Login', style: TextStyle(fontSize: 22)),
                      const SizedBox(height: 24),
                      CustomInput(
                        label: 'Email',
                        hint: 'Digite seu email',
                        controller: emailController,
                      ),
                      const SizedBox(height: 18),
                      CustomInput(
                        label: 'Senha',
                        hint: 'Digite sua senha',
                        controller: passwordController,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomTextButton(
                          buttonText: 'Esqueci minha senha',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        backgroundColor: const Color(0xFF03A9F4),
                        buttonText: 'Entrar',
                        onPressed: _signIn,
                      ),
                      const SizedBox(height: 18),
                      CustomTextButton(
                        buttonText: 'Não tem uma conta? Cadastre-se',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
