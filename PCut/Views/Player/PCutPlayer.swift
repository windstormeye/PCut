//
//  PCutPlayer.swift
//  PCut
//
//  Created by PJHubs on 2021/11/1.
//

import Foundation
import AVFoundation

protocol PCutPlayerProtocol {
    func readyToPlay(_ player: PCutPlayer)
}

extension PCutPlayerProtocol {
    func readyToPlay(_ player: PCutPlayer) {}
}

class PCutPlayer: NSObject {
    var player: AVPlayer?
    var duration: CGFloat?
    var size: CGSize?
    var delegate: PCutPlayerProtocol?
    
    private var playerItemKVOToken: NSKeyValueObservation?
    
    private var playerItem: AVPlayerItem?

    
    init(playerItem: AVPlayerItem) {
        super.init()
        
        player = AVPlayer(playerItem: playerItem)
        self.playerItem = playerItem
        
        
        playerItemKVOToken = self.playerItem?.observe(\.status, changeHandler: { _playerItem, value in
            if (_playerItem.status == .readyToPlay) {
                self.player?.play()
                self.delegate?.readyToPlay(self)
            }
        })
    }
    
    deinit {
        playerItemKVOToken?.invalidate()
    }
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
