class ApiConfig {
  static const bool usarApi = bool.fromEnvironment('USAR_API');

  static const String urlBase = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static String get descricaoDaOrigem {
    if (!usarApi) return 'Dados de exemplo no próprio navegador';
    return 'API em $urlBase';
  }
}
