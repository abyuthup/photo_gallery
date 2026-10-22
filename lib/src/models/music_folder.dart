part of photogallery;

 class MusicFolder{
    final String id;
    final String name;
    final int count;
    final String path;

    MusicFolder.fromJson(dynamic json)
        : id = json['id'],
          name = json['name'],
          count = json['count'] ?? 0,
          path = json['path'];
 }