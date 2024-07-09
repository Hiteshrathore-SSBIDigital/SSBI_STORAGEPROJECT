import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> checkAndRequestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      return status;
    } else if (status.isDenied || status.isRestricted) {
      return await Permission.storage.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return status;
    }

    return status;
  }
}

class FileService {
  Future<void> createVersionFolder() async {
    final Directory? directory = await getExternalStorageDirectory();

    if (directory != null) {
      final String folderPath = '${directory.path}/Android';
      String versionFolder = '$folderPath/AndroidVersions';

      try {
        final Directory androidDir = Directory(folderPath);
        if (!await androidDir.exists()) {
          await androidDir.create(recursive: true);
          print('Android directory created: $folderPath');
        } else {
          print('Android directory already exists: $folderPath');
        }

        final Directory versionDir = Directory(versionFolder);
        if (!await versionDir.exists()) {
          await versionDir.create(recursive: true);
          print('Version folder created: $versionFolder');
        } else {
          print('Version folder already exists: $versionFolder');
        }
      } catch (e) {
        print('Error creating folders: $e');
      }
    } else {
      print('Could not get the external storage directory');
    }
  }

  Future<String> _getAndroidVersion() async {
    String androidVersion = 'Unknown';
    if (Platform.isAndroid) {
      try {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        androidVersion = androidInfo.version.release;
      } catch (e) {
        print('Error getting Android version: $e');
      }
    }
    return androidVersion;
  }
}
