import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormatVND = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');

  static String formatCurrency(double amount, [String currencyCode = 'VND']) {
    if (currencyCode.toUpperCase() == 'VND') {
      return _currencyFormatVND.format(amount);
    }
    return NumberFormat.currency(name: currencyCode).format(amount);
  }

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatMonthYear(int month, int year) => _monthYearFormat.format(DateTime(year, month));
}
