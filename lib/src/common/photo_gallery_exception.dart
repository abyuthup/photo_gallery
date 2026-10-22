part of photogallery;

/// Thrown when a platform call of [PhotoGallery] fails.
class PhotoGalleryException implements Exception {
  /// Creates an exception with an error [code] and an optional [message].
  const PhotoGalleryException(this.code, [this.message]);

  /// Error code reported by the platform, e.g. `NOT_FOUND`.
  final String code;

  /// Human-readable description of the failure.
  final String? message;

  @override
  String toString() => 'PhotoGalleryException($code, $message)';
}
