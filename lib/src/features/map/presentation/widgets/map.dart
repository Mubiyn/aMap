import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_test/src/features/map/presentation/controllers/map_viewmodel.dart';
import 'package:map_test/src/features/map/presentation/widgets/map_button.dart';
import 'package:map_test/src/features/settings/settings_controller.dart';
import 'package:map_test/src/injection.dart';
import 'package:map_test/src/services/notification/notification.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapViewModel? viewmodel;
  @override
  void initState() {
    super.initState();
    viewmodel = context.read<MapViewModel>();
  }

  Marker? _selectedMarkerId;
  bool _isFavorite = false;

  final notificationService = NotificationService();

  void _onMarkerTapped(Marker marker) {
    setState(() {
      _selectedMarkerId = marker;
      _isFavorite = _checkIfFavorite(marker);
    });
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MarkerActionSheet(
            addToFavorites: _addToFavorites,
            removeFromFavorites: _removeFromFavorites,
            isFavorite: _isFavorite,
            selectedMarkerId: _selectedMarkerId);
      },
    );
  }

  bool _checkIfFavorite(Marker marker) {
    return viewmodel!.favoriteMarkers.contains(marker);
  }

  void _addToFavorites(Marker marker) {
    setState(() {
      viewmodel!.addToFavorites(marker);
      _isFavorite = true;
    });
    notificationService.showNotification(marker.markerId.hashCode,
        '${marker.infoWindow.title} Added to Favourites');
    Navigator.pop(context);
  }

  void _removeFromFavorites(Marker marker) {
    setState(() {
      viewmodel!.removeFromFavorites(marker);
      _isFavorite = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(builder: (context, viewmodel, _) {
      return Stack(children: [
        GoogleMap(
          style: viewmodel.mapStyle,
          initialCameraPosition: CameraPosition(
            target: LatLng(viewmodel.value.latitude, viewmodel.value.longitude),
            zoom: viewmodel.initZoom,
          ),
          onMapCreated: (GoogleMapController controller) {
            if (!viewmodel.controller.isCompleted) {
              viewmodel.controller.complete(controller);
            }
            viewmodel.newGoogleMapController = controller;
          },
          onCameraMove: (CameraPosition newPosition) {
            viewmodel.value = newPosition.target;
            viewmodel.updatePinMargin();
          },
          onCameraIdle: () async {
            viewmodel.pinMargin = 0;
            if (mounted) {
              viewmodel.getNewAddressWhenMapMoves().then((value) {});
            }
          },
          mapType: viewmodel.currentMapType,
          buildingsEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          padding: const EdgeInsets.symmetric(vertical: 80),
          markers: Set<Marker>.of(viewmodel.filteredMarkers.map((marker) {
            return Marker(
              markerId: marker.markerId,
              position: marker.position,
              onTap: () => _onMarkerTapped(marker),
              infoWindow: InfoWindow(
                title: marker.infoWindow.title,
                snippet: marker.infoWindow.snippet,
              ),
            );
          })),
          trafficEnabled: true,
        ),
        if (viewmodel.hasError)
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Text(
                viewmodel.error,
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        Positioned(
            bottom: 0,
            right: 10,
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: locator<SettingsController>().themeMode ==
                              ThemeMode.dark
                          ? Colors.grey.withOpacity(0.8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 10,
                      children: [
                        MapTypeButton(
                            label: 'Normal',
                            icon: Icons.map,
                            mapType: MapType.normal,
                            selectedMapType: viewmodel.currentMapType,
                            setMapType: () =>
                                viewmodel.setMapType(MapType.normal)),
                        MapTypeButton(
                            label: 'Satellite',
                            icon: Icons.satellite,
                            mapType: MapType.satellite,
                            selectedMapType: viewmodel.currentMapType,
                            setMapType: () =>
                                viewmodel.setMapType(MapType.satellite)),
                        MapTypeButton(
                            label: 'Terrain',
                            icon: Icons.terrain,
                            mapType: MapType.terrain,
                            selectedMapType: viewmodel.currentMapType,
                            setMapType: () => viewmodel.setMapType(
                                  MapType.terrain,
                                )),
                        MapTypeButton(
                            label: 'Hybrid',
                            icon: Icons.layers,
                            mapType: MapType.hybrid,
                            selectedMapType: viewmodel.currentMapType,
                            setMapType: () => viewmodel.setMapType(
                                  MapType.hybrid,
                                )),
                      ],
                    )),
              ],
            )),
      ]);
    });
  }
}
