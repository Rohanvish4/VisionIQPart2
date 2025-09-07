class AppConfig {
  // Private constructor
  AppConfig._();

  // Singleton instance
  static final AppConfig _instance = AppConfig._();
  static AppConfig get instance => _instance;

  // Configuration values
  String? _geminiApiKey;

  // Initialize configuration
  void initialize({required String geminiApiKey}) {
    _geminiApiKey = geminiApiKey;
  }

  // Getters
  String get geminiApiKey {
    if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
      throw Exception(
        'Gemini API Key not configured. Please set up your API key in the app configuration.',
      );
    }
    return _geminiApiKey!;
  }

  // Check if configuration is valid
  bool get isConfigured => _geminiApiKey != null && _geminiApiKey!.isNotEmpty;

  // Environment-based configuration
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Auto-initialize from environment or default
  static void autoInitialize() {
    String apiKey = _envApiKey;

    // If no environment variable, try to load from secure storage or config file
    if (apiKey.isEmpty) {
      // For development, you can add a default here, but never commit it
      // apiKey = 'your-development-api-key-here';

      // In production, this should come from secure storage or server
      throw Exception(
        'API Key not found. Please configure GEMINI_API_KEY environment variable '
        'or set up secure configuration.',
      );
    }

    AppConfig.instance.initialize(geminiApiKey: apiKey);
  }
}
