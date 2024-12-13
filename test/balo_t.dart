import 'dart:io';

import 'package:balo/command/command_facade.dart';
import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/command_line_interface/cli_execution.dart';
import 'package:balo/command_line_interface/input_parser.dart';
import 'package:balo/command_line_interface/user_input.dart';
import 'package:balo/repository/repository.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('Introduction', () async {

    // Show command help command
    int helpCode = await runTest([CliCommandsEnum.merge.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
    assert(helpCode == 0);

  });
}

///Runs the actual commands
Future<int> runTest(List<String> arguments) async {
  UserInput userInput = CliUserInput(arguments);
  final UndoableCommandExecutor runner = DefaultCommandLineRunner();

  //Interface to run commands
  CommandFacade commandFacade = runner.inputToCommands(
    userInput,
    inputParser,
  );
  return await runner.runCommand(commandFacade.initialize());
}

///Initializes a local [Repository]
///Runs a [doTest] function
///If [cleanup], un-initializes the [Repository]
Future<void> testWithRepository({
  bool cleanup = true,
  bool verbose = false,
  required Future<void> Function(Repository local, Repository remote, bool verbose) doTest,
}) async {
  Repository tempLocalRepository = Repository(Directory.current.path);
  Repository tempRemoteRepository = Repository(join(Directory.current.path, "test-remote"));

  try {
    //Run create repository command
    int createRepositoryCommand = await runTest([
      CliCommandsEnum.init.command,
      "-${CliCommandOptionsEnum.path.abbreviation}",
      tempLocalRepository.path,
      verbose ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : '',
    ]);
    assert(createRepositoryCommand == 0);

    //Check if local repository was created
    bool repositoryFound = Directory(tempLocalRepository.repositoryPath).existsSync();
    assert(repositoryFound);

    //Run create remote repository command
    int createRemoteRepositoryCommand = await runTest([
      CliCommandsEnum.init.command,
      "-${CliCommandOptionsEnum.path.abbreviation}",
      tempRemoteRepository.path,
      verbose ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : '',
    ]);
    assert(createRemoteRepositoryCommand == 0);

    //Check if remote repository was created
    bool remoteRepositoryFound = Directory(tempLocalRepository.repositoryPath).existsSync();
    assert(remoteRepositoryFound);

    await doTest(tempLocalRepository, tempRemoteRepository, verbose);
  } finally {
    if (cleanup) {
      //Clean up local repository
      tempLocalRepository.unInitializeRepository();
      assert(!tempLocalRepository.isInitialized);

      //Clean up remote repository
      tempRemoteRepository.unInitializeRepository();
      assert(!tempRemoteRepository.isInitialized);

      if(tempRemoteRepository.workingDirectory.existsSync()) {
        tempRemoteRepository.workingDirectory.deleteSync(recursive: true);
      }
    }
  }

}