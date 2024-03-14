//
//  GSVideoController.swift
//  Runner
//
//  Created by Ujas Majithiya on 13/06/23.
//

import Foundation
import GSPlayer
import AVKit

class GSVideoController: UIViewController {
    let playerView = VideoPlayerView()
    
    let url = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
    func setCacheMananger() {
        VideoPreloadManager.shared.preloadByteCount = 1024 * 1024
    }
    
    override func viewDidAppear(_ animated: Bool) {
        play()
    }
    func play(){
        if(url == nil) {
            return
        }
        let controller = AVPlayerViewController()
        controller.player = playerView.player
        present(controller, animated: true) {
            self.playerView.play(for: self.url!)
        }
    }
}
