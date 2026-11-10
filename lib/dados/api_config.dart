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

  /// Projeto Supabase usado no login do painel. A chave "publishable" é
  /// feita para ficar no app; quem protege os dados são as regras do banco.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mjqqwgpxbtatjqleigph.supabase.co',
  );

  static const String supabaseChave = String.fromEnvironment(
    'SUPABASE_CHAVE',
    defaultValue: 'sb_publishable_ShoWeXW19RMggtVoOZvk3Q_5oj_jOT5',
  );

  static const Duration tempoDeEspera = Duration(seconds: 3);
}
