import 'package:get_it/get_it.dart';
import 'package:map_test/src/features/map/presentation/controllers/map_viewmodel.dart';
import 'package:map_test/src/features/settings/settings_controller.dart';
import 'package:provider/provider.dart';

var providers = [
  ChangeNotifierProvider<MapViewModel>(
    create: (_) => GetIt.I<MapViewModel>(),
  ),
  ChangeNotifierProvider<SettingsController>(
    create: (_) => GetIt.I<SettingsController>(),
  ),
];
