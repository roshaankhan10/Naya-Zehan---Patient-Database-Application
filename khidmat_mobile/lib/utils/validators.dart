class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value == null) return null;
    return value.length > max ? 'Maximum $max characters allowed' : null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final clean = value.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(clean)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      DateTime.parse(value);
      return null;
    } catch (_) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
  }

  static String? pastDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;
    final parsed = DateTime.parse(value!);
    if (parsed.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> rules) {
    for (final rule in rules) {
      final error = rule(value);
      if (error != null) return error;
    }
    return null;
  }
}
