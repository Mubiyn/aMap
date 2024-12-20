import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin LocationServices on ChangeNotifier {
  LatLng initCoordinates = const LatLng(55.7558, 37.6173);
  double initZoom = 12;

  LatLng? _currentLocation;
  LatLng get currentLocation => _currentLocation ?? initCoordinates;
  set currentLocation(LatLng val) {
    _currentLocation = val;
    notifyListeners();
  }

  Future<void> determineUserCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition();
    currentLocation = LatLng(position.latitude, position.longitude);
  }
}
