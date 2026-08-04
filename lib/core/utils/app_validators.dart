import 'package:flutter/widgets.dart';
import 'package:twigamoney/l10n/app_localizations.dart';

class AppValidators {
  static FormFieldValidator<String> required(String errorText) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorText;
      }
      return null;
    };
  }

  static String? price(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterValidPrice;
    }
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return l10n.pleaseEnterValidPrice;
    }
    return null;
  }
}
