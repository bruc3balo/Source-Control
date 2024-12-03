// bool shouldIgnorePath(String path, List<String> ignoredPatterns) {
//   // Get the basename of the file
//   String basename = path.split('/').last;
//
//   for (String pattern in ignoredPatterns) {
//     // Check for exact file extension match
//     if (pattern.startsWith('.')) {
//       if (basename.endsWith(pattern)) return true;
//     }
//
//     // Check for exact filename match
//     if (basename == pattern) return true;
//
//     // Check for nested path match
//     if (path.contains('/$pattern/') || path.contains('/$pattern')) return true;
//   }
//
//   return false;
// }
//
// bool shouldAddPath(String path, String pattern) {
//   // Get the basename of the file
//   String basename = path.split('/').last;
//
//   // Check if pattern starts with a dot (file extension)
//   if (pattern.startsWith('.')) {
//     return basename.endsWith(pattern);
//   }
//
//   // Check for exact filename match
//   if (basename == pattern) return true;
//
//   // Check for path containing the pattern
//   return path.contains('/$pattern/') || path.contains('/$pattern');
// }

bool shouldIgnorePath(String path, List<String> ignoredPatterns) {
  return ignoredPatterns.any((pattern) {
    // Convert pattern to a regex that matches file extensions, exact filenames, and nested paths
    String regexPattern = pattern.startsWith('.')
        ? r'(^|/)' + pattern.replaceFirst('.', r'\.')  + r'(/|$)'
        : r'(^|/)' + pattern + r'(/|$)';

    return RegExp(regexPattern).hasMatch(path);
  });
}

bool shouldAddPath(String path, String pattern) {
  // Convert pattern to a regex that matches file extensions, exact filenames, and nested paths
  String regexPattern = pattern.startsWith('.')
      ? r'(^|/)' + pattern.replaceFirst('.', r'\.')  + r'(/|$)'
      : r'(^|/)' + pattern + r'(/|$)';

  return RegExp(regexPattern).hasMatch(path);
}