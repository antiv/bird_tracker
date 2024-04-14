import 'dart:convert';
import 'dart:typed_data';

import 'package:ciconia_tracker/model/placemark.dart';
import 'package:ciconia_tracker/model/species.dart';
import 'package:ciconia_tracker/utils/kml_utils.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:share_plus/share_plus.dart';

import '../service/data_service.dart';
import '../utils/file_utils.dart';
import '../utils/location_helper.dart';

part 'transect.g.dart';

@collection
class Transect {
  Id id = Isar.autoIncrement;
  late DateTime startDate;
  String? name;
  DateTime? endDate;
  String? description;
  // List<Point>? points;
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
  /// get duration in format hh:mm:ss - hh:mm:ss
  String get fromTo {
      if (endDate == null) {
        return DateFormat('hh:mm:ss').format(startDate);
      }
      return '${DateFormat('hh:mm:ss').format(startDate)} - ${DateFormat('hh:mm:ss').format(endDate!)}';
  }

  // double get distance {
  //   if (points != null) {
  //     return calculateDistance(points!.map((e) => e.latLng).toList());
  //   }
  //   return 0;
  // }

  /// distance in KM, m
  // String get distanceString {
  //   return '${distance.toStringAsFixed(2)} km';
  // }

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
    String name = DataService().getNamePreference() ?? '';
    String email = DataService().getEmailPreference() ?? '';
    String phone = DataService().getPhonePreference() ?? '';
    final sb = StringBuffer();
    sb.writeln(
        'Datum obilaska, Vreme, Latitude(DMS), Longitude(DMS), Polozaj gnezda, Stanje u gnezdu, Broj mladunaca, Atlas kod, Mesto, Opstina, Napomena, Popisivac, Email, Telefon');
    markers?.forEach((placeMark) {
      // placeMark.species?.forEach((species) {
        sb.writeln(
            '${DateFormat('dd/MM/yyyy').format(placeMark.startDate!)},'
            '${placeMark.species?.time},'
            '${convertLatLng(placeMark.latitude!, true)},'
            '${convertLatLng(placeMark.longitude!, false)},'
            '"${placeMark.species?.position}",'
            '"${placeMark.species?.state}",'
            '${placeMark.species?.count},'
            '${placeMark.species?.code ?? ''},'
            '"${placeMark.species?.place ?? ''}",'
            '"${placeMark.species?.municipality ?? ''}",'
            '"${placeMark.species?.description ?? ''}",'
            '"$name",'
            '"$email",'
            '"$phone"'
            );
      // });
    });
    return sb.toString();
  }

  /// convert transect to KML
  String toKML() {
    return KMLUtils.generateKML(this);
  }


  /// share transect as CSV file
  Future<void> shareCSV() async {
    Uint8List? bytes = Uint8List.fromList(utf8.encode(toCSV()));
    String path = await storeFileTemporarily(bytes, '$name-${DateFormat('dd-MM-yyyy').format(startDate)}.csv');
    await Share.shareXFiles(
      [
        XFile(path)
      ],
      text: '$name ${DateFormat('dd/MM/yyyy').format(startDate)}',
      subject: '$name ${DateFormat('dd/MM/yyyy').format(startDate)}',
    );
  }

  /// share transect as KML file
  Future<void> shareKML() async {
    Uint8List? bytes = Uint8List.fromList(utf8.encode(toKML()));
    String path = await storeFileTemporarily(bytes, '$name-${DateFormat('dd-MM-yyyy').format(startDate)}.kml');

    await Share.shareXFiles(
      [
        XFile(path)
      ],
      text: '$name ${DateFormat('dd/MM/yyyy').format(startDate)} as KML',
      subject: '$name ${DateFormat('dd/MM/yyyy').format(startDate)} as KML',
    );
  }

  void goToFirst() {
    // if (points?.isNotEmpty ?? false) {
    //   goToLocation(
    //       points!.first.latLng, DataService().controller,
    //       DataService().completer
    //   );
    // } else {
      if (markers?.isNotEmpty ?? false) {
        goToLocation(
            markers!.first.latLng, DataService().controller,
            DataService().completer
        );
      }
    // }
  }
}
