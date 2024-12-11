import 'dart:collection';
import 'dart:io';

import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/remote/remote.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';

///Represents a [Remote]'s [Branch} in memory
class RemoteBranch {
  final Remote remote;
  final Branch branch;

  RemoteBranch(this.branch, this.remote);
}

extension RemoteBranchCommon on RemoteBranch {
  ///Name of the working [Directory]
  String get workingDirName => basenameWithoutExtension(remote.url);

  /// Updates a [localRepository] with latest [Commit]'s from a [RemoteBranch] for a [branch]
  void pull({
    required Repository localRepository,
    Function()? onNoChanges,
    Function()? onNoStateData,
    Function()? onNoRemoteData,
    Function()? onRepositoryNotInitialized,
    Function()? onSuccessfulPull,
  }) {
    //Must be in an initialized
    if (!localRepository.isInitialized) {
      onRepositoryNotInitialized?.call();
      return;
    }

    //Get remote branch data
    Repository remoteRepository = branch.repository;
    BranchTreeMetaData? remoteTreeData = branch.branchTreeMetaData;
    if (remoteTreeData == null) {
      onNoRemoteData?.call();
      return;
    }

    //remoteCommits
    List<CommitTreeMetaData> remoteCommits = remoteTreeData.sortedBranchCommitsFromLatest;

    State localState = localRepository.state;
    StateData? localStateData = localState.stateInfo;
    if (localStateData == null) {
      onNoStateData?.call();
      return;
    }

    Branch localBranch = Branch(branch.branchName, localRepository);
    BranchTreeMetaData? localTreeMetaData = localBranch.branchTreeMetaData;
    localTreeMetaData ??= localBranch.saveBranchTreeMetaData(BranchTreeMetaData(name: localBranch.branchName, commits: HashMap()));
    CommitTreeMetaData? localLatestCommit = localTreeMetaData.latestBranchCommits;
    if (remoteTreeData.latestBranchCommits?.sha == localLatestCommit?.sha) {
      onNoChanges?.call();
      return;
    }

    //Get commits needed to pull
    List<CommitTreeMetaData> commitsToPull = [];
    for (CommitTreeMetaData c in remoteCommits) {
      bool isMergeBase = c.sha == localLatestCommit?.sha;
      if (isMergeBase) break;

      commitsToPull.add(c);
    }

    //Objects needed to pull
    List<RepoObjectsData> objectsToBePulled = _extractRepoObjectsNotPresentInAggregateBranchTree(
      commitsWithRepoObject: commitsToPull,
      aggregateBranchTree: localTreeMetaData,
    );

    //add missing objects
    localLatestCommit!.commitedObjects.values.where((e) => !e.exists(localRepository)).forEach(objectsToBePulled.add);

    //pull objects
    objectsToBePulled.map((e) => e.fetchObject(remoteRepository)).where((e) => e != null).forEach(
      (remoteObject) {
        //RepoObjects
        RepoObjects o = RepoObjects(
          repository: localRepository,
          sha1: remoteObject!.sha1,
          relativePathToRepository: remoteObject.relativePathToRepository,
          commitedAt: remoteObject.commitedAt,
          blob: remoteObject.blob,
        );

        //Store to local repository
        RepoObjectsData data = o.writeRepoObject();

        //write file to working dir
        String objectFilePath = fullPathFromDir(
          relativePath: data.filePathRelativeToRepository,
          directoryPath: localRepository.workingDirectory.path,
        );

        File(objectFilePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(
            o.blob,
            flush: true,
            mode: FileMode.write,
          );
      },
    );


    //pull commits
    localTreeMetaData = localTreeMetaData.copyWith(
      commits: Map.from(localTreeMetaData.commits)..addAll({for (var c in commitsToPull) c.sha: c}),
    );
    localBranch.saveBranchTreeMetaData(localTreeMetaData);

    //pull branches
    Map<String, Branch> localBranchMap = {for (var b in localRepository.allBranches) b.branchName: b};
    for (Branch remoteB in remoteRepository.allBranches) {
      if (localBranchMap.containsKey(remoteB.branchName)) continue;

      Branch newLocalBranch = Branch(remoteB.branchName, localRepository);
      BranchTreeMetaData? branchTree = remoteB.branchTreeMetaData;
      if (branchTree == null) continue;

      printToConsole(
        message: "Branch ${remoteB.branchName} has been added and is not in local repository",
        color: CliColor.brightMagenta,
        newLine: true,
      );

      newLocalBranch.saveBranchTreeMetaData(branchTree);
    }

    onSuccessfulPull?.call();
  }

  ///Downloads a remote [Repository] from a [RemoteBranch] into a local branch
  void clone({
    required Repository localRepository,
    Function()? onRepositoryNotFound,
    Function()? onNoCommitFound,
    Function()? onSuccessfulPush,
  }) {
    //Get remote repository
    Repository remoteRepository = branch.repository;

    //Get remote branch data
    BranchTreeMetaData? remoteBranchMetaData = branch.branchTreeMetaData;
    if (remoteBranchMetaData == null) {
      onRepositoryNotFound?.call();
      return;
    }

    //Get latest commit to clone
    CommitTreeMetaData? latestCommit = remoteBranchMetaData.latestBranchCommits;
    if (latestCommit == null) {
      onNoCommitFound?.call();
      return;
    }

    // Create Repository
    createRepositoryTemplate(
      initializeRepository: () async => localRepository.initializeRepository(),
      createIgnoreFile: () async {
        //Copy ignore file
        if (remoteRepository.ignore.ignoreFile.existsSync()) {
          remoteRepository.ignore.ignoreFile.copySync(localRepository.ignore.ignoreFile.path);
          return;
        }

        localRepository.ignore.ignoreFile.createSync();
      },
      addIgnoreFile: () async => defaultIgnore.forEach(localRepository.ignore.addIgnore),
      createNewBranch: () async => Branch(branch.branchName, localRepository),
      createNewStateFile: () async =>
          localRepository.state.saveStateData(stateData: StateData(currentBranch: branch.branchName, currentCommit: latestCommit.sha)),
    );

    //Add remote file
    Remote(localRepository, remote.name, remote.url).addRemote();

    //Copy commits
    Branch localBranch = Branch(branch.branchName, localRepository);
    localBranch.saveBranchTreeMetaData(remoteBranchMetaData);

    // Copy objects
    latestCommit.commitedObjects.values.map((e) => e.fetchObject(remoteRepository)).where((e) => e != null).forEach(
      (remoteObject) {
        //RepoObjects
        RepoObjects o = RepoObjects(
          repository: localRepository,
          sha1: remoteObject!.sha1,
          relativePathToRepository: remoteObject.relativePathToRepository,
          commitedAt: remoteObject.commitedAt,
          blob: remoteObject.blob,
        );

        //Store to local repository
        RepoObjectsData data = o.writeRepoObject();

        //write file to working dir
        String objectFilePath = fullPathFromDir(
          relativePath: data.filePathRelativeToRepository,
          directoryPath: localRepository.workingDirectory.path,
        );

        File(objectFilePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(
            o.blob,
            flush: true,
            mode: FileMode.write,
          );
      },
    );

    onSuccessfulPush?.call();
  }

  ///Uploads [Commit]s from a [localRepository] into a [RemoteBranch]
  void push({
    required Repository localRepository,
    Function()? onNoCommits,
    Function()? onRemoteUrlNotSupported,
    Function()? onSuccessfulPush,
  }) {
    //Only path remotes
    if (!remote.isPath) {
      onRemoteUrlNotSupported?.call();
      return;
    }

    //Get local branch data
    Branch localBranch = Branch(branch.branchName, localRepository);
    BranchTreeMetaData? localBranchTree = localBranch.branchTreeMetaData;
    if (localBranchTree == null) {
      onNoCommits?.call();
      return;
    }

    //localCommits
    List<CommitTreeMetaData> localCommits = localBranchTree.sortedBranchCommitsFromLatest;

    //Compare latest commit on both ends
    Repository remoteRepository = Repository(remote.url);
    if (!remoteRepository.isInitialized) {
      createRepositoryTemplate(
        initializeRepository: () => remoteRepository.initializeRepository(),
        createIgnoreFile: () => remoteRepository.ignore.createIgnoreFile(),
        addIgnoreFile: () => defaultIgnore.forEach(localRepository.ignore.addIgnore),
        createNewBranch: () => branch.createBranch(),
        createNewStateFile: () => remoteRepository.state.saveStateData(stateData: StateData(currentBranch: branch.branchName)),
      );
    }

    //Get remote branch data
    BranchTreeMetaData? remoteBranchTree = branch.branchTreeMetaData;
    CommitTreeMetaData? latestRemoteCommit = remoteBranchTree?.latestBranchCommits;

    //Get commits needed to push
    List<CommitTreeMetaData> commitsToPush = [];
    for (CommitTreeMetaData c in localCommits) {
      bool isMergeBase = c.sha == latestRemoteCommit?.sha;
      if (isMergeBase) break;

      commitsToPush.add(c);
    }

    //Objects needed to push
    List<RepoObjectsData> objectsToBePushed = _extractRepoObjectsNotPresentInAggregateBranchTree(
      commitsWithRepoObject: commitsToPush,
      aggregateBranchTree: remoteBranchTree,
    );

    //push objects
    objectsToBePushed.map((e) => e.fetchObject(localRepository)).where((e) => e != null).forEach(
      (localObject) {
        //RepoObjects
        RepoObjects o = RepoObjects(
          repository: remoteRepository,
          sha1: localObject!.sha1,
          relativePathToRepository: localObject.relativePathToRepository,
          commitedAt: localObject.commitedAt,
          blob: localObject.blob,
        );

        //Store to remote repository
        RepoObjectsData data = o.writeRepoObject();
      },
    );

    //Write all the commits
    if (remoteBranchTree == null) {
      branch.createBranch();
      remoteBranchTree = branch.branchTreeMetaData!;
    }

    //push commits
    remoteBranchTree = remoteBranchTree.copyWith(
      commits: Map.from(remoteBranchTree.commits)..addAll({for (var c in commitsToPush) c.sha: c}),
    );
    branch.saveBranchTreeMetaData(remoteBranchTree);

    onSuccessfulPush?.call();
  }

  ///TLDR: Strips and extracts [RepoObjectsData] already in [aggregateBranchTree]
  List<RepoObjectsData> _extractRepoObjectsNotPresentInAggregateBranchTree({
    required List<CommitTreeMetaData> commitsWithRepoObject,
    BranchTreeMetaData? aggregateBranchTree,
  }) {
    Map<String, RepoObjectsData> allCommitObjects = {
      for (RepoObjectsData c in commitsWithRepoObject.expand((e) => e.commitedObjects.values)) c.sha: c,
    };

    if (aggregateBranchTree == null) return allCommitObjects.values.toList();

    //filter out present objects
    for (RepoObjectsData presentObject in aggregateBranchTree.commits.values.expand((e) => e.commitedObjects.values)) {
      allCommitObjects.remove(presentObject.sha);
    }

    return allCommitObjects.values.toList();
  }
}

///Template pattern
///Steps to create a [Repository]
void createRepositoryTemplate({
  required Function() initializeRepository,
  required Function() createIgnoreFile,
  required Function() addIgnoreFile,
  required Function() createNewBranch,
  required Function() createNewStateFile,
}) {
  initializeRepository();
  createIgnoreFile();
  addIgnoreFile();
  createNewBranch();
  createNewStateFile();
}
