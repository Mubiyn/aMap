import 'package:flutter/material.dart';
import 'package:map_test/src/features/map/presentation/controllers/map_viewmodel.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  static const String routeName = '/fav-screen';

  const FavoritesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<MapViewModel>(
        builder: (context, value, child) => ListView.builder(
          itemCount: value.favoriteMarkers.length,
          itemBuilder: (context, index) {
            final marker = value.favoriteMarkers[index];
            return ListTile(
              title: Text(marker.infoWindow.title ?? ''),
              subtitle: Text(
                'Lat: ${marker.infoWindow.snippet?.split(';').first}, Long: ${marker.infoWindow.snippet?.split(';').last}',
              ),
              trailing: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }
}
