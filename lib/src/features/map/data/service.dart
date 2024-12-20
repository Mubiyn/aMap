import 'package:map_test/src/injection.dart';
import 'package:map_test/src/features/map/data/geolocating_methods.dart';
import 'package:map_test/src/features/map/domain/model.dart';

abstract class IGeolocatingApiService {
  Future<LatitudeLongitude?> coordinatesFromAddress(String address);
}

class GeolocatingService extends IGeolocatingApiService {
  final geoApi = locator<IGeolocatingApi>();

  @override
  Future<LatitudeLongitude?> coordinatesFromAddress(address) {
    return geoApi.coordinatesFromAddress(address);
  }
}
