import 'package:email_validator/email_validator.dart';
import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    if (!EmailValidator.validate(value)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    final error = validatePassword(value);
    if (error != null) return error;

    if (value != password) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.nameRequired;
    }
    return null;
  }
}
