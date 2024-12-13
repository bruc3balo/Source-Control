import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/remote/remote.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:test/test.dart';
import 'balo_t.dart' as test_runner;

void main() {
  test('Add and remove remoteName branch test', () async {

    // Test with repository
    await test_runner.testWithRepository(
      doTest: (localRepository, remoteRepository, v) async {

        // Show command help command
        int helpCode = await test_runner.runTest([CliCommandsEnum.remote.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
        assert(helpCode == 0);

        //Add a remoteName
        String remoteName = "origin";
        String url = remoteRepository.path;

        int addRemoteCommand = await test_runner.runTest([
            CliCommandsEnum.remote.command,
            "-${CliCommandOptionsEnum.add.abbreviation}",
            remoteName,
            "-${CliCommandOptionsEnum.remoteUrl.abbreviation}",
            url,
            v ?"-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
        assert(addRemoteCommand == 0);

        Remote remote = Remote(localRepository, remoteName, url);
        assert(remote.remoteData.remotes.containsKey(remoteName));

        //Remove  remote
        int removeRemoteCommand = await test_runner.runTest([
            CliCommandsEnum.remote.command,
            "-${CliCommandOptionsEnum.remove.abbreviation}",
            remoteName,
            "-${CliCommandOptionsEnum.remoteUrl.abbreviation}",
            url,
            v ?"-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ]);
        assert(removeRemoteCommand == 0);

        assert(!remote.remoteData.remotes.containsKey(remoteName));

      },
    );

    printToConsole(
      message: "Remote added and removed test completed",
      color: CliColor.brightYellow,
      style: CliStyle.bold,
      newLine: true,
    );

  });
}
