import 'package:date_format/date_format.dart' as df;

class TrackPoint {
  TrackPoint({String lon, String lat, String ele, String hr, String time})
      : _lon = lon,
        _lat = lat,
        _ele = ele,
        _hr = hr,
        _time = _TrackPointTime(time),
        _adjustedTime = _TrackPointTime(time);

  /// Longitude.
  String get lon => _lon;
  String _lon;

  /// Latitude.
  String get lat => _lat;
  String _lat;

  /// Elevacao.
  String get ele => _ele;
  String _ele;

  /// Heart hate.
  String get hr => _hr;
  String _hr;

  /// Data/hora.
  _TrackPointTime get time => _time;
  _TrackPointTime _time;

  /// Data/hora ajustadas.
  _TrackPointTime get adjustedTime => _adjustedTime;
  _TrackPointTime _adjustedTime;

  set lon(String lon) => _lon = lon;

  set lat(String lat) => _lat = lat;

  set ele(String ele) => _ele = ele;

  set hr(String hr) => _hr = hr;

  /// Ajusta o valor de [adjustedTime], adicionando as horas de [hoursToAdd].
  void adjustTime(int hoursToAdd) {
    DateTime dateTime = DateTime.parse(_time.timeUtc);
    if (_time.isUtc) dateTime = dateTime.toLocal();
    dateTime = dateTime.add(Duration(hours: hoursToAdd));
    _adjustedTime.dateTime = dateTime;
  }

  @override
  String toString() => 'TrackPoint '
      '[lon=$lon, lat=$lat, ele=$ele, hr=$hr '
      'time=${time.timeUtc}, adjustedTime=${adjustedTime.timeUtc}]';
}

class _TrackPointTime with DateUtils {
  _TrackPointTime(String time) {
    this.timeUtc = time;
  }

  /// DateTime com data/hora.
  DateTime get dateTime => _dateTime;
  DateTime _dateTime;

  /// Data/hora no time zone UTC.
  String get timeUtc => _timeUtc;
  String _timeUtc;

  /// Seta o valor da data/hora.
  set dateTime(DateTime dateTime) {
    _dateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    _timeUtc = _formatDate(dateTime.toUtc());
  }

  /// Seta o valor da data/hora.
  set timeUtc(String timeUtc) {
    try {
      dateTime = DateTime.parse(timeUtc);
    } on FormatException catch (e) {
      print('[_TimeDetail][set timeUtc]: $e');
    }
  }

  String get hour => _padWithZeros(_dateTime.hour);

  String get minute => _padWithZeros(_dateTime.minute);

  String get second => _padWithZeros(_dateTime.second);

  String get year => _padWithZeros(_dateTime.year, size: 4);

  String get month => _padWithZeros(_dateTime.month);

  String get day => _padWithZeros(_dateTime.day);

  String get timeZoneName => _dateTime.timeZoneName;

  String get timeZoneOffset => _dateTime.timeZoneOffset.inHours.toString();

  bool get isUtc => _dateTime.isUtc;

  String get millisecondsSinceEpoch => _dateTime.millisecondsSinceEpoch.toString();

  String get dateString => '$day/$month/$year';

  String get timeString => '$hour:$minute:$second';

  String get dateTimeString => '$dateString $timeString';
}

mixin DateUtils {
  static final _pattern = []
    ..addAll([df.yyyy, '-', df.mm, '-', df.dd, 'T'])
    ..addAll([df.HH, ':', df.nn, ':', df.ss, df.z]);

  /// Retorna o [dateTime] formatado.
  String _formatDate(DateTime dateTime) => df.formatDate(dateTime.toUtc(), _pattern);

  /// Ajusta o numero de zeros a esquerda de um valor numerico.
  String _padWithZeros(num value, {int size = 2}) {
    return value.abs().toString().padLeft(size, '0');
  }
}
