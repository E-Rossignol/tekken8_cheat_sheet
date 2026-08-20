import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import 'firebase_helper.dart';

class UpdateService {
  final Dio _dio = Dio();

  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  bool needsUpdate({
    required String currentVersion,
    required String remoteVersion,
  }) {
    final current = Version.parse(currentVersion);
    final remote = Version.parse(remoteVersion);

    return remote > current;
  }

  Future<String> downloadInstaller(String url) async {
    final tempDirectory = Directory.systemTemp;

    final installerPath = path.join(
      tempDirectory.path,
      'Tekken8CheatSheet-update.exe',
    );

    await _dio.download(url, installerPath);

    return installerPath;
  }

  Future<void> installUpdate(String url) async {
    final installerPath = await downloadInstaller(url);

    await Process.start(installerPath, [], mode: ProcessStartMode.detached);

    exit(0);
  }

  Future<UpdateInfo?> getUpdateInfo() async {
    final data = await FirebaseHelper.instance.getCollection('app_config');

    if (data.isEmpty) {
      return null;
    }

    final version = data[0]['version'] as String?;
    final downloadUrl = data[0]['downloadUrl'] as String?;

    if (version == null || downloadUrl == null) {
      return null;
    }

    return UpdateInfo(version: version, downloadUrl: downloadUrl);
  }
}

class UpdateInfo {
  final String version;
  final String downloadUrl;

  UpdateInfo({required this.version, required this.downloadUrl});
}
