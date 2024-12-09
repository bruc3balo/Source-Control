import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:balo/command/command_facade.dart';
import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/command_line_interface/input_parser.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/diff/diff.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/remote/remote.dart';
import 'package:balo/repository/remote_branch/remote_branch.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:dart_console/dart_console.dart';

/// Basic executable command by a [CommandFacade]
abstract class UndoableCommand {
  Future<void> execute();

  Future<void> undo();
}

/// [UndoableCommand] to show usage of commands in [CliCommandsEnum] and their options [CliCommandOptionsEnum]
class ShowHelpCommand extends UndoableCommand {
  final CliCommandsEnum? command;

  ShowHelpCommand({this.command});

  @override
  Future<void> execute() async {
    inputParser.printHelp(command: command);
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to show an error to the
class ShowErrorCommand extends UndoableCommand {
  final String error;

  ShowErrorCommand(this.error);

  @override
  Future<void> execute() async {
    printToConsole(
      message: error,
      color: CliColor.red,
      newLine: true,
      alignment: TextAlignment.center,
      style: CliStyle.bold,
    );
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to create a new [Repository] in a [Directory]
class InitializeRepositoryCommand extends UndoableCommand {
  final Repository repository;

  InitializeRepositoryCommand(this.repository);

  @override
  Future<void> execute() async {
    repository.initializeRepository(
      onAlreadyInitialized: () => printToConsole(
        message: "Balo repository is already initialized",
      ),
      onSuccessfullyInitialized: () => printToConsole(
        message: "Repository initialized",
      ),
      onFileSystemException: (e) => printToConsole(
        message: e.message,
      ),
    );
  }

  @override
  Future<void> undo() async {
    repository.unInitializeRepository(
      onRepositoryNotInitialized: () => printToConsole(
        message: "Balo repository is not initialized",
      ),
      onSuccessfullyUninitialized: () => printToConsole(
        message: "Repository has been initialized at ${repository.path}",
      ),
      onFileSystemException: (e) => printToConsole(
        message: e.message,
        color: CliColor.red,
      ),
    );
  }
}

/// [UndoableCommand] to create a new [State] file in a local [Repository]
class CreateStateFileCommand extends UndoableCommand {
  final Repository repository;
  final Branch currentBranch;

  CreateStateFileCommand(this.repository, this.currentBranch);

  @override
  Future<void> execute() async {
    repository.state.createStateFile(
      currentBranch: currentBranch,
      onAlreadyExists: () => debugPrintToConsole(
        message: "Ignore file already exists",
      ),
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
      ),
      onSuccessfullyCreated: () => debugPrintToConsole(
        message: "State file successfully created",
      ),
      onFileSystemException: (e) => debugPrintToConsole(
        message: e.message,
        color: CliColor.red,
      ),
    );
  }

  @override
  Future<void> undo() async {
    repository.state.deleteStateFile(
      onDoesntExists: () => debugPrintToConsole(
        message: "State file doesn't exists",
      ),
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
      ),
      onSuccessfullyDeleted: () => debugPrintToConsole(
        message: "State file successfully deleted",
      ),
      onFileSystemException: (e) => debugPrintToConsole(
        message: e.message,
        color: CliColor.red,
      ),
    );
  }
}

/// [UndoableCommand] to create a new [Ignore] file in a local [Repository]
class CreateIgnoreFileCommand extends UndoableCommand {
  final Repository repository;

  CreateIgnoreFileCommand(this.repository);

  @override
  Future<void> execute() async {
    repository.ignore.createIgnoreFile(
      onFileSystemException: (e) => debugPrintToConsole(
        message: e.message,
        color: CliColor.red,
      ),
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
      ),
      onAlreadyExists: () => debugPrintToConsole(
        message: "Ignore file already exists",
      ),
      onSuccessfullyCreated: () => debugPrintToConsole(
        message: "Ignore file successfully created",
      ),
    );
  }

  @override
  Future<void> undo() async {
    repository.ignore.deleteIgnoreFile(
      onFileSystemException: (e) => debugPrintToConsole(
        message: e.message,
        color: CliColor.red,
      ),
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
      ),
      onSuccessfullyDeleted: () => debugPrintToConsole(
        message: "Ignore file successfully deleted",
      ),
      onDoesntExists: () => debugPrintToConsole(
        message: "Ignore file doesn't exist",
      ),
    );
  }
}

