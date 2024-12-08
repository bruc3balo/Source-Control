import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/remote/remote.dart';
import 'package:balo/repository/remote_branch/remote_branch.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';

abstract class CommandFacade {
  List<UndoableCommand> initialize();
}

class ErrorInitializer implements CommandFacade {
  final String error;

  ErrorInitializer(this.error);

  @override
  List<UndoableCommand> initialize() => [ShowErrorCommand(error)];
}

class HelpInitializer implements CommandFacade {
  final CliCommandsEnum? command;

  HelpInitializer({this.command});

  @override
  List<UndoableCommand> initialize() => [ShowHelpCommand(command: command)];
}

class RepositoryInitializer implements CommandFacade {
  final String? path;

  RepositoryInitializer(this.path);

  @override
  List<UndoableCommand> initialize() {
    if (path == null) {
      debugPrintToConsole(message: "Path not provided");
      return [ShowErrorCommand("Path required")];
    }

    // Initialize the repository
    Repository repository = Repository(path!);
    Branch branch = Branch(defaultBranch, repository);

    // Return the list of commands
    return [
      InitializeRepositoryCommand(repository),
      CreateIgnoreFileCommand(repository),
      AddIgnorePatternCommand(repository, repositoryWorkingDirName),
      CreateNewBranchCommand(repository, branch),
      CreateStateFileCommand(repository, branch),
    ];
  }
}

class StageFilesInitializer implements CommandFacade {
  final String pattern;

  StageFilesInitializer(this.pattern);

  @override
  List<UndoableCommand> initialize() {
    if (pattern.isEmpty) {
      debugPrintToConsole(message: "Pattern not provided");
      return [ShowErrorCommand("Pattern required")];
    }

    //Read current state
    Repository repository = Repository(Directory.current.path);
    State state = State(repository);
    Branch? currentBranch = state.getCurrentBranch();
    if (currentBranch == null) {
      debugPrintToConsole(message: "Branch not provided");

      return [
        ShowErrorCommand("Unable to get current branch info"),
      ];
    }

    Staging staging = Staging(currentBranch);

    return [
      StageFilesCommand(staging, pattern),
    ];
  }
}

class ModifyIgnoreFileInitializer implements CommandFacade {
  final String? patternToAdd;
  final String? patternToRemove;

  ModifyIgnoreFileInitializer({this.patternToAdd, this.patternToRemove});

  @override
  List<UndoableCommand> initialize() {
    if ((patternToAdd == null || patternToAdd!.isEmpty) && (patternToRemove == null || patternToRemove!.isEmpty)) {
      debugPrintToConsole(message: "No pattern provided");
      return [ShowErrorCommand("Pattern to add or remove required")];
    }

    if (patternToAdd == patternToRemove) {
      debugPrintToConsole(message: "Add and remove pattern is the same");
      return [ShowErrorCommand("Pattern to add and remove should not be the same")];
    }

    Repository repository = Repository(Directory.current.path);
    List<UndoableCommand> commands = [];

    if (patternToAdd != null && patternToAdd!.isNotEmpty) {
      debugPrintToConsole(message: "Found pattern to add $patternToAdd");
      commands.add(AddIgnorePatternCommand(repository, patternToAdd!));
    }

    if (patternToRemove != null && patternToRemove!.isNotEmpty) {
      debugPrintToConsole(message: "Found pattern to remove $patternToRemove");
      commands.add(RemoveIgnorePatternCommand(repository, patternToRemove!));
    }

    return commands;
  }
}

class ListBranchesInitializer implements CommandFacade {
  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "extends ${repository.path}");
    return [ListBranchesCommand(repository)];
  }
}

class PrintStatusOfCurrentBranchInitializer implements CommandFacade {
  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [GetStatusOfCurrentBranch(repository)];
  }
}

class CommitStagedFilesInitializer implements CommandFacade {
  final String message;

  CommitStagedFilesInitializer(this.message);

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [CommitStagedFilesCommand(repository, message)];
  }
}

class GetCommitHistoryInitializer implements CommandFacade {
  final String? branchName;

  GetCommitHistoryInitializer(this.branchName);

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");

