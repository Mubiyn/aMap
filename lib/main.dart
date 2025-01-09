import 'package:flutter/material.dart';
import 'package:map_test/src/features/map/presentation/controllers/viewmodel.dart';
import 'package:map_test/src/injection.dart';
import 'package:map_test/src/services/notification/notification.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await AppInjectionContainer.initialize();

  runApp(MultiProvider(
    providers: providers,
    child: const MyApp(),
  ));
}
