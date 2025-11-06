import 'package:flutter/material.dart';
import 'core/supabase_client.dart';
import 'ui/pages/auth/login_page.dart';
// import 'ui/pages/home/home_page.dart';

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
      title: 'Zipzap Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginPage(),
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