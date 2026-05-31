import 'package:intl/intl.dart';

class BrDateFormatter {
  const BrDateFormatter._();

  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }
}
