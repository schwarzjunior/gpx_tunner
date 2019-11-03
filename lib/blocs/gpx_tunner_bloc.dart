import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:gpx_tunner/helpers/storage_helper.dart';
import 'package:gpx_tunner/helpers/gpx_xml_helper.dart';
import 'package:gpx_tunner/models/gpx_data.dart';
import 'package:gpx_tunner/models/track_point.dart';

class GpxTunnerBloc extends BlocBase {
  GpxTunnerBloc()
      : _loadedFileData = GpxFileData.empty(),
        _hoursToAddData = HoursToAddData._internal(),
        _origem = GpxData(),
        _destino = GpxData(),
        _isDocPickerInProgress = false,
        _isOrigemOk = false,
        _isDestinoConverted = false,
        _isFileSystemBusy = false,
        _hoursToAdd = 0;

  GpxFileData _loadedFileData;

  GpxData get gpxOrigem => _origem;
  GpxData _origem;

  GpxData get gpxDestino => _destino;
  GpxData _destino;

  bool get isDocPickerInProgress => _isDocPickerInProgress;
  bool _isDocPickerInProgress;

  bool get isOrigemOk => _isOrigemOk;
  bool _isOrigemOk;

  bool get isDestinoConverted => _isDestinoConverted;
  bool _isDestinoConverted;

  bool get isFileSystemBusy => _isFileSystemBusy;
  bool _isFileSystemBusy;

  int get hoursToAdd => _hoursToAdd;
  int _hoursToAdd;

  HoursToAddData get hoursToAddData => _hoursToAddData;
  HoursToAddData _hoursToAddData;

  void incrementHour() {
    _hoursToAddData._increment();
    notifyListeners();
  }

  void decrementHour() {
    _hoursToAddData._decrement();
    notifyListeners();
  }

  Future<void> openGpxOrigemFile() async {
    _isDocPickerInProgress = true;
    _loadedFileData = GpxFileData.empty();
    notifyListeners();

    String result;
    try {
      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ['gpx'],
        allowedMimeTypes: ['application/*'],
      );
      result = await FlutterDocumentPicker.openDocument(params: params);
    } catch (e) {
      print('>>> [openGpxOrigemFile()]: $e');
    }

    _loadedFileData = GpxFileData(result);

