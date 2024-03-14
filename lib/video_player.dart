import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Video player screen.
class VideoPlayerScreen extends StatefulWidget {
  /// Video player widget that shows a video from the provided [path].
  const VideoPlayerScreen(this.path, {super.key});

  /// The path of the video.
  final String path;

  @override
  VideoPlayerState createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network((widget.path))
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) => Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: GestureDetector(
                  onTap: _onTap,
                  child: VideoPlayer(_controller),
                ),
              )
            : null,
      );

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _onTap() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }
}
