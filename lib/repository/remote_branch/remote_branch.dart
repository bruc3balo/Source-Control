import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/remote/remote.dart';
import 'package:balo/repository/repo_objects/repo_objects.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/variables.dart';
import 'package:path/path.dart';

class RemoteBranch {
  final Remote remote;
  final Branch branch;

  RemoteBranch(this.branch, this.remote);
}

extension RemoteBranchCommon on RemoteBranch {

  String get workingDirName => basenameWithoutExtension(remote.url);

  Future<void> pull({
    required Repository localRepository,
    Function()? onNoStateData,
    Function()? onNoRemoteData,
    Function()? onSuccessfulPull,
  }) async {
    BranchTreeMetaData? remoteTreeData = branch.branchTreeMetaData;
    if (remoteTreeData == null) {
      onNoRemoteData?.call();
      return;
    }
    List<CommitMetaData> remoteCommits = remoteTreeData.commits.values.toList();

    State state = localRepository.state;

    StateData? stateData = state.stateInfo;
    if (stateData == null) {
      onNoStateData?.call();
      return;
    }

    Branch localBranch = Branch(branch.branchName, localRepository);
    BranchTreeMetaData? localTreeMetaData = localBranch.branchTreeMetaData;
    CommitMetaData? localLatestCommit = localTreeMetaData?.latestBranchCommits;

    //Get commits needed to pull
    List<CommitMetaData> commitsToPull = [];
    if (localTreeMetaData != null && localLatestCommit != null) {
      for (int i = remoteCommits.length - 1; i >= 0; i--) {
        CommitMetaData c = remoteCommits[i];
        commitsToPull.add(c);
        if (c.sha == localLatestCommit.sha) break;
      }
    } else {
      localTreeMetaData = remoteTreeData;
    }

    //Objects needed to push
    List<RepoObjectsData> objectsToBePushed = filterObjectsPresent(
      commitsWithRepoObject: commitsToPull,
      aggregateBranchTree: localTreeMetaData,
    );

    //push commits then push objects
    List<RepoObjects> objectsToBePulledData = objectsToBePushed
        .map((e) => e.fetchObject(localRepository))
        .where((e) => e != null)
        .map(
          (e) => RepoObjects(
            repository: localRepository,
            sha1: e!.sha1,
            relativePathToRepository: e.relativePathToRepository,
            commitedAt: e.commitedAt,
            blob: e.blob,
          ),
        )
        .toList();

    //Write all the commits
    localBranch.saveBranchTreeMetaData(localTreeMetaData);

    //Write remote objects
    for (var e in objectsToBePulledData) {
      e.store();
      File(join(localRepository.workingDirectory.path, e.relativePathToRepository.substring(1, e.relativePathToRepository.length - 1)))
          .writeAsBytesSync(e.blob, flush: true, mode: FileMode.writeOnly);
    }

    onSuccessfulPull?.call();
  }

  Future<void> clone({
    required Repository localRepository,
    Function()? onRepositoryNotFound,
    Function()? onNoCommitFound,
    Function()? onSuccessfulPush,
  }) async {
    Repository remoteRepository = branch.repository;

    BranchTreeMetaData? remoteBranchMetaData = branch.branchTreeMetaData;
    if (remoteBranchMetaData == null) {
      onRepositoryNotFound?.call();
      return;
    }

    CommitMetaData? latestCommit = remoteBranchMetaData.latestBranchCommits;
    if (latestCommit == null) {
      onNoCommitFound?.call();
      return;
    }

    // RepoObjects
    List<RepoObjects> objectsToDownload = latestCommit.commitedObjects.values
        .map((e) => e.fetchObject(remoteRepository))
        .where((e) => e != null)
        .map(
          (e) => RepoObjects(
            repository: localRepository,
            sha1: e!.sha1,
            relativePathToRepository: e.relativePathToRepository,
            commitedAt: e.commitedAt,
            blob: e.blob,
          ),
        )
        .toList();

    // Create Repository
    if (!localRepository.isInitialized) {
      createRepositoryFacade(
        initializeRepository: () async => await localRepository.initializeRepository(),
        createIgnoreFile: () async {
          //Copy ignore file
          if (remoteRepository.ignore.ignoreFile.existsSync()) {
            remoteRepository.ignore.ignoreFile.copySync(localRepository.ignore.ignoreFile.path);
            return;
          }

          localRepository.ignore.ignoreFile.createSync();
        },
        addIgnoreFile: () async => localRepository.ignore.addIgnore(pattern: repositoryIgnoreFileName),
        createNewBranch: () async => Branch(branch.branchName, localRepository),
        createNewStateFile: () async => localRepository.state.createStateFile(currentBranch: branch),
      );

      //add remote file
      Remote(localRepository, remote.name, remote.url).addRemote();
    }

    //Copy commits
    Branch localBranch = Branch(branch.branchName, localRepository);
    localBranch.saveBranchTreeMetaData(remoteBranchMetaData);

    //Save state
    State state = State(localRepository);
    state.saveStateData(stateData: StateData(currentBranch: localBranch.branchName, currentCommit: latestCommit.sha));

    //Copy objects
    for (var e in objectsToDownload) {
      e.store();
      File(join(localRepository.workingDirectory.path, e.relativePathToRepository.substring(1, e.relativePathToRepository.length - 1)))
          .writeAsBytesSync(e.blob, flush: true, mode: FileMode.writeOnly);
    }

    //Add remote
    remote.addRemote();

    onSuccessfulPush?.call();
  }

