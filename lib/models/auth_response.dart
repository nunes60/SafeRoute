import '../core/json_reader.dart';

/// Representa os dados retornados após uma autenticação bem-sucedida.
class AuthResponse {
  const AuthResponse({
    required this.userId,
    required this.email,
    required this.message,
  });

  final int userId;
  final String email;
  final String message;

  /// Cria a resposta de autenticação a partir do JSON da API.
  factory AuthResponse.fromJson(Map<String, dynamic> data) {
    final usuario = JsonReader.requiredObject(data, 'usuario');

    return AuthResponse(
      userId: JsonReader.requiredInt(usuario, const [
        'id',
      ], fieldName: 'usuario.id'),
      email: JsonReader.requiredNonEmptyString(usuario, const [
        'email',
      ], fieldName: 'usuario.email'),
      message: (data['mensagem'] ?? 'Login realizado com sucesso.').toString(),
    );
  }
}
