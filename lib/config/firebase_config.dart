/// Firebase configuration and initialization
/// 
/// This file contains Firebase project configuration.
/// Replace the values with your actual Firebase project configuration
/// from Firebase Console: https://console.firebase.google.com
class FirebaseConfig {
  FirebaseConfig._();

  /// Firebase API Key (public, safe for web)
  /// Get this from: Firebase Console > Project Settings > General > Your apps > Web app
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  /// Firebase Project ID
  /// Get this from: Firebase Console > Project Settings > General
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  /// Firebase App ID
  /// Get this from: Firebase Console > Project Settings > General > Your apps > Web app
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '',
  );

  /// Firebase Messaging Sender ID
  /// Get this from: Firebase Console > Project Settings > Cloud Messaging
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );

  /// Firebase Measurement ID (for Analytics)
  /// Get this from: Firebase Console > Project Settings > General > Your apps > Web app
  static const String measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: '',
  );

  /// Check if Firebase is configured
  static bool get isConfigured {
    return apiKey.isNotEmpty &&
        projectId.isNotEmpty &&
        appId.isNotEmpty &&
        messagingSenderId.isNotEmpty;
  }
}

