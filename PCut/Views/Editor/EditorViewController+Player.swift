//
//  EditorViewController+Player.swift
//  PCut
//
//  Created by wengpeijun on 2022/2/21.
//

import UIKit
import AVFoundation

extension EditorViewController {
    @objc
    func sliderChange(slider: UISlider) {
        let sliderValue = slider.value
        
        let duraion = core.avPlayer().currentItem!.asset.duration
        let durationSeconds = CMTimeGetSeconds(duraion)
        let currentDurationSeconds = durationSeconds * Float64(sliderValue)
        let currentDuration = CMTimeMakeWithSeconds(currentDurationSeconds, preferredTimescale: duraion.timescale)
        core.avPlayer().seek(to: currentDuration)
    }
    
    @objc
    func sliderBegin(slider: UISlider) {
        core.avPlayer().pause()
    }
    
    @objc
    func sliderTouchEnd(slider: UISlider) {
        core.avPlayer().play()
    }
}
