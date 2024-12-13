import 'dart:io';

import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'balo_t.dart' as test_runner;

void main() {
  test('Commit staged files test', () async {

    // Test with repository
    await test_runner.testWithRepository(
      doTest: (localRepository, remoteRepository, v) async {
        // Show command help command
        int helpCode = await test_runner.runTest([CliCommandsEnum.commit.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
        assert(helpCode == 0);

        String expectedFile = "${Platform.pathSeparator}${join("test", "balo_t.dart")}";

        //Run stage files command
        int stageFilesCode = await test_runner.runTest([
          CliCommandsEnum.add.command,
          "-${CliCommandOptionsEnum.filePattern.abbreviation}",
          expectedFile,
          v ?"-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);

        assert(stageFilesCode == 0);

        String commitMessage = "This is a test commit";

        //Commit the staged file
        int commitFilesCode = await test_runner.runTest([
          CliCommandsEnum.commit.command,
          "-${CliCommandOptionsEnum.message.abbreviation}",
          commitMessage,
          v ?"-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);

        assert(commitFilesCode == 0);

        //Check for the commit
        Branch branch = Branch(defaultBranch, localRepository);

        BranchTreeMetaData? branchTree = branch.branchTreeMetaData;
        assert(branchTree != null);

        CommitTreeMetaData? commitTree = branchTree!.commits.values.firstOrNull;
        assert(commitTree != null);

        assert(commitTree!.message == commitMessage);
        assert(commitTree!.commitedObjects.values.first.filePathRelativeToRepository == expectedFile);
      },
    );

    printToConsole(
      message: "Commit files test completed",
      color: CliColor.brightYellow,
      style: CliStyle.bold,
      newLine: true,
    );
  });
}
