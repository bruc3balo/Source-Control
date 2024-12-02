import 'dart:io';

String? listenForInput({String? title}) {
  //Write title
  if(title != null) printToConsole(title);

  //Prompt writing
  printToConsole("> ");

  //Get input
  return stdin.readLineSync(retainNewlines: true);
}

void printToConsole(String s) {
  stdout.writeln(s);
}

