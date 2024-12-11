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
  Repository tempRepository = Repository(Directory.current.path);
  Repository tempRemoteRepository = Repository(join(Directory.current.path, "test-remote"));

  try {
    //Run create repository command
    int createRepositoryCommand = await runTest([
      CliCommandsEnum.init.command,
      "-${CliCommandOptionsEnum.path.abbreviation}",
      tempRepository.path,
      verbose ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : '',
    ]);
    assert(createRepositoryCommand == 0);

    //Check if repository was created
    bool repositoryFound = Directory(tempRepository.repositoryPath).existsSync();
    assert(repositoryFound);

    await doTest(tempRepository, tempRemoteRepository, verbose);
  } finally {
    if (cleanup) {
      //Clean up local repository
      tempRepository.unInitializeRepository();
      assert(!tempRepository.isInitialized);

      //Clean up remote repository
      tempRemoteRepository.unInitializeRepository();
      assert(!tempRemoteRepository.isInitialized);

      if(tempRemoteRepository.workingDirectory.existsSync()) {
        tempRemoteRepository.workingDirectory.deleteSync(recursive: true);
      }
    }
  }
}