//
//  PCutPlayer.swift
//  PCut
//
//  Created by PJHubs on 2021/11/1.
//

import Foundation
import AVFoundation
import UIKit

protocol PCutPlayerProtocol {
    func readyToPlay(_ player: PCutPlayer)
}

extension PCutPlayerProtocol {
    func readyToPlay(_ player: PCutPlayer) {}
}

class PCutPlayer: UIView {
    var player: AVPlayer?
    var duration: CGFloat?
    var size: CGSize?
    var delegate: PCutPlayerProtocol?
    
    private var playerItemKVOToken: NSKeyValueObservation?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    
    override var frame: CGRect {
        set {
            super.frame = newValue
            playerLayer?.frame = newValue
        }
        get {
            return super.frame
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(playerItem: AVPlayerItem) {
        super.init(frame: CGRect.zero)
        
        player = AVPlayer(playerItem: playerItem)
        self.playerItem = playerItem
        
        playerLayer = AVPlayerLayer(player: player)
        layer.addSublayer(playerLayer!)
        
        playerItemKVOToken = self.playerItem?.observe(\.status, changeHandler: { _playerItem, value in
            if (_playerItem.status == .readyToPlay) {
                self.player?.play()
                self.delegate?.readyToPlay(self)
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
