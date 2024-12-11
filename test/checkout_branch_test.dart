import 'package:balo/command_line_interface/cli_arguments.dart';
import 'package:balo/repository/branch/branch.dart';
import 'package:balo/repository/staging/staging.dart';
import 'package:balo/repository/state/state.dart';
import 'package:balo/utils/variables.dart';
import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';
import 'package:test/test.dart';
import 'balo_t.dart' as test_runner;

void main() {
  test('Merge staged files test', () async {

    // Test with repository
    await test_runner.testWithRepository(
      doTest: (r, _, v) async {

        // Show command help command
        int helpCode = await test_runner.runTest([CliCommandsEnum.merge.command, "-${CliCommandOptionsEnum.help.abbreviation}"]);
        assert(helpCode == 0);

        //Checkout to a new branch from defaultBranch
        String newBranch = "new_branch";
        int createNewBranchCommand = await test_runner.runTest(
          [
            CliCommandsEnum.checkout.command,
            "-${CliCommandOptionsEnum.branch.abbreviation}",
            newBranch,
            v ?"-${CliCommandOptionsEnum.verbose.abbreviation}" : ''
          ],
        );

        assert(createNewBranchCommand == 0);

        State state = State(r);
        Branch? branch = state.getCurrentBranch();

        assert(newBranch == branch?.branchName);
      },
    );

    printToConsole(
      message: "Merge from branch test completed",
      color: CliColor.brightYellow,
      style: CliStyle.bold,
      newLine: true,
    );

  });
}