  Future<void> push({
    required Repository localRepository,
    Function()? onNoCommits,
    Function()? onRemoteUrlNotSupported,
    Function()? onSuccessfulPush,
  }) async {
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
    List<CommitMetaData> localCommits = localBranchTree.sortedBranchCommits;

    //Compare latest commit on both ends
    Repository remoteRepository = Repository(remote.url);
    if (!remoteRepository.isInitialized) {
      createRepositoryFacade(
        initializeRepository: () async => await remoteRepository.initializeRepository(),
        createIgnoreFile: () async => remoteRepository.ignore.createIgnoreFile(),
        addIgnoreFile: () async => remoteRepository.ignore.addIgnore(pattern: repositoryIgnoreFileName),
        createNewBranch: () async => branch.createBranch(),
        createNewStateFile: () async => remoteRepository.state.createStateFile(currentBranch: branch),
      );
    }

    //Get remote branch data
    BranchTreeMetaData? remoteBranchTree = branch.branchTreeMetaData;
    CommitMetaData? latestRemoteCommit = remoteBranchTree?.latestBranchCommits;

    //Get commits needed to push
    List<CommitMetaData> commitsToPush = [];
    if (latestRemoteCommit != null) {
      for (int i = 0; i < localCommits.length; i++) {
        CommitMetaData c = localCommits[i];
        commitsToPush.add(c);
        if (c.sha == latestRemoteCommit.sha) break;
      }
    } else {
      commitsToPush.addAll(localCommits);
    }

    //Objects needed to push
    List<RepoObjectsData> objectsToBePushed = filterObjectsPresent(
      commitsWithRepoObject: commitsToPush,
      aggregateBranchTree: remoteBranchTree,
    );

    //push commits then push objects
    List<RepoObjects> objectsToBePushedData = objectsToBePushed
        .map((e) => e.fetchObject(localRepository))
        .where((e) => e != null)
        .map(
          (e) => RepoObjects(
            repository: remoteRepository,
            sha1: e!.sha1,
            relativePathToRepository: e.relativePathToRepository,
            commitedAt: e.commitedAt,
            blob: e.blob,
          ),
        )
        .toList();

    //Write all the commits
    if (remoteBranchTree == null) {
      await branch.createBranch();
      await branch.createTreeMetaDataFile();
      remoteBranchTree = branch.branchTreeMetaData!;
    }

    //Write remote commits
    Map<String, CommitMetaData> remoteCommits = Map.from(remoteBranchTree.commits);
    remoteCommits.addAll({for (var c in commitsToPush) c.sha: c});

    remoteBranchTree = remoteBranchTree.copyWith(commits: remoteCommits);
    branch.saveBranchTreeMetaData(remoteBranchTree);

    //Write remote objects
    for (var e in objectsToBePushedData) {
      e.store();
    }

    onSuccessfulPush?.call();
  }

  List<RepoObjectsData> filterObjectsPresent({
    required List<CommitMetaData> commitsWithRepoObject,
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

void createRepositoryFacade({
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
