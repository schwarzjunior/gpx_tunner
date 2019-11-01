import 'package:gpx_tunner/models/track_point.dart';

class GpxData with _PathUtils {
  /// Nome do arquivo *gpx*.
  String get fileName => _fileName;
  String _fileName;

  /// Caminho absoluto do arquivo *gpx*.
  String get filePath => _filePath;
  String _filePath;

  /// Diretorio do arquivo *gpx*.
  String get fileBaseDir => _fileBaseDir;
  String _fileBaseDir;

  /// Conteudo do arquivo *gpx*.
  String get content => _content;
  String _content;

  /// Lista dos [TrackPoint].
  List<TrackPoint> get tpList => _tpList;
  List<TrackPoint> _tpList;

  set content(String value) => _content = value;

  set trackPoints(List<TrackPoint> value) => _tpList = value;

  set filePath(String value) {
    _filePath = value;
    _fileName = _getFileName(value);
    _fileBaseDir = _getBaseDir(value);
  }

  /// O primeiro [TrackPoint] da lista.
  TrackPoint get firstTp => _tpList.first;

  /// O ultimo [TrackPoint] da lista.
  TrackPoint get lastTP => _tpList.last;

  void addTrackPoint(TrackPoint trackPoint) {
    _tpList.add(trackPoint);
  }

  void adjustTimes(int hoursToAdd) {
    for (TrackPoint tp in _tpList) tp.adjustTime(hoursToAdd);
  }

  int getMediaHr() {
    var hrList = _tpList
        .map((tp) => tp.hr != null && tp.hr.isNotEmpty ? int.parse(tp.hr) : null)
        .where((tpHr) => tpHr != null);
    return hrList.reduce((value, element) => value + element) ~/ hrList.length;
  }
}

mixin _PathUtils {
  /// Retorna o nome do arquivo de um caminho absoluto.
  String _getFileName(String path) {
    if (path is! String)
      return null;
    else if (path.isEmpty || !path.contains('/'))
      return '';
    else
      return path.split('/').last;
  }

  /// Retorna o diretorio de um caminho absoluto.
  String _getBaseDir(String path) {
    if (path is! String)
      return null;
    else if (path.isEmpty || !path.contains('/'))
      return '';
    else
      return path.replaceAll(path.split('/').last, '');
  }
}
