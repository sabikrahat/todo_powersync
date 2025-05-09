// Copy this template: `cp lib/app_config_template.dart lib/app_config.dart`
// Edit lib/app_config.dart and enter your Supabase and PowerSync project details.
class AppConfig {
  static const String supabaseUrl = 'https://uydjxcawzbcsqgupcwav.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5ZGp4Y2F3emJjc3FndXBjd2F2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3OTQ3NDksImV4cCI6MjA2MjM3MDc0OX0.yejgYvjSj_bQMPDRFItnDMwA0omPAtSWuKMHaE4jCKg';
  static const String powersyncUrl = 'https://681dfd172199a58840c17f9d.powersync.journeyapps.com';
  static const String supabaseStorageBucket =
      ''; // Optional. Only required when syncing attachments and using Supabase Storage. See packages/powersync_attachments_helper.
}
