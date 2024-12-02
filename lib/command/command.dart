// Command interface

import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/repository/branch.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/repository/repository.dart';

abstract class Command {
  Future<void> execute();

  Future<void> undo();
}

class CommandLineRunner {
  static Future<void> runCommand(List<Command> commands) async {
    int i = 0;
    try {
      while(i < commands.length) {
        await commands[i++].execute();
      }
    } catch (e) {
      while(i > 0) {
        await commands[i--].undo();
      }
    }
  }
}

class InitializeRepositoryCommand implements Command {
  final Repository repository;

  const InitializeRepositoryCommand({required this.repository});

  @override
  Future<void> execute() async{
    await repository.initializeRepository(
      onAlreadyInitialized: () => printToConsole(
        "Balo repository is already initialized",
      ),
    );
  }

  @override
  Future<void> undo() async{
    await repository.unInitializeRepository(
      onNotInitialized: () => printToConsole(
        "Balo repository is not initialized",
      ),
    );
  }
}

class CreateIgnoreFileCommand implements Command {
  final Ignore ignore;

  CreateIgnoreFileCommand(this.ignore);

  @override
  Future<void> execute() async{
    await ignore.createIgnoreFile();
  }

  @override
  Future<void> undo() async{
    await ignore.deleteIgnoreFile();
  }
}

class CreateBranchCommand implements Command {

  final Branch branch;

  CreateBranchCommand(this.branch);

  @override
  Future<void> execute() async {
    await branch.createBranch();
  }

  @override
  Future<void> undo() async {
    await branch.deleteBranch();
  }

}
