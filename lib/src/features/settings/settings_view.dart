import 'package:flutter/material.dart';
import 'package:map_test/src/features/map/presentation/controllers/map_viewmodel.dart';
import 'package:map_test/src/shared/strings.dart';
import 'package:provider/provider.dart';

import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (__, value, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<MapViewModel>(
          builder: (_, map, __) => DropdownButton<ThemeMode>(
            value: value.themeMode,
            onChanged: (val) async {
              await value.updateThemeMode(val);
              if (value.themeMode == ThemeMode.dark) {
                map.mapStyle = darkMapStyle;
              } else {
                map.mapStyle = lightMapMode;
              }
            },
            underline: const SizedBox.shrink(),
            icon: Icon(
                value.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white),
            dropdownColor: Colors.grey,
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child:
                    Text('System Theme', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child:
                    Text('Light Theme', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child:
                    Text('Dark Theme', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
