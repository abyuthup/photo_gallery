part of photogallery;

/// A medium type.
enum MediumType {
  /// MediumType.image aby
  image,

  /// MediumType.video
  video,

  /// MediumType.video
  audio,
}

/// Convert MediumType to String
String? mediumTypeToJson(MediumType? value) {
  switch (value) {
    case MediumType.image:
      return 'image';
    case MediumType.video:
      return 'video';
    case MediumType.audio:
      return 'audio';
    default:
      return null;
  }
}

/// Parse String to MediumType
MediumType? jsonToMediumType(String? value) {
  switch (value) {
    case 'image':
      return MediumType.image;
    case 'video':
      return MediumType.video;
    case 'audio':
      return MediumType.audio;
    default:
      return null;
  }
}
