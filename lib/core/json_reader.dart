/// Fornece leitura validada para campos usados nos modelos da API.
class JsonReader {
  const JsonReader._();

  /// Lê um inteiro obrigatório aceitando diferentes nomes de chave.
  static int requiredInt(
    Map<String, dynamic> json,
    List<String> keys, {
    required String fieldName,
  }) {
    final value = _firstValue(json, keys);
    if (value is int) {
      return value;
    }

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }

    throw FormatException('Campo invalido: $fieldName');
  }

  /// Lê um texto obrigatório e garante que ele não esteja vazio.
  static String requiredNonEmptyString(
    Map<String, dynamic> json,
    List<String> keys, {
    required String fieldName,
  }) {
    final value = _firstValue(json, keys);
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }

    throw FormatException('Campo invalido: $fieldName');
  }

  /// Lê uma data obrigatória e tenta convertê-la para DateTime.
  static DateTime requiredDate(
    Map<String, dynamic> json,
    List<String> keys, {
    required String fieldName,
  }) {
    final value = _firstValue(json, keys);
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }

    throw FormatException('Campo invalido: $fieldName');
  }

  /// Lê um objeto obrigatório do JSON e normaliza seu tipo de mapa.
  static Map<String, dynamic> requiredObject(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw FormatException('Campo invalido: $key');
  }

  /// Retorna o primeiro valor não nulo encontrado entre as chaves informadas.
  static dynamic _firstValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key];
      }
    }

    return null;
  }
}
