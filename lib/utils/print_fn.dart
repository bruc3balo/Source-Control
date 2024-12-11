import 'dart:io';

import 'package:balo/view/terminal.dart';
import 'package:balo/view/themes.dart';

///Repository prints
void onRepositoryAlreadyInitialized() => printToConsole(message: "Repository has already been initialized", color: CliColor.white);

void onRepositoryNotInitialized() => printToConsole(message: "Repository is not initialized", color: CliColor.red);

void onRepositorySuccessfullyUninitialized() => printToConsole(message: "Repository uninitialized", color: CliColor.green);
void onRepositorySuccessfullyInitialized() => printToConsole(message: "Repository initialized", color: CliColor.green);

void onFileSystemException(FileSystemException e) => printToConsole(message: e.message, color: CliColor.red);

///Ignore prints
void onIgnoreFileAlreadyExists() => printToConsole(message: "Ignore file already exists", color: CliColor.white);

void onIgnoreFileSuccessfullyCreated() => printToConsole(message: "Ignore file successfully created", color: CliColor.green);

void onIgnoreFileSuccessfullyDeleted() => printToConsole(message: "Ignore file successfully deleted", color: CliColor.green);

void onIgnoreFileDoesntExists() => printToConsole(message: "Ignore file doesn't exists", color: CliColor.white);

///Commit
void onNoCommitBranchMetaData(b) => printToConsole(message: "Branch ${b.branchName} (${b.branchName}) has no branch data", color: CliColor.red);

void onNoCommitMetaData(c) => printToConsole(message: "Commit ${c.sha} (${c.branch.branchName}) has no commit meta data", color: CliColor.red);

///State
void onSuccessfullyStateSaved() => printToConsole(message: "State data saved", color: CliColor.green);

void onStateDoesntExist() => printToConsole(message: "State data not found", color: CliColor.red);

void onSuccessfullyStateDeleted() => printToConsole(message: "State data deleted", color: CliColor.green);

///Staging
void onNoStagingData() => printToConsole(message: "No staging data", color: CliColor.red);

///Remote branch
void onNoChanges() => printToConsole(message: "No changes", color: CliColor.white);

void onNoRemoteData() => printToConsole(message: "Failed to get remote repository data", color: CliColor.red);

void onSuccessfulPull() => printToConsole(message: "Successfully pulled data", color: CliColor.green);

void onRemoteRepositoryNotFound() => printToConsole(message: "Remote repository has not found", color: CliColor.red);

void onNoCommitsFound() => printToConsole(message: "No commits found", color: CliColor.red);

void onSuccessfulClone() => printToConsole(message: "Repository cloned", color: CliColor.green);

void onSuccessfulPush() => printToConsole(message: "Push successful", color: CliColor.green);

void onRemoteUrlNotSupported() => printToConsole(message: "Only path remotes are successful", color: CliColor.red);

///Remote
void onRemoteAlreadyExists() => printToConsole(message: "Remote already exists", color: CliColor.red);

void onRemoteDoesntAlreadyExists() => printToConsole(message: "Remote not found", color: CliColor.red);

///Merge
void onSuccessfulMerge() => printToConsole(message: "Merge is successful", color: CliColor.green);

void onPendingCommit() => printToConsole(message: "You must commit your changes first", color: CliColor.red);

void onPendingMerge() => printToConsole(message: "You have an incomplete merge", color: CliColor.red);

void onSameBranchMerge() => printToConsole(message: "Merging from the same branch is not allowed", color: CliColor.red);

///Branch
void onBranchAlreadyExists() => printToConsole(message: "Branch already exists", color: CliColor.red);
void onBranchCreated(d) => debugPrintToConsole(message: "Branch has been created on ${d.path}", color: CliColor.green);
