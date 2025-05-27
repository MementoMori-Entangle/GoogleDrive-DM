import 'package:googleapis/drive/v3.dart' as drive;

abstract class FilesResourceInterface {
  Future<drive.FileList> list({
    String? corpora,
    String? corpus,
    String? driveId,
    bool? includeItemsFromAllDrives,
    String? includeLabels,
    String? includePermissionsForView,
    bool? includeTeamDriveItems,
    String? orderBy,
    int? pageSize,
    String? pageToken,
    String? q,
    String? spaces,
    bool? supportsAllDrives,
    bool? supportsTeamDrives,
    String? teamDriveId,
    String? $fields,
  });
}

abstract class AboutResourceInterface {
  Future<drive.About> get({String? $fields});
}

class MockFilesResourceApi implements FilesResourceInterface {
  @override
  Future<drive.FileList> list({
    String? corpora,
    String? corpus,
    String? driveId,
    bool? includeItemsFromAllDrives,
    String? includeLabels,
    String? includePermissionsForView,
    bool? includeTeamDriveItems,
    String? orderBy,
    int? pageSize,
    String? pageToken,
    String? q,
    String? spaces,
    bool? supportsAllDrives,
    bool? supportsTeamDrives,
    String? teamDriveId,
    String? $fields,
  }) async {
    return drive.FileList(files: [
      drive.File(
          id: 'mock1', name: 'mock_file1.txt', size: (1024 * 1000).toString()),
      drive.File(
          id: 'mock2',
          name: 'mock_file2.jpg',
          size: (1024 * 1000 * 2).toString()),
    ]);
  }
}

class MockAboutResourceApi implements AboutResourceInterface {
  @override
  Future<drive.About> get({String? $fields}) async {
    return drive.About.fromJson({
      'storageQuota': {
        'usage': (1024 * 1024 * 30).toString(),
        'limit': (1024 * 1024 * 1024 * 15).toString()
      }
    });
  }
}
