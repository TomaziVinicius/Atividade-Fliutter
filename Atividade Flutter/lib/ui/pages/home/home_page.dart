import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapizapi/core/supabase_client.dart';
import 'package:zapizapi/ui/pages/chat/chat_page.dart';
import 'package:zapizapi/services/profile_service.dart';
import 'package:zapizapi/ui/pages/chat/user_search_page.dart'; // <-- NOVO IMPORT

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Usuário não autenticado.';
          _loading = false;
        });
        return;
      }

      // 1) buscar conversas onde o usuário participa
      final participantsResponse = await supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', user.id);

      final conversationIds =
          List<Map<String, dynamic>>.from(participantsResponse)
              .map((row) => row['conversation_id'] as String)
              .toList();

      if (!mounted) return;

      if (conversationIds.isEmpty) {
        setState(() {
          _conversations = [];
          _loading = false;
        });
        return;
      }

      // 2) buscar dados das conversas
      final idsList = conversationIds.map((id) => '"$id"').join(',');
      final inValue = '($idsList)';

      final convResponse = await supabase
          .from('conversations')
          .select('id, title, is_group, is_public, created_at')
          .filter('id', 'in', inValue)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(convResponse);

      if (!mounted) return;
      setState(() {
        _conversations = data;
        _loading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar conversas: ${e.message}';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro inesperado ao carregar conversas.';
        _loading = false;
      });
    }
  }

  void _openChat(Map<String, dynamic> conversation) {
    final id = conversation['id'] as String;
    final title = conversation['title'] as String?;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId: id,
          title: title ?? 'Chat',
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
  }

  /// Nova conversa direta (modo antigo: digitar nome exato)
  Future<void> _startNewConversation() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova conversa'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da pessoa',
              hintText: 'Digite o nome exatamente como em profiles',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um nome.')),
      );
      return;
    }

    try {
      // buscar usuário pelo nome
      final profilesResponse = await supabase
          .from('profiles')
          .select('id, full_name')
          .ilike('full_name', name);

      final profilesList = List<Map<String, dynamic>>.from(profilesResponse);

      if (profilesList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum usuário encontrado com esse nome.')),
        );
        return;
      }

      if (profilesList.length > 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mais de um usuário com esse nome. Refine a busca.'),
          ),
        );
        return;
      }

      final otherUser = profilesList.first;
      final otherUserId = otherUser['id'] as String;

      // criar conversa 1:1
      final convInsertResponse = await supabase
          .from('conversations')
          .insert({
            'is_group': false,
            'is_public': false,
            'title': otherUser['full_name'],
            'created_by': user.id,
          })
          .select()
          .single();

      final conversationId = convInsertResponse['id'] as String;

      // adicionar participantes
      await supabase.from('conversation_participants').insert([
        {
          'conversation_id': conversationId,
          'user_id': user.id,
          'role': 'owner',
        },
        {
          'conversation_id': conversationId,
          'user_id': otherUserId,
          'role': 'member',
        },
      ]);

      await _loadConversations();

      if (!mounted) return;
      _openChat(convInsertResponse);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar conversa: $e')),
      );
    }
  }

  /// Criar grupo
  Future<void> _createGroup() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final TextEditingController nameCtrl = TextEditingController();
    bool isPublic = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Criar grupo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome do grupo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Switch(
                        value: isPublic,
                        onChanged: (val) => setState(() => isPublic = val),
                      ),
                      const Text('Grupo público'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  child: const Text('Criar'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != true) return;

    final groupName = nameCtrl.text.trim();
    if (groupName.isEmpty) return;

    try {
      // criar grupo
      final conv = await supabase
          .from('conversations')
          .insert({
            'is_group': true,
            'is_public': isPublic,
            'title': groupName,
            'created_by': user.id,
          })
          .select()
          .single();

      final groupId = conv['id'] as String;

      // adicionar criador como admin
      await supabase.from('conversation_participants').insert({
        'conversation_id': groupId,
        'user_id': user.id,
        'role': 'admin',
      });

      await _loadConversations();
      if (!mounted) return;
      _openChat(conv);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar grupo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
          IconButton(
            icon: const Icon(Icons.search),         // <-- NOVO BOTÃO
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UserSearchPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _conversations.isEmpty
                  ? const Center(child: Text('Nenhuma conversa ainda.'))
                  : ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conv = _conversations[index];
                        final title = conv['title'] as String? ?? 'Sem título';
                        final isGroup = conv['is_group'] as bool? ?? false;

                        return ListTile(
                          leading: Icon(
                            isGroup ? Icons.group : Icons.person,
                            size: 32,
                          ),
                          title: Text(title),
                          subtitle: Text(isGroup ? 'Grupo' : 'Conversa direta'),
                          onTap: () => _openChat(conv),
                        );
                      },
                    ),
      floatingActionButton: PopupMenuButton<String>(
        icon: const Icon(Icons.add_circle, size: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == 'direct') _startNewConversation();
          if (value == 'group') _createGroup();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'direct', child: Text('Nova conversa')),
          const PopupMenuItem(value: 'group', child: Text('Novo grupo')),
        ],
      ),
    );
  }
}
