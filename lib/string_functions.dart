bool containsSymbol(String input) {
  final symbolRegex = RegExp(r'[^\w\s]');
  return symbolRegex.hasMatch(input);
}

  bool isAlphanumeric(String char) {
    return RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);
  }

  bool isSymbol(String char) {
    return !RegExp(r'^[a-zA-Z0-9]$').hasMatch(char);
  }