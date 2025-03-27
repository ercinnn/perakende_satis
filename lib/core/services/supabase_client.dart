import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  
    final supabaseUrl = dotenv.get('SUPABASE_URL');
    final apiKey = dotenv.get('SUPABASE_KEY');

}