import 'dart:io';
import 'dart:typed_data';

import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/repository.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'balo_t.dart' as test_runner;

void main() {
  test('pull changes test', () async {
    // Test with repository
    await test_runner.testWithRepository(
      cleanup: true,
      verbose: false,
      doTest: (localRepository, remoteRepository, v) async {

        // Show command help command
        int helpCode = await test_runner.runTest([CliCommandsEnum.pull.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
        assert(helpCode == 0);

        //Stage file
        String expectedFilePath = "${Platform.pathSeparator}${join("test", "balo_t.dart")}";
        int stageFilesCode = await test_runner.runTest([
          CliCommandsEnum.add.command,
          "-${CliCommandOptionsEnum.filePattern.abbreviation}",
          expectedFilePath,
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

        ///Clone from remote repository
        String clonePath = join(Directory.current.path, "test-clone-path");

        int cloneFromRemoteCommand = await test_runner.runTest([
          CliCommandsEnum.clone.command,
          "-${CliCommandOptionsEnum.remoteUrl.abbreviation}",
          url,
          "-${CliCommandOptionsEnum.path.abbreviation}",
          clonePath,
          v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);
        assert(cloneFromRemoteCommand == 0);

        String cloneWorkingDir = join(clonePath, remoteRepository.path.split(Platform.pathSeparator).last);
        Repository clonedRepository = Repository(cloneWorkingDir);
        assert(clonedRepository.isInitialized);

        ///Make changes to cloned repo
        //Cache original expectedFile
        Uint8List expectedFileCache = File(join(Directory.current.path, "test","balo_t.dart")).readAsBytesSync();

        //Change to cloned repo
        //Cache original directory
        Directory originalDirectory = Directory.current;
        Directory.current = cloneWorkingDir;

        //Alter cloned repo file
        String clonedExpectedFileCachePath = join(cloneWorkingDir, "test", "balo_t.dart");
        File clonedExpectedFileCacheFile = File(clonedExpectedFileCachePath);

        String clonedRepoChange = "//LGTM";
        clonedExpectedFileCacheFile.writeAsStringSync("\n$clonedRepoChange", mode: FileMode.append, flush: true);

        //Stage altered file
        int stageClonedExpectedFileCachePathCommand = await test_runner.runTest([
          CliCommandsEnum.add.command,
          "-${CliCommandOptionsEnum.filePattern.abbreviation}",
          clonedExpectedFileCachePath,
          v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);
        assert(stageClonedExpectedFileCachePathCommand == 0);

        //Commit the staged altered file
        String secondCommit = "Code has been reviewed";
        int secondCommitFilesCode = await test_runner.runTest([
          CliCommandsEnum.commit.command,
          "-${CliCommandOptionsEnum.message.abbreviation}",
          secondCommit,
          v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);
        assert(secondCommitFilesCode == 0);

        //Push to remote branch
        int pushSecondCommitToRemoteCommand = await test_runner.runTest([
          CliCommandsEnum.push.command,
          "-${CliCommandOptionsEnum.remoteName.abbreviation}",
          remoteName,
          v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);
        assert(pushSecondCommitToRemoteCommand == 0);

        ///Switch to original repository
        Directory.current = originalDirectory;

        //Pull the changes
        int pullChangesCommand = await test_runner.runTest([
          CliCommandsEnum.pull.command,
          "-${CliCommandOptionsEnum.remoteName.abbreviation}",
          remoteName,
          v ? "-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
        ]);
        assert(pullChangesCommand == 0);

        //Check if second commit exists
        //Check if commit has been recorded
        Branch branch = Branch(defaultBranch, localRepository);
        BranchTreeMetaData? branchTree = branch.branchTreeMetaData;
        assert(branchTree != null);
        assert(branchTree!.commits.length == 2);
        assert(branchTree!.commits.values.any((c) => c.message == secondCommit));

        //Check if file has change
        File expectedFile = File(join(localRepository.workingDirectory.path, "test", "balo_t.dart"));
        assert(expectedFile.readAsLinesSync().last == clonedRepoChange);

        ///Restore original local repository state
        expectedFile.writeAsBytesSync(expectedFileCache);

        //Clean up cloned repo
        Directory(clonePath).deleteSync(recursive: true);
      },
    );

    printToConsole(
      message: "Pull commit test completed",
      color: CliColor.brightYellow,
      style: CliStyle.bold,
      newLine: true,
    );
  }, timeout: Timeout(Duration(days: 1)));
}