/// [UndoableCommand] to create a new [Branch] in a local [Repository]
class CreateNewBranchCommand extends UndoableCommand {
  final Repository repository;
  final Branch branch;

  CreateNewBranchCommand(this.repository, this.branch);

  @override
  Future<void> execute() async {
    branch.createBranch(
      isValidBranchName: isValidBranchName,
      onFileSystemException: (e) => debugPrintToConsole(
        message: e.message,
        color: CliColor.red,
      ),
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
        color: CliColor.red,
      ),
      onBranchAlreadyExists: () => debugPrintToConsole(
        message: "${branch.branchName} already exists",
        color: CliColor.red,
      ),
      onBranchCreated: (d) => debugPrintToConsole(
        message: "${branch.branchName} created at ${d.path}",
        color: CliColor.red,
      ),
      onInvalidBranchName: (n) => debugPrintToConsole(
        message: "Invalid branch name $n",
        color: CliColor.red,
      ),
    );
  }

  @override
  Future<void> undo() async {
    branch.deleteBranch(
      onFileSystemException: (e) => debugPrintToConsole(
        message: e.message,
        color: CliColor.red,
      ),
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
        color: CliColor.red,
      ),
      onBranchDeleted: () => debugPrintToConsole(
        message: "${branch.branchName} deleted",
        color: CliColor.red,
      ),
      onBranchDoesntExist: () => debugPrintToConsole(
        message: "Branch ${branch.branchName} doesn't exist",
        color: CliColor.red,
      ),
    );
  }
}

/// [UndoableCommand] to add [File]'s to [Staging] ready to be commited
class StageFilesCommand extends UndoableCommand {
  final Staging staging;
  final String pattern;

  StageFilesCommand(this.staging, this.pattern);

  @override
  Future<void> execute() async {
    await Isolate.run(
      () => staging.stageFiles(
        pattern: pattern,
        onFileSystemException: (e) => debugPrintToConsole(
          message: e.message,
          color: CliColor.red,
        ),
        onUninitializedRepository: () => debugPrintToConsole(
          message: "Repository not initialized",
        ),
      ),
    );
  }

  @override
  Future<void> undo() async {
    staging.unstageFiles(
      onUninitializedRepository: () => debugPrintToConsole(
        message: "Repository not initialized",
      ),
      onStagingFileDoesntExist: () => debugPrintToConsole(
        message: "Staging file doesn't exist",
      ),
      onFileSystemException: (e) => debugPrintToConsole(
        message: e.message,
        color: CliColor.red,
      ),
    );
  }
}

/// [UndoableCommand] to add a pattern from [Ignore] file
class AddIgnorePatternCommand extends UndoableCommand {
  final Repository repository;
  final String pattern;

  AddIgnorePatternCommand(this.repository, this.pattern);

