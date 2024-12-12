import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/diff/diff.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/utils/print_fn.dart';

/// Hash of a sha1 with validation
class Sha1 {
  final String hash;

  Sha1(this.hash) : assert(hash.length == 40);

  String get sub => hash.substring(0, 2);

  String get short => hash.substring(0, 6);
}

/// Snapshot of a working directory
class Commit {
  final Branch fromBranch;
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
    this.fromBranch,
    this.commitedAt,
  );
}

extension CommitActions on Commit {

  ///Get list of commited [RepoObjectsData] in a [Commit]
  Map<String, RepoObjectsData>? getCommitFiles({
    Function(Branch)? onNoCommitBranchMetaData = onNoCommitBranchMetaData,
    Function(Commit)? onNoCommitMetaData = onNoCommitMetaData,
  }) {
    Branch commitBranch = branch;

    BranchTreeMetaData? branchCommitMetaData = commitBranch.branchTreeMetaData;
    if (branchCommitMetaData == null) {
      onNoCommitBranchMetaData?.call(branch);
      return null;
    }

    CommitTreeMetaData? commitMetaData = branchCommitMetaData.commits[sha.hash];
    if (commitMetaData == null) {
      onNoCommitMetaData?.call(this);
      return null;
    }

    return {for(var o in commitMetaData.commitedObjects.values) o.filePathRelativeToRepository : o};
  }

  ///Compare a [CommitDiff] to another commit [other]
  Future<void> compareCommitDiff({
    required Commit other,
    Function(Branch)? onNoOtherCommitBranchMetaData = onNoCommitBranchMetaData,
    Function(Commit)? onNoOtherCommitMetaData = onNoCommitMetaData,
    Function(Branch)? onNoThisCommitBranchMetaData = onNoCommitBranchMetaData,
    Function(Commit)? onNoThisCommitMetaData = onNoCommitMetaData,
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
