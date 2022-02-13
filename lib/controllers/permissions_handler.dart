import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  var perms = Platform.isAndroid
      ? [
          Permission.storage,
          Permission.photos,
          Permission.contacts,
          Permission.camera,
          Permission.phone,
          Permission.microphone,
          Permission.location,
          Permission.locationWhenInUse,
        ]
      : [
          Permission.photos,
          Permission.contacts,
          Permission.camera,
          Permission.mediaLibrary,
          Permission.photos,
          Permission.microphone,
          Permission.location,
          Permission.locationWhenInUse,
        ];

  Future<void> askPermissions() async {
    /* Map<Permission, PermissionStatus> statuses = */ await perms.request();
  }
}
