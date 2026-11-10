class ApiConfig {
  static const bool tentarApi = bool.fromEnvironment(
    'USAR_API',
    defaultValue: true,
  );

  static const String urlBase = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Token das rotas administrativas da API (ADMIN_API_TOKEN do back).
  /// Vai na compilação: flutter build web --dart-define=ADMIN_TOKEN=...
  static const String tokenAdmin = String.fromEnvironment('ADMIN_TOKEN');

  static const Duration tempoDeEspera = Duration(seconds: 3);
}
