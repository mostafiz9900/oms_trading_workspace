


extension ExtendedString on String {
  bool get isValidName {
    return !contains(RegExp(r'[0–9]'));
  }
}

extension StringExtension on String {
  String toCapitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
