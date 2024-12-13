import 'dart:io';

import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'balo_t.dart' as test_runner;

void main() {
  test('Push branch test', () async {

    // Test with repository
    await test_runner.testWithRepository(
      doTest: (localRepository, remoteRepository, v) async {

        // Show command help command
        int helpCode = await test_runner.runTest([CliCommandsEnum.push.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
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

        //Add a remote
        String remoteName = "origin";
        String url = remoteRepository.path;

        int addRemoteCommand = await test_runner.runTest([
          CliCommandsEnum.remote.command,
          "-${CliCommandOptionsEnum.add.abbreviation}",
          remoteName,
          "-${CliCommandOptionsEnum.remoteUrl.abbreviation}",
          url,
          v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);
        assert(addRemoteCommand == 0);

        //Push to remote branch
        int pushToRemoteCommand = await test_runner.runTest([
          CliCommandsEnum.push.command,
          "-${CliCommandOptionsEnum.remoteName.abbreviation}",
          remoteName,
          v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);
        assert(pushToRemoteCommand == 0);

        //Check if commit has been recorded
        Branch branch = Branch(defaultBranch, remoteRepository);
        BranchTreeMetaData? branchTree = branch.branchTreeMetaData;
        assert(branchTree != null);
        assert(branchTree!.commits.length == 1);
        assert(branchTree!.commits.values.first.message == initialCommit);

      },
    );

    printToConsole(
      message: "Clone commit test completed",
      color: CliColor.brightYellow,
      style: CliStyle.bold,
      newLine: true,
    );
  },);
}