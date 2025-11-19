import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapizapi/core/supabase_client.dart';
import 'package:zapizapi/ui/pages/chat/chat_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';
  List<Map<String, dynamic>> _results = [];

  Future<void> _performSearch() async {
    final term = _searchCtrl.text.trim();

    if (term.isEmpty) {
      setState(() {
        _error = 'Digite um nome para buscar.';
        _results = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _results = [];
    });

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'Usuário não autenticado.';
          _loading = false;
        });
        return;
      }

      // Busca por nome (contém, ignorando maiúsc/minúsc)
      final resp = await supabase
          .from('profiles')
          .select('id, full_name')
          .ilike('full_name', '%$term%')
          .neq('id', currentUser.id) // não mostra o próprio usuário
          .limit(50);

      final list = List<Map<String, dynamic>>.from(resp);

      setState(() {
        _results = list;
        _loading = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _error = 'Erro ao buscar usuários: ${e.message}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro inesperado ao buscar usuários.';
        _loading = false;
      });
    }
  }

  Future<void> _startDirectChat(Map<String, dynamic> userRow) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    final otherUserId = userRow['id'] as String;
    final otherName = userRow['full_name'] as String? ?? 'Conversa';

    if (otherUserId == currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você não pode conversar consigo mesmo.')),
      );
      return;
    }

    try {
      // Cria nova conversa 1:1
      final conv = await supabase
          .from('conversations')
          .insert({
            'is_group': false,
            'is_public': false,
            'title': otherName,
            'created_by': currentUser.id,
          })
          .select()
          .single();

      final conversationId = conv['id'] as String;

      // adiciona participantes
      await supabase.from('conversation_participants').insert([
        {
          'conversation_id': conversationId,
          'user_id': currentUser.id,
          'role': 'owner',
        },
        {
          'conversation_id': conversationId,
          'user_id': otherUserId,
          'role': 'member',
        },
      ]);

      if (!mounted) return;

      // abre o chat com o usuário selecionado
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversationId,
            title: otherName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar conversa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar usuários'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome do usuário',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          if (_loading)
            const LinearProgressIndicator(),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _results.isEmpty && !_loading
                ? const Center(
                    child: Text('Nenhum resultado.'),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final user = _results[index];
                      final name =
                          user['full_name'] as String? ?? '(sem nome)';

                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(name),
                        onTap: () => _startDirectChat(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
