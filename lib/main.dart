import 'package:flutter/material.dart';
import 'app.dart';
import 'package:googledrive_dm/services/auth_service.dart';
import 'package:googledrive_dm/services/directory_service.dart';
import 'package:googledrive_dm/services/drive_service.dart';

void main() {
  FlutterError.onError = FlutterError.dumpErrorToConsole;
  runApp(MyApp(
    authServiceInterface: AuthService(),
    driveServiceInterface: DriveService(),
    directoryServiceInterface: DirectoryService(),
  ));
}
