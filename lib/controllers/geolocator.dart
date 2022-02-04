import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:report_child/controllers/bottom_nav_controller.dart';
import 'package:report_child/controllers/show_snackbar.dart';
import 'package:geocoding/geocoding.dart';

class GeolocalizationManager {
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  ///
  late final LocationSettings locationSettings;
  late StreamSubscription<Position> positionStream;
  Future<bool> initGeolocator({bool alreadyCalled = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      showInSnackBar(
          "Para poder localizar al niño, se necesita acceso a su localización. Por favor, le pedimos que active la localización.",
          navBarControllerKey);

      await Future.delayed(Duration(seconds: 5));
      await Geolocator.openLocationSettings();
      await Future.delayed(Duration(seconds: 60));
      if (!alreadyCalled) {
        return initGeolocator(alreadyCalled: true);
      } else {
        return false;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        showInSnackBar(
            "Para poder localizar al niño, se necesita acceso a su localización. Por favor, le pedimos que active los permisos.",
            navBarControllerKey);
        await Future.delayed(Duration(seconds: 5));
        if (!alreadyCalled) {
          return initGeolocator(alreadyCalled: true);
        } else {
          return false;
        }
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (!alreadyCalled) {
        showInSnackBar(
            "Para poder localizar al niño, se necesita acceso a su localización. Por favor, le pedimos que active los permisos.",
            navBarControllerKey);
        if (await Geolocator.openAppSettings()) {
          await Future.delayed(Duration(minutes: 1));

          return initGeolocator(alreadyCalled: true);
        }
      } else {
        showInSnackBar(
            "Para poder localizar al niño, se necesita acceso a su localización. Por favor, le pedimos que active los permisos.",
            navBarControllerKey);
      }
    }
    _getLocationSettings();
    return true;
  }

  startStreaming(_onPositionChanged onPositionChanged) {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen(onPositionChanged);
  }

  void _getLocationSettings() {
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
  }

  static Future<Placemark?> setPlacemarkFromCoordinates(
      double latitude, double longitude) async {
    if (latitude == 0.0 || longitude == 0.0) return null;
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      return placemarks[0];
    } catch (e) {
      return null;
    }
  }
}

typedef void _onPositionChanged(Position? position);
