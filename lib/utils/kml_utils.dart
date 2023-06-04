/// Class to create .kml file from a transect, using xml package

import 'package:bird_tracker/model/species.dart';
import 'package:bird_tracker/model/transect.dart';
import 'package:xml/xml.dart';

import '../model/placemark.dart';
import '../model/point.dart';

class KMLUtils {
  static final KMLUtils _singleton = KMLUtils._internal();

  factory KMLUtils() {
    return _singleton;
  }

  KMLUtils._internal();

  static String generateKML(Transect transect) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('kml', nest: () {
      builder.attribute('xmlns', 'http://www.opengis.net/kml/2.2');
      builder.element('Document', nest: () {
        builder.element('name', nest: () {
          builder.text('Transect ${transect.startDate}');
        });
        builder.element('description', nest: () {
          builder.text('Transect ${transect.description}');
        });
        builder.element('Style', nest: () {
          builder.attribute('id', 'redLineRedPoly');
          builder.element('LineStyle', nest: () {
            builder.element('color', nest: () {
              builder.text('ff0051e6');
            });
            builder.element('width', nest: () {
              builder.text('4');
            });
          });
          builder.element('PolyStyle', nest: () {
            builder.element('color', nest: () {
              builder.text('ff9C1E13');
            });
          });
        });

        /// placemark style for markers
        builder.element('Style', nest: () {
          builder.attribute('id', 'markerPlacemark');
          builder.element('IconStyle', nest: () {
           builder.element('Color', nest: () {
              builder.text('ff0051e6');
            });
            builder.element('scale', nest: () {
              builder.text('1.0');
            });
          });
        });

        /// add placemarks from transect.markers
        transect.markers?.forEach((marker) {
          builder.element('Placemark', nest: () {
            builder.attribute('id', 'marker${marker.id}');
            builder.element('styleUrl', nest: () {
              builder.text('#markerPlacemark');
            });
            builder.element('name', nest: () {
              builder.text('Point ${marker.id! + 1}');
            });
            builder.element('description', nest: () {
              // builder.text('<![CDATA[  ${marker.speciesString ?? ''} ]]>');
              builder.text(marker.speciesString);
            });
            builder.element('Point', nest: () {
              builder.element('coordinates', nest: () {
                builder.text('${marker.longitude},${marker.latitude}');
              });
            });
          });
        });

        /// add path from transect.points
        builder.element('Placemark', nest: () {
          builder.element('name', nest: () {
            builder.text('Path');
          });
          builder.element('description', nest: () {
            builder.text('Path of transect');
          });
          builder.element('styleUrl', nest: () {
            builder.text('#redLineRedPoly');
          });
          builder.element('LineString', nest: () {
            builder.element('tessellate', nest: () {
              builder.text('1');
            });
            builder.element('coordinates', nest: () {
              builder.text(transect.points
                      ?.map((e) => '${e.longitude},${e.latitude},0')
                      .join(' ') ??
                  '');
            });
          });
        }); // end document
      }); // end kml
    });
    return builder.buildDocument().toXmlString(pretty: true, indent: '\t');
  }

  Transect kmlToTransect(String kml, DateTime fileDate) {
    final document = XmlDocument.parse(kml);
    final transect = Transect();
    transect.startDate = fileDate;
    final markers = <Placemark>[];
    final points = <Point>[];
    final placemarks = document.findAllElements('Placemark');
    for (final placemark in placemarks) {
      /// Find markers
      final point = placemark.findElements('Point');
      if (point.isNotEmpty) {
        final coordinates = point.first.findElements('coordinates').first.innerText;
        final pointString = coordinates.split(',');
        final desc = placemark.findElements('description');
        final species = desc.isNotEmpty ? desc.first.innerText : null;
        markers.add(Placemark()
          ..id = markers.length
          ..latitude = double.parse(pointString[1])
          ..longitude = double.parse(pointString[0])
          ..description = species?.split('<br/>').join('\n')
          ..species = getSpeciesFromDescription(species));
      }
      /// Find path
      final lineString = placemark.findElements('LineString');
      if (lineString.isNotEmpty) {
        final coord = lineString.first.findElements('coordinates');
        final coordinates = coord.isNotEmpty ? coord.first.innerText : '';
        final pointsString = coordinates.split(' ');
        for (final pointString in pointsString) {
          final point = pointString.trim().split(',');
          if (point.length < 2) {
            continue;
          }
          points.add(Point()
            ..latitude = double.parse(point[1])
            ..longitude = double.parse(point[0]));
        }
      }

    }
    transect.markers = markers;
    transect.points = points;
    return transect;
  }

  List<Species>? getSpeciesFromDescription(String? description) {
    if (description == null) {
      return null;
    }
    final species = description.split('\n');
    if (species.isEmpty) {
      return null;
    } else {
      /// return Species().listFromString(species) and remove nulls
      return Species().listFromString(species)?.toList();
    }
  }
}
