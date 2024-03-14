import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class ListPlayer extends StatefulWidget {
  const ListPlayer({super.key});

  @override
  State<ListPlayer> createState() => _ListPlayerState();
}

class _ListPlayerState extends State<ListPlayer> {
  List<String> urls = [
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
    // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: urls.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (_, i) {
          return SinglePlayer(url: urls[i]);
        },
      ),
    );
  }
}

class SinglePlayer extends StatefulWidget {
  const SinglePlayer({
    super.key,
    required this.url,
  });

  final String url;

  @override
  State<SinglePlayer> createState() => _SinglePlayerState();
}

class _SinglePlayerState extends State<SinglePlayer>
    with AutomaticKeepAliveClientMixin {
  late BetterPlayerController c;

  @override
  void initState() {
    super.initState();
    c = BetterPlayerController(
      const BetterPlayerConfiguration(),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        videoFormat: BetterPlayerVideoFormat.hls,
          cacheConfiguration: BetterPlayerCacheConfiguration()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BetterPlayer(
      controller: c,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return BetterPlayerPlaylist(
      betterPlayerDataSourceList: [
        BetterPlayerDataSource(BetterPlayerDataSourceType.network,
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            cacheConfiguration: BetterPlayerCacheConfiguration()),
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        ),
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        ),
      ],
      betterPlayerConfiguration: const BetterPlayerConfiguration(
        autoPlay: true,
        fullScreenByDefault: true,
      ),
      betterPlayerPlaylistConfiguration:
          const BetterPlayerPlaylistConfiguration(),
    );
  }
}
