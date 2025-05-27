import 'dart:async';
import '../models/file_info.dart';
import 'package:googledrive_dm/services/drive_service_interface.dart';
import 'package:googledrive_dm/test_mock/mock_google_drive_api.dart';

class MockDriveService implements DriveServiceInterface {
  @override
  Future<List<FileInfo>> fetchFilesInDirectory({
    required dynamic user, // GoogleSignInAccountまたはauth.AuthClient
    required String directoryId,
  }) async {
    final fileList = await MockFilesResourceApi().list(
      q: "'$directoryId' in parents and trashed = false",
      spaces: 'drive',
      $fields: 'files(id,name,size)',
      pageSize: 1000,
    );
    final files = fileList.files ?? [];
    return files
        .where((f) => f.size != null)
        .map((f) => FileInfo(
              id: f.id ?? '',
              name: f.name ?? '',
              size: int.tryParse(f.size ?? '0') ?? 0,
            ))
        .toList();
  }

  @override
  Future<Map<String, int>> fetchDriveStorageInfo(
      {required dynamic user}) async {
    final about = await MockAboutResourceApi().get($fields: 'storageQuota');
    final quota = about.storageQuota;
    final usage = int.tryParse(quota?.usage ?? '0') ?? 0;
    final limit = int.tryParse(quota?.limit ?? '0') ?? 0;
    return {'usage': usage, 'limit': limit};
  }
}
