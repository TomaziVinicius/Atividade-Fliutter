import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import 'package:zapizapi/ui/widgets/custom_button.dart';
import '../auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> chats = [
    {
      'name': 'João Silva',
      'lastMessage': 'Opa, tudo bem?',
      'time': '14:30',
      'unread': 2,
      'avatar': '👤',
    },
    {
      'name': 'Maria Santos',
      'lastMessage': 'Pode ser depois?',
      'time': '13:15',
      'unread': 0,
      'avatar': '👤',
    },
    {
      'name': 'Grupo de Trabalho',
      'lastMessage': 'Você: Vou confirmar depois',
      'time': 'ontem',
      'unread': 5,
      'avatar': '👥',
    },
  ];

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: const Text('Novo chat'), onTap: () {}),
              PopupMenuItem(child: const Text('Configurações'), onTap: () {}),
              PopupMenuItem(child: const Text('Sair'), onTap: _signOut),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(child: Text(chat['avatar'])),
            title: Text(chat['name']),
            subtitle: Text(
              chat['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'], style: const TextStyle(fontSize: 12)),
                if (chat['unread'] > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: const Color(0xFF03A9F4),
                    child: Text(
                      chat['unread'].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            onTap: () {
              // Navegar para chat detalhado
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Novo chat
        },
        backgroundColor: const Color(0xFF03A9F4),
        child: const Icon(Icons.chat),
      ),
    );
  }
}
