import 'package:flutter/material.dart';
import 'package:zapizapi/services/chat_service.dart';
import 'package:zapizapi/ui/pages/chat/group_management_page.dart';
import 'package:zapizapi/core/supabase_client.dart'; // usuario logado
import 'package:zapizapi/services/profile_service.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String? title;

  const ChatPage({
    super.key,
    required this.conversationId,
    this.title,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  // emojis disponíveis
  final List<String> _emojiList = ['👍', '❤️', '😂', '🔥', '😢', '😮'];

  Map<String, dynamic>? _otherUserProfile;
  bool _loadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadOtherUserStatus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // carrega o perfil do outro participante (para 1:1)
  Future<void> _loadOtherUserStatus() async {
    final current = supabase.auth.currentUser;
    if (current == null) {
      setState(() => _loadingStatus = false);
      return;
    }

    try {
      final resp = await supabase
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', widget.conversationId);

      final list = List<Map<String, dynamic>>.from(resp);

      String? otherId;
      for (final row in list) {
        if (row['user_id'] != current.id) {
          otherId = row['user_id'] as String;
          break;
        }
      }

      if (otherId == null) {
        setState(() => _loadingStatus = false);
        return;
      }

      final profile = await ProfileService.getProfileById(otherId);

      if (!mounted) return;
      setState(() {
        _otherUserProfile = profile;
        _loadingStatus = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStatus = false);
    }
  }

  String _formatLastSeen(dynamic lastSeen) {
    if (lastSeen == null) return 'offline';

    final dt = DateTime.tryParse(lastSeen.toString());
    if (dt == null) return 'offline';

    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');

    return 'visto por último em $d/$m $h:$min';
  }

  void _openGroupManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GroupManagementPage(conversationId: widget.conversationId),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await ChatService.sendTextMessage(
        conversationId: widget.conversationId,
        content: text,
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    }
  }

  // popup de reações ao segurar uma mensagem
  void _showReactionsPopup(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _emojiList.map((emoji) {
              return GestureDetector(
                onTap: () async {
                  await ChatService.toggleReaction(
                    messageId: messageId,
                    emoji: emoji,
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // popup de ações (editar / apagar)
  void _showMessageActions(Map<String, dynamic> msg) {
    final msgId = msg['id'];
    final senderId = msg['sender_id'];
    final currentUser = supabase.auth.currentUser;

    // só o autor pode editar / apagar
    if (currentUser == null || currentUser.id != senderId) return;

    // se já foi apagada, não faz nada
    if (msg['deleted_at'] != null) return;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar mensagem'),
                onTap: () {
                  Navigator.pop(context);
                  _openEditDialog(msgId, msg['content'] ?? '');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Apagar mensagem'),
                onTap: () async {
                  Navigator.pop(context);
                  await ChatService.deleteMessage(msgId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // diálogo para editar mensagem
  void _openEditDialog(String messageId, String oldContent) {
    final controller = TextEditingController(text: oldContent);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar mensagem'),
          content: TextField(
            controller: controller,
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newText = controller.text.trim();
                if (newText.isEmpty) {
                  Navigator.pop(context);
                  return;
                }
                await ChatService.editMessage(
                  messageId: messageId,
                  content: newText,
                );
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = () {
      if (_otherUserProfile == null) return '';
      if (_otherUserProfile!['is_online'] == true) return 'online';
      return _formatLastSeen(_otherUserProfile!['last_seen']);
    }();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title ?? 'Chat'),
            if (statusText.isNotEmpty)
              Text(
                statusText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _openGroupManagement,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // 1º Stream: reações
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService.reactionsStream(),
              builder: (context, reactSnap) {
                final reactions = reactSnap.data ?? [];

                // agrupar reações por mensagem
                final Map<String, Map<String, int>> groupedReactions = {};
                for (final r in reactions) {
                  final msgId = r['message_id'];
                  final emoji = r['emoji'];

                  groupedReactions.putIfAbsent(msgId, () => {});
                  groupedReactions[msgId]!
                      .update(emoji, (v) => v + 1, ifAbsent: () => 1);
                }

                // 2º Stream: mensagens da conversa
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: ChatService.messagesStream(widget.conversationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Erro ao carregar mensagens'),
                      );
                    }

                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma mensagem ainda.'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final msgId = msg['id'];
                        final content = msg['content'] ?? '';
                        final senderId = msg['sender_id'] ?? '';
                        final createdAt = msg['created_at']?.toString();
                        final messageReactions =
                            groupedReactions[msgId] ?? {};
                        final deletedAt = msg['deleted_at'];
                        final isEdited = msg['is_edited'] == true;

                        return GestureDetector(
                          onLongPress: () => _showReactionsPopup(msgId),
                          onTap: () => _showMessageActions(msg),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    senderId,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  if (deletedAt != null) ...[
                                    const Text(
                                      'Mensagem apagada',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(content),
                                    if (isEdited)
                                      const Text(
                                        '(editada)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],

                                  if (messageReactions.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      children: messageReactions.entries
                                          .map((entry) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                              right: 6),
                                          padding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                          ),
                                          child: Text(
                                              "${entry.key} ${entry.value}"),
                                        );
                                      }).toList(),
                                    ),
                                  ],

                                  if (createdAt != null)
                                    Text(
                                      createdAt,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Digite uma mensagem',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
