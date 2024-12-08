import 'dart:io';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/diff/diff.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

///Snapshot of a working directory

class Sha1 {
  final String hash;

  Sha1(this.hash) : assert(hash.length == 40);

  String get sub => hash.substring(0, 2);

  String get short => hash.substring(0, 6);
}

class Commit {
  final Branch branch;
  final Sha1 sha;
  final String message;
  final Map<String, RepoObjectsData> objects;
  final DateTime commitedAt;

  Commit(
    this.sha,
    this.branch,
    this.message,
    this.objects,
    this.commitedAt,
  );
}

extension CommitActions on Commit {
  List<File>? getCommitFiles({
    Function()? onNoCommitBranchMetaData,
    Function()? onNoCommitMetaData,
  }) {
    Branch commitBranch = branch;

    BranchTreeMetaData? branchCommitMetaData = commitBranch.branchTreeMetaData;
    if (branchCommitMetaData == null) {
      onNoCommitBranchMetaData?.call();
      return null;
    }

    CommitMetaData? commitMetaData = branchCommitMetaData.commits[sha];
    if (commitMetaData == null) {
      onNoCommitMetaData?.call();
      return null;
    }

    String commitDirPath = join(
      commitBranch.branchDirectoryPath,
      branchCommitFolder,
      sha.hash,
    );
    Directory commitDir = Directory(commitDirPath);

    return commitDir.listSync(recursive: true).where((e) => e.statSync().type == FileSystemEntityType.file).map((e) => File(e.path)).toList();
  }

  Future<void> compareCommitDiff({
    required Commit other,
    Function()? onNoOtherCommitBranchMetaData,
    Function()? onNoOtherCommitMetaData,
    Function()? onNoThisCommitBranchMetaData,
    Function()? onNoThisCommitMetaData,
    Function(CommitDiff)? onDiffCalculated,
  }) async {
    CommitDiff commitDiff = await CommitDiff.calculateDiff(
      thisCommit: this,
      otherCommit: other,
      onNoThisCommitBranchMetaData: onNoThisCommitBranchMetaData,
      onNoThisCommitMetaData: onNoThisCommitMetaData,
      onNoOtherCommitBranchMetaData: onNoOtherCommitBranchMetaData,
      onNoOtherCommitMetaData: onNoOtherCommitMetaData,
    );
    onDiffCalculated?.call(commitDiff);
  }
}
