import 'dart:async';
import '../models/file_info.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googledrive_dm/services/drive_service_interface.dart';

class DriveService implements DriveServiceInterface {
  @override
  Future<List<FileInfo>> fetchFilesInDirectory({
    required dynamic user, // GoogleSignInAccountまたはauth.AuthClient
    required String directoryId,
  }) async {
    late http.Client client;
    if (user is GoogleSignInAccount) {
      final authHeaders = await user.authHeaders;
      client = GoogleAuthClient(authHeaders);
    } else if (user is auth.AuthClient) {
      client = user;
    } else {
      throw ArgumentError('userはGoogleSignInAccountまたはAuthClientである必要があります');
    }
    final driveApi = drive.DriveApi(client);
    final fileList = await driveApi.files.list(
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
    late http.Client client;
    if (user is GoogleSignInAccount) {
      final authHeaders = await user.authHeaders;
      client = GoogleAuthClient(authHeaders);
    } else if (user is auth.AuthClient) {
      client = user;
    } else {
      throw ArgumentError('userはGoogleSignInAccountまたはAuthClientである必要があります');
    }
    final driveApi = drive.DriveApi(client);
    final about = await driveApi.about.get($fields: 'storageQuota');
    final quota = about.storageQuota;
    final usage = int.tryParse(quota?.usage ?? '0') ?? 0;
    final limit = int.tryParse(quota?.limit ?? '0') ?? 0;
    return {'usage': usage, 'limit': limit};
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
