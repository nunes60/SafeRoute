/// Representa falhas retornadas pela API ou pela sua interpretação.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  /// Descreve a exceção com código HTTP e mensagem para depuração.
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
