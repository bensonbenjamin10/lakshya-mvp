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
    defaultValue: 'https://spzcjpvtikyoykbgnlgr.supabase.co',
  );

  /// Supabase anonymous (public) API key
  /// Get this from: https://supabase.com/dashboard/project/_/settings/api
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwemNqcHZ0aWt5b3lrYmdubGdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNTY2NzgsImV4cCI6MjA3OTkzMjY3OH0.m06J6IujRB6dX0Cqw00Y6NnGgGUCo6yU7CdnqSIWVzc',
  );
}
