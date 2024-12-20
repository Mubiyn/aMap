import 'dart:developer';
import 'package:map_test/src/injection.dart';
import 'package:map_test/src/core/api/base_client.dart';
import 'package:map_test/src/features/map/domain/model.dart';
import 'package:map_test/src/shared/api_key.dart';

abstract class IGeolocatingApi {
  Future<LatitudeLongitude?> coordinatesFromAddress(String address);
}

class GeolocatingApi extends IGeolocatingApi {
  final client = locator<BaseClient>();

  GeolocatingApi();

  @override
  Future<LatitudeLongitude?> coordinatesFromAddress(String address) async {
    final addressUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$address,+CA&key=$kGoogleApiKey";

    try {
      final httpResponse = await client.get(addressUrl);
      final result = httpResponse.data;

      if (result['status'] == "OK") {
        final location = result['results'][0]['geometry']['location'];
        return LatitudeLongitude.fromJson(location);
      }

      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
