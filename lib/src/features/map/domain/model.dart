import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacePredictions {
  String? secondarytext;
  String? maintext;
  String? placeID;
  String? description;

  PlacePredictions({
    this.maintext,
    this.placeID,
    this.secondarytext,
    this.description,
  });

  PlacePredictions.fromJson(Map<String, dynamic> json) {
    placeID = json['place_id'];
    maintext = json['structured_formatting']['main_text'];
    secondarytext = json['structured_formatting']['secondary_text'];
    description = json['description'];
  }
}

class LatitudeLongitude {
  double? latitude;
  double? longitude;

  LatitudeLongitude({this.latitude, this.longitude});

  LatitudeLongitude.fromJson(Map<String, dynamic> json) {
    latitude = json['location']['lat'];
    longitude = json['location']['lng'];
  }

  @override
  toString() {
    return 'latitude: $latitude, longitude: $longitude';
  }
}

class DirectionDetails {
  int? distanceValue;
  int? duration;
  String? distanceText;
  String? durationText;
  String? encodedPoints;

  DirectionDetails(
      {this.distanceValue,
      this.duration,
      this.distanceText,
      this.durationText,
      this.encodedPoints});

  @override
  toString() {
    return 'distance: $distanceValue, duration: $duration, distance Text: $distanceText, duration Text: $durationText, encoded Points: $encodedPoints';
  }
}

Map<String, dynamic> markerToMap(Marker marker) {
  return {
    'markerId': marker.markerId.value,
    'alpha': marker.alpha,
    'anchor': [marker.anchor.dx, marker.anchor.dy],
    'consumeTapEvents': marker.consumeTapEvents,
    'draggable': marker.draggable,
    'flat': marker.flat,
    'icon': marker.icon
        .toString(), // You may want to convert this to a string if using custom icons
    'infoWindow': {
      'title': marker.infoWindow.title,
      'snippet': marker.infoWindow.snippet,
      'anchor': [marker.infoWindow.anchor.dx, marker.infoWindow.anchor.dy],
    },
    'position': {
      'latitude': marker.position.latitude,
      'longitude': marker.position.longitude,
    },
    'rotation': marker.rotation,
    'visible': marker.visible,
    'zIndex': marker.zIndex,
  };
}

Marker markerFromMap(Map<String, dynamic> map) {
  MarkerId markerId = MarkerId(map['markerId']);
  double alpha = map['alpha'] ?? 1.0;
  Offset anchor = Offset(map['anchor'][0], map['anchor'][1]);
  bool consumeTapEvents = map['consumeTapEvents'] ?? false;
  bool draggable = map['draggable'] ?? false;
  bool flat = map['flat'] ?? false;

  // Handle infoWindow
  InfoWindow infoWindow = InfoWindow(
    title: map['infoWindow']['title'],
    snippet: map['infoWindow']['snippet'],
    anchor:
        Offset(map['infoWindow']['anchor'][0], map['infoWindow']['anchor'][1]),
  );

  // Handle position
  LatLng position =
      LatLng(map['position']['latitude'], map['position']['longitude']);

  // Handle icon (use a default icon if not provided)
  BitmapDescriptor icon = map['icon'] != null
      ? BitmapDescriptor.defaultMarker
      : BitmapDescriptor.defaultMarker;

  // Create the Marker
  return Marker(
    markerId: markerId,
    alpha: alpha,
    anchor: anchor,
    consumeTapEvents: consumeTapEvents,
    draggable: draggable,
    flat: flat,
    icon: icon,
    infoWindow: infoWindow,
    position: position,
    rotation: map['rotation'] ?? 0.0,
    visible: map['visible'] ?? true,
    zIndex: map['zIndex'] ?? 0.0,
    onTap: map['onTap'],
    onDragStart: map['onDragStart'],
    onDrag: map['onDrag'],
    onDragEnd: map['onDragEnd'],
  );
}
