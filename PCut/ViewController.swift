//
//  ViewController.swift
//  PCut
//
//  Created by 翁培钧 on 2021/10/21.
//

import UIKit
import AVFoundation

var PlayerItemStatusContext = 0


class ViewController: UIViewController {

    var player: AVPlayer?
    var timeSlider: UISlider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoUrl = Bundle.main.url(forResource: "test_video", withExtension: "mov")
        let videoAsset = AVAsset(url: videoUrl!)
        let playerItem = AVPlayerItem(asset: videoAsset)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player!)
        playerLayer.frame = CGRect(x: 0, y: 45, width: view.bounds.width, height: view.bounds.height/3)
        view.layer.addSublayer(playerLayer)
        
        
        playerItem.addObserver(self,
                               forKeyPath: "status",
                               options: NSKeyValueObservingOptions.initial,
                               context: &PlayerItemStatusContext)
        
        timeSlider = UISlider(frame: CGRect(x: 50, y: playerLayer.frame.size.height + playerLayer.frame.origin.y, width: UIScreen.main.bounds.width - 100, height: 50))
        view.addSubview(timeSlider!)
        timeSlider!.minimumValue = 0
        timeSlider!.maximumValue = 1;
        timeSlider!.addTarget(self,
                              action: #selector(ViewController.sliderChange(slider:)),
                              for: UIControl.Event.valueChanged)
        timeSlider!.addTarget(self,
                              action: #selector(ViewController.sliderBegin(slider:)),
                              for: UIControl.Event.touchDown)
        timeSlider!.addTarget(self,
                              action: #selector(ViewController.sliderTouchEnd(slider:)),
                              for: UIControl.Event.touchUpInside)
        
        // NOTE: 1/30，也即 1 帧回调一次
        player!.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: DispatchQueue.main) { currentTime in
            print(CMTimeGetSeconds(currentTime))
            let currentSecondes = CMTimeGetSeconds(currentTime)
            let duraion = self.player!.currentItem!.asset.duration
            let durationSeconds = CMTimeGetSeconds(duraion)
            self.timeSlider?.setValue(Float(currentSecondes/durationSeconds), animated: false)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if context == &PlayerItemStatusContext {
            let playerItem = object as! AVPlayerItem
            if playerItem.status == AVPlayerItem.Status.readyToPlay {
                player?.play()
            }
        }
    }
    
    @objc
    func sliderChange(slider: UISlider) {
        let sliderValue = slider.value
        
        let duraion = player!.currentItem!.asset.duration
        let durationSeconds = CMTimeGetSeconds(duraion)
        let currentDurationSeconds = durationSeconds * Float64(sliderValue)
        let currentDuration = CMTimeMakeWithSeconds(currentDurationSeconds, preferredTimescale: duraion.timescale)
        player?.seek(to: currentDuration)
        print(sliderValue)
    }
    
    @objc
    func sliderBegin(slider: UISlider) {
        player?.pause()
    }
    
    @objc
    func sliderTouchEnd(slider: UISlider) {
        player?.play()
    }
}

