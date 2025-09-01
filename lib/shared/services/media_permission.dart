import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

/// Helper untuk meminta izin media (foto/video) bila benar-benar diperlukan.
///
/// Catatan penting:
/// - Aplikasi ini tidak membutuhkan izin media untuk menyimpan/berbagi PDF.
/// - Gunakan fungsi di bawah hanya jika Anda menambahkan fitur yang memang
///   membaca foto/video dari galeri.
class MediaPermissionService {
  /// Meminta izin melihat foto (Android 13+: READ_MEDIA_IMAGES).
  static Future<bool> ensurePhotosPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.photos.status;
    if (status.isGranted) return true;
    final result = await Permission.photos.request();
    return result.isGranted;
  }

  /// Meminta izin melihat video (Android 13+: READ_MEDIA_VIDEO).
  static Future<bool> ensureVideosPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.videos.status;
    if (status.isGranted) return true;
    final result = await Permission.videos.request();
    return result.isGranted;
  }

  /// Membuka settings aplikasi jika izin ditolak permanen.
  static Future<void> openSettingsIfPermanentlyDenied() async {
    final photosDenied = await Permission.photos.isPermanentlyDenied;
    final videosDenied = await Permission.videos.isPermanentlyDenied;
    if (photosDenied || videosDenied) {
      await openAppSettings();
    }
  }
}

