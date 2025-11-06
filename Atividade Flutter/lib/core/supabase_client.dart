import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig{
  static const url = 'https://aakzolirkrhwcwbnrlgq.supabase.co';
  static const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFha3pvbGlya3Jod2N3Ym5ybGdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NTk3OTksImV4cCI6MjA3ODAzNTc5OX0.2ouc9DOArq5S-lyWNudFiC1UDS7TcOGRG86ldwf54Zs';
}

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}