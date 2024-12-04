String regexPattern(String pattern) => pattern.startsWith('.')
    ? r'(^|/)' + pattern.replaceFirst('.', r'\.') + r'(/|$)'
    : r'(^|/)' + pattern + r'(/|$)';

bool shouldIgnorePath(String path, List<String> ignoredPatterns) {
  return ignoredPatterns.any((pattern) {
    String p = regexPattern(pattern);
    return RegExp(p).hasMatch(path);
  });
}

bool shouldAddPath(String path, String pattern) {
  String p = regexPattern(pattern);
  return RegExp(p).hasMatch(path);
}