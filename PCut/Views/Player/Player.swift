//
//  PCutPlayer.swift
//  PCut
//
//  Created by PJHubs on 2021/11/1.
//

import Foundation
import AVFoundation
import UIKit

protocol PlayerProtocol {
    func readyToPlay(_ player: PlayerView)
}

extension PlayerProtocol {
    func readyToPlay(_ player: PlayerView) {}
}

class PlayerView: UIView {
    var player: AVPlayer?
    var duration: CGFloat?
    var delegate: PlayerProtocol?
    var playerLayer: AVPlayerLayer?
    
    private var playerItemKVOToken: NSKeyValueObservation?
    private var playerItem: AVPlayerItem?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(playerItem: AVPlayerItem) {
        super.init(frame: CGRect.zero)
        
        player = AVPlayer(playerItem: playerItem)
        self.playerItem = playerItem
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer!)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("音频设置失败：" + error.localizedDescription)
        }
        
        playerItemKVOToken = self.playerItem?.observe(\.status, changeHandler: { _playerItem, value in
            if (_playerItem.status == .readyToPlay) {
                self.delegate?.readyToPlay(self)
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        playerLayer?.frame.size = frame.size
    }
    
    deinit {
        playerItemKVOToken?.invalidate()
    }
}

/// MARK: - Play
extension PlayerView {
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seekToTime(_ time: CMTime) {
        
    }
    
    func scrollToTime(_ time: CMTime) {
        
    }
    
    func replay() {
        
    }
}
