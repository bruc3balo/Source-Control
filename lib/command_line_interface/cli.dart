import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command/command_facade.dart';
import 'package:balo/command/command_mapper.dart';
import 'package:balo/user_input/user_input.dart';
import 'package:dart_console/dart_console.dart';

final Console console = Console();

enum CliColor {
  // Text Colors
  defaultColor('\x1B[0m'),
  black('\x1B[30m'),
  red('\x1B[31m'),
  green('\x1B[32m'),
  yellow('\x1B[33m'),
  blue('\x1B[34m'),
  magenta('\x1B[35m'),
  cyan('\x1B[36m'),
  white('\x1B[37m'),

  // Bright Text Colors
  brightBlack('\x1B[90m'),
  brightRed('\x1B[91m'),
  brightGreen('\x1B[92m'),
  brightYellow('\x1B[93m'),
  brightBlue('\x1B[94m'),
  brightMagenta('\x1B[95m'),
  brightCyan('\x1B[96m'),
  brightWhite('\x1B[97m'),

  // Background Colors
  bgBlack('\x1B[40m'),
  bgRed('\x1B[41m'),
  bgGreen('\x1B[42m'),
  bgYellow('\x1B[43m'),
  bgBlue('\x1B[44m'),
  bgMagenta('\x1B[45m'),
  bgCyan('\x1B[46m'),
  bgWhite('\x1B[47m'),

  // Bright Background Colors
  bgBrightBlack('\x1B[100m'),
  bgBrightRed('\x1B[101m'),
  bgBrightGreen('\x1B[102m'),
  bgBrightYellow('\x1B[103m'),
  bgBrightBlue('\x1B[104m'),
  bgBrightMagenta('\x1B[105m'),
  bgBrightCyan('\x1B[106m'),
  bgBrightWhite('\x1B[107m');

  final String color;

  const CliColor(this.color);
}

enum CliStyle {
  bold('\x1B[1m'),
  underline('\x1B[4m'),
  reversed('\x1B[7m');

  final String style;

  const CliStyle(this.style);
}

String? listenForInput({String? title}) {
  //Write title
  if (title != null) printToConsole(message: title, color: CliColor.blue);

  //Prompt writing
  printToConsole(message: "> ");

  //Get input
  return stdin.readLineSync(retainNewlines: true);
}

void printToConsole({
  required String message,
  bool newLine = false,
  CliColor color = CliColor.defaultColor,
  CliStyle? style,
  TextAlignment alignment = TextAlignment.left,
}) {
  String data =
      '${newLine ? '\n' : ''}${color.color}${style?.style ?? ''}$message${CliColor.defaultColor.color}';
  console.writeLine(data, alignment);
}

/// CommandExecutor
abstract class CommandExecutor {
  CommandFacade inputToCommands(UserInput userInput);

  //Run commands and return and exit code
  Future<int> runCommand(List<Command> commands);
}

///Parses user input and creates commands
///Runs commands created
class CommandLineRunner implements CommandExecutor {
  @override
  CommandFacade inputToCommands(UserInput userInput) {
    if (userInput.isEmpty) return HelpInitializer();

    CommandMapperEnum? commandEnum = userInput.commandEnum;
    Map<CommandOptionsMapperEnum, String?> optionMapEnum =
        userInput.mapOptionsEnum;

    switch (commandEnum) {
      case CommandMapperEnum.help:
        return HelpInitializer();
      case CommandMapperEnum.init:
        //Path
        String? path = optionMapEnum[CommandOptionsMapperEnum.path];
        if (path == "." || path == null) path = Directory.current.path;

        return RepositoryInitializer(path);

      case CommandMapperEnum.add:
        //Path
        String? path = optionMapEnum[CommandOptionsMapperEnum.path];
        if (path == "." || path == null) path = "*";

        return StageFilesInitializer(path);

      case CommandMapperEnum.ignore:
        //Path
        String? patternToAdd = optionMapEnum[CommandOptionsMapperEnum.add];
        String? patternToRemove =
            optionMapEnum[CommandOptionsMapperEnum.remove];

        return ModifyIgnoreFileInitializer(
          patternToAdd: patternToAdd,
          patternToRemove: patternToRemove,
        );
      default:
        return ErrorInitializer("Unknown command ${userInput.command}");
    }
  }

  @override
  Future<int> runCommand(List<Command> commands) async {
    int i = 0;
    try {
      while (i < commands.length) {
        await commands[i++].execute();
      }
      return 0;
    } catch (e) {
      while (i > 0) {
        await commands[--i].undo();
      }
      return 1;
    }
  }
}
