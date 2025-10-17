import 'package:email_validator/email_validator.dart';
import '../localization/app_localizations.dart';

class Validators {
  Validators._();

  static String? validateEmail(AppLocalizations l, String? value) {
    if (value == null || value.isEmpty) {
      return l.t('errors.generic');
    }
    if (!EmailValidator.validate(value)) {
      return l.t('errors.generic');
    }
    return null;
  }

  static String? validatePassword(AppLocalizations l, String? value) {
    if (value == null || value.isEmpty) {
      return l.t('errors.generic');
    }
    if (value.length < 6) {
      return l.t('errors.generic');
    }
    return null;
  }

  static String? validateConfirmPassword(
    AppLocalizations l,
    String? value,
    String password,
  ) {
    final error = validatePassword(l, value);
    if (error != null) return error;

    if (value != password) {
      return l.t('errors.generic');
    }
    return null;
  }

  static String? validateName(AppLocalizations l, String? value) {
    if (value == null || value.isEmpty) {
      return l.t('errors.generic');
    }
    return null;
  }
}
