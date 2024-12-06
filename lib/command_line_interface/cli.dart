import 'dart:async';
import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command/command_facade.dart';
import 'package:balo/command/command_mapper.dart';
import 'package:balo/command_line_interface/user_input.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:dart_console/dart_console.dart';


/// CommandExecutor
abstract class CommandExecutor {
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
        String? path = optionMapEnum[CommandOptionsMapperEnum.pattern];
        if ("." == path) path = "*";
        path ??= "*";

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
      case CommandMapperEnum.branch:
        if (optionMapEnum.isEmpty) {
          return PrintCurrentBranchInitializer();
        }

        return PrintCurrentBranchInitializer();
      case CommandMapperEnum.status:
        return PrintStatusOfCurrentBranchInitializer();
      case CommandMapperEnum.commit:
        String? message = optionMapEnum[CommandOptionsMapperEnum.message];
        if (message == null) {
          return ErrorInitializer("Commit message required");
        }

        return CommitStagedFilesInitializer(message);
      case CommandMapperEnum.log:
        String? branch = optionMapEnum[CommandOptionsMapperEnum.branch];
        return GetCommitHistoryInitializer(branch);
      case CommandMapperEnum.checkout:
        String? branch = optionMapEnum[CommandOptionsMapperEnum.branch];
        if (branch == null) {
          debugPrintToConsole(message: "No branch name");
          return ErrorInitializer("Branch required");
        }

        return CheckoutToBranchInitializer(branch);
      case CommandMapperEnum.merge:
        String? branch = optionMapEnum[CommandOptionsMapperEnum.branch];
        if (branch == null) {
          debugPrintToConsole(message: "No branch name");
          return ErrorInitializer("Branch required");
        }

        return MergeBranchInitializer(branch);

      case CommandMapperEnum.diff:
        String? branchAName = optionMapEnum[CommandOptionsMapperEnum.branchA];
        if (branchAName == null) {
          debugPrintToConsole(message: "No branch a name");
          return ErrorInitializer("Branch a required");
        }

        String? shaAName = optionMapEnum[CommandOptionsMapperEnum.shaA];
        if (shaAName == null) {
          debugPrintToConsole(message: "No commit a sha");
          return ErrorInitializer("Sha a required");
        }

        String? branchBName = optionMapEnum[CommandOptionsMapperEnum.branchB];
        if (branchBName == null) {
          debugPrintToConsole(message: "No branch b name");
          return ErrorInitializer("Branch b required");
        }

        String? shaBName = optionMapEnum[CommandOptionsMapperEnum.shaB];
        if (shaBName == null) {
          debugPrintToConsole(message: "No commit b sha");
          return ErrorInitializer("Sha b required");
        }

        return ShowDiffBetweenCommitsInitializer(
          branchAName: branchAName,
          branchBName: branchBName,
          commitASha: shaAName,
          commitBSha: shaBName,
        );
      default:
        return ErrorInitializer("Unknown command ${userInput.command}");
    }
  }

  //Run commands and return and exit code
  FutureOr<int> runCommand(List<Command> commands) async {
    debugPrintToConsole(message: "Executing ${commands.length} commands");

    int i = 0;
    try {
      while (i < commands.length) {
        await commands[i++].execute();
      }
      return 0;
    } catch (e, trace) {
      debugPrintToConsole(message: e.toString(), color: CliColor.red);
      debugPrintToConsole(message: trace.toString(), color: CliColor.red);

      while (i > 0) {
        await commands[--i].undo();
      }

      return 1;
    }
  }
}

///Parses user input and creates commands
///Runs commands created
class CommandLineRunner extends CommandExecutor {

}
