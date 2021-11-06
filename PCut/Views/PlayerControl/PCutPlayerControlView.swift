//
//  PCutPlayerControlView.swift
//  PCut
//
//  Created by bytedance on 2021/11/6.
//

import Foundation
import UIKit
import SnapKit


class PCutPlayerCotrolView: UIView {
    
    var core = PCutCore()
    
    var preSegmentButton = UIButton()
    var nextSegmentButton = UIButton()
    var playButton = UIButton()
    
    init() {
        super.init(frame: .zero)
    }
    
    init(core: PCutCore) {
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
        
        playButton.setImage(UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        playButton.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.center.equalTo(self)
        }
        
        preSegmentButton.setImage(UIImage(systemName: "backward.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        preSegmentButton.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.right.equalTo(playButton.snp.left)
        }
        
        nextSegmentButton.setImage(UIImage(systemName: "forward.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        nextSegmentButton.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.left.equalTo(playButton.snp.right)
        }
        
        playButton.addTarget(self,
                             action: #selector(PCutPlayerCotrolView.togglePlayerStatus),
                             for: .touchUpInside)
    }
}

extension PCutPlayerCotrolView {
    @objc
    func togglePlayerStatus() {
        if (core.isPlaying()) {
            core.player.pause()
            playButton.setImage(UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            core.player.play()
            playButton.setImage(UIImage(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
}
