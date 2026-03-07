import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyText extends StatelessWidget {
  final num value;
  final String? currencyCode;

  const CurrencyText(this.value, {this.currencyCode, super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );
    return Text(format.format(value));
  }
}
