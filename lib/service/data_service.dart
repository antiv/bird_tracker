import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/transect.dart';

/// Singleton data service class to hold data for the app



class DataService with ChangeNotifier{
  static final DataService _singleton = DataService._internal();

  factory DataService() {
    return _singleton;
  }

  SharedPreferences? prefs;

  initPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void setEmailPreference(String email) {
    prefs?.setString('email', email);
  }

  DataService._internal();

  Transect? transect;

  MapType? mapType;

  void setMapType(MapType? mapType) {
    this.mapType = mapType;
    notifyListeners();
  }

  /// Notify listeners
  void notify() {
    notifyListeners();
  }

  void setTransect(Transect? transect) {
    this.transect = transect;
    notifyListeners();
  }

  String? getEmailPreference() {
    return prefs?.getString('email');
  }
}