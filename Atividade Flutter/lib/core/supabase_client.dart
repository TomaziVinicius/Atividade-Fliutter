import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig{
  static const url = 'https://pupvsjffsdpkstludngy.supabase.co';
  static const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1cHZzamZmc2Rwa3N0bHVkbmd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyODUzMDksImV4cCI6MjA3Nzg2MTMwOX0.GEjrYkKIpvsT4_u97TDxlBwbB3wfi9LNpkBU6aVY2bE';
}

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}