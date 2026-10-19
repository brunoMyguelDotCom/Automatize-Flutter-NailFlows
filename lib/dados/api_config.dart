class ApiConfig {
  static const bool tentarApi = bool.fromEnvironment(
    'USAR_API',
    defaultValue: true,
  );

  static const String urlBase = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const Duration tempoDeEspera = Duration(seconds: 3);
}
