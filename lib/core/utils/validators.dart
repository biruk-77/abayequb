class Validators {
  static final RegExp _ethiopianPhoneRegex = RegExp(r'^(\+251|0)(9|7)\d{8}$');

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!_ethiopianPhoneRegex.hasMatch(value)) {
      return 'Invalid Ethiopian phone number';
    }
    return null;
  }
}
