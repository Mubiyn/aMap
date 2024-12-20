import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin MarkerFiltering on ChangeNotifier {
  final List<Marker> _allMarkers = [];
  List<Marker> _filteredMarkers = [];

  List<Marker> get filteredMarkers => _filteredMarkers;

  void initializeMarkers(List<Marker> markers) {
    _allMarkers.clear();
    _allMarkers.addAll(markers);
    _filteredMarkers = List.from(_allMarkers);
    notifyListeners();
  }

  void filterMarkers(String query) {
    if (query.isEmpty) {
      _filteredMarkers = List.from(_allMarkers);
    } else {
      _filteredMarkers = _allMarkers
          .where((marker) =>
              marker.infoWindow.title != null &&
              marker.infoWindow.title!
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
