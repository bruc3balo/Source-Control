import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:balo/command/command_facade.dart';
import 'package:balo/command/command_mapper.dart';
import 'package:balo/command_line_interface/user_input.dart';
import 'package:balo/utils/utils.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';

import 'cli.dart';

ArgParser get argParser {
  if(_argParser != null) return _argParser!;
  _argParser = _buildParser();
  return _argParser!;
}
ArgParser? _argParser;

ArgParser _buildParser() {
  final parser = ArgParser();

  for (var command in CommandMapperEnum.values) {
    final commandParser = ArgParser();

    for (var option in command.options) {
      final primaryOption = option.optionEnum.option.first.replaceAll('--', '');
      final aliases = option.optionEnum.option.skip(1).toList();

      // Check if aliases contain valid single-character abbreviations
      String? abbreviation;
      if (aliases.isNotEmpty && aliases.first.length == 1) {
        abbreviation = aliases.first;
      }

      // Add options to the command parser
      commandParser.addOption(
        primaryOption,
        abbr: abbreviation,
        help: option.optionEnum.description,
        defaultsTo: option.defaultValue,
        mandatory: option.mandatory,
      );
    }

    // Add command to the main parser
    parser.addCommand(command.command, commandParser);
  }

  return parser;
}


class ArgParserCommandExecutor extends CommandExecutor {

  @override
  CommandFacade inputToCommands(UserInput userInput) {
    final ArgResults results = argParser.parse(userInput.originalUserInput);


    final commandName = results.command?.name;
    CommandMapperEnum? command =
        CommandMapperEnum.commandOptionsMap[commandName];

    final commandArgs = results.command?.arguments;
    final commandOptions = results.command?.options;

    debugPrintToConsole(message: 'Command: $commandName');
    debugPrintToConsole(message: 'Arguments: $commandArgs');
    debugPrintToConsole(message: 'Options: $commandOptions');

    // Handle specific commands
    switch (command) {
      case null:
      case CommandMapperEnum.help:
        print(argParser.usage);

        return HelpInitializer();

      // case CommandMapperEnum.add:
      //   print('Adding file with pattern: ${results.command!['file']}');
      //   break;

      // Add other command cases as needed
      default:
        return ErrorInitializer("Invalid command $commandName");
    }
  }
}