    String? branch = branchName;
    if (branch == null) {
      debugPrintToConsole(
        message: "Branch not provided. Switching to current branch",
      );
    }

    branch ??= repository.state
        .getCurrentBranch(
          onRepositoryNotInitialized: () => debugPrintToConsole(
            message: "Repository not initialized",
          ),
          onNoStateFile: () => debugPrintToConsole(
            message: "No state file provided",
          ),
        )
        ?.branchName;

    if (branch == null) {
      debugPrintToConsole(
        message: "Failed to get current branch",
      );
      return [ShowErrorCommand("Provide a branch name")];
    }

    return [
      GetBranchCommitHistoryCommand(repository, branch),
    ];
  }
}

class CheckoutToBranchInitializer implements CommandFacade {
  final String branchName;
  final String? commitSha;

  CheckoutToBranchInitializer(this.branchName, this.commitSha);

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [
      CheckoutToBranchCommand(
        repository,
        Branch(branchName, repository),
        commitSha,
      ),
    ];
  }
}

class ShowDiffBetweenCommitsInitializer implements CommandFacade {
  final String? thisBranchName;
  final String? thisCommitSha;
  final String otherBranchName;
  final String? otherCommitSha;

  ShowDiffBetweenCommitsInitializer({
    required this.thisBranchName,
    required this.thisCommitSha,
    required this.otherBranchName,
    required this.otherCommitSha,
  });

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");

    State state = repository.state;
    StateData? stateData = state.stateInfo;
    if (stateData == null) {
      return [ShowErrorCommand("Repository has no state data")];
    }

    Branch? thisBranch = thisBranchName == null ? state.getCurrentBranch() : Branch(thisBranchName!, repository);
    if (thisBranch == null) {
      return [ShowErrorCommand("Unable to get current branch info and has not been provided")];
    }

    BranchTreeMetaData? thisBranchMetaData = thisBranch.branchTreeMetaData;
    if (thisBranchMetaData == null) {
      return [ShowErrorCommand("This branch $thisBranchName has no meta data")];
    }

    CommitMetaData? thisCommitMetaData =
        thisCommitSha == null ? thisBranchMetaData.sortedBranchCommits.firstOrNull : thisBranchMetaData.commits[thisCommitSha];
    if (thisCommitMetaData == null) {
      debugPrintToConsole(message: "commitAMetaData == null");
      return [ShowErrorCommand("Commit $thisCommitSha has no meta data")];
    }

    Branch otherBranch = Branch(otherBranchName, repository);
    BranchTreeMetaData? otherBranchMetaData = otherBranch.branchTreeMetaData;
    if (otherBranchMetaData == null) {
      debugPrintToConsole(message: "branchBMetaData == null");

      return [ShowErrorCommand("Branch $otherBranchName has no meta data")];
    }

    CommitMetaData? otherCommitMetaData =
        otherCommitSha == null ? otherBranchMetaData.sortedBranchCommits.firstOrNull : otherBranchMetaData.commits[otherCommitSha];
    if (otherCommitMetaData == null) {
      debugPrintToConsole(message: "commitBMetaData == null");
      return [ShowErrorCommand("Commit $otherCommitSha has no meta data")];
    }

    Commit thisCommit = Commit(
      Sha1(thisCommitMetaData.sha),
      thisBranch,
      thisCommitMetaData.message,
      thisCommitMetaData.commitedObjects,
      thisCommitMetaData.commitedAt,
    );

    Commit otherCommit = Commit(
      Sha1(otherCommitMetaData.sha),
      otherBranch,
      otherCommitMetaData.message,
      otherCommitMetaData.commitedObjects,
      otherCommitMetaData.commitedAt,
    );

    return [ShowCommitDiffCommand(repository, thisCommit, otherCommit)];
  }
}

class MergeBranchInitializer implements CommandFacade {
  final String otherBranchName;

  MergeBranchInitializer(this.otherBranchName);

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");

    Branch otherBranch = Branch(otherBranchName, repository);
    State state = State(repository);
    Branch? thisBranch = state.getCurrentBranch(
      onRepositoryNotInitialized: () => debugPrintToConsole(
        message: "Repository on path is ${repository.path} is not initialized",
      ),
      onNoStateFile: () => debugPrintToConsole(
        message: "Missing repository state file",
      ),
    );

