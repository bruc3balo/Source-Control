import 'dart:io';

import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';

///Repository prints
void onRepositoryAlreadyInitialized() => printToConsole(message: "Repository has already been initialized", color: CliColor.white);

void onRepositoryNotInitialized() => printToConsole(message: "Repository is not initialized", color: CliColor.red);

void onRepositorySuccessfullyUninitialized() => debugPrintToConsole(message: "Repository uninitialized", color: CliColor.green);

void onRepositorySuccessfullyInitialized() => printToConsole(message: "Repository initialized", color: CliColor.green);

void onFileSystemException(FileSystemException e) => printToConsole(message: e.message, color: CliColor.red);

///Ignore prints
void onIgnoreFileAlreadyExists() => printToConsole(message: "Ignore file already exists", color: CliColor.white);

void onIgnoreFileSuccessfullyCreated() => debugPrintToConsole(message: "Ignore file successfully created", color: CliColor.green);

void onIgnoreFileSuccessfullyDeleted() => debugPrintToConsole(message: "Ignore file successfully deleted", color: CliColor.green);

void onIgnoreFileDoesntExists() => printToConsole(message: "Ignore file doesn't exists", color: CliColor.red);

///Commit
void onNoCommitBranchMetaData(b) => printToConsole(message: "Branch ${b.branchName} (${b.branchName}) has no branch data", color: CliColor.red);

void onNoCommitMetaData(c) => printToConsole(message: "Commit ${c.sha} (${c.branch.branchName}) has no commit meta data", color: CliColor.red);

void onCommitCreated(c) => printToConsole(message: "A new commit ${c.sha} has been added from ${c.originalBranch} branch", color: CliColor.green);

///State
void onSuccessfullyStateSaved() => debugPrintToConsole(message: "State data saved", color: CliColor.green);

void onStateDoesntExist() => printToConsole(message: "State data not found", color: CliColor.red);

void onSuccessfullyStateDeleted() => debugPrintToConsole(message: "State data deleted", color: CliColor.green);

///Staging
void onNoStagingData() => printToConsole(message: "No staging data", color: CliColor.red);

///Remote branch
void onNoChanges() => printToConsole(message: "No changes", color: CliColor.white);

void onNoRemoteData() => printToConsole(message: "Failed to get remote repository data", color: CliColor.red);

void onSuccessfulPull() => printToConsole(message: "Successfully pulled data", color: CliColor.green);

void onRemoteRepositoryNotFound() => printToConsole(message: "Remote repository has not been found", color: CliColor.red);

void onNoCommitsFound() => printToConsole(message: "No commits found", color: CliColor.red);

void onSuccessfulClone() => printToConsole(message: "Repository cloned", color: CliColor.green);

void onSuccessfulPush() => printToConsole(message: "Push successful", color: CliColor.green);

void onRemoteUrlNotSupported() => printToConsole(message: "Only path remotes are allowed", color: CliColor.red);

///Remote
void onRemoteAlreadyExists() => printToConsole(message: "Remote already exists", color: CliColor.red);

void onRemoteDoesntExists() => printToConsole(message: "Remote not found", color: CliColor.red);

///Merge
void onSuccessfulMerge() => printToConsole(message: "Merge is successful", color: CliColor.green);

void onPendingCommit() => printToConsole(message: "You must commit your changes first", color: CliColor.red);

void onPendingMerge() => printToConsole(message: "You have an incomplete merge", color: CliColor.red);

void onSameBranchMerge() => printToConsole(message: "Merging from the same branch is not allowed", color: CliColor.red);

///Branch
void onBranchAlreadyExists() => printToConsole(message: "Branch already exists", color: CliColor.red);

void onBranchDoesntExists() => printToConsole(message: "Branch doesn't exist", color: CliColor.red);

void onBranchCreated(d) => debugPrintToConsole(message: "Branch has been created on ${d.path}", color: CliColor.green);

void onBranchDeleted(d) => debugPrintToConsole(message: "Branch ${d.branchName} been deleted", color: CliColor.green);

void onSameCommit() => printToConsole(message: "Already on the same commit", color: CliColor.red);

void onNoCommit() => printToConsole(message: "No commit has been found on branch", color: CliColor.red);
