String convertPatternToRegExp(String pattern) {
// Escape special regex characters
  pattern = pattern.replaceAllMapped(
    RegExp(r'[.\\^$+(){}|[\]]'),
    (match) => '\\${match[0]}',
  );

// Convert '*' to '.*' for wildcard matching
  pattern = pattern.replaceAll('*', '.*');

// Anchor the pattern to the start of the string
  if (!pattern.startsWith('^')) pattern = '^$pattern';

// Anchor the pattern to the end of the string if it doesn't end with '.*'
  if (!pattern.endsWith('.*')) pattern += r'$';

  return pattern;
}
