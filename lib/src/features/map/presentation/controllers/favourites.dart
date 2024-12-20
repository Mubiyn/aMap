import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_test/src/features/map/domain/model.dart';
import 'package:map_test/src/injection.dart';

mixin FavoritesManagement on ChangeNotifier {
  final List<Marker> _favoriteMarkers = [];
  List<Marker> get favoriteMarkers => _favoriteMarkers;

  void addToFavorites(Marker marker) {
    if (!_favoriteMarkers.contains(marker)) {
      _favoriteMarkers.add(marker);
      saveFavorites();
    }
  }

  void removeFromFavorites(Marker marker) {
    _favoriteMarkers.remove(marker);
    saveFavorites();
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
    notifyListeners();
  }

  Future<void> saveFavorites() async {
    final List<Map<String, dynamic>> markersMap =
        _favoriteMarkers.map((marker) => markerToMap(marker)).toList();

    await prefs.setString('favoriteMarkers', jsonEncode(markersMap));
  }
}
