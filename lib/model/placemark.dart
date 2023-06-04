import 'package:bird_tracker/model/species.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import '../utils/location_helper.dart';

part 'placemark.g.dart';

@embedded
class Placemark {
  int? id;
  DateTime? startDate;
  DateTime? endDate;
  double? latitude;
  double? longitude;
  String? description;
  List<Species>? species = [];

  Placemark({
    this.id,
    this.startDate,
    this.endDate,
    this.latitude,
    this.longitude,
    this.description,
    this.species,
  });

  static List<Placemark> fromMarkers(List<Marker> markers) {
    return markers.map((e) => Placemark.fromMarker(e, 1)).toList();
  }

  factory Placemark.fromMarker(Marker marker, int id) {
    return Placemark(
      id: id,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      latitude: marker.position.latitude,
      longitude: marker.position.longitude,
      description: marker.infoWindow.title,
    );
  }

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(id.toString()),
      position: LatLng(latitude!, longitude!),
      infoWindow: InfoWindow(
        title: description ?? 'Point ${(id ?? 0) + 1}',
      ),
      onTap: () => showMarkerInfo(id ?? 0),
    );
  }

  /// get duration in format hh:mm:ss - hh:mm:ss
  String get duration {
    if (startDate != null) {
      if (endDate == null) {
        return DateFormat('hh:mm:ss').format(startDate!);
      }
      return '${DateFormat('hh:mm:ss').format(startDate!)} - ${DateFormat('hh:mm:ss').format(endDate!)}';
    }
    return '';
  }

  String get durationWithDay {
    if (startDate != null) {
      if (endDate == null) {
        return DateFormat('dd.MM.yyyy HH:mm:ss').format(startDate!);
      }
      return '${DateFormat('dd.MM.yyyy HH:mm:ss').format(startDate!)} - ${DateFormat('HH:mm:ss').format(endDate!)}';
    }
    return '';
  }

  String get speciesString {
    /// return all species in format: species1, species2, species3
    /// if no species, return 'No species recorded'
    if (species != null) {
      if (species!.isNotEmpty) {
        return species!.map((e) => e.speciesString).join('\n');
      } else {
        return 'No species recorded';
      }
    } else {
      return 'No species recorded';
    }
  }

  @ignore
  LatLng get latLng {
    return LatLng(latitude!, longitude!);
  }
}

