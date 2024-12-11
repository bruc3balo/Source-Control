import 'dart:io';

const executableName = "balo";
const executableDescription = "A cli utility for balo repository";
const repositoryWorkingDirName = ".balo";
const repositoryIgnoreFileName = ".baloignore";
const branchFolderName = "branches";
const stateFileName = "state.json";
const defaultBranch = "default";
const branchStage = "stage.json";
const branchCommitFolder = "commits";
const branchTreeMetaDataFileName = "tree.json";
const objectsStore = "objects";
const remoteFileName = "remotes.json";
const defaultRemote = "origin";
const branchMergeFileName = "merge.json";

final defaultIgnore = ["${Platform.pathSeparator}$repositoryWorkingDirName", "${Platform.pathSeparator}.git", "${Platform.pathSeparator}.dart_tool", "${Platform.pathSeparator}.idea"];

const stagedAtKey = "staged_at";
const filePathsKey = "file_paths";
const currentBranchKey = "current_branch";

const dot = '.';
const star = '*';