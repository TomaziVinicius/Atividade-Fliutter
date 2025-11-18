import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String avatar;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.avatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = supabase.auth.currentUser?.id;
    _listenToMessages();
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _listenToMessages() {
    supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', widget.chatId)
        .order('created_at', ascending: true)
        .listen((List<Map<String, dynamic>> data) {
          setState(() => messages = data);
          _scrollToBottom();
        });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'chat_id': widget.chatId,
      'sender_id': currentUserId ?? 'unknown',
      'content': text,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() => messages.add(newMessage));
    _controller.clear();
    _scrollToBottom();

    try {
      await supabase.from('messages').insert(newMessage);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar: $e')));
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _messageBubble(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == currentUserId;
    final bg = isMe ? const Color(0xFF03A9F4) : Colors.grey.shade200;
    final textColor = isMe ? Colors.white : Colors.black87;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg['content'] ?? '', style: TextStyle(color: textColor)),
            const SizedBox(height: 6),
            Text(
              msg['created_at'] != null
                  ? (DateTime.tryParse(msg['created_at']) != null
                        ? TimeOfDay.fromDateTime(
                            DateTime.parse(msg['created_at']),
                          ).format(context)
                        : '')
                  : '',
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(child: Text(widget.avatar)),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.chatName)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(child: Text('Ver contato')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('Sem mensagens ainda'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _messageBubble(messages[index]),
                  ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Mensagem',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: _sendMessage,
                    backgroundColor: const Color(0xFF03A9F4),
                    child: const Icon(Icons.send),
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
