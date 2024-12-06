import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:balo/command/command_facade.dart';
import 'package:balo/command_line_interface/cli.dart';
import 'package:balo/command_line_interface/input_parser.dart';
import 'package:balo/command_line_interface/user_input.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';

Future<void> main(List<String> arguments) async {
  int code = 0;
  try {
    UserInput userInput = CliUserInput(arguments);
    final UndoableCommandExecutor runner = DefaultCommandLineRunner();

    //Interface to run commands
    CommandFacade commandFacade = runner.inputToCommands(
      userInput,
      inputParser,
    );
    code = await runner.runCommand(commandFacade.initialize());
  } on UsageException catch (e, trace) {
    debugPrintToConsole(message: e.toString(), color: CliColor.red);
    debugPrintToConsole(message: trace.toString(), color: CliColor.red);
    code = 400;
  } catch (e, trace) {
    debugPrintToConsole(message: e.toString(), color: CliColor.red);
    debugPrintToConsole(message: trace.toString(), color: CliColor.red);
    code = 500;
  } finally {
    printToConsole(
      message: "Finished with exit code: $code",
      color: CliColor.brightYellow,
      style: CliStyle.bold,
      newLine: true,
    );

    exit(code);
  }
}
