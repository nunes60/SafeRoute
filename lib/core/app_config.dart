/// Centraliza as configurações estáticas usadas pelo app.
class AppConfig {
  const AppConfig._();

  /// Define a URL base da API, permitindo sobrescrita por ambiente.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://saferoute-production-726a.up.railway.app',
  );
}
