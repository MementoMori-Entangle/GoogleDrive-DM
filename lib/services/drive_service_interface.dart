import 'dart:async';
import '../models/file_info.dart';

abstract class DriveServiceInterface {
  // Fetch files in a specific directory
  Future<List<FileInfo>> fetchFilesInDirectory({
    required dynamic user,
    required String directoryId,
  });
  // Fetch storage information for the user's Google Drive
  Future<Map<String, int>> fetchDriveStorageInfo({
    required dynamic user,
  });
}
