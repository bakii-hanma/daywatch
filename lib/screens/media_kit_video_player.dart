import 'package:flutter/material.dart';

class MediaKitVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const MediaKitVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<MediaKitVideoPlayer> createState() => _MediaKitVideoPlayerState();
}

class _MediaKitVideoPlayerState extends State<MediaKitVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'MediaKit Player - En cours de développement',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
