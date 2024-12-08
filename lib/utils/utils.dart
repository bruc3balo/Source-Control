import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:balo/repository/commit.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/view/terminal.dart';
import 'package:crypto/crypto.dart';

String filePatternToRegex(String pattern) {
  return pattern.replaceAll('.', r'\.').replaceAll('**', r'.*').replaceAll('*', r'[^/]*').replaceAll('?', r'[^/]');
}

bool isValidBranchName(String? branchName) {
  // Check if the branch name is null or empty
  if (branchName == null || branchName.isEmpty) {
    return false;
  }

  // branch should contain spaces
  if (branchName.contains(" ")) {
    return false;
  }

  // branch should not start with a dot
  if (branchName.startsWith(".")) {
    return false;
  }

  return true;
}

///Sha1 algorithm
Sha1 createBranchSha({
  required String branchName,
  required String message,
  required int noOfObjects,
  required DateTime commitedAt,
}) {
  return computeSha1Hash(
    utf8.encode(
      [branchName, message, noOfObjects, commitedAt].join(),
    ),
  );
}

Future<Sha1> computeFileSha1Hash(File file) async => computeSha1Hash(await file.readAsBytes());

Sha1 computeSha1Hash(Uint8List bytes) => Sha1(sha1.convert(bytes).toString());
