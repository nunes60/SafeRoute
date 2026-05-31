import 'package:intl/intl.dart';

/// Padroniza a formatação de datas no locale brasileiro.
class BrDateFormatter {
  const BrDateFormatter._();

  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

  /// Converte uma data para o formato curto exibido nas telas.
  static String formatShort(DateTime date) {
    return _shortDateFormat.format(date);
  }
}
