import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/commit.dart';
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
  @override
  List<UndoableCommand> initialize() => [ShowHelpCommand()];
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

    // Return the list of commands
    return [
      InitializeRepositoryCommand(repository),
      CreateIgnoreFileCommand(repository),
      AddIgnorePatternCommand(repository, repositoryFolderName),
      CreateNewBranchCommand(repository, defaultBranch),
      CreateStateFileCommand(repository, defaultBranch),
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
    if ((patternToAdd == null || patternToAdd!.isEmpty) &&
        (patternToRemove == null || patternToRemove!.isEmpty)) {
      debugPrintToConsole(message: "No pattern provided");
      return [ShowErrorCommand("Pattern to add or remove required")];
    }

    if (patternToAdd == patternToRemove) {
      debugPrintToConsole(message: "Add and remove pattern is the same");
      return [
        ShowErrorCommand("Pattern to add and remove should not be the same")
      ];
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

class PrintCurrentBranchInitializer implements CommandFacade {
  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "extends ${repository.path}");
    return [PrintCurrentBranchCommand(repository)];
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

  CheckoutToBranchInitializer(this.branchName);

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [CheckoutToBranchCommand(repository, branchName)];
  }
}

class ShowDiffBetweenCommitsInitializer implements CommandFacade {
  final String branchAName;
  final String commitASha;
  final String branchBName;
  final String commitBSha;

  ShowDiffBetweenCommitsInitializer({
    required this.branchAName,
    required this.commitASha,
    required this.branchBName,
    required this.commitBSha,
  });

  @override
  List<UndoableCommand> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");

    Branch branchA = Branch(branchAName, repository);
    BranchMetaData? branchAMetaData = branchA.branchMetaData;
    if (branchAMetaData == null) {
      debugPrintToConsole(message: "branchAMetaData == null");

      return [ShowErrorCommand("Branch $branchAName has no meta data")];
    }

    CommitMetaData? commitAMetaData = branchAMetaData.commits[commitASha];
    if (commitAMetaData == null) {
      debugPrintToConsole(message: "commitAMetaData == null");
      return [ShowErrorCommand("Commit $commitASha has no meta data")];
    }

    Branch branchB = Branch(branchBName, repository);
    BranchMetaData? branchBMetaData = branchB.branchMetaData;
    if (branchBMetaData == null) {
      debugPrintToConsole(message: "branchBMetaData == null");

      return [ShowErrorCommand("Branch $branchBName has no meta data")];
    }
    CommitMetaData? commitBMetaData = branchBMetaData.commits[commitBSha];
    if (commitBMetaData == null) {
      debugPrintToConsole(message: "commitBMetaData == null");
      return [ShowErrorCommand("Commit $commitBSha has no meta data")];
    }

    Commit commitA = Commit(
      commitAMetaData.sha,
      branchA,
      commitAMetaData.message,
      commitAMetaData.commitedAt,
    );

    Commit commitB = Commit(
      commitBMetaData.sha,
      branchB,
      commitBMetaData.message,
      commitBMetaData.commitedAt,
    );

    return [ShowCommitDiffCommand(repository, commitA, commitB)];
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
