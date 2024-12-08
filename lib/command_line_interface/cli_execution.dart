import 'dart:async';
import 'dart:io';

import 'package:balo/command/command.dart';
import 'package:balo/command/command_facade.dart';
import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/command_line_interface/input_parser.dart';
import 'package:balo/command_line_interface/user_input.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';

/// [UndoableCommand] Executor
abstract class UndoableCommandExecutor {
  ///Parses [UserInput] using a [CommandParser] to return a run list
  ///of contiguous commands to be run as a facade [CommandFacade]
  CommandFacade inputToCommands(
    UserInput userInput,
    CommandParser commandParser,
  ) {
    if (userInput.isEmpty) return HelpInitializer();

    ParsedCommands parsedCommands = commandParser.parseUserInput(userInput);
    isVerboseMode = parsedCommands.getOption(CliCommandOptionsEnum.verbose);

    debugPrintToConsole(
      message: "Arguments: ${parsedCommands.toString()} \n",
      style: CliStyle.bold,
      newLine: true,
    );

    if (parsedCommands.hasOption(CliCommandOptionsEnum.help)) {
      return HelpInitializer(command: parsedCommands.command);
    }

    switch (parsedCommands.command) {
      case CliCommandsEnum.help:
        return HelpInitializer();

      case CliCommandsEnum.init:
        if (parsedCommands.hasOption(CliCommandOptionsEnum.help)) {
          return HelpInitializer(command: parsedCommands.command);
        }
        //Path
        String? path = parsedCommands.getOption(CliCommandOptionsEnum.path);
        if (path == "." || path == null) path = Directory.current.path;

        return RepositoryInitializer(path);

      case CliCommandsEnum.add:
        //Path
        String path = parsedCommands.getOption(CliCommandOptionsEnum.filePattern);
        return StageFilesInitializer(path);

      case CliCommandsEnum.ignore:
        //Path
        String? patternToAdd = parsedCommands.getOption(
          CliCommandOptionsEnum.add,
        );
        String? patternToRemove = parsedCommands.getOption(
          CliCommandOptionsEnum.remove,
        );

        return ModifyIgnoreFileInitializer(
          patternToAdd: patternToAdd,
          patternToRemove: patternToRemove,
        );
      case CliCommandsEnum.branch:
        return ListBranchesInitializer();
      case CliCommandsEnum.status:
        return PrintStatusOfCurrentBranchInitializer();
      case CliCommandsEnum.commit:
        String? message = parsedCommands.getOption(
          CliCommandOptionsEnum.message,
        );
        if (message == null) {
          return ErrorInitializer("Commit message required");
        }

        return CommitStagedFilesInitializer(message);
      case CliCommandsEnum.log:
        String? branch = parsedCommands.getOption(
          CliCommandOptionsEnum.branch,
        );
        return GetCommitHistoryInitializer(branch);
      case CliCommandsEnum.checkout:
        String? branch = parsedCommands.getOption(
          CliCommandOptionsEnum.branch,
        );
        if (branch == null) {
          debugPrintToConsole(message: "No branch name");
          return ErrorInitializer("Branch required");
        }

        String? commitSha = parsedCommands.getOption(
          CliCommandOptionsEnum.sha,
        );

        printToConsole(message: "Branch $branch, commit $commitSha");

        return CheckoutToBranchInitializer(branch, commitSha);
      case CliCommandsEnum.merge:
        String? branch = parsedCommands.getOption(
          CliCommandOptionsEnum.branch,
        );
        if (branch == null) {
          debugPrintToConsole(message: "No branch name");
          return ErrorInitializer("Branch required");
        }

        return MergeBranchInitializer(branch);

      case CliCommandsEnum.diff:
        String? thisBranchName = parsedCommands.getOption(
          CliCommandOptionsEnum.thisBranch,
        );

        String? thisSha = parsedCommands.getOption(
          CliCommandOptionsEnum.thisSha,
        );

        String? otherBranchName = parsedCommands.getOption(
          CliCommandOptionsEnum.otherBranch,
        );
        if (otherBranchName == null) {
          debugPrintToConsole(message: "No branch b name");
          return ErrorInitializer("Branch b required");
        }

        String? otherSha = parsedCommands.getOption(
          CliCommandOptionsEnum.otherSha,
        );

        return ShowDiffBetweenCommitsInitializer(
          thisBranchName: thisBranchName,
          otherBranchName: otherBranchName,
          thisCommitSha: thisSha,
          otherCommitSha: otherSha,
        );
      case CliCommandsEnum.remote:
        if (!parsedCommands.hasOption(CliCommandOptionsEnum.add) && !parsedCommands.hasOption(CliCommandOptionsEnum.remove)) {
          debugPrintToConsole(message: "Remote option is null");
          return ListAllRemoteInitializer();
        }

        bool isAdding = parsedCommands.hasOption(CliCommandOptionsEnum.add);

        String remoteName = parsedCommands.getOption(
          isAdding ? CliCommandOptionsEnum.add : CliCommandOptionsEnum.remove,
        );

        String? remoteUrl = parsedCommands.getOption(
          CliCommandOptionsEnum.remoteUrl,
        );

        if (isAdding && remoteUrl == null) {
          debugPrintToConsole(message: "Remote url is null");
          return ErrorInitializer("Remote option required url");
        }

        if(isAdding) {
          return AddRemoteInitializer(remoteName, remoteUrl!);
        } else {
          return RemoveRemoteInitializer(remoteName);
        }

      case CliCommandsEnum.clone:

        String? remoteUrl = parsedCommands.getOption(
          CliCommandOptionsEnum.remoteUrl,
        );

        if (remoteUrl == null) {
          debugPrintToConsole(message: "Remote url is null");
          return ErrorInitializer("Remote option required url");
        }

        String? branchName = parsedCommands.getOption(
          CliCommandOptionsEnum.branch,
        );

        return CloneRepositoryInitializer(remoteUrl, branchName);

      case CliCommandsEnum.push:

        String? remoteName = parsedCommands.getOption(
          CliCommandOptionsEnum.remoteName,
        );

        if (remoteName == null) {
          debugPrintToConsole(message: "Remote name is null");
          return ErrorInitializer("Remote option required url");
        }

        String? branchName = parsedCommands.getOption(
          CliCommandOptionsEnum.branch,
        );

        return PushRepositoryInitializer(remoteName, branchName);


      case CliCommandsEnum.pull:

        String? remoteName = parsedCommands.getOption(
          CliCommandOptionsEnum.remoteName,
        );

        if (remoteName == null) {
          debugPrintToConsole(message: "Remote name is null");
          return ErrorInitializer("Remote option required url");
        }

        String? branchName = parsedCommands.getOption(
          CliCommandOptionsEnum.branch,
        );

        return PullRepositoryInitializer(remoteName, branchName);


      default:
        return ErrorInitializer("Unknown command");
    }
  }

  ///Runs a list of contiguous [UndoableCommand] and return an exit code
  ///If one command throws an [Exception] they will all be undone
  FutureOr<int> runCommand(List<UndoableCommand> commands) async {
    debugPrintToConsole(message: "Executing ${commands.length} commands");

    int i = 0;
    try {
      while (i < commands.length) {
        UndoableCommand c = commands[i++];
        debugPrintToConsole(
          message: "Executing $i: ${c.runtimeType}",
        );
        await c.execute();
      }
      return 0;
    } catch (e, trace) {
      debugPrintToConsole(message: e.toString(), color: CliColor.red);
      debugPrintToConsole(message: trace.toString(), color: CliColor.red);

      while (i > 0) {
        UndoableCommand c = commands[--i];
        debugPrintToConsole(
          message: "Undoing $i: ${c.runtimeType}",
        );
        await commands[--i].undo();
      }

      return 1;
    }
  }
}

///Default implementation of an [UndoableCommandExecutor] with default functions
class DefaultCommandLineRunner extends UndoableCommandExecutor {}
