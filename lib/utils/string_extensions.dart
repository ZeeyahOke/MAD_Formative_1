extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String camelCaseToTitle() {
      if (isEmpty) return this;
      return replaceAll(RegExp(r'(?=[A-Z])'), ' ').trim().capitalize();
  }
}
