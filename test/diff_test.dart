import 'dart:io';

import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'balo_t.dart' as test_runner;

void main() {
  test(
    'Diff test',
    () async {
      await test_runner.testWithRepository(
        doTest: (localRepository, remoteRepository, v) async {
          // Show command help command
          int helpCode = await test_runner.runTest([CliCommandsEnum.diff.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
          assert(helpCode == 0);

          //Stage file
          String initialCommitFile = "${Platform.pathSeparator}${join("test", "balo_t.dart")}";
          int stageFilesCode = await test_runner.runTest([
            CliCommandsEnum.add.command,
            "-${CliCommandOptionsEnum.filePattern.abbreviation}",
            initialCommitFile,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(stageFilesCode == 0);

          //Commit the staged file
          String initialCommit = "This is an initial commit";
          int commitFilesCode = await test_runner.runTest([
            CliCommandsEnum.commit.command,
            "-${CliCommandOptionsEnum.message.abbreviation}",
            initialCommit,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(commitFilesCode == 0);

          //Checkout to a new branch
          String newBranch = "new_branch";
          int createNewBranchCommand = await test_runner.runTest([
            CliCommandsEnum.checkout.command,
            "-${CliCommandOptionsEnum.branch.abbreviation}",
            newBranch,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(createNewBranchCommand == 0);

          //Stage file
          String secondCommitFile = "${Platform.pathSeparator}${join("test", "checkout_branch_test.dart")}";
          int secondCommitStageCode = await test_runner.runTest([
            CliCommandsEnum.add.command,
            "-${CliCommandOptionsEnum.filePattern.abbreviation}",
            secondCommitFile,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(secondCommitStageCode == 0);

          //Commit the second commit file
          String secondCommit = "This is the second commit";
          int secondCommitCode = await test_runner.runTest([
            CliCommandsEnum.commit.command,
            "-${CliCommandOptionsEnum.message.abbreviation}",
            secondCommit,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(secondCommitCode == 0);

          //Diff command
          int diffCode = await test_runner.runTest([
            CliCommandsEnum.diff.command,
            "-${CliCommandOptionsEnum.otherBranch.abbreviation}",
            defaultBranch,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(diffCode == 0);
        },
      );

      debugPrintToConsole(
        message: "Diff test completed",
        color: CliColor.brightYellow,
        style: CliStyle.bold,
        newLine: true,
      );
    },
  );
}
