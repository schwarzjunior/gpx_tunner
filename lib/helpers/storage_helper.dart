import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:gpx_tunner/app_values.dart';

enum StorageDir {
  ROOT_DIR,
  TEMP_DIR,
  EXTERNAL_DIR,
  APP_PRIVATE_DIR,
  APP_PUBLIC_DIR,
}

class StorageHelper {
  static const String _SYSTEM_APPS_DIR = "/storage/emulated/0/Android/data/";

  static final _instance = StorageHelper();

  String _tempDir, _externalDir, _appPrivateDir, _appPublicDir;

  static Future<String> get appPublicDir async {
    if (_instance._appPublicDir == null) {
      _instance._appPublicDir = '$_SYSTEM_APPS_DIR${AppValues.APP_PUBLIC_DIR}';
      final Directory directory = Directory(_instance._appPublicDir);
      if (!directory.existsSync()) directory.createSync(recursive: true);
    }
    return _instance._appPublicDir;
  }

  static Future<String> get appPrivateDir async {
    _instance._appPrivateDir ??= await getApplicationDocumentsDirectory().then((x) => x.path);
    return _instance._appPrivateDir;
  }

  static Future<String> get tempDir async {
    _instance._tempDir ??= await getTemporaryDirectory().then((x) => x.path);
    return _instance._tempDir;
  }

  static Future<String> get externalDir async {
    _instance._externalDir ??= await getExternalStorageDirectory().then((x) => x.path);
    return _instance._externalDir;
  }

  static Future<String> readFile(String fileName, StorageDir storageDir) async {
    String contents;
    try {
      final File file = await _instance._generateFile(fileName, storageDir);
      if (file.existsSync())
        contents = await file.readAsString();
      else
        print('[StorageHelper][readFile()] => Error (file not exists): "${file.path}"');
    } catch (e) {
      print('[StorageHelper][readFile()] => Error: "$e"');
    }
    return contents;
  }

  static Future<File> writeFile(
      String fileName, StorageDir storageDir, String contents) async {
    try {
      final File file = await _instance._generateFile(fileName, storageDir);
      return await file.writeAsString(contents);
    } catch (e) {
      print('[StorageHelper][writeFile()] => Error: "$e"');
    }
    return null;
  }

  Future<String> _getStorageDir(StorageDir storageDir) async {
    switch (storageDir) {
      case StorageDir.ROOT_DIR:
        return '/';
      case StorageDir.TEMP_DIR:
        return await tempDir;
      case StorageDir.EXTERNAL_DIR:
        return await externalDir;
      case StorageDir.APP_PRIVATE_DIR:
        return await appPrivateDir;
      case StorageDir.APP_PUBLIC_DIR:
        return await appPublicDir;
      default:
        return null;
    }
  }

  Future<File> _generateFile(String fileName, StorageDir storageDir) async {
    return File(path.join(
      await _getStorageDir(storageDir).then((dirPath) => dirPath),
      fileName,
    ));
  }
}
