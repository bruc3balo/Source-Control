import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/merge/merge.dart';
import 'package:balo/repository/remote/remote.dart';
import 'package:balo/repository/remote_branch/remote_branch.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:path/path.dart';

///Basic aggregation of commands abstracted to run user known [UndoableCommand]s
abstract class CommandFacade {
  List<UndoableCommand> initialize();
}

///[CommandFacade] to show an error to a user
class ErrorInitializer implements CommandFacade {
  final String error;

  ErrorInitializer(this.error);

  @override
  List<UndoableCommand> initialize() => [ShowErrorCommand(error)];
}

///[CommandFacade] to show help for a [CliCommandsEnum] to a user
class HelpInitializer implements CommandFacade {
  final CliCommandsEnum? command;

  HelpInitializer({this.command});

  @override
  List<UndoableCommand> initialize() => [ShowHelpCommand(command: command)];
}

///[CommandFacade] to show create a [Repository] and all that is needed
///e.g. [Ignore] file, default [Branch] and a [State] for the [Repository]
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
      AddIgnorePatternCommand(repository, '/$repositoryWorkingDirName'),
      CreateNewBranchCommand(repository, branch),
      CreateStateFileCommand(repository, branch),
    ];
  }
}

///[CommandFacade] to create a [Staging] in preparation for a [Commit]
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

///[CommandFacade] to add or remove an entry from the [Ignore] file in a [Repository]
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

///[CommandFacade] to create a [Branch]es in a local [Repository]
class CreateBranchInitializer implements CommandFacade {

  final String branchName;

  CreateBranchInitializer(this.branchName);

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    Branch branch = Branch(branchName, repository);
    debugPrintToConsole(message: "extends ${repository.path}");
    return [CreateNewBranchCommand(repository, branch)];
  }
}


///[CommandFacade] to list all [Branch]es in a local [Repository]
class ListBranchesInitializer implements CommandFacade {
  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "extends ${repository.path}");
    return [ListBranchesCommand(repository)];
  }
}

///[CommandFacade] to display the current status of the current [Branch] in a [State] file
class PrintStatusOfCurrentBranchInitializer implements CommandFacade {
  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [GetStatusOfCurrentBranch(repository)];
  }
}

///[CommandFacade] to [Commit] files in [Staging] of a branch
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

///[CommandFacade] to get [Commit] history of a [Branch]
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

///[CommandFacade] to checkout of a [Branch] to a new one or a specific [Commit]
///This will also change files in the working directory
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

///[CommandFacade] to show differences between 2 [Commit]s in the same or different [Branch]es
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

    CommitTreeMetaData? thisCommitMetaData =
        thisCommitSha == null ? thisBranchMetaData.sortedBranchCommitsFromLatest.firstOrNull : thisBranchMetaData.commits[thisCommitSha];
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

    CommitTreeMetaData? otherCommitMetaData =
        otherCommitSha == null ? otherBranchMetaData.sortedBranchCommitsFromLatest.firstOrNull : otherBranchMetaData.commits[otherCommitSha];
    if (otherCommitMetaData == null) {
      debugPrintToConsole(message: "commitBMetaData == null");
      return [ShowErrorCommand("Commit $otherCommitSha has no meta data")];
    }

    Commit thisCommit = Commit(
      Sha1(thisCommitMetaData.sha),
      thisBranch,
      thisCommitMetaData.message,
      thisCommitMetaData.commitedObjects,
      Branch(otherCommitMetaData.originalBranch, repository),
      thisCommitMetaData.commitedAt,
    );

    Commit otherCommit = Commit(
      Sha1(otherCommitMetaData.sha),
      otherBranch,
      otherCommitMetaData.message,
      otherCommitMetaData.commitedObjects,
      Branch(otherCommitMetaData.originalBranch, repository),
      otherCommitMetaData.commitedAt,
    );

    return [ShowCommitDiffCommand(repository, thisCommit, otherCommit)];
  }
}

///[CommandFacade] to merge a [Branch] from one [Commit] from a local [Repository] to the current working directory in a local [Repository]
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

///[CommandFacade] to add a [Remote] to a local [Repository]
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

///[CommandFacade] to remove a [Remote] from a local [Repository]
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

///[CommandFacade] to list all [Remote]s in a local [Repository]
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

///[CommandFacade] to clone a [RemoteBranch]s from a remote [Repository] into a local [Repository]
class CloneRepositoryInitializer implements CommandFacade {
  final String path;
  final String branchName;

  CloneRepositoryInitializer(this.path, String? branchName) : branchName = branchName ?? defaultBranch;

  @override
  List<UndoableCommand> initialize() {
    String remoteName = basenameWithoutExtension(path);
    Repository localRepository = Repository(join(Directory.current.path, remoteName));
    Repository remoteRepository = Repository(path);
    Remote remote = Remote(remoteRepository, defaultRemote, path);
    RemoteBranch remoteBranch = RemoteBranch(Branch(branchName, remoteRepository), remote);
    return [
      CloneBranchCommitCommand(localRepository, remoteBranch),
    ];
  }
}

///[CommandFacade] to update changes from a [RemoteBranch]s [Commit]s into a local [Branch] into a [Repository]
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

///[CommandFacade] to update changes from a local [Branch]s [Commit]s into a [RemoteBranch] in a remote [Repository]
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