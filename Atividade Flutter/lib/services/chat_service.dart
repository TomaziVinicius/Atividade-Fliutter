import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapizapi/core/supabase_client.dart';

class ChatService {
  static final SupabaseClient _db = Supabase.instance.client;

  /// STREAM DE MENSAGENS
  static Stream<List<Map<String, dynamic>>> messagesStream(String conversationId) {
    return _db
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }


  /// STREAM DE REAÇÕES (SEM .in_(), SEM .in())
  static Stream<List<Map<String, dynamic>>> reactionsStream() {
    return _db
        .from('message_reactions')
        .stream(primaryKey: ['message_id', 'user_id'])
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  /// REAGIR / REMOVER
  static Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) throw AuthException('Usuário não autenticado');

    final existing = await _db
        .from('message_reactions')
        .select()
        .eq('message_id', messageId)
        .eq('user_id', user.id)
        .eq('emoji', emoji)
        .maybeSingle();

    if (existing != null) {
      await _db
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', user.id)
          .eq('emoji', emoji);
    } else {
      await _db.from('message_reactions').insert({
        'message_id': messageId,
        'user_id': user.id,
        'emoji': emoji,
      });
    }
  }

  static Future<void> sendTextMessage({
    required String conversationId,
    required String content,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) throw AuthException('Usuário não autenticado');

    await _db.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': user.id,
      'content': content,
      'type': 'text',
    });
  }

  static Future<void> sendImageMessage({
    required String conversationId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) throw AuthException('Usuário não autenticado');

    final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}-$fileName';

    await _db.storage.from('chat_uploads').uploadBinary(path, bytes);

    final fileUrl = _db.storage.from('chat_uploads').getPublicUrl(path);

    await _db.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': user.id,
      'type': 'image',
      'file_url': fileUrl,
    });
  }
    static Future<void> editMessage({
    required String messageId,
    required String content,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) throw AuthException('Usuário não autenticado');

    await _db
        .from('messages')
        .update({
          'content': content,
          'is_edited': true,
        })
        .eq('id', messageId);
  }

  static Future<void> deleteMessage(String messageId) async {
  final user = _db.auth.currentUser;
  if (user == null) throw AuthException('Usuário não autenticado');

  await _db
      .from('messages')
      .update({
        'content': null,
        'deleted_at': DateTime.now().toIso8601String(),
      })
      .eq('id', messageId);
  }

}
