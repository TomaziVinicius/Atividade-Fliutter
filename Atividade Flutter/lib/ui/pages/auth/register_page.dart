import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import 'package:zapizapi/ui/widgets/custom_button.dart';
import 'package:zapizapi/ui/widgets/custom_input.dart';
import 'package:zapizapi/ui/widgets/custom_text_button.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> _signUp() async {
    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos')),
        );
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem')),
        );
        return;
      }

      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A senha deve ter pelo menos 6 caracteres'),
          ),
        );
        return;
      }

      await supabase.auth.signUp(email: email, password: password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/logos/logo_login.png', height: 180),
                        const SizedBox(height: 24),
                        const Text('Cadastro', style: TextStyle(fontSize: 22)),
                        const SizedBox(height: 24),
                        CustomInput(
                          label: 'Nome',
                          hint: 'Digite seu nome',
                          controller: nameController,
                        ),
                        const SizedBox(height: 18),
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
                          obscureText: true,
                        ),
                        const SizedBox(height: 18),
                        CustomInput(
                          label: 'Confirmar Senha',
                          hint: 'Confirme sua senha',
                          controller: confirmPasswordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          backgroundColor: const Color(0xFF03A9F4),
                          buttonText: 'Cadastrar',
                          onPressed: _signUp,
                        ),
                        const SizedBox(height: 18),
                        CustomTextButton(
                          buttonText: 'Já tem uma conta? Faça login',
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
