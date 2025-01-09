import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_test/src/features/map/presentation/ui/chat.dart';
import 'package:map_test/src/features/map/presentation/ui/favourites.dart';
import 'package:map_test/src/features/map/presentation/controllers/map_viewmodel.dart';
import 'package:map_test/src/features/map/presentation/widgets/map.dart';
import 'package:map_test/src/features/settings/settings_controller.dart';
import 'package:map_test/src/features/settings/settings_view.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = '/map-screen';
  const MapScreen({
    super.key,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getLocationAndLoadMarkers();
  }

  void getLocationAndLoadMarkers() async {
    final map = context.read<MapViewModel>();
    map
      ..getLastLocation()
      ..determineUserCurrentPosition()
      ..loadFavorites();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(builder: (__, viewmodel, _) {
      return Consumer<SettingsController>(builder: (_, value, __) {
        final isDarkMode = value.themeMode == ThemeMode.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: isDarkMode ? Colors.black : Colors.deepPurple,
            statusBarIconBrightness:
                isDarkMode ? Brightness.dark : Brightness.light,
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                viewmodel.userAddress,
                style: const TextStyle().copyWith(fontSize: 13),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.pushNamed(context, FavoritesScreen.routeName);
                  },
                ),
                const SettingsView(),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.restorablePushNamed(context, ChatScreen.routeName);
                },
                label: const Text('Chat')),
            body: Stack(
              children: [
                const SafeArea(
                  minimum: EdgeInsets.only(bottom: 20),
                  child: MapWidget(),
                ),
                Center(
                  child: AnimatedContainer(
                    margin: EdgeInsets.only(bottom: viewmodel.pinMargin),
                    duration: const Duration(
                      milliseconds: 350,
                    ),
                    height: 30,
                    child: Image.asset(
                      'assets/images/pin.png',
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: 50,
                    width: MediaQuery.sizeOf(context).width * 0.7,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.9)
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
                    child: TextField(
                      controller: searchController,
                      onChanged: viewmodel.filterMarkers,
                      decoration: InputDecoration(
                        hintText: 'Search for a location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            viewmodel.filterMarkers(searchController.text);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (viewmodel.loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
              ],
            ),
          ),
        );
      });
    });
  }
}
