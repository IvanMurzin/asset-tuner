abstract final class AuthFormValidators {
  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _letterRegExp = RegExp(r'[A-Za-z]');
  static final _digitRegExp = RegExp(r'\d');

  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    return password.length >= 6 &&
        _letterRegExp.hasMatch(password) &&
        _digitRegExp.hasMatch(password);
  }

  static bool isValidOtpCode(String code) {
    return code.trim().length == 6;
  }
}
