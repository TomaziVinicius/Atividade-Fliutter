import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapizapi/core/supabase_client.dart';

class GroupManagementPage extends StatefulWidget {
  final String conversationId;

  const GroupManagementPage({super.key, required this.conversationId});

  @override
  State<GroupManagementPage> createState() => _GroupManagementPageState();
}

class _GroupManagementPageState extends State<GroupManagementPage> {
  List<Map<String, dynamic>> _participants = [];
  bool _loading = true;
  bool _isAdmin = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final resp = await supabase
          .from('conversation_participants')
          .select('user_id, role, joined_at, profiles(full_name)')
          .eq('conversation_id', widget.conversationId);

      final data = List<Map<String, dynamic>>.from(resp);

      bool admin = false;
      for (final p in data) {
        if (p['user_id'] == user.id && p['role'] == 'admin') {
          admin = true;
        }
      }

      setState(() {
        _currentUserId = user.id;
        _participants = data;
        _isAdmin = admin;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  // ----------------------------------------------
  // ADICIONAR MEMBRO
  // ----------------------------------------------
  Future<void> _addParticipant() async {
    final TextEditingController searchCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar membro'),
        content: TextField(
          controller: searchCtrl,
          decoration: const InputDecoration(labelText: 'Nome (profiles.full_name)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Adicionar')),
        ],
      ),
    );

    if (ok != true) return;

    final name = searchCtrl.text.trim();
    if (name.isEmpty) return;

    try {
      final result = await supabase
          .from('profiles')
          .select('id, full_name')
          .ilike('full_name', name);

      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado')),
        );
        return;
      }

      final userId = result.first['id'];

      await supabase.from('conversation_participants').insert({
        'conversation_id': widget.conversationId,
        'user_id': userId,
        'role': 'member',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membro adicionado')),
      );

      _loadParticipants();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  // ----------------------------------------------
  // REMOVER MEMBRO
  // ----------------------------------------------
  Future<void> _removeParticipant(String userId) async {
    if (!_isAdmin) return;

    // Não pode remover a si mesmo aqui (usar sair do grupo)
    if (userId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use "Sair do grupo" para remover você.')),
      );
      return;
    }

    await supabase
        .from('conversation_participants')
        .delete()
        .eq('conversation_id', widget.conversationId)
        .eq('user_id', userId);

    _loadParticipants();
  }

  // ----------------------------------------------
  // PROMOVER MEMBRO A ADMIN
  // ----------------------------------------------
  Future<void> _promoteToAdmin(String userId) async {
    if (!_isAdmin) return;

    await supabase
        .from('conversation_participants')
        .update({'role': 'admin'})
        .eq('conversation_id', widget.conversationId)
        .eq('user_id', userId);

    _loadParticipants();
  }

  // ----------------------------------------------
  // SAIR DO GRUPO
  // ----------------------------------------------
  Future<void> _leaveGroup() async {
    final userId = _currentUserId;
    if (userId == null) return;

    // Verificar se o usuário é admin
    final me = _participants.firstWhere((p) => p['user_id'] == userId);
    final myRole = me['role'];

    // Contar admins
    final adminCount =
        _participants.where((p) => p['role'] == 'admin').length;

    // Se só existe 1 admin → precisa transferir antes
    if (myRole == 'admin' && adminCount == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você é o único admin. Transfira antes.')),
      );
      return;
    }

    await supabase
        .from('conversation_participants')
        .delete()
        .eq('conversation_id', widget.conversationId)
        .eq('user_id', userId);

    if (mounted) Navigator.pop(context);
  }

  // ----------------------------------------------
  // UI
  // ----------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participantes do grupo'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _addParticipant,
            ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _leaveGroup,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final p = _participants[index];
                final name = p['profiles']['full_name'] ?? 'Sem nome';
                final role = p['role'];
                final isMe = p['user_id'] == _currentUserId;

                return ListTile(
                  leading: CircleAvatar(child: Text(name[0])),
                  title: Text(name),
                  subtitle: Text(role == 'admin' ? 'Administrador' : 'Membro'),
                  trailing: _isAdmin && !isMe
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'remove') _removeParticipant(p['user_id']);
                            if (value == 'admin') _promoteToAdmin(p['user_id']);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remover do grupo'),
                            ),
                            const PopupMenuItem(
                              value: 'admin',
                              child: Text('Tornar administrador'),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
    );
  }
}
