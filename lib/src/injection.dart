import 'package:get_it/get_it.dart';
import 'package:map_test/src/core/api/base_client.dart';
import 'package:map_test/src/features/map/data/geolocating_methods.dart';
import 'package:map_test/src/features/map/data/service.dart';
import 'package:map_test/src/features/map/presentation/controllers/map_viewmodel.dart';
import 'package:map_test/src/features/settings/settings_controller.dart';
import 'package:map_test/src/features/settings/settings_service.dart';
import 'package:map_test/src/services/notification/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

SettingsController get settingsController => locator<SettingsController>();
NotificationService notificationService = locator<NotificationService>();
final prefs = locator<SharedPreferences>();

class AppInjectionContainer {
  static Future<void> initialize() async {
    final sharedPreference = await SharedPreferences.getInstance();
    locator.registerLazySingleton<SharedPreferences>(() => sharedPreference);

    locator.registerLazySingleton<BaseClient>(
      () => BaseClient(),
    );

    locator.registerFactory<SettingsService>(
      () => SettingsService(),
    );
    locator.registerLazySingleton<SettingsController>(
      () => SettingsController(),
    );
    locator<SettingsController>().loadSettings();
    locator.registerLazySingleton<IGeolocatingApi>(() => GeolocatingApi());
    locator.registerLazySingleton<IGeolocatingApiService>(
        () => GeolocatingService());

    locator.registerFactory<MapViewModel>(
      () => MapViewModel(),
    );
    locator.registerLazySingleton<NotificationService>(
      () => NotificationService(),
    );
    locator<NotificationService>().init();
  }
}
