library photogallery;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

part 'src/common/medium_type.dart';

part 'src/common/photo_gallery_exception.dart';

part 'src/image_providers/album_thumbnail_provider.dart';

part 'src/image_providers/photo_provider.dart';

part 'src/image_providers/thumbnail_provider.dart';

part 'src/models/album.dart';

part 'src/models/media_page.dart';

part 'src/models/medium.dart';

/// Accessing the native photo gallery.
class PhotoGallery {
  static const MethodChannel _channel = MethodChannel('photo_gallery');

  /// Invokes [method] and rethrows platform failures as [PhotoGalleryException].
  static Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      throw PhotoGalleryException(e.code, e.message);
    }
  }

  /// List all available gallery albums and counts number of items of [MediumType].
  static Future<List<Album>> listAlbums({
    MediumType? mediumType,
    bool newest = true,
    bool hideIfEmpty = true,
  }) async {
    final json = await _invoke<List<Object?>>('listAlbums', {
      'mediumType': mediumTypeToJson(mediumType),
      'newest': newest,
      'hideIfEmpty': hideIfEmpty,
    });
    return (json ?? const [])
        .map<Album>((album) => Album.fromJson(album, mediumType, newest))
        .toList();
  }

  //listAllMusic
  static Future<List<Album>> listAllMusic({
    MediumType? mediumType = MediumType.audio,
    bool newest = true,
    bool hideIfEmpty = true,
  }) async {
    final json = await _invoke<List<Object?>>('listAllMusic', {
      'mediumType': mediumTypeToJson(mediumType),
      'newest': newest,
      'hideIfEmpty': hideIfEmpty,
    });
    return (json ?? const [])
        .map<Album>((album) => Album.fromJson(album, mediumType, newest))
        .toList();
  }

  /// List all available media in a specific album, support pagination of media
  static Future<MediaPage> _listMedia({
    required Album album,
    int? skip,
    int? take,
    bool? lightWeight,
  }) async {
    final json = await _invoke('listMedia', {
      'albumId': album.id,
      'mediumType': mediumTypeToJson(album.mediumType),
      'newest': album.newest,
      'skip': skip,
      'take': take,
      'lightWeight': lightWeight,
    });
    return MediaPage.fromJson(album, json);
  }

  /// Get medium metadata by medium id
  static Future<Medium> getMedium({
    required String mediumId,
    MediumType? mediumType,
  }) async {
    final json = await _invoke('getMedium', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
    });
    return Medium.fromJson(json);
  }

  /// Get medium thumbnail by medium id
  static Future<List<int>> getThumbnail({
    required String mediumId,
    MediumType? mediumType,
    int? width,
    int? height,
    bool? highQuality = false,
  }) async {
    final bytes = await _invoke<Uint8List>('getThumbnail', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    if (bytes == null) {
      throw PhotoGalleryException('NOT_FOUND', "Failed to fetch thumbnail of medium $mediumId");
    }
    return bytes;
  }

  /// Get video thumbnail from video file path
  static Future<List<int>> getVideoThumbnailFromPath({
    required String videoPath,
    int width = -1,
    int timeMs = 0,
    int quality = 100,
  }) async {
    final bytes = await _invoke<Uint8List>('getVideoThumbnailFromPath', {
      'videoPath': videoPath,
      'width': width,
      'timeMs': timeMs,
      'quality': quality,
    });
    if (bytes == null) {
      throw PhotoGalleryException('NOT_FOUND', "Failed to fetch video thumbnail from $videoPath");
    }
    return bytes;
  }

  /// Get album thumbnail by album id
  static Future<List<int>> getAlbumThumbnail({
    required String albumId,
    MediumType? mediumType,
    bool newest = true,
    int? width,
    int? height,
    bool? highQuality = false,
  }) async {
    final bytes = await _invoke<Uint8List>('getAlbumThumbnail', {
      'albumId': albumId,
      'mediumType': mediumTypeToJson(mediumType),
      'newest': newest,
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    if (bytes == null) {
      throw PhotoGalleryException('NOT_FOUND', "Failed to fetch thumbnail of album $albumId");
    }
    return bytes;
  }

  /// get medium file by medium id
  static Future<File> getFile({
    required String mediumId,
    MediumType? mediumType,
    String? mimeType,
  }) async {
    final path = await _invoke<String>('getFile', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
      'mimeType': mimeType,
    });
    if (path == null) {
      throw PhotoGalleryException(
          'FILE_UNAVAILABLE', "Cannot get file $mediumId with type $mimeType");
    }
    return File(path);
  }

  /// Delete medium by medium id
  static Future<void> deleteMedium({
    required String mediumId,
    MediumType? mediumType,
  }) async {
    await _invoke('deleteMedium', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
    });
  }

  /// Get music files as a JSON tree keyed by folder path, with the files of a
  /// folder under `mFiles`.
  ///
  /// Android only for now; other platforms get an empty tree (`{}`).
  static Future<String> getAllMusicFiles() async {
    if (!Platform.isAndroid) return '{}';
    return await _invoke<String>('getAllMusicFiles') ?? '{}';
  }

  /// Clean medium file cache
  static Future<void> cleanCache() async {
    await _invoke('cleanCache', {});
  }
}
