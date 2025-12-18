import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}

/**
 * import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Get values from environment variables
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';

  // Application configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Ainslie';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // Authentication configuration
  static bool get enableEmailConfirmation =>
      dotenv.env['ENABLE_EMAIL_CONFIRMATION']?.toLowerCase() == 'true';
  static bool get enablePhoneConfirmation =>
      dotenv.env['ENABLE_PHONE_CONFIRMATION']?.toLowerCase() == 'true';

  // Database configuration
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String chatsTable = 'chats';

  // Storage configuration
  static const String avatarBucket = 'avatars';
  static const String documentsBucket = 'documents';
}

 */
