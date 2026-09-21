class AppValidators {
  static String? requiredField(String? value, {String message = 'هذا الحقل مطلوب'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? validAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال المبلغ';
    }
    // Normalize Arabic numerals to Western
    final normalized = normalizeDigits(value.trim());
    final amount = double.tryParse(normalized);
    if (amount == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    if (amount <= 0) {
      return 'المبلغ يجب أن يكون أكبر من الصفر';
    }
    return null;
  }

  static String? validPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 6) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }

  static String normalizeDigits(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const westernDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String output = input;
    for (int i = 0; i < 10; i++) {
      output = output.replaceAll(arabicDigits[i], westernDigits[i]);
    }
    return output;
  }
}