    if (thisBranch == null) {
      return [ShowErrorCommand("error")];
    }

    return [
      MergeBranchCommand(repository, thisBranch, otherBranch),
    ];
  }
}

class AddRemoteInitializer implements CommandFacade {
  final String name;
  final String url;

  AddRemoteInitializer(this.name, this.url);

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    Remote remote = Remote(repository, name, url);
    return [
      AddRemoteCommand(repository, remote),
    ];
  }
}

class RemoveRemoteInitializer implements CommandFacade {
  final String name;

  RemoveRemoteInitializer(this.name);

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    Remote remote = Remote(repository, name, '');
    return [
      RemoveRemoteCommand(repository, remote),
    ];
  }
}

class ListAllRemoteInitializer implements CommandFacade {
  ListAllRemoteInitializer();

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    return [
      ListRemoteCommand(repository),
    ];
  }
}

class CloneRepositoryInitializer implements CommandFacade {
  final String path;
  final String branchName;

  CloneRepositoryInitializer(this.path, String? branchName) : branchName = branchName ?? defaultBranch;

  @override
  List<UndoableCommand> initialize() {
    Repository localRepository = Repository(Directory.current.path);
    Repository remoteRepository = Repository(path);
    Remote remote = Remote(remoteRepository, branchName, path);
    RemoteBranch remoteBranch = RemoteBranch(Branch(branchName, remoteRepository), remote);
    return [
      CloneBranchCommitCommand(localRepository, remoteBranch),
    ];
  }
}

class PullRepositoryInitializer implements CommandFacade {
  final String remoteName;
  final String? branchName;

  PullRepositoryInitializer(this.remoteName, this.branchName);

  @override
  List<UndoableCommand> initialize() {
    Repository localRepository = Repository(Directory.current.path);
    State state = localRepository.state;

    Branch? currentBranch = branchName == null ? state.getCurrentBranch() : Branch(branchName!, localRepository);
    if (currentBranch == null) {
      return [ShowErrorCommand("Provide a branch name")];
    }

    RemoteMetaData? remoteMetaData = localRepository.remoteMetaData;
    if (remoteMetaData == null) {
      return [ShowErrorCommand("No remotes")];
    }

    RemoteData? remoteData = remoteMetaData.remotes[remoteName];
    if (remoteData == null) {
      return [ShowErrorCommand("Remote $remoteName not found")];
    }

    Repository remoteRepository = Repository(remoteData.url);
    RemoteBranch remoteBranch = RemoteBranch(
      Branch(
        currentBranch.branchName,
        remoteRepository,
      ),
      Remote(
        remoteRepository,
        remoteData.name,
        remoteData.url,
      ),
    );

    return [
      PullBranchCommitCommand(localRepository, remoteBranch),
    ];
  }
}


class PushRepositoryInitializer implements CommandFacade {
  final String remoteName;
  final String? branchName;

  PushRepositoryInitializer(this.remoteName, this.branchName);

  @override
  List<UndoableCommand> initialize() {
    Repository localRepository = Repository(Directory.current.path);
    State state = localRepository.state;

    Branch? currentBranch = branchName == null ? state.getCurrentBranch() : Branch(branchName!, localRepository);
    if (currentBranch == null) {
      return [ShowErrorCommand("Provide a branch name")];
    }

    RemoteMetaData? remoteMetaData = localRepository.remoteMetaData;
    if (remoteMetaData == null) {
      return [ShowErrorCommand("No remotes")];
    }

    RemoteData? remoteData = remoteMetaData.remotes[remoteName];
    if (remoteData == null) {
      return [ShowErrorCommand("Remote $remoteName not found")];
    }

    Repository remoteRepository = Repository(remoteData.url);
    RemoteBranch remoteBranch = RemoteBranch(
      Branch(
        currentBranch.branchName,
        remoteRepository,
      ),
      Remote(
        remoteRepository,
        remoteData.name,
        remoteData.url,
      ),
    );

    return [
      PushBranchCommitCommand(localRepository, remoteBranch),
    ];
  }
}
