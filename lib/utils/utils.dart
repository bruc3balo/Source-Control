import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

///[Function] to validate a [Branch] name and takes a [branchName]
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

///Sha1 algorithm on a [Commit]
Sha1 createCommitSha({
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

///Creates a [Sha1] from a [file]
Future<Sha1> computeFileSha1Hash(File file) async => computeSha1Hash(await file.readAsBytes());

///Creates a [Sha1] hash from [bytes] data
Sha1 computeSha1Hash(Uint8List bytes) => Sha1(sha1.convert(bytes).toString());

///Strips leading [pathSeparator] from [path] if exists
String stripBeginningPathSeparatorPath(String path, {String? pathSeparator}) => path.startsWith(pathSeparator ?? Platform.pathSeparator) ? path.replaceFirst(pathSeparator ?? Platform.pathSeparator, "") : path;

/// Returns a relative path from a [directoryPath] for [path]
String relativePathFromDir({ required String directoryPath, required String path}) => path.replaceAll(directoryPath, "");

/// Attaches a [relativePath] to a [directoryPath]
String fullPathFromDir({required String relativePath, required String directoryPath}) => join(
      directoryPath,
      stripBeginningPathSeparatorPath(relativePath),
    );
