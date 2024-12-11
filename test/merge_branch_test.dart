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
        cleanup: false,
        verbose: true,
        doTest: (r, _, v) async {
          // Show add help command
          int helpCode = await test_runner.runTest([CliCommandsEnum.merge.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
          assert(helpCode == 0);

          //Stage file
          String expectedFile = "/test/balo_t.dart";
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

          //Merge commits from default branch to new branch
          int mergeFromDefaultBranchToNewBranchCode = await test_runner.runTest([
            CliCommandsEnum.merge.command,
            "-${CliCommandOptionsEnum.branch.abbreviation}",
            defaultBranch,
            v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
          assert(mergeFromDefaultBranchToNewBranchCode == 0);

          //assert merge file exists
          Merge merge = Merge(r, Branch(newBranch, r));
          assert(merge.hasPendingMerge);

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
