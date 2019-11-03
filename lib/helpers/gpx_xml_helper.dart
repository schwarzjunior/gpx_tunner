import 'package:gpx_tunner/models/track_point.dart';
import 'package:xml/xml.dart' as xml;

class GpxXmlReaderHelper {
  final String xmlOriginal;
  String _contents;
  xml.XmlDocument _document;

  GpxXmlReaderHelper(this.xmlOriginal);

  Future<String> get contents async {
    if (_contents is! String || _contents.isEmpty) {
      await _readDocument();
      _contents = _document.toXmlString(pretty: true, indent: "  ");
    }
    return _contents;
  }

  Future<List<TrackPoint>> getTrackPointsList(String tag) async {
    await _readDocument();
    final Iterable<xml.XmlElement> elements = _document.findAllElements(tag);
    List<TrackPoint> items =
        elements.map((xml.XmlElement item) => _buildTrackPoint(item)).toList();
    return items;
  }

  TrackPoint _buildTrackPoint(xml.XmlElement item) {
    var lon = item.getAttribute("lon");
    var lat = item.getAttribute("lat");
    var ele = _getElementValue(item.findAllElements("ele"));
    var time = _getElementValue(item.findAllElements("time"));
    var hr = _getElementValue(item.findAllElements("gpxtpx:hr"));
    return TrackPoint(lon: lon, lat: lat, ele: ele, hr: hr, time: time);
  }

  String _getElementValue(Iterable<xml.XmlElement> items) {
    var textValue;
    items.map((xml.XmlElement node) => textValue = node.text).toList();
    return textValue;
  }

  Future<void> _readDocument({bool forceRead = false}) async {
    if (_document is! xml.XmlDocument || forceRead) _document = xml.parse(xmlOriginal);
  }
}

class GpxXmlCreatorHelper {
  static const bool _PRETTY = true;
  static const String _INDENT = "  ";

  final String gpxCreator;
  final String authorName;
  final String activityName;
  final String startTime;
  final List<TrackPoint> items;
  final int hoursToAdd;

  GpxXmlCreatorHelper(
    this.items,
    this.hoursToAdd, {
    this.gpxCreator = "Unknown",
    this.authorName = "Unknown",
    this.activityName,
    this.startTime,
  })  : assert(items != null),
        assert(hoursToAdd != null);

  xml.XmlDocument get documentXml => _document;
  xml.XmlDocument _document;

  String get documentString {
    return (_document != null)
        ? _document.toXmlString(pretty: _PRETTY, indent: _INDENT)
        : null;
  }

  String get startTimeUsed => _startTimeUsed;
  String _startTimeUsed;

  Future<void> buildGpx() async {
    if (items != null) {
      // Adicionando [hoursToAdjust] aos tempos dos items da lista.
      //for (var item in items) item.adjustTime(hoursToAdjust);
      items.forEach((item) => item.adjustTime(hoursToAdd));

      // Se [startTime] for *null*, o [_startTimeUsed] sera o [adjustedTime]
      // do primeiro item [TrackPoint] da lista.
      _startTimeUsed = (startTime != null
          ? startTime
          : (items != null && items.isNotEmpty ? items.first.adjustedTime.timeUtc : ''));

      xml.XmlBuilder builder = xml.XmlBuilder();
      await _createGpx(builder, _startTimeUsed);

      _document = builder.build();
    }
  }

  /// Cria o conteudo principal do XML.
  Future<void> _createGpx(xml.XmlBuilder builder, String startTimeValue) async {
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    // <gpx>
    builder.element('gpx', nest: () {
      builder.attribute('creator', gpxCreator);
      builder.attribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      builder.attribute('xsi:schemaLocation',
          'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd');
      builder.attribute('version', '1.1');
      // Existe somente no gpx exportado do Strava, e nao no do GadgetBridge.
      builder.attribute('xmlns', 'http://www.topografix.com/GPX/1/1');
      builder.attribute(
          'xmlns:gpxtpx', 'http://www.garmin.com/xmlschemas/TrackPointExtension/v1');
      // Existe somente no gpx exportado do Strava, e nao no do GadgetBridge.
      builder.attribute('xmlns:gpxx', 'http://www.garmin.com/xmlschemas/GpxExtensions/v3');
      // <metadata>
      builder.element('metadata', nest: () {
        builder.element('author', nest: () {
          builder.element('name', nest: authorName);
        });
        builder.element('time', nest: startTimeValue);
      });
      // </metadata>
      // <trk>
      builder.element('trk', nest: () {
        builder.element('name', nest: (activityName != null ? activityName : startTimeValue));
        builder.element('type', nest: 9);
        // <trkseg>
        builder.element(
          'trkseg',
          isSelfClosing: false,
          nest: () {
            if (items != null && items.isNotEmpty)
              // for (var item in items) _createTrackPointItem(builder, item);
              items.forEach((item) => _createTrackPointItem(builder, item));
            else
              return null;
          },
        );
        // </trkseg>
      });
      // </trk>
    });
    // </gpx>
  }

  /// Cria uma *tag* XML <*trkpt*> conforme o modelo de um arquivo *gpx*, onde:
  ///
  /// * [builder] : [XmlBuilder] onde sera criada a *tag*.
  /// * [item] : [TrackPoint] com os dados para criar a *tag*.
  void _createTrackPointItem(xml.XmlBuilder builder, TrackPoint item) {
    builder.element('trkpt', nest: () {
      builder.attribute('lon', item.lon);
      builder.attribute('lat', item.lat);
      builder.element('ele', nest: item.ele);
      builder.element('time', nest: item.adjustedTime.timeUtc);
      if (item.hr != null && item.hr.isNotEmpty) {
        builder.element('extensions', nest: () {
          builder.element('gpxtpx:TrackPointExtension', nest: () {
            builder.element('gpxtpx:hr', nest: item.hr);
          });
        });
      }
    });
  }
}
