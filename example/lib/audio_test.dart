import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:photo_gallery/photo_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Music Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MusicFilePicker(),
    );
  }
}

class MusicFilePicker extends StatefulWidget {
  const MusicFilePicker({Key? key}) : super(key: key);

  @override
  _MusicFilePickerState createState() => _MusicFilePickerState();
}

class _MusicFilePickerState extends State<MusicFilePicker> {
  MusicFolder? currentFolder;
  List<MusicFolder> folderPath = [];

  @override
  void initState() {
    super.initState();

      loadMusicDataAndPrint();

  }

  Future<void> loadMusicDataAndPrint() async {
    String  jsonString = await  PhotoGallery.getAllMusicFiles();
    print("LINSLOG: $jsonString"); // This should now work correctly
    loadMusicData(jsonString:jsonString);
  }

  Future<void> loadMusicData({required String jsonString}  ) async {
    try {

      final jsonResponse = json.decode(jsonString);

      var rootJson = jsonResponse['']['storage']['emulated']['0'] as Map<String, dynamic>;
      MusicFolder rootFolder = MusicFolder.fromJson(rootJson, '0');
      setState(() {
        currentFolder = rootFolder;
        folderPath.clear(); // Clear existing path
        folderPath.add(rootFolder); // Add '0' as the initial folder in the path
      });
    } catch (e) {
      // Handle errors, e.g., file not found, JSON parsing error
      print('Error loading music data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music File Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              if (folderPath.length > 1) {
                setState(() {
                  currentFolder = folderPath[0];
                  folderPath.clear();
                  folderPath.add(currentFolder!);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (folderPath.length > 1) {
                setState(() {
                  folderPath.removeLast();
                  currentFolder = folderPath.last;
                });
              }
            },
          ),

        ],
      ),
      body: currentFolder == null
          ? const CircularProgressIndicator()
          : ListView.builder(
        itemCount: currentFolder!.musicFiles.length + currentFolder!.subFolders.length,
        itemBuilder: (context, index) {
          if (index < currentFolder!.subFolders.length) {
            return buildFolderItem(currentFolder!.subFolders[index]);
          } else {
            int fileIndex = index - currentFolder!.subFolders.length;
            return buildMusicItem(currentFolder!.musicFiles[fileIndex]);
          }
        },
      ),
    );
  }

  Widget buildFolderItem(MusicFolder folder) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.name),
      onTap: () {
        setState(() {
          folderPath.add(currentFolder!);
          currentFolder = folder;
        });
      },
    );
  }

  Widget buildMusicItem(MusicItem item) {
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(item.displayName),
      onTap: () {
        // Implement the logic for playing music or navigating into the folder
        print('Tapped music file: ${item.dataPath}');
      },
    );
  }
}

class MusicItem {
  final int id;
  final String artist;
  final String title;
  final String dataPath;
  final String displayName;
  final int duration;

  MusicItem({
    required this.id,
    required this.artist,
    required this.title,
    required this.dataPath,
    required this.displayName,
    required this.duration,
  });

  factory MusicItem.fromJson(Map<String, dynamic> json) {
    return MusicItem(
      id: json['ID'],
      artist: json['Artist'],
      title: json['Title'],
      dataPath: json['Data'],
      displayName: json['DisplayName'],
      duration: json['Duration'],
    );
  }
}

class MusicFolder {
  final String name;
  final List<MusicItem> musicFiles;
  final List<MusicFolder> subFolders;

  MusicFolder({required this.name, required this.musicFiles, required this.subFolders});
  static MusicFolder fromJson(Map<String, dynamic> json, String folderName) {
    List<MusicItem> musicFiles = [];
    List<MusicFolder> subFolders = [];

    json.forEach((key, value) {
      if (value is List) {
        // Assuming all lists contain music files
        List<dynamic> musicList = value;
        musicFiles.addAll(musicList.map((item) => MusicItem.fromJson(item as Map<String, dynamic>)).toList());
      } else if (value is Map) {
        // Subfolder
        Map<String, dynamic> folderMap = value as Map<String, dynamic>;
        subFolders.add(MusicFolder.fromJson(folderMap, key));
      }
    });

    return MusicFolder(name: folderName, musicFiles: musicFiles, subFolders: subFolders);
  }
}
