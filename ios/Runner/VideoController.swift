//
//  VideoController.swift
//  Runner
//
//  Created by Ujas Majithiya on 12/06/23.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import Flutter
import HLSCachingReverseProxyServer
import GSPlayer

// MARK: FLNativeView
class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var videoView: ViewController
    private var nativeFrame: CGRect
    //private var gsVideoController: GSVideoController
    
    let playerView = VideoPlayerView()
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        videoView = ViewController()
        nativeFrame = frame
        //gsVideoController = GSVideoController()
        //let playerView = VideoPlayerView()
        //playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //_view.addSubview(playerView)
        //playerView.play(for: URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        //_view.addSubview(videoView.playerController.view)
        super.init()
        self.createHLSVideoPlayer(view: _view)
        
        // MARK: Old code gsVideoController
        //createNativeView(view: _view)
        //gsVideoController.playerView.play(for: gsVideoController.url!)
    }

    func view() -> UIView {
        videoView.playerController.view.frame = nativeFrame
        //videoView.playerController.view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        return videoView.playerController.view
    }
    
    
    // MARK: Create HLSPlayer
    func createHLSVideoPlayer(view _view: UIView){
        videoView.center = _view.center
        videoView.playLocalVideo()
        _view.frame = videoView.playerController.view.bounds
        _view.addSubview(videoView.playerController.view)
        _view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }

    
//    func createNativeView(view _view: UIView){
//        gsVideoController.view.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
////        _view.addSubview(videoView.view)
//        _view.addSubview(gsVideoController.playerView)
//    }
}

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class ViewController: UIView {
    
    let playerController = AVPlayerViewController()
    var playerLayer = AVPlayerLayer()
       
    
    func playLocalVideo() {
        if #available(iOS 13.0, *) {
            let url = URL.init(string: "https://janakmistry2000.github.io/video_cache_samples/samplehls/sample.m3u8")
            if(url == nil) {
                print("URL is nil")
                return
            }
            
            let videoURL = HLSVideoCache.shared.reverseProxyURL(from: url!)!
            print(url!.absoluteString)
            print(videoURL.absoluteString)
            //let player = AVPlayer()
            //let playerItem = AVPlayerItem(url: videoURL)
            let player = AVPlayer.init(url: url!)
            playerController.player = player
            //player.replaceCurrentItem(with: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            playerController.showsPlaybackControls = true
            //playerController.view.frame = CGRect(x: 0, y: 0, width: 300, height: 20)
            //addSubview(playerController.view)
            //layer.addSublayer(playerLayer)
            player.play()
        }
    }
}

class VideoController: UIViewController {
    private let player = AVPlayer()
    private var playerLayer: AVPlayerLayer?

    // Test stream examples
    private let videos = [
        "https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8",
        "https://cph-msl.akamaized.net/hls/live/2000341/test/master.m3u8",
        "https://l2voddemo.akamaized.net/hls/live/644624/l2vc/master.m3u8"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let playerLayer = AVPlayerLayer(player: player)
        self.playerLayer = playerLayer
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            self.playVideo(at: 1)
        } else {
            // Fallback on earlier versions
        }
    }

    @available(iOS 13.0, *)
    private func playVideo(at index: Int) {
//        let url = URL(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!
//        let videoURL = HLSCachingReverseProxyServer().reverseProxyURL(from: url)!
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        let playerItem = AVPlayerItem(url: videoURL)
//        player.replaceCurrentItem(with: playerItem)
//        present(playerController, animated: true) {
//            self.player.play()
//        }
        
    }

    @objc private func didTapPlayerView(_ sender: UITapGestureRecognizer) {
        if player.rate > 0 {
            player.pause()
        } else {
            player.play()
        }
    }
}
