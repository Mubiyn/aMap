import 'package:flutter/material.dart';
import 'package:map_test/src/features/map/presentation/controllers/map_viewmodel.dart';
import 'package:map_test/src/features/settings/settings_view.dart';
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
        centerTitle: false,
        actions: const [
          SettingsView(),
        ],
      ),
      body: Consumer<MapViewModel>(
        builder: (context, value, child) => ListView.separated(
          itemCount: value.favoriteMarkers.length,
          itemBuilder: (context, index) {
            final marker = value.favoriteMarkers[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                    '${marker.infoWindow.title!.split(' ').first[0]}${marker.infoWindow.title!.split(' ').last[0]}'),
              ),
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
          separatorBuilder: (context, index) => const Divider(
            thickness: 0.3,
          ),
        ),
      ),
    );
  }
}
