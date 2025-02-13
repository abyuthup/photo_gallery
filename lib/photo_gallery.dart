library photogallery;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

part 'src/common/medium_type.dart';

part 'src/image_providers/album_thumbnail_provider.dart';

part 'src/image_providers/photo_provider.dart';

part 'src/image_providers/thumbnail_provider.dart';

part 'src/models/album.dart';

part 'src/models/media_page.dart';

part 'src/models/medium.dart';

/// Accessing the native photo gallery.
class PhotoGallery {
  static const MethodChannel _channel = MethodChannel('photo_gallery');

  /// List all available gallery albums and counts number of items of [MediumType].
  static Future<List<Album>> listAlbums({
    MediumType? mediumType,
    bool newest = true,
    bool hideIfEmpty = true,
  }) async {
    final json = await _channel.invokeMethod('listAlbums', {
      'mediumType': mediumTypeToJson(mediumType),
      'newest': newest,
      'hideIfEmpty': hideIfEmpty,
    });
    return json
        .map<Album>((album) => Album.fromJson(album, mediumType, newest))
        .toList();
  }

  /// listing audio albums is a challenge. when using the same logic as for video and photo albums, it returns albums list, which is the album attribute of the audio file. actually we
  /// wanted to get the folder based list. This can't be done using the media store album list. so if we alter album name with folder name, then we have to write file scanning code to get the list of audio files.
  ///
  // static Future<List<Album>> listAudioAlbums({
  //   MediumType? mediumType = MediumType.audio,
  //   bool newest = true,
  //   bool hideIfEmpty = true,
  // }) async {
  //   final json = await _channel.invokeMethod('listAlbums', {
  //     'mediumType': mediumTypeToJson(mediumType),
  //     'newest': newest,
  //     'hideIfEmpty': hideIfEmpty,
  //   });
  //   return json
  //       .map<Album>((album) => Album.fromJson(album, mediumType, newest))
  //       .toList();
  // }

// ----------------- New Function ----------------//
  static Future<List<Album>> listAudioAlbums({
    MediumType? mediumType = MediumType.audio,
    bool newest = true,
    bool hideIfEmpty = true,
  }) async {

    // 1. fist list all audio file with file path

    //

    final json = await _channel.invokeMethod('getAllMusicFiles');

    // 2. then group this file list to albums based on file path
    // album name is directory name of file path


    return json
        .map<Album>((album) => Album.fromJson(album, mediumType, newest))
        .toList();
  }
// ----------------- New Function ----------------//



  //listAllMusic
  static Future<List<Album>> listAllMusic({
    MediumType? mediumType = MediumType.audio,
    bool newest = true,
    bool hideIfEmpty = true,
  }) async {
    final json = await _channel.invokeMethod('listAllMusic', {
      'mediumType': mediumTypeToJson(mediumType),
      'newest': newest,
      'hideIfEmpty': hideIfEmpty,
    });
    return json
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
    final json = await _channel.invokeMethod('listMedia', {
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
    final json = await _channel.invokeMethod('getMedium', {
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
    final bytes = await _channel.invokeMethod('getThumbnail', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    if (bytes == null) throw "Failed to fetch thumbnail of medium $mediumId";
    return List<int>.from(bytes);
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
    final bytes = await _channel.invokeMethod('getAlbumThumbnail', {
      'albumId': albumId,
      'mediumType': mediumTypeToJson(mediumType),
      'newest': newest,
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    if (bytes == null) throw "Failed to fetch thumbnail of album $albumId";
    return List<int>.from(bytes);
  }

  /// get medium file by medium id
  static Future<File> getFile({
    required String mediumId,
    MediumType? mediumType,
    String? mimeType,
  }) async {
    final path = await _channel.invokeMethod('getFile', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
      'mimeType': mimeType,
    }) as String?;
    if (path == null) throw "Cannot get file $mediumId with type $mimeType";
    return File(path);
  }

  /// Delete medium by medium id
  static Future<void> deleteMedium({
    required String mediumId,
    MediumType? mediumType,
  }) async {
    await _channel.invokeMethod('deleteMedium', {
      'mediumId': mediumId,
      'mediumType': mediumTypeToJson(mediumType),
    });
  }

  /// Get music files
  static Future getAllMusicFiles() async {
    final result = await _channel.invokeMethod('getAllMusicFiles');
    return result;
  }

  /// Clean medium file cache
  static Future<void> cleanCache() async {
    _channel.invokeMethod('cleanCache', {});
  }
}
