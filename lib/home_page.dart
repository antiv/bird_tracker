import 'dart:async';
import 'package:bird_tracker/configuration/constants.dart';
import 'package:bird_tracker/model/point.dart';
import 'package:bird_tracker/model/transect.dart';
import 'package:bird_tracker/service/data_service.dart';
import 'package:bird_tracker/service/isar_service.dart';
import 'package:bird_tracker/utils/location_helper.dart';
import 'package:bird_tracker/utils/ux_builder.dart';
import 'package:bird_tracker/widgets/app_menu.dart';
import 'package:bird_tracker/widgets/species_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'model/placemark.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  Location location = Location();
  Transect? transect = DataService().transect;

  bool? _serviceEnabled;
  LocationData? _locationData;

  StreamSubscription<LocationData>? locationStream;

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? completer;
// on below line we have specified camera position
  static const CameraPosition _kHome = CameraPosition(
    target: LatLng(44.8, 20.36),
    zoom: 14.4746,
  );

  late final Set<Polyline>? _polyLines;

  ValueNotifier<bool> isOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    IsarService().init();
    _polyLines = {Polyline(polylineId: const PolylineId('1'), points: transect?.points?.map((e) => LatLng(e.latitude, e.longitude)).toList() ?? [], color: Colors.red, width: 5)};
    _goToCurrentLocation();
    DataService().initPreferences();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  _goToCurrentLocation() async {
    if (locationStream != null) {
      await _stopListener();
      await goToCurrentLocation(_serviceEnabled ?? false, location, _locationData,
          completer, _controller);
      await _startListener();
    } else {
      await goToCurrentLocation(_serviceEnabled ?? false, location, _locationData,
          completer, _controller);
    }

  }

  onLocationChange(LocationData currentLocation) {
    setState(() {
      _locationData = currentLocation;
      // points.add(LatLng(_locationData!.latitude!, _locationData!.longitude!));
      _polyLines?.add(Polyline(
          polylineId: const PolylineId('1'),
          points: _polyLines?.first.points ?? []..add(LatLng(_locationData!.latitude!, _locationData!.longitude!)),
          color: Colors.red,
          width: 5));
      transect?.points = transect?.points?.toList(growable: true) ?? [];
      transect?.points?.add(Point()
        ..latitude = _locationData!.latitude!
        ..longitude = _locationData!.longitude!);
      /// get current camera zum
      completer?.getZoomLevel().then((value) {
        /// change camera position
        CameraPosition cameraPosition = CameraPosition(
          target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
          zoom: value,
        );
        completer
            ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      });
    });
  }

  _startListener() async {
    if (locationStream == null) {
      location.changeSettings(
          accuracy: LocationAccuracy.high, interval: 1000, distanceFilter: 10);
      isOpen.value = false;
      locationStream =
          location.onLocationChanged.listen((LocationData currentLocation) {
            onLocationChange(currentLocation);
          });
    }
  }

  _pauseListener() async {
    // locationStream?.pause();
    /// Save transect with points and markers
    // transect?.markers = Placemark.fromMarkers(_markers);
    transect?.points = _polyLines?.first.points.map((e) => Point()..latitude = e.latitude..longitude = e.longitude).toList();
    await IsarService().updateTransect(transect!);
    _stopListener();
  }

  _stopListener() async {
    locationStream?.cancel();
    locationStream = null;
  }

  _stopTransect() async {
    /// Ask for confirmation
    showYesNoDialog(() async {
      _stopListener();
      transect?.endDate = DateTime.now();
      // transect?.markers = Placemark.fromMarkers(_markers);
      transect?.points = _polyLines?.first.points.map((e) => Point()..latitude = e.latitude..longitude = e.longitude).toList();
      await IsarService().updateTransect(transect!);
      transect = null;
      DataService().setTransect(null);
    }, () {});

  }

  _addMarker() {
    showFullScreenDialog(SpeciesForm(onSaved: (species) {
      setState(() {
        transect?.markers = transect?.markers?.toList(growable: true) ?? [];
        transect?.markers?.add(
          Placemark(
            latitude: _locationData!.latitude!,
            longitude: _locationData!.longitude!,
            startDate: DateTime.now(),
            id: transect?.markers?.length ?? 0,
            species: [species],
          ),
        );
      });
      _goToCurrentLocation();
    },));
  }

  _startTransect() async {
    if (transect != null) {
      _startListener();
    } else {
      // _markers.clear();
      // points.clear();
      transect = Transect()
        ..startDate = DateTime.now()
        ..points = List<Point>.empty(growable: true)
        ..markers = List<Placemark>.empty(growable: true);
      DataService().setTransect(transect);
      /// insert transect to db
      await IsarService().addTransect(transect!);
      _startListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F9D58),
        title: const Text(kAppTitle),
        leading: InkWell(
          onTap: () {
            _key.currentState!.openDrawer();
          },
          child: SvgPicture.asset(
            kAppIcon,
            semanticsLabel: 'Bird Tracker Logo',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
      drawer: const Drawer(
        child: AppMenu(),
      ),
      body: SafeArea(
        // on below line creating google maps
        child: Consumer<DataService>(builder: (context, dataService, _) {
          debugPrint('============================================= reBuild =============================================');
          transect = dataService.transect;
          _polyLines?.first.points.clear();
          _polyLines?.first.points.addAll(transect?.points?.map((e) => LatLng(e.latitude, e.longitude)).toList() ?? []);
          return GoogleMap(
              // on below line setting camera position
              initialCameraPosition: _kHome,
              // on below line we are setting markers on the map
              markers: Set<Marker>.of(transect?.markers?.map((e) => e.toMarker()) ?? []),
              polylines: _polyLines ?? {},
              // on below line specifying map type.
              mapType: dataService.mapType ?? MapType.hybrid,
              // on below line setting user location enabled.
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              // on below line setting compass enabled.
              compassEnabled: true,
              // on below line setting zoom controls enabled.
              zoomControlsEnabled: true,
              // on below line setting map toolbar enabled.
              mapToolbarEnabled: true,
              // on below line setting traffic enabled
              trafficEnabled: false,
              // on below line setting buildings enabled.
              buildingsEnabled: false,
              indoorViewEnabled: false,
              // on below line specifying controller on map complete.
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            );
          }
        ),
      ),
      // on pressing floating action button the camera will take to user current location
      floatingActionButton: Padding(
        padding: EdgeInsets.only(

            /// Calculate position somehow
            top: (Theme.of(context).appBarTheme.toolbarHeight ?? 56) +
                150 +
                (isOpen.value ? 130 : 10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
                onPressed: _goToCurrentLocation,
                backgroundColor: Colors.grey.shade400,
                child: const Icon(Icons.location_searching)),
            const SizedBox(height: 10),
            SpeedDial(
              openCloseDial: isOpen,
              icon: Icons.directions_walk,
              backgroundColor:
                  locationStream != null ? Colors.red.shade700 : null,
              activeIcon: Icons.close,
              spacing: 3,
              mini: false,
              childPadding: const EdgeInsets.all(5),
              spaceBetweenChildren: 4,
              direction: SpeedDialDirection.down,
              renderOverlay: false,
              onOpen: () {
                setState(() {
                  if (locationStream == null) {
                    isOpen.value = false;
                    _startTransect();
                  }
                });
              },
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.pause),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  label: 'Pause',
                  onTap: () async {
                    await _pauseListener();
                    setState(() {});
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.stop),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  label: 'Stop',
                  onTap: () async {
                    await _stopTransect();
                    setState(() {});
                  },
                ),
              ],
            ),
            SizedBox(height: isOpen.value ? 130 : 10),
            FloatingActionButton(
                onPressed: locationStream != null ? _addMarker : () => showSnackBar('Start transect first'),
                backgroundColor: Colors.orangeAccent,
                child: const Icon(Icons.add_location_alt_outlined)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