  @override
  Future<void> execute() async {
    repository.ignore.addIgnore(
      pattern: pattern,
      onFileSystemException: (e) => debugPrintToConsole(
        message: e.message,
        color: CliColor.red,
      ),
      onAdded: () => debugPrintToConsole(
        message: "Pattern $pattern has been added to ignore file",
      ),
      onAlreadyPresent: () => debugPrintToConsole(
        message: "Pattern $pattern already exists in ignore file",
      ),
    );
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to remove a pattern from [Ignore] file
class RemoveIgnorePatternCommand extends UndoableCommand {
  final Repository repository;
  final String pattern;

  RemoveIgnorePatternCommand(this.repository, this.pattern);

  @override
  Future<void> execute() async {
    repository.ignore.removeIgnore(
      pattern: pattern,
      onRemoved: () => debugPrintToConsole(
        message: "Pattern $pattern has been removed from ignore file",
      ),
      onNotFoundPresent: () => debugPrintToConsole(
        message: "Pattern $pattern not found in ignore file",
      ),
    );
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to list the current [Branch]es in the [Repository]
class ListBranchesCommand extends UndoableCommand {
  final Repository repository;

  ListBranchesCommand(this.repository);

  @override
  Future<void> execute() async {
    State state = repository.state;

    Branch? currentBranch = state.getCurrentBranch(
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
        color: CliColor.red,
      ),
      onNoStateFile: () => debugPrintToConsole(
        message: "No state file found",
      ),
    );

    for (Branch b in repository.allBranches) {
      bool isCurrentBranch = b.branchName == currentBranch?.branchName;
      printToConsole(
        message: "${b.branchName} ${isCurrentBranch ? "*" : ''} ${isCurrentBranch ? "-> ${state.stateInfo?.currentCommit}" : ''}",
        style: isCurrentBranch ? null : CliStyle.bold,
        alignment: TextAlignment.left,
        color: isCurrentBranch ? CliColor.brightCyan : CliColor.white,
      );
    }
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to get the current status of a [Branch] returns staged and unstaged files
class GetStatusOfCurrentBranch extends UndoableCommand {
  final Repository repository;

  GetStatusOfCurrentBranch(this.repository);

  @override
  Future<void> execute() async {
    if (!repository.isInitialized) {
      printToConsole(
        message: "Repository is not initialized at path ${repository.repositoryPath}",
        alignment: TextAlignment.left,
        color: CliColor.red,
      );
      return;
    }

    StateData? stateData = repository.state.stateInfo;
    if (stateData == null) {
      printToConsole(
        message: "Repository is doesn't have state data at ${repository.state.stateFilePath}",
        alignment: TextAlignment.left,
        color: CliColor.red,
      );
      return;
    }

    Branch branch = Branch(stateData.currentBranch, repository);

    Map<BranchFileStatus, HashSet<String>> status = branch.getBranchStatus();
    printToConsole(
      message: "On branch ${branch.branchName}",
      color: CliColor.defaultColor,
    );

    for (MapEntry<BranchFileStatus, HashSet<String>> e in status.entries) {
      printToConsole(
        message: "${e.key.name} files",
        style: CliStyle.bold,
        alignment: TextAlignment.left,
        color: CliColor.defaultColor,
        newLine: true,
      );
      printToConsole(
        message: e.value.join("\n"),
        alignment: TextAlignment.left,
        color: e.key == BranchFileStatus.staged ? CliColor.brightGreen : CliColor.red,
      );
    }
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to [Commit] all files at [Staging]
class CommitStagedFilesCommand extends UndoableCommand {
  final Repository repository;
  final String message;

  CommitStagedFilesCommand(this.repository, this.message);

  @override
  Future<void> execute() async {
    Branch? branch = repository.state.getCurrentBranch(
      onNoStateFile: () => debugPrintToConsole(
        message: "No state file",
        style: CliStyle.bold,
        alignment: TextAlignment.left,
        color: CliColor.red,
      ),
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
      ),
    );
    if (branch == null) {
      printToConsole(
        message: "Failed to get current branch",
        style: CliStyle.bold,
        alignment: TextAlignment.left,
        color: CliColor.red,
      );
      return;
    }

    late final Staging staging = Staging(branch);
    if (!staging.isStaged) {
      printToConsole(
        message: "Files not staged",
        style: CliStyle.bold,
        alignment: TextAlignment.left,
        color: CliColor.red,
      );
      return;
    }
    await Isolate.run(
      () async {
        staging.commitStagedFiles(
          message: message,
          onNoStagingData: () => debugPrintToConsole(
            message: "Files not staged",
            style: CliStyle.bold,
            alignment: TextAlignment.left,
            color: CliColor.red,
          ),
        );
      },
    );
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to get all [Commit]s in a [Branch]
class GetBranchCommitHistoryCommand extends UndoableCommand {
  final Repository repository;
  final String branchName;

  GetBranchCommitHistoryCommand(this.repository, this.branchName);

  @override
  Future<void> execute() async {
    Branch branch = Branch(branchName, repository);

    printToConsole(message: "On branch $branchName", color: CliColor.defaultColor);

    BranchTreeMetaData? metaData = branch.branchTreeMetaData;
    if (metaData == null) {
      printToConsole(message: "Branch out of sync", color: CliColor.brightRed);
      return;
    }

    if (metaData.commits.isEmpty) {
      printToConsole(message: "No commits found", newLine: true, color: CliColor.brightRed);
      return;
    }

    String history =
        metaData.commits.values.map((c) => "Commit: ${c.sha} \nMessage: ${c.message} \nDate: ${c.commitedAt.toLocal().toIso8601String()}").join("\n");

    printToConsole(message: history, color: CliColor.cyan);
  }

  @override
  Future<void> undo() async {
    debugPrintToConsole(
      message: "Undoing get branch history command on $branchName",
    );
  }
}

/// [UndoableCommand] to switch to a new or existing [Branch] from [State]
class CheckoutToBranchCommand extends UndoableCommand {
  final Repository repository;
  final Branch branch;
  final String? commitSha;

  CheckoutToBranchCommand(this.repository, this.branch, this.commitSha);

  @override
  Future<void> execute() async {
    await Isolate.run(() async {
      branch.checkoutToBranch(
        commitSha: commitSha,
        onRepositoryNotInitialized: () => debugPrintToConsole(message: "Repository not initialized"),
        onNoCommitFound: () => debugPrintToConsole(message: "Commit not found"),
        onSameCommit: () => debugPrintToConsole(message: "Cannot check out to same commit"),
        onStateDoesntExists: () => debugPrintToConsole(message: "State doesn't exist"),
        onBranchMetaDataDoesntExists: () => debugPrintToConsole(message: "Branch meta data doesn't exists"),
        onFileSystemException: (e) => debugPrintToConsole(message: e.message, color: CliColor.red),
      );
    });
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to show differences between a [Commit] in a [Branch] with another [Commit] in another [Branch]
class ShowCommitDiffCommand extends UndoableCommand {
  final Repository repository;
  final Commit thisCommit;
  final Commit otherCommit;

  ShowCommitDiffCommand(this.repository, this.thisCommit, this.otherCommit);

  @override
  Future<void> execute() async {
    await Isolate.run(() async {
      await thisCommit.compareCommitDiff(
        other: otherCommit,
        onDiffCalculated: (d) => d.fullPrint(),
        onNoOtherCommitMetaData: () => debugPrintToConsole(
          message: "Commit b ${otherCommit.sha} (${otherCommit.branch.branchName}) has no commit meta data",
        ),
        onNoOtherCommitBranchMetaData: () => debugPrintToConsole(
          message: "Commit b ${otherCommit.sha} (${otherCommit.branch.branchName}) has no branch data",
        ),
        onNoThisCommitMetaData: () => debugPrintToConsole(
          message: "Commit a ${thisCommit.sha} (${thisCommit.branch.branchName}) has no commit meta data",
        ),
        onNoThisCommitBranchMetaData: () => debugPrintToConsole(
          message: "Commit a ${thisCommit.sha} (${thisCommit.branch.branchName}) has no branch data",
        ),
      );
    });
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to merge a local repository [Branch] with a [Commit] to a working directory [Branch]
class MergeBranchCommand extends UndoableCommand {
  final Repository repository;
  final Branch thisBranch;
  final Branch otherBranch;

  MergeBranchCommand(this.repository, this.thisBranch, this.otherBranch);

  @override
  Future<void> execute() async {
    //TODO: FIx merge branch command
    /*await thisBranch.mergeFromOtherBranchIntoThis(
      otherBranch: otherBranch,
      onSameBranchMerge: () => debugPrintToConsole(
        message: "Cannot merge from the same branch",
      ),
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository not initialized",
      ),
      onNoOtherBranchMetaData: () => debugPrintToConsole(
        message: "${otherBranch.branchName} branch doesn't exist",
      ),
      onNoCommit: () => debugPrintToConsole(
        message: "${otherBranch.branchName} branch doesn't have a commit",
      ),
      onNoCommitMetaData: () => debugPrintToConsole(
        message: "No commit meta data",
      ),
      onNoCommitBranchMetaData: () => debugPrintToConsole(
        message: "No commit branch meta data",
      ),
    );*/
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to add a remote [Remote] to a local [Repository]
class AddRemoteCommand extends UndoableCommand {
  final Repository repository;
  late Remote remote;

  AddRemoteCommand(this.repository, this.remote);

  @override
  Future<void> execute() async {
    remote.addRemote(
      onRemoteAlreadyExists: () => debugPrintToConsole(message: "Remote already exists"),
    );
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to remove a remote [Remote] from a local [Repository]
class RemoveRemoteCommand extends UndoableCommand {
  final Repository repository;
  late Remote remote;

  RemoveRemoteCommand(this.repository, this.remote);

  @override
  Future<void> execute() async {
    remote.removeRemote(
      onRemoteDoesntExists: () => debugPrintToConsole(message: "Remote doesn't exists"),
    );
  }

  @override
  Future<void> undo() async {}
}

/// [UndoableCommand] to list all [Remote]'s in local [Repository]
class ListRemoteCommand extends UndoableCommand {
  final Repository repository;

  ListRemoteCommand(this.repository);

  @override
  Future<void> execute() async {
    RemoteMetaData? remoteMetaData = repository.remoteMetaData;
    if (remoteMetaData == null || remoteMetaData.remotes.isEmpty) {
      printToConsole(
        message: "No remotes found",
        color: CliColor.red,
        newLine: true,
      );
      return;
    }

    for (RemoteData r in remoteMetaData.remotes.values) {
      printToConsole(
        message: "(${r.name}) ${r.url}",
        color: CliColor.cyan,
        newLine: true,
      );
    }
  }

  @override
  Future<void> undo() async {}
}

///[UndoableCommand] to clone a [Repository] from a [RemoteBranch] to the local [Repository]
class CloneBranchCommitCommand extends UndoableCommand {
  final Repository localRepository;
  final RemoteBranch remoteBranch;

  CloneBranchCommitCommand(this.localRepository, this.remoteBranch);

  @override
  Future<void> execute() async {
    remoteBranch.clone(localRepository: localRepository);
  }

  @override
  Future<void> undo() async {
    localRepository.unInitializeRepository();
  }
}

///[UndoableCommand] to push latest changes from a [Branch] to a [RemoteBranch]
class PushBranchCommitCommand extends UndoableCommand {
  final Repository localRepository;
  final RemoteBranch remoteBranch;

  PushBranchCommitCommand(this.localRepository, this.remoteBranch);

  @override
  Future<void> execute() async {
    remoteBranch.push(
      localRepository: localRepository,
      onNoCommits: () => debugPrintToConsole(message: "Nothing to commit"),
      onRemoteUrlNotSupported: () => debugPrintToConsole(message: "Unsupported remote"),
      onSuccessfulPush: () => printToConsole(message: "Pushed successfully"),
    );
  }

  @override
  Future<void> undo() async {}
}

///[UndoableCommand] to pull changes from the [RemoteBranch]
class PullBranchCommitCommand extends UndoableCommand {
  final Repository localRepository;
  final RemoteBranch remoteBranch;

  PullBranchCommitCommand(this.localRepository, this.remoteBranch);

  @override
  Future<void> execute() async {
    remoteBranch.pull(
      localRepository: localRepository,
      onNoRemoteData: () => debugPrintToConsole(
        message: "No data to pull on remote branch",
        newLine: true,
      ),
      onNoStateData: () => debugPrintToConsole(
        message: "Missing state data",
        newLine: true,
      ),
      onSuccessfulPull: () => debugPrintToConsole(
        message: "Pulled success",
        newLine: true,
      ),
      onNoChanges: () => debugPrintToConsole(
        message: "No changes to pull",
        newLine: true,
      ),
    );
  }

  @override
  Future<void> undo() async {}

}