class Validators {
  Validators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Please enter a valid email';
    return null;
  }

  // Accepts: +923001234567 or 03001234567
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
    final cleaned = value.trim().replaceAll(' ', '').replaceAll('-', '');
    final regex = RegExp(r'^(\+92|0)3[0-9]{9}$');
    if (!regex.hasMatch(cleaned)) return 'Enter a valid Pakistani mobile number';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? promoCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a promo code';
    return null;
  }
}
