import 'dart:async';
import 'package:ciconia_tracker/configuration/constants.dart';
import 'package:ciconia_tracker/model/transect.dart';
import 'package:ciconia_tracker/service/data_service.dart';
import 'package:ciconia_tracker/service/isar_service.dart';
import 'package:ciconia_tracker/utils/location_helper.dart';
import 'package:ciconia_tracker/utils/ux_builder.dart';
import 'package:ciconia_tracker/widgets/app_menu.dart';
import 'package:ciconia_tracker/widgets/species_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
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

  // StreamSubscription<LocationData>? locationStream;

  final Completer<GoogleMapController> _completer = Completer();
  GoogleMapController? controller;
  Set<Marker> _markers = {};
// on below line we have specified camera position
  static const CameraPosition _kHome = CameraPosition(
    target: LatLng(44.8, 20.36),
    zoom: 14.4746,
  );

  // late final Set<Polyline>? _polyLines;

  ValueNotifier<bool> isOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    IsarService().init();
    // _polyLines = {
    //   Polyline(
    //       polylineId: const PolylineId('1'),
    //       points: transect?.points
    //               ?.map((e) => LatLng(e.latitude, e.longitude))
    //               .toList() ??
    //           [],
    //       color: Colors.red,
    //       width: 5)
    // };

    DataService().initPreferences();
    DataService().completer = _completer;
    DataService().controller = controller;
    _goToCurrentLocation();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  _goToCurrentLocation() async {
    _locationData = await location.getLocation();
      await goToCurrentLocation(_serviceEnabled ?? false, location,
          _locationData, controller, _completer);
  }

  _stopTransect() async {
    /// showTextInputDialog to enter transect name
    await showTextInputDialog(
        'Unesi naziv popisa', 'Naziv popisa', 'Popis od ${DateFormat('dd.MM.yyyy').format(DateTime.now())}', (name) {
      // _stopListener();
      transect?.endDate = DateTime.now();
      transect?.name = name;
      // transect?.points = _polyLines?.first.points
      //     .map((e) => Point()
      //   ..latitude = e.latitude
      //   ..longitude = e.longitude)
      //     .toList();
      /// close last marker if not closed
      if (transect?.markers?.isNotEmpty ?? false) {
        Placemark lastMarker = transect!.markers!.last;
        lastMarker.endDate ??= DateTime.now();
      }
      IsarService().updateTransect(transect!);
      transect = null;
      DataService().setTransect(null);
      setState(() {});
    });
  }

  _addMarker(LatLng? latLng) async {
    /// close last marker
    if (transect?.markers?.isNotEmpty ?? false) {
      Placemark lastMarker = transect!.markers!.last;
      lastMarker.endDate ??= DateTime.now();
    }
    /// open transect if not started
    if (transect == null) {
      _startTransect();
    }
    if (latLng == null) {
      /// get current location
      _locationData = await location.getLocation();
      latLng = LatLng(_locationData!.latitude!, _locationData!.longitude!);
    }
    showFullScreenDialog(SpeciesForm(
      onSaved: (species, close) {
        setState(() {
          transect?.markers = transect?.markers?.toList(growable: true) ?? [];
          /// Find last marker
          /// if this marker is not closed, add species to it
          /// else create new marker
          if (transect?.markers?.isNotEmpty ?? false) {
            Placemark lastMarker = transect!.markers!.last;
            if (lastMarker.endDate == null) {
              lastMarker.species = species;
              IsarService().updateTransect(transect!);
              return;
            } else {
              transect?.markers?.add(
                Placemark(
                  latitude: latLng?.latitude,
                  longitude: latLng?.longitude,
                  startDate: DateTime.now(),
                  endDate: null,
                  id: transect?.markers?.length ?? 0,
                  species: species,
                ),
              );
            }
          } else {
            transect?.markers?.add(
              Placemark(
                latitude: latLng?.latitude,
                longitude: latLng?.longitude,
                startDate: DateTime.now(),
                endDate: null,
                id: transect?.markers?.length ?? 0,
                species: species,
              ),
            );
          }
        });
        _goToCurrentLocation();
        IsarService().updateTransect(transect!);
      },
    ));
  }

  _startTransect() async {
    if (transect != null) {
      /// ask to continue or open new transect
      showYesNoDialog(() {
        // _startListener();
      }, () {
        _startNewTransect();
      },
          title: 'Continue transect or start new one?',
          yesText: 'Continue',
          noText: 'New transect'
      );
    } else {
      _startNewTransect();
    }
  }

  _startNewTransect() {
    transect = Transect()
      ..startDate = DateTime.now()
      // ..points = List<Point>.empty(growable: true)
      ..markers = List<Placemark>.empty(growable: true);
    DataService().setTransect(transect);
    /// insert transect to db
    IsarService().addTransect(transect!);
    // _startListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F9D58),
        title: const Text(kAppTitle, style: TextStyle(color: Colors.white)),
        leading: InkWell(
          onTap: () {
            _key.currentState!.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              kAppIcon,
              fit: BoxFit.scaleDown,
              semanticsLabel: 'Ciconia Logo',
              // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
      drawer: const Drawer(
        child: AppMenu(),
      ),
      body: SafeArea(
        // on below line creating google maps
        child: Consumer<DataService>(builder: (context, dataService, _) {
          debugPrint(
              '============================================= reBuild =============================================');
          transect = dataService.transect;
          // _polyLines?.first.points.clear();
          // _polyLines?.first.points.addAll(transect?.points
          //         ?.map((e) => LatLng(e.latitude, e.longitude))
          //         .toList() ??
          //     []);
          _markers = Set<Marker>.of(
              transect?.markers?.map((e) => e.toMarker()) ?? []);
          return GoogleMap(
            key: const Key('map'),
            // on below line setting camera position
            initialCameraPosition: _kHome,
            // on below line we are setting markers on the map
            markers: _markers,
            // polylines: _polyLines ?? {},
            // on below line specifying map type.
            mapType: dataService.mapType ?? MapType.normal,
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
              _completer.complete(controller);
              DataService().controller = controller;
              setState(() {
                _markers = Set<Marker>.of(
                    transect?.markers?.map((e) => e.toMarker()) ?? []);
              });
            },
            onLongPress: (LatLng latLng) {
              _addMarker(latLng);
            },
          );
        }),
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
                  transect != null ? Colors.red.shade700 : null,
              activeIcon: Icons.close,
              spacing: 3,
              mini: false,
              childPadding: const EdgeInsets.all(5),
              spaceBetweenChildren: 4,
              direction: SpeedDialDirection.down,
              renderOverlay: false,
              onOpen: () {
                setState(() {
                  if (transect == null) {
                    isOpen.value = false;
                    _startTransect();
                  }
                });
              },
              onClose: () {
                setState(() {});
              },
              children: [
                // SpeedDialChild(
                //   child: const Icon(Icons.pause),
                //   backgroundColor: Colors.red.shade700,
                //   foregroundColor: Colors.white,
                //   label: 'Pause',
                //   onTap: () async {
                //     await _pauseListener();
                //     setState(() {});
                //   },
                // ),
                SpeedDialChild(
                  child: const Icon(Icons.stop),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  label: 'Stop',
                  onTap: () async {
                    await _stopTransect();
                  },
                ),
              ],
            ),
            SizedBox(height: isOpen.value ? 130 : 10),
            FloatingActionButton(
                onPressed: () => _addMarker(null),
                backgroundColor: Colors.orangeAccent,
                child: const Icon(Icons.add_location_alt_outlined)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
