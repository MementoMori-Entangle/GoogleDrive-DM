import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'app_config.dart';
import 'package:googledrive_dm/services/auth_service_interface.dart';
import 'package:googledrive_dm/services/directory_service_interface.dart';
import 'package:googledrive_dm/services/drive_service_interface.dart';

class MyApp extends StatefulWidget {
  final AuthServiceInterface authServiceInterface;
  final DriveServiceInterface driveServiceInterface;
  final DirectoryServiceInterface directoryServiceInterface;
  const MyApp(
      {super.key,
      required this.authServiceInterface,
      required this.driveServiceInterface,
      required this.directoryServiceInterface});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
            authServiceInterface: widget.authServiceInterface,
            driveServiceInterface: widget.driveServiceInterface,
            directoryServiceInterface: widget.directoryServiceInterface),
        // 他のルートをここに追加できます
      },
    );
  }
}
