import 'dart:io';

import 'package:balo/view/themes.dart';

///check to store verbose mode for [debugPrintToConsole]
bool isVerboseMode = false;

///takes user input from terminal
String? listenForInput({String? title}) {
  //Write title
  if (title != null) printToConsole(message: title, color: CliColor.blue);

  //Prompt writing
  printToConsole(message: "> ",newLine: true);

  //Get input
  return stdin.readLineSync(retainNewlines: true);
}


/// if [isVerboseMode] is true, will call [printToConsole]
void debugPrintToConsole({
  required String message,
  bool newLine = false,
  CliColor color = CliColor.magenta,
  CliStyle? style,
}) {
  // if (!isVerboseMode) return;
  printToConsole(
    message: message,
    newLine: newLine,
    color: color,
    style: style,
  );
}

///Display a [message] for the user to see
void printToConsole({
  required String message,
  bool newLine = false,
  CliColor color = CliColor.defaultColor,
  CliStyle? style,
}) {
  String data =
      '${newLine ? '\n' : ''}${color.color}${style?.style ?? ''}$message${CliColor.defaultColor.color}';
  stdout.writeln(data);
}