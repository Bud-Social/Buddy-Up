String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
  if (!regex.hasMatch(value)) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Password must be at least 8 characters';
  return null;
}

String? validateRequired(String? value, [String field = 'This field']) {
  if (value == null || value.trim().isEmpty) return '$field is required';
  return null;
}

String? validateUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  final regex = RegExp(r'^https?://');
  if (!regex.hasMatch(value)) return 'Enter a valid URL starting with http(s)://';
  return null;
}
