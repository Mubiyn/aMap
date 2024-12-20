import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_test/src/shared/strings.dart';

mixin MapManagement on ChangeNotifier {
  final Completer<GoogleMapController> controller = Completer();
  GoogleMapController? _newGoogleMapController;

  GoogleMapController? get newGoogleMapController => _newGoogleMapController;
  set newGoogleMapController(GoogleMapController? controller) {
    _newGoogleMapController = controller;
    notifyListeners();
  }

  MapType _currentMapType = MapType.normal;
  MapType get currentMapType => _currentMapType;

  String _mapStyle = lightMapMode;
  String get mapStyle => _mapStyle;

  set mapStyle(String val) {
    _mapStyle = val;
    Timer(const Duration(milliseconds: 10), () => notifyListeners());
  }

  void setMapType(MapType mapType) {
    _currentMapType = mapType;
    notifyListeners();
  }

  void updateMapStyle(String style) {
    _mapStyle = style;
    notifyListeners();
  }
}
