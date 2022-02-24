//
//  PCutPlayerControlView.swift
//  PCut
//
//  Created by bytedance on 2021/11/6.
//

import Foundation
import UIKit
import SnapKit


class PlayerCotrolView: UIView {
    
    var core = Core()
    
    var preSegmentButton = UIButton()
    var nextSegmentButton = UIButton()
    var playButton = UIButton()
    
    init() {
        super.init(frame: .zero)
    }
    
    init(core: Core) {
        self.core = core
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(playButton)
        addSubview(preSegmentButton)
        addSubview(nextSegmentButton)
        
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 20)
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: buttonConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        playButton.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.center.equalTo(self)
        }
        
        preSegmentButton.setImage(UIImage(systemName: "backward.fill", withConfiguration: buttonConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        preSegmentButton.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.right.equalTo(playButton.snp.left)
        }
        
        nextSegmentButton.setImage(UIImage(systemName: "forward.fill", withConfiguration: buttonConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        nextSegmentButton.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.left.equalTo(playButton.snp.right)
        }
        
        playButton.addTarget(self,
                             action: #selector(PlayerCotrolView.togglePlayerStatus),
                             for: .touchUpInside)
    }
}

extension PlayerCotrolView {
    @objc
    func togglePlayerStatus() {
        if (core.isPlaying()) {
            core.playerView.pause()
            playButton.setImage(UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            core.playerView.play()
            playButton.setImage(UIImage(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
}
