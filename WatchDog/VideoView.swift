//
//  VideoView.swift
//  WatchDog
//
//  Created by 姚逸晨 on 2/11/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoView: UIView {

    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isLoop: Bool = false
    var playButton: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    // AVPlayer configuration, the view source is from the firebase storage url
    func configure(url: URL) {
        
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = AVLayerVideoGravity.resize
        if let playerLayer = self.playerLayer {
            layer.addSublayer(playerLayer)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    // AVPlayer play function
    func play() {
        if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
            player?.play()
        }
    }
    
    // AVPlayer pause function
    func pause() {
        player?.pause()
    }
    
    // AVPlayer stop function
    func stop() {
        player?.pause()
        player?.seek(to: CMTime.zero)
    }
    
    // If the view reaches the end, decide whether the video is loop or not
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        if isLoop {
            player?.pause()
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }

}
