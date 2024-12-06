import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:balo/command_line_interface/user_input.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';

import 'arguments.dart';

ArgsCommandParser inputParser = ArgsCommandParser.instance;

///Represents result of [CliCommandsEnum] and [CliCommandOptionsEnum]
///mapped from [UserInput]
class ParsedCommands {
  final CliCommandsEnum command;
  final Map<CliCommandOptionsEnum, dynamic> _options;

  ParsedCommands(this.command, Map<CliCommandOptionsEnum, dynamic> options)
      : _options = options;

  dynamic getOption(CliCommandOptionsEnum o) => _options[o];

  dynamic hasOption(CliCommandOptionsEnum o) => _options.containsKey(o);

  @override
  String toString() => """
  \n  {
    Command: ${command.command},
    Options: ${_options.entries.map((e) => "${e.key.option} = ${e.value}")}
  }
  """;
}

///A Basic definition of what a command parser would do
abstract class CommandParser {
  CommandRunner get _runner => CommandRunner(
        executableName,
        executableDescription,
      );

  ParsedCommands parseUserInput(UserInput userInput);

  void printHelp();
}

///Implementation of a [CommandParser] using [ArgParser] package
class ArgsCommandParser extends CommandParser {
  final ArgParser _argParser = _buildParser();

  //Singleton constructor
  static final ArgsCommandParser instance = ArgsCommandParser._internal();

  ArgsCommandParser._internal();

  @override
  ParsedCommands parseUserInput(UserInput userInput) {
    ArgResults parsedInput = _argParser.parse(userInput.originalUserInput);

    Map<CliCommandOptionsEnum, dynamic> options = {};
    options[CliCommandOptionsEnum.verbose] = parsedInput.flag(
      CliCommandOptionsEnum.verbose.option,
    );

    ArgResults? command = parsedInput.command;
    //All command help
    if (command == null) {
      //Default to help
      return ParsedCommands(CliCommandsEnum.help, options);
    }

    String? commandName = command.name;
    if (commandName == null) {
      throw UsageException("No command provided", _argParser.usage);
    }

    CliCommandsEnum? commandsEnum = CliCommandsEnum.cliCommandsMap[commandName];
    if (commandsEnum == null) {
      throw UsageException("Unknown command $commandName", _argParser.usage);
    }

    //Single command help
    if (command[CliCommandOptionsEnum.help.option] == true) {
      options.putIfAbsent(CliCommandOptionsEnum.help, () => true);
      return ParsedCommands(commandsEnum, options);
    }

    for (String optionName in parsedInput.options) {
      String? optionValue = command[optionName];

      CliCommandOptionsEnum? optionsEnum =
          CliCommandOptionsEnum.cliCommandOptionsMap[optionName];
      if (optionsEnum == null) {
        throw UsageException(
          "Unknown option $optionName for command $commandName",
          _argParser.usage,
        );
      }

      options.putIfAbsent(optionsEnum, () => optionValue);
    }

    options[CliCommandOptionsEnum.verbose] = parsedInput.flag(
      CliCommandOptionsEnum.verbose.option,
    );

    return ParsedCommands(commandsEnum, options);
  }

  @override
  void printHelp() {

    for (ArgParser command in _argParser.commands.values) {

      printToConsole(
        message: command.usage,
        color: CliColor.brightWhite,
        newLine: true,
      );

      printToConsole(
        message: "=" * 200,
        color: CliColor.cyan,
        newLine: true,
      );
    }
  }

  static ArgParser _buildParser() {
    final ArgParser cliCommandParser = ArgParser();
    for (CliCommandsEnum commandEnum in CliCommandsEnum.values) {
      final ArgParser cliCommandOptionsParser = ArgParser();

      for (CommandOption cliCommandOption in commandEnum.options) {
        CliCommandOptionsEnum o = cliCommandOption.optionEnum;

        // Add options to the command parser
        cliCommandOptionsParser.addOption(
          o.option,
          abbr: o.abbreviation,
          help: o.description,
          valueHelp: o.valueHelp,
          defaultsTo: cliCommandOption.defaultValue,
          mandatory: cliCommandOption.mandatory,
          aliases: o.aliases,
        );
      }

      // Add options to the command parser
      if (commandEnum != CliCommandsEnum.help) {
        CliCommandOptionsEnum h = CliCommandOptionsEnum.help;
        cliCommandOptionsParser.addFlag(
          h.option,
          abbr: h.abbreviation,
          help: "Show info related to ${commandEnum.command}",
          defaultsTo: false,
          negatable: false,
          aliases: h.aliases,
        );
      }

      // Add command to the main parser
      cliCommandParser.addCommand(commandEnum.command, cliCommandOptionsParser);
    }

    //Add verbose flag
    CliCommandOptionsEnum v = CliCommandOptionsEnum.verbose;
    cliCommandParser.addFlag(
      v.option,
      abbr: v.abbreviation,
      help: v.description,
      defaultsTo: false,
      negatable: false,
      aliases: v.aliases,
    );

    return cliCommandParser;
  }
}
