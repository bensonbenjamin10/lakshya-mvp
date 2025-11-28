/// Supabase configuration and initialization
/// 
/// This file contains Supabase project configuration.
/// Replace YOUR_SUPABASE_URL and YOUR_SUPABASE_ANON_KEY with your actual values
/// from your Supabase project dashboard.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL
  /// Get this from: https://supabase.com/dashboard/project/_/settings/api
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  /// Supabase anonymous (public) API key
  /// Get this from: https://supabase.com/dashboard/project/_/settings/api
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );
}
