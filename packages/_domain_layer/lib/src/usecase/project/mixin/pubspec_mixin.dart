import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';

import '../../../entity/project/project.dart';
import '../../../exception/l10n_fix_exception.dart';
import '../../../exception/l10n_pubspec_exception.dart';

mixin PubspecMixin {
  Future<Pubspec> readPubspec(Project project) async {
    final file = File('${project.path}/pubspec.yaml');
    if (!await file.exists()) {
      throw const L10nMissingPubspecException();
    }

    final content = await file.readAsString();
    return Pubspec.parse(content);
  }

  Dependency checkPubspecDependency(
    Project project,
    Pubspec pubspec,
    String depName, {
    bool isSdk = false,
  }) {
    final dep = pubspec.dependencies[depName];
    if (dep == null) {
      throw L10nMissingDependencyError(depName, projectPath: project.path, isSDK: true);
    }
    if (isSdk && dep is! SdkDependency) {
      throw L10nIncompleteDependencyException(depName);
    }
    return dep;
  }

  Future<void> addPubspecDependency(
    String depName, {
    required String projectPath,
    bool isSDK = false,
    bool isDev = false,
  }) async {
    final result = await Process.run(
      'flutter',
      [
        'pub',
        'add',
        if (isDev) '--dev',
        depName,
        if (isSDK) '--sdk=flutter',
      ],
      workingDirectory: projectPath,
      runInShell: true,
    );
    if (result.exitCode != 0) {
      throw L10nAddDependencyError(depName);
    }
  }
}
