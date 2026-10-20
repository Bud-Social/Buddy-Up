/// Client-side profanity masking for post bodies (Settings → Content).
/// Device-level preference; nothing is sent to the API.
const List<String> _profanityWords = [
  'arse', 'arsehole', 'ass', 'asshole', 'bastard', 'bitch', 'bollocks',
  'bullshit', 'crap', 'cunt', 'damn', 'dick', 'dickhead', 'fuck', 'fucker',
  'goddamn', 'hell', 'motherfucker', 'piss', 'prick', 'pussy', 'shit',
  'slut', 'twat', 'wanker', 'whore',
];

final List<RegExp> _patterns = [
  for (final word in _profanityWords)
    RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false),
];

/// Mask each profanity, keeping the first letter ("hell" → "h***").
String maskProfanity(String text) {
  if (text.isEmpty) return text;
  var masked = text;
  for (final pattern in _patterns) {
    masked = masked.replaceAllMapped(pattern, (match) {
      final value = match.group(0)!;
      if (value.length <= 1) return '*' * value.length;
      return value[0] + '*' * (value.length - 1);
    });
  }
  return masked;
}
