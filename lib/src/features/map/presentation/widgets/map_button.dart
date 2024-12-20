import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTypeButton extends StatelessWidget {
  const MapTypeButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.mapType,
      required this.setMapType,
      required this.selectedMapType});
  final String label;
  final IconData icon;
  final MapType mapType, selectedMapType;
  final VoidCallback setMapType;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: setMapType,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor:
                selectedMapType == mapType ? Colors.blue : Colors.grey[300],
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: selectedMapType == mapType ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class MarkerActionSheet extends StatelessWidget {
  const MarkerActionSheet({
    super.key,
    required this.selectedMarkerId,
    required this.isFavorite,
    required this.addToFavorites,
    required this.removeFromFavorites,
  });
  final Marker? selectedMarkerId;
  final bool isFavorite;
  final Function(Marker) addToFavorites;
  final Function(Marker) removeFromFavorites;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedMarkerId?.infoWindow.title ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (selectedMarkerId != null) {
                isFavorite
                    ? removeFromFavorites(selectedMarkerId!)
                    : addToFavorites(selectedMarkerId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFavorite ? Colors.red : Colors.green,
            ),
            child:
                Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the pop-up
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
