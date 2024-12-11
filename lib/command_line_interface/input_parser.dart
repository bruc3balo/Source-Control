import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:balo/command_line_interface/user_input.dart';
import 'package:balo/repository/ignore.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';

import 'cli_arguments.dart';

final ArgsCommandParser inputParser = ArgsCommandParser.instance;

///Represents result of [CliCommandsEnum] and [CliCommandOptionsEnum]
///mapped from [UserInput]
class ParsedCommands {
  final CliCommandsEnum command;
  final Map<CliCommandOptionsEnum, dynamic> _options;

  ParsedCommands(this.command, Map<CliCommandOptionsEnum, dynamic> options) : _options = options;

  dynamic getOption(CliCommandOptionsEnum o) => _options[o] ?? command.options.where((e) => e.optionEnum == o).map((e) => e.defaultValue).firstOrNull;

  bool hasOption(CliCommandOptionsEnum o) => _options.containsKey(o);

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

  ///Transform [UserInput] into [ParsedCommands]
  ParsedCommands parseUserInput(UserInput userInput);

  ///Display the use of one [CliCommandsEnum]
  void printHelp({CliCommandsEnum? command});
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
    if (commandsEnum == CliCommandsEnum.help || command[CliCommandOptionsEnum.help.option] == true) {
      options.putIfAbsent(CliCommandOptionsEnum.help, () => true);
      return ParsedCommands(commandsEnum, options);
    }

    for (String optionName in command.options) {
      if (!command.wasParsed(optionName)) continue;

      String? optionValue = command[optionName];

      CliCommandOptionsEnum? optionsEnum = CliCommandOptionsEnum.cliCommandOptionsMap[optionName];
      if (optionsEnum == null) {
        throw UsageException(
          "Unknown option $optionName for command $commandName",
          _argParser.usage,
        );
      }

      options.putIfAbsent(optionsEnum, () => optionValue);
    }

    return ParsedCommands(commandsEnum, options);
  }

  static ArgParser _buildParser() {
    final ArgParser cliCommandParser = ArgParser();
    for (CliCommandsEnum commandEnum in CliCommandsEnum.values) {
      final ArgParser cliCommandOptionsParser = ArgParser();

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

  @override
  void printHelp({CliCommandsEnum? command}) {
    printToConsole(
      message: "${"=" * 45} $executableName help page ${"=" * 45}",
      color: CliColor.defaultColor,
      style: CliStyle.bold,
      newLine: true,
    );

    printToConsole(
      message: executableName,
      color: CliColor.brightWhite,
      style: CliStyle.bold,
      newLine: true,
    );

    printToConsole(
      message: executableDescription,
      color: CliColor.defaultColor,
    );

    List<Option> globalOptions = _argParser.options.values.toList();
    printToConsole(
      message: "Global options",
      newLine: true,
      style: CliStyle.underline,
    );
    globalOptions.forEach(_printOption);

    printToConsole(
      message: "Commands",
      newLine: true,
      style: CliStyle.underline,
    );

    if (command == null || command == CliCommandsEnum.help) {
      // Print help for all commands
      CliCommandsEnum.values.forEach(_printCommandHelp);
      return;
    }

    // Print help for a specific command
    _printCommandHelp(command);
  }

  void _printCommandHelp(CliCommandsEnum command) {
    String commandName = command.command;

    ArgParser? arg = _argParser.commands[commandName];
    if (arg == null) return;

    CliCommandsEnum? cliCommand = CliCommandsEnum.cliCommandsMap[commandName];
    if (cliCommand == null) return;

    printToConsole(
      message: commandName,
      color: CliColor.brightMagenta,
      style: CliStyle.bold,
      newLine: true,
    );

    printToConsole(
      message: cliCommand.description,
      color: CliColor.brightWhite,
    );

    List<Option> options = arg.options.values.toList();
    options.sort((a, b) => a.mandatory ? -1 : 1);
    options.forEach(_printOption);

    // Separator between commands
    printToConsole(
      message: "-" * 100,
      color: CliColor.cyan,
      newLine: true,
    );
  }

  void _printOption(Option o) {

    CliCommandOptionsEnum? cli = CliCommandOptionsEnum.cliCommandOptionsMap[o.name];
    if (cli == null) return;

    CliColor color = o.mandatory ? CliColor.brightGreen : CliColor.white;

    printToConsole(
      message: "${o.help}: ${CliColor.brightMagenta.color}--${o.name}, -${o.abbr}${color.color}${o.valueHelp == null ? '' : ' = <${o.valueHelp}>'} ${o.defaultsTo == null ? "" : "(default = ${o.defaultsTo})"}",
      color: color,
    );

    if (cli == CliCommandOptionsEnum.filePattern) {
      printToConsole(
        message: "File pattern rules",
        color: CliColor.blue,
        style: CliStyle.underline
      );
      for (IgnorePatternRules ipr in IgnorePatternRules.values) {
        printToConsole(
          message: "${ipr.description}: ${CliColor.brightMagenta.color}${ipr.pattern}${CliColor.defaultColor.color} = <pattern> (pattern position = ${ipr.position.name}) e.g. ${CliColor.brightYellow.color}${ipr.example.testPattern}${CliColor.defaultColor.color}",
          color: CliColor.defaultColor,
        );
      }
      printToConsole(message: "");
    }

  }
}
