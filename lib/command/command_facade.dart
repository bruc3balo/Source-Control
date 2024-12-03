import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/repository/staging.dart';
import 'package:balo/repository/state.dart';
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
      return [ShowErrorCommand("Pattern required")];
    }

    //Read current state
    Repository repository = Repository(Directory.current.path);
    State state = State(repository);
    Staging staging = Staging(state.currentBranch);

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
    if ((patternToAdd == null || patternToAdd!.isEmpty) && (patternToRemove == null || patternToRemove!.isEmpty)) {
      return [ShowErrorCommand("Pattern to add or remove required")];
    }

    if(patternToAdd == patternToRemove) {
      return [ShowErrorCommand("Pattern to add and remove should not be the same")];
    }

    Repository repository = Repository(Directory.current.path);
    List<Command> commands = [];

    if(patternToAdd != null && patternToAdd!.isNotEmpty) {
      commands.add(AddIgnorePatternCommand(repository, patternToAdd!));
    }

    if(patternToRemove != null && patternToRemove!.isNotEmpty) {
      commands.add(RemoveIgnorePatternCommand(repository, patternToRemove!));
    }

    return commands;
  }

}