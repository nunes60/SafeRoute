/// Centraliza as configurações estáticas do app por ambiente.
class AppConfig {
  const AppConfig._();

  /// Lê a URL base da API via --dart-define e usa fallback de produção.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://saferoute-production-726a.up.railway.app',
  );
}
