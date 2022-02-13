import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:report_child/controllers/bottom_nav_controller.dart';
import 'package:report_child/controllers/show_snackbar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:report_child/models/case_model.dart';

class GeolocalizationManager {
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  ///
  late final LocationSettings locationSettings;
  StreamSubscription<Position>? positionStream;
  bool _initialized = false;
/*   bool _streaming = false; */

  Future<bool> initGeolocator({bool alreadyCalled = false}) async {
    if (_initialized) return true;
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      showInSnackBar(translate('LocationSettings.ActivateLocationMessage'),
          navBarControllerKey);

      await Future.delayed(const Duration(seconds: 5));
      await Geolocator.openLocationSettings();
      await Future.delayed(const Duration(seconds: 60));
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
            translate('LocationSettings.ActivateLocationPermsMessage'),
            navBarControllerKey);
        await Future.delayed(const Duration(seconds: 5));
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
            translate('LocationSettings.ActivateLocationPermsMessage'),
            navBarControllerKey);
        if (await Geolocator.openAppSettings()) {
          await Future.delayed(const Duration(minutes: 1));

          return initGeolocator(alreadyCalled: true);
        }
      } else {
        showInSnackBar(
            translate('LocationSettings.ActivateLocationPermsMessage'),
            navBarControllerKey);
      }
    }
    _getLocationSettings();

    _initialized = true;
    return true;
  }

  Future<bool> getCurrentLocation(BuildContext context) async {
    await initGeolocator();
    try {
      Provider.of<CaseModel>(context, listen: false).position =
          await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 30));

      return true;
    } catch (e) {
      Position? p = await Geolocator.getLastKnownPosition();
      if (p == null) {
        return false;
      }
      Provider.of<CaseModel>(context, listen: false).position = p;
      return true;
    }
  }

/* 
  startStreaming(_onPositionChanged onPositionChanged) {
    if (!_initialized) return;
    if (_streaming) return;
    if (positionStream != null) {
      if (positionStream!.isPaused) {
        positionStream!.resume();
        return;
      }
    }
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen(onPositionChanged);
    _streaming = true;
  }

  pauseStreaming() {
    if (!_initialized) return;
    if (!_streaming) return;
    if (positionStream != null) {
      positionStream!.pause();
    }
    _streaming = false;
  }
 */
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
      locationSettings = const LocationSettings(
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

/* typedef void _onPositionChanged(Position? position); */
