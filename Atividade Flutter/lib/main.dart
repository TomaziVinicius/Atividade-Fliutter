import 'package:flutter/material.dart';
import 'core/supabase_client.dart';
import 'services/auth_service.dart';
import 'ui/pages/auth/login_page.dart';
import 'ui/pages/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Final Flutter Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 255, 251, 34),
      ),
      home: const LoginPage(),
    );
  }
}

class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context){
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final session = AuthService.currentSession;

        if(session == null){
          return const LoginPage();
        }
        return LoginPage(); //temp
        // return const HomePage();
      },
    );
  }
}
// {
//   @override
//   Widget build(BuildContext context){
//     return MaterialApp(
//       title: 'Zapizapi Chat',
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: Colors.blue,
//       ),
//       home: const AuthGate(),
//     );
//   }
// }

// class AuthGate extends StatelessWidget{
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context){
//     final session = supabase.auth.currentSession;

//     if(session == null){
//       return const LoginPage();
//     }else{
//       return const HomePage();
//     }
//   }
// }