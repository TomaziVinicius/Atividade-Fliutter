import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import 'package:zapizapi/ui/widgets/custom_button.dart';
import 'package:zapizapi/ui/widgets/custom_input.dart';
import 'package:zapizapi/ui/widgets/custom_text_button.dart';

// TODO(gustavo96ma): Implementar sistema de rotas das páginas
// TODO: Extrair o código para a login_screen
// TODO:Implementar a register screen
// TODO: Integrar com o Supabase
// TODO: Login Social
// TODO: Implementar awesome_lints

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signIn() async {
    try{
      final email = emailController.text.trim();
      final password = passwordController.text;

      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if(res.session != null && mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Realizado com Sucesso')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
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
                  width: constraints.maxWidth > 768 ? 768 : constraints.maxWidth,
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
                        onPressed: () {},
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

// @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.all(24.0),
//                   child: SizedBox(
//                     width: constraints.maxWidth > 768
//                         ? 768
//                         : constraints.maxWidth,
//                     child: Column(
//                       children: [
//                         Image(
//                           image: AssetImage('assets/logos/logo_login.png'),
//                           height: 280,
//                         ),
//                         SizedBox(height: 18),
//                         SizedBox(
//                           width: double.infinity,
//                           child: Text('Login', style: TextStyle(fontSize: 20)),
//                         ),
//                         SizedBox(height: 18),
//                         CustomInput(
//                           hint: 'Digite seu email',
//                           label: 'Email',
//                           controller: emailController,
//                         ),
//                         SizedBox(height: 18),
//                         CustomInput(
//                           hint: 'Digite sua senha',
//                           label: 'Senha',
//                           controller: passwordController,
//                         ),
//                         Align(
//                           alignment: AlignmentGeometry.centerRight,
//                           child: CustomTextButton(
//                             buttonText: 'Esqueci minha senha',
//                           ),
//                         ),
//                         SizedBox(height: 18),
//                         CustomButton(
//                           buttonText: 'Entrar',
//                           backgroundColor: Color(0xFF03A9F4),
//                           onPressed: () {},
//                           // () async {
//                             // try{
//                             //   final emai = emailController.text.trim();
//                             //   final password = passwordController.text;

//                             //   final res = await.auth.signInWithPassword(
//                             //     email: email,
//                             //     password: password,
//                             //   );

//                             //   if (res.session != null && constext.mounted) {
//                             //     Navigator.of(context).pushReplacement(
//                             //       MaterialPageRoute(builder: (_) => const HomePage()),
//                             //     );
//                             //   }
//                             // } catch (e){
//                             //   // Mostra Erro
//                             // }
//                           // }
//                         ),
//                         SizedBox(height: 18),
//                         CustomTextButton(
//                           buttonText: 'Não tem uma conta? Cadastre-se',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }


// -----------------------Modelo--------------------------

// void main() {
//   runApp(MainApp());
// }

// class MainApp extends StatelessWidget {
//   MainApp({super.key});

//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.all(24.0),
//                   child: SizedBox(
//                     width: constraints.maxWidth > 768
//                         ? 768
//                         : constraints.maxWidth,
//                     child: Column(
//                       children: [
//                         Image(
//                           image: AssetImage('assets/logos/logo_login.png'),
//                           height: 280,
//                         ),
//                         SizedBox(height: 18),
//                         SizedBox(
//                           width: double.infinity,
//                           child: Text('Login', style: TextStyle(fontSize: 20)),
//                         ),
//                         SizedBox(height: 18),
//                         CustomInput(
//                           hint: 'Digite seu email',
//                           label: 'Email',
//                           controller: emailController,
//                         ),
//                         SizedBox(height: 18),
//                         CustomInput(
//                           hint: 'Digite sua senha',
//                           label: 'Senha',
//                           controller: passwordController,
//                         ),
//                         Align(
//                           alignment: AlignmentGeometry.centerRight,
//                           child: CustomTextButton(
//                             buttonText: 'Esqueci minha senha',
//                           ),
//                         ),
//                         SizedBox(height: 18),
//                         CustomButton(
//                           buttonText: 'Entrar',
//                           backgroundColor: Color(0xFF03A9F4),
//                           onPressed: () async {
//                             try{
//                               final emai = emailController.text.trim();
//                               final password = passwordController.text;

//                               final res = await.auth.signInWithPassword(
//                                 email: email,
//                                 password: password,
//                               );

//                               if (res.session != null && constext.mounted) {
//                                 Navigator.of(context).pushReplacement(
//                                   MaterialPageRoute(builder: (_) => const HomePage()),
//                                 );
//                               }
//                             } catch (e){
//                               // Mostra Erro
//                             }
//                           }
//                         ),
//                         SizedBox(height: 18),
//                         CustomTextButton(
//                           buttonText: 'Não tem uma conta? Cadastre-se',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
