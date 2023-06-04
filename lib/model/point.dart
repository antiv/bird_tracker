import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:isar/isar.dart';

part 'point.g.dart';

@embedded
class Point {
  late double latitude;
  late double longitude;

  @ignore
  LatLng get latLng => LatLng(latitude, longitude);
}