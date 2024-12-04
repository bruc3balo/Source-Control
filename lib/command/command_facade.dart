import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/variables.dart';

abstract class CommandFacade {
  List<Command> initialize();
}

class ErrorInitializer implements CommandFacade {
  final String error;

  ErrorInitializer(this.error);

  @override
  List<Command> initialize() => [ShowErrorCommand(error)];
}

class HelpInitializer implements CommandFacade {
  @override
  List<Command> initialize() => [ShowHelpCommand()];
}

class RepositoryInitializer implements CommandFacade {
  final String? path;

  RepositoryInitializer(this.path);

  @override
  List<Command> initialize() {
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
  List<Command> initialize() {
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
  List<Command> initialize() {
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
    List<Command> commands = [];

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
  List<Command> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [PrintCurrentBranchCommand(repository)];
  }
}

class PrintStatusOfCurrentBranchInitializer implements CommandFacade {
  @override
  List<Command> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [GetStatusOfCurrentBranch(repository)];
  }
}

class CommitStagedFilesInitializer implements CommandFacade {
  final String message;

  CommitStagedFilesInitializer(this.message);

  @override
  List<Command> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [CommitStagedFilesCommand(repository, message)];
  }
}

class GetCommitHistoryInitializer implements CommandFacade {
  final String? branchName;

  GetCommitHistoryInitializer(this.branchName);

  @override
  List<Command> initialize() {
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
  List<Command> initialize() {
    Repository repository = Repository(Directory.current.path);
    debugPrintToConsole(message: "Repository path is ${repository.path}");
    return [CheckoutToBranchCommand(repository, branchName)];
  }
}