    if (_loadedFileData.hasData) {
      await _readGpxOrigemFileData();
    } else {
      _isDocPickerInProgress = false;
      notifyListeners();
    }
  }

  Future<void> startConversion() async {
    _isFileSystemBusy = true;
    notifyListeners();

    String gpxDestinoFilePath = path.join(
      await StorageHelper.appPublicDir,
      _generateGpxDestinoFileName(),
    );
    _destino.filePath = gpxDestinoFilePath;

    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_startConversion, receivePort.sendPort);

    String gpxCreator = 'gpx_tunner';
    String authorName = 'Unknown';
    String activityName = 'Unknown';

    Map<String, dynamic> sendMessage = {
      'gpxOrigem': _origem,
      'gpxDestino': _destino,
      'hoursToAdd': _hoursToAddData.hoursToAdd,
      'gpxCreator': gpxCreator,
      'authorName': authorName,
      'activityName': activityName,
    };

    SendPort sendPort = await receivePort.first;
    var result = await _sendReceive(sendPort, sendMessage);

    bool conversionOk = (result is GpxData);
    _destino = conversionOk ? (result as GpxData) : _destino;

    _isFileSystemBusy = false;
    _isDestinoConverted = true;
    notifyListeners();
  }

  Future<void> _readGpxOrigemFileData() async {
    if (!_loadedFileData.hasData) return;

    _isDocPickerInProgress = false;
    _isOrigemOk = false;
    _isDestinoConverted = false;
    _isFileSystemBusy = true;
    notifyListeners();

    _origem.filePath = _loadedFileData.fullPath;
    _destino.filePath = null;

    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_loadGpxOrigemDetails, receivePort.sendPort);

    final SendPort sendPort = await receivePort.first;
    final result = await _sendReceive(sendPort, _origem);

    bool origemLoaded = (result is GpxData);
    bool origemOk;

    _origem = origemLoaded ? (result as GpxData) : GpxData();
    origemOk = (_origem.trackPoints != null && _origem.trackPoints.isNotEmpty);

    _isFileSystemBusy = false;
    _isOrigemOk = origemOk;
    notifyListeners();
  }

  static _loadGpxOrigemDetails(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    var msg = await receivePort.first;

    SendPort replyPort = msg[0];
    if (msg[1] is! GpxData) {
      replyPort.send(null);
      return;
    }

    GpxData gpxData = (msg[1] as GpxData);
    gpxData.content = await StorageHelper.readFile(gpxData.filePath, StorageDir.ROOT_DIR);
    GpxXmlReaderHelper reader = GpxXmlReaderHelper(gpxData.content);
    gpxData.trackPoints = await reader.getTrackPointsList('trkpt');

    replyPort.send(gpxData);
  }

  static _startConversion(SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final msg = await receivePort.first;

    final SendPort replyPort = msg[0];

    Map<String, dynamic> data = (msg[1] as Map<String, dynamic>);
    final GpxData origem = data['gpxOrigem'];
    final GpxData destino = data['gpxDestino'];
    final int hoursToAdd = data['hoursToAdd'];
    final String gpxCreator = data['gpxCreator'];
    final String authorName = data['authorName'];
    final String activityName = data['activityName'];

    final GpxXmlCreatorHelper creator = GpxXmlCreatorHelper(
      origem.trackPoints,
      hoursToAdd,
      gpxCreator: gpxCreator,
      authorName: authorName,
      activityName: activityName,
    );
    await creator.buildGpx();
    destino.content = creator.documentString;
    destino.trackPoints = creator.items.toList();

    final File file = await StorageHelper.writeFile(
      destino.filePath,
      StorageDir.ROOT_DIR,
      destino.content,
    );

    replyPort.send(file.existsSync() ? destino : null);
  }

  Future<dynamic> _sendReceive(SendPort send, dynamic message) {
    ReceivePort receivePort = ReceivePort();
    send.send([receivePort.sendPort, message]);
    return receivePort.first;
  }

  String _generateGpxDestinoFileName() {
    final TrackPoint tp = _origem.firstTp;
    tp.adjustTime(_hoursToAddData.hoursToAdd);
    final dt = tp.adjustedTime;
    return 'gpxtunner_'
        '${dt.year}-${dt.month}-${dt.day}_'
        '${dt.hour}-${dt.minute}-${dt.second}.gpx';
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class HoursToAddData {
  static const int MAX_HOURS_ALLOWED = 5;

  HoursToAddData._internal({int initialValue}) : _hoursToAdd = initialValue ?? 0;

  int get hoursToAdd => _hoursToAdd;
  int _hoursToAdd;

  bool get maxHoursReached => (_hoursToAdd >= MAX_HOURS_ALLOWED);

  bool get minHoursReached => (_hoursToAdd <= -MAX_HOURS_ALLOWED);

  void _increment() => ++_hoursToAdd;

  void _decrement() => --_hoursToAdd;
}

@immutable
class GpxFileData {
  final String fullPath;
  final String fileName;
  final String dirName;

  const GpxFileData._internal(this.fullPath, this.fileName, this.dirName);

  factory GpxFileData(String fullPath) {
    String fileName = fullPath?.split('/')?.last ?? null;
    String dirName = (fullPath is String)
        ? fullPath.substring(0, fullPath.length - fullPath.split('/').last.length)
        : null;
    return GpxFileData._internal(fullPath, fileName, dirName);
  }

  factory GpxFileData.empty() => GpxFileData._internal(null, null, null);

  bool get hasData => (fullPath is String);
}
