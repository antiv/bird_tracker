import 'dart:typed_data';

import 'package:bird_tracker/model/placemark.dart';
import 'package:bird_tracker/model/point.dart';
import 'package:bird_tracker/model/species.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/location_helper.dart';

part 'transect.g.dart';

@collection
class Transect {
  Id id = Isar.autoIncrement;
  late DateTime startDate;
  DateTime? endDate;
  String? description;
  List<Point>? points;
  List<Placemark>? markers;

  void addMarker(Placemark marker) {
    markers?.add(marker);
  }

  void updateMarker(Placemark marker) {
    markers?[markers!.indexWhere((element) => element.id == marker.id)] =
        marker;
  }

  void deleteMarker(Placemark marker) {
    markers?.remove(marker);
  }

  String get duration {
    if (endDate != null) {
      final duration = endDate!.difference(startDate);
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
    }
    return '';
  }

  double get distance {
    if (points != null) {
      return calculateDistance(points!.map((e) => e.latLng).toList());
    }
    return 0;
  }

  /// distance in KM, m
  String get distanceString {
    return '${distance.toStringAsFixed(2)} km';
  }

  /// get the total number of species recorded
  int get speciesCount {
    if (markers != null) {
      return markers!.length;
    }
    return 0;
  }

  /// get from - to date in format dd.mm.yyyy hh:mm - hh:mm
  String get dateRange {
    /// if same day return end in hh:mm format
    if (startDate.year == endDate?.year &&
        startDate.month == endDate?.month &&
        startDate.day == endDate?.day) {
      return '${DateFormat('dd.MM.yyyy hh:mm:ss').format(startDate)} - ${DateFormat('hh:mm:ss').format(endDate!)}';
    } else if (endDate != null) {
      return '${DateFormat('dd.MM.yyyy hh:mm:ss').format(startDate)} - ${DateFormat('dd.MM.yyyy hh:mm:ss').format(endDate!)}';
    }

    /// start date only
    return DateFormat('dd.MM.yyyy hh:mm:ss').format(startDate);
  }

  /// convert transect to CSV
  String toCSV() {
    final sb = StringBuffer();
    sb.writeln(
        'Specie,Date, Time (from - to), Latitude(DMS),Longitude(DMS),Count, Comment, Stratification, Direction');
    markers?.forEach((placeMark) {
      placeMark.species?.forEach((species) {
        sb.writeln('${species.species},'
            '${DateFormat('dd/MM/yyyy').format(placeMark.startDate!)},'
            '${placeMark.duration},'
            '${convertLatLng(placeMark.latitude!, true)},${convertLatLng(placeMark.longitude!, false)},'
            '${species.count},'
            '${species.description ?? ''},'
            '${species.stratification.toString().split('.').last},'
            '${species.direction.toString().split('.').last}');
      });
    });
    return sb.toString();
  }

  /// share transect as CSV file
  Future<void> shareCSV() async {
    Uint8List? bytes = Uint8List.fromList(toCSV().codeUnits);
    await Share.shareXFiles(
      [
        XFile.fromData(bytes,
            mimeType: 'text/csv',
            name: 'transect-${DateFormat('dd/MM/yyyy').format(startDate)}.csv'),
      ],
      text: 'Transect ${DateFormat('dd/MM/yyyy').format(startDate)}',
      subject: 'Transect ${DateFormat('dd/MM/yyyy').format(startDate)}',
    );
  }
}
