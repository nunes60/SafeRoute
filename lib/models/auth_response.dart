class AuthResponse {
  const AuthResponse({
    required this.userId,
    required this.email,
    required this.message,
  });

  final int userId;
  final String email;
  final String message;

  factory AuthResponse.fromJson(Map<String, dynamic> data) {
    final usuario = (data['usuario'] as Map<String, dynamic>? ?? {});

    return AuthResponse(
      userId: _parseInt(usuario['id']),
      email: (usuario['email'] ?? '').toString(),
      message: (data['mensagem'] ?? 'Login realizado com sucesso.').toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
