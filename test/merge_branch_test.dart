import 'dart:io';

import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/merge/merge.dart';
import 'package:balo/repository/remote/remote.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'balo_t.dart' as test_runner;

void main() {
  test(
    'Merge branch test',
    () async {
      // Test with repository
      await test_runner.testWithRepository(
        doTest: (localRepository, remoteRepository, v) async {
          // Show command help command
          int helpCode = await test_runner.runTest([CliCommandsEnum.merge.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
          assert(helpCode == 0);

          //Stage file
          String expectedFile = "${Platform.pathSeparator}${join("test", "balo_t.dart")}";
          int stageFilesCode = await test_runner.runTest([
            CliCommandsEnum.add.command,
            "-${CliCommandOptionsEnum.filePattern.abbreviation}",
            expectedFile,
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

          //Stage second file
          String expectedSecondFile = "${Platform.pathSeparator}${join("test", "checkout_branch_test.dart")}";
          int expectedSecondFileCode = await test_runner.runTest([
            CliCommandsEnum.add.command,
            "-${CliCommandOptionsEnum.filePattern.abbreviation}",
            expectedSecondFile,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(expectedSecondFileCode == 0);

          //Commit the staged file
          String secondCommit = "This is the second commit";
          int secondCommitCode = await test_runner.runTest([
            CliCommandsEnum.commit.command,
            "-${CliCommandOptionsEnum.message.abbreviation}",
            secondCommit,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(secondCommitCode == 0);

          //Checkout to a default
          int backToDefaultBranchCommand = await test_runner.runTest([
            CliCommandsEnum.checkout.command,
            "-${CliCommandOptionsEnum.branch.abbreviation}",
            defaultBranch,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(backToDefaultBranchCommand == 0);

          //Merge commits from new branch branch to default branch
          int mergeFromDefaultBranchToNewBranchCode = await test_runner.runTest([
            CliCommandsEnum.merge.command,
            "-${CliCommandOptionsEnum.branch.abbreviation}",
            newBranch,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(mergeFromDefaultBranchToNewBranchCode == 0);

          //Assert merge file exists
          Merge merge = Merge(localRepository, Branch(defaultBranch, localRepository));
          assert(merge.hasPendingMerge);

          //Commit changes
          String commitMessage = "Merged from $defaultBranch";

          //Commit the staged file
          int commitMergedFilesCode = await test_runner.runTest([
            CliCommandsEnum.commit.command,
            "-${CliCommandOptionsEnum.message.abbreviation}",
            commitMessage,
            v ?"-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);

          assert(commitMergedFilesCode == 0);

        },
      );

      printToConsole(
        message: "Merged branch test completed",
        color: CliColor.brightYellow,
        style: CliStyle.bold,
        newLine: true,
      );
    },
  );
}
