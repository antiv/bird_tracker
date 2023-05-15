import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:bird_tracker/service/data_service.dart';
import 'package:bird_tracker/utils/ux_builder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../widgets/marker_info.dart';

goToCurrentLocation(
    bool serviceEnabled,
    Location location,
    LocationData? locationData,
    GoogleMapController? controller,
    Completer<GoogleMapController> completer) async {
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  locationData = await location.getLocation();

  // specified current users location
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(locationData.latitude!, locationData.longitude!),
    zoom: 16,
  );
  enableBackgroundMode(location);

  /// if controller is not initialized, wait for it
  // if (!_controller.isCompleted) {
  //   controller = await _controller.future;
  // }
  controller ??= await completer.future;
  controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  // });
}

Future<bool> enableBackgroundMode(
  Location location,
) async {
  bool bgModeEnabled = await location.isBackgroundModeEnabled();
  if (bgModeEnabled) {
    return true;
  } else {
    try {
      await location.enableBackgroundMode();
    } catch (e) {
      log('====================================================${e.toString()}====================================================');
    }
    try {
      bgModeEnabled = await location.enableBackgroundMode();
    } catch (e) {
      log('====================================================${e.toString()}====================================================');
    }
    log('=============================================$bgModeEnabled================================================='); //True!
    return bgModeEnabled;
  }
}

Marker getNewMarker(String id, LocationData locationData, Function onTap) {
  return Marker(
    markerId: MarkerId(id),
    position: LatLng(locationData.latitude!, locationData.longitude!),
    infoWindow: InfoWindow(title: 'Point $id'),
    icon: BitmapDescriptor.defaultMarker,
    //BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    onTap: () => onTap(id),
  );
}

void showMarkerInfo(int index) {
  final selected =
      DataService().transect?.markers?.firstWhere((m) => m.id == index);
  showBottomModal(MarkerInfo(selected: selected));
}

double calculateDistance(List<LatLng> polyline) {
  double totalDistance = 0;
  for (int i = 0; i < polyline.length; i++) {
    if (i < polyline.length - 1) {
      // skip the last index
      totalDistance += getStraightLineDistance(
          polyline[i + 1].latitude,
          polyline[i + 1].longitude,
          polyline[i].latitude,
          polyline[i].longitude);
    }
  }
  return totalDistance;
}

double getStraightLineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the earth in km
  final dLat = deg2rad(lat2 - lat1);
  final dLon = deg2rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(deg2rad(lat1)) *
          math.cos(deg2rad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  final d = R * c; // Distance in km
  return d;
}

dynamic deg2rad(deg) {
  return deg * (math.pi / 180);
}

getTimeDifference(DateTime? startDate, DateTime? endDate) {
  if (startDate == null || endDate == null) {
    return '';
  }
  final difference = endDate.difference(startDate);
  return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
}

String convertLatLng(double decimal, bool isLat) {
  String degree = "${decimal.toString().split(".")[0]}°";
  double minutesBeforeConversion =
      double.parse("0.${decimal.toString().split(".")[1]}");
  String minutes =
      "${(minutesBeforeConversion * 60).toString().split('.')[0]}'";
  double secondsBeforeConversion = double.parse(
      "0.${(minutesBeforeConversion * 60).toString().split('.')[1]}");
  String seconds =
      '${double.parse((secondsBeforeConversion * 60).toString()).toStringAsFixed(2)}" ';
  String dmsOutput =
      "${isLat ? decimal > 0 ? 'N' : 'S' : decimal > 0 ? 'E' : 'W'} $degree $minutes $seconds";
  return dmsOutput;
}
