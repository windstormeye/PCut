//
//  PCutPlayer.swift
//  PCut
//
//  Created by PJHubs on 2021/11/1.
//

import Foundation
import AVFoundation

class PCutPlayer {
    var player: AVPlayer?
    var duration: CGFloat?
    var size: CGSize?
    
    private var playerItem: AVPlayerItem

    
    init(playerItem: AVPlayerItem) {
        self.playerItem = playerItem
    }
    
//    private func 
}

/// MARK: - Play
extension PCutPlayer {
    func play() {
        
    }
    
    func pause() {
        
    }
    
    func seekToTime(_ time: CMTime) {
        
    }
    
    func scrollToTime(_ time: CMTime) {
        
    }
    
    func replay() {
        
    }
}
