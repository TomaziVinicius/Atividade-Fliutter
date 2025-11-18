import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapizapi/core/supabase_client.dart';

class ProfileService {
  /// Atualizar o nome do usuário no Auth (user_metadata) e na tabela profiles
  static Future<void> updateDisplayName(String newName) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw AuthException('Usuário não autenticado');
    }

    // 1) Atualiza metadata do auth.users
    await supabase.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': newName,
        },
      ),
    );

    // 2) Atualiza na tabela profiles
    await supabase.from('profiles').update({
      'full_name': newName,
    }).eq('id', user.id);
  }

  /// Carregar dados do profile do usuário logado
  static Future<Map<String, dynamic>?> getMyProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  /// Buscar profile de outro usuário pelo id (para mostrar status)
  static Future<Map<String, dynamic>?> getProfileById(String userId) async {
    final response = await supabase
        .from('profiles')
        .select('full_name, is_online, last_seen')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  /// Atualiza is_online e last_seen do usuário logado
  static Future<void> setOnlineStatus(bool isOnline) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final update = <String, dynamic>{
      'is_online': isOnline,
    };

    if (!isOnline) {
      update['last_seen'] = DateTime.now().toIso8601String();
    }

    await supabase
        .from('profiles')
        .update(update)
        .eq('id', user.id);
  }
}
