import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_poc/hlscaching/hls_proxy_server.dart';

const String viewType = 'video_player_view';

const Map<String, dynamic> creationParams = <String, dynamic>{};

class IOSPlayer extends StatefulWidget {
  const IOSPlayer({super.key});

  @override
  State<IOSPlayer> createState() => _IOSPlayerState();
}

class _IOSPlayerState extends State<IOSPlayer> {
  late final VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    final proxyURL = HLSProxyServer().proxyURL(
        'https://janakmistry2000.github.io/video_cache_samples/samplehls/sample.m3u8');
    controller = VideoPlayerController.network(proxyURL);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller?.initialize();
      controller?.play();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: VideoPlayer(controller!)
              // child: UiKitView(
              //   viewType: viewType,
              //   layoutDirection: TextDirection.ltr,
              //   creationParams: creationParams,
              //   creationParamsCodec: StandardMessageCodec(),
              // ),
              ),
          VideoProgressIndicator(
            controller!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
                backgroundColor: Colors.red,
                bufferedColor: Colors.black,
                playedColor: Colors.blueAccent),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}