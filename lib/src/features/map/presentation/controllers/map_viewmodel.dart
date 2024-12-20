import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_test/src/features/map/data/service.dart';
import 'package:map_test/src/features/map/domain/model.dart';
import 'package:map_test/src/injection.dart';
import 'package:map_test/src/shared/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapViewModel extends ChangeNotifier {
  //Variables
  final prefs = locator<SharedPreferences>();
  final geoService = locator<IGeolocatingApiService>();

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    Timer(const Duration(milliseconds: 10), () => notifyListeners());
  }

  String _error = 'Something went wrong\nTry again later';
  String get error => _error;
  set error(String val) {
    _error = val;
    notifyListeners();
  }

  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError(bool error) {
    _hasError = error;
    notifyListeners();
  }

  //Map Setup
  double initZoom = 12;
  LatLng initCoordinates = const LatLng(55.7558, 37.6173);
  final Completer<GoogleMapController> controller = Completer();
  GoogleMapController? _newGoogleMapController;
  GoogleMapController? get newGoogleMapController => _newGoogleMapController;
  set newGoogleMapController(GoogleMapController? controller) {
    _newGoogleMapController = controller;
    notifyListeners();
  }

  String _mapStyle = lightMapMode;
  String get mapStyle => _mapStyle;
  set mapStyle(String val) {
    _mapStyle = val;
    Timer(const Duration(milliseconds: 10), () => notifyListeners());
  }

  MapType _currentMapType = MapType.normal;
  MapType get currentMapType => _currentMapType;
  void setMapType(MapType mapType) {
    _currentMapType = mapType;
    notifyListeners();
  }

  double _pinMargin = 0;
  double get pinMargin => _pinMargin;
  set pinMargin(double val) {
    _pinMargin = val;
    notifyListeners();
  }

  void updatePinMargin() {
    if (pinMargin == 0) {
      pinMargin = 20;
    } else {
      pinMargin = 0;
    }
  }

//Geolocation
  String _userAddress = 'Default Address';
  String get userAddress => _userAddress;
  set userAddress(String val) {
    _userAddress = val;
    Timer(const Duration(milliseconds: 10), () => notifyListeners());
  }

  LatLng? _value;
  LatLng get value => _value ?? initCoordinates;
  set value(LatLng val) {
    _value = val;
    Timer(const Duration(milliseconds: 10), () => notifyListeners());
  }

  //when map moves
  Future<void> getNewAddressWhenMapMoves() async {
    List<Placemark> placemarks = [];
    try {
      placemarks =
          await placemarkFromCoordinates(value.latitude, value.longitude);
    } catch (e) {
      error = 'Something went wrong\nTry again later';
      hasError = true;
    }
    userAddress = placemarks.first.subAdministrativeArea!.split(' ').first;
    userAddress =
        '${placemarks.last.administrativeArea}, ${placemarks.first.street}, ${placemarks.last.subAdministrativeArea}';
    saveLocation();
    notifyListeners();
  }

  Future<LatitudeLongitude?> getCoordinatesFromAddress(String address) async {
    final result = await geoService.coordinatesFromAddress(address);
    if (result == null) {
      return null;
    }
    return result;
  }

  determineUserCurrentPosition() async {
    final Position position;
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    loading = true;
    position = await Geolocator.getCurrentPosition();
    value = LatLng(position.latitude, position.longitude);
    _addDummyMarkersNearUser(value);
    return await getNewAddressWhenMapMoves();
  }

  Future<void> getLastLocation() async {
    mapStyle = settingsController.themeMode == ThemeMode.dark
        ? darkMapStyle
        : lightMapMode;
    final location = prefs.getString('location') ?? '';
    if (location.isNotEmpty) {
      final locationData = location.split('%');
      userAddress = locationData[0];
      value =
          LatLng(double.parse(locationData[1]), double.parse(locationData[2]));
    }
  }

  Future<void> saveLocation() async {
    await prefs.setString(
      'location',
      '$userAddress%${value.latitude}%${value.longitude}',
    );
  }

  ///Markers
  final List<Marker> _allMarkers = [];
  List<Marker> _filteredMarkers = [];
  List<Marker> get filteredMarkers => _filteredMarkers;
  // Favorite Points Management
  final List<Marker> _favoriteMarkers = []; // Saved favorite markers
  List<Marker> get favoriteMarkers => _favoriteMarkers;
  // Search functionality
  void filterMarkers(String query) {
    if (query.isEmpty) {
      _filteredMarkers = List.from(_allMarkers); // Show all markers
    } else {
      _filteredMarkers = _allMarkers
          .where((marker) =>
              marker.infoWindow.title != null &&
              marker.infoWindow.title!
                  .toLowerCase()
                  .startsWith(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void initializeMarkers(List<Marker> markers) {
    _allMarkers.clear();
    _allMarkers.addAll(markers);
    _filteredMarkers = List.from(_allMarkers);
    loading = false;
    notifyListeners();
  }

  void _addDummyMarkersNearUser(LatLng userLocation) {
    loading = true;
    final List<Marker> dummyMarkers = [];
    const int numberOfMarkers = 10;
    const double offsetRange = 0.01; // Range to generate nearby lat/lng offsets
    for (int i = 0; i < numberOfMarkers; i++) {
      final double latOffset =
          (i % 2 == 0 ? 1 : -1) * (i + 1) * offsetRange * 0.5;
      final double lngOffset =
          (i % 3 == 0 ? 1 : -1) * (i + 1) * offsetRange * 0.5;
      final LatLng markerPosition = LatLng(
        userLocation.latitude + latOffset,
        userLocation.longitude + lngOffset,
      );
      dummyMarkers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: markerPosition,
          infoWindow: InfoWindow(
            title: dummyTitles[i],
            snippet:
                'Lat: ${markerPosition.latitude}; Lng: ${markerPosition.longitude}',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    initializeMarkers(dummyMarkers);
  }

//Favourites
  void addToFavorites(Marker marker) {
    if (!_favoriteMarkers.contains(marker)) {
      _favoriteMarkers.add(marker);
      saveFavorites();
      notifyListeners();
    }
  }

  void removeFromFavorites(Marker marker) {
    _favoriteMarkers.remove(marker);
    saveFavorites();
    notifyListeners();
  }

  bool isFavorite(Marker marker) {
    return _favoriteMarkers.contains(marker);
  }

  Future<void> loadFavorites() async {
    final favoriteTitles = prefs.getString('favoriteMarkers') ?? '';
    _favoriteMarkers.clear();
    if (favoriteTitles.isNotEmpty) {
      final listOfMarkers = jsonDecode(favoriteTitles);
      _favoriteMarkers.addAll(
        (listOfMarkers as List<dynamic>).map((e) => markerFromMap(e)).toList(),
      );
    }
  }

  Future<void> saveFavorites() async {
    final List<Map<String, dynamic>> markersMap =
        _favoriteMarkers.map((marker) => markerToMap(marker)).toList();

    await prefs.setString('favoriteMarkers', jsonEncode(markersMap));
    loadFavorites();
  }

  void disposeValues() {
    _loading = false;
    error = 'Something went wrong\nTry again later';
  }
}
