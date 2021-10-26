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
    var thumbnailGenarater: AVAssetImageGenerator?
    var thumbnailSrollView: UIScrollView?
    
    /// 时间轴缩放倍数
    var currentTimeScale: Double = 3
    var currentSpeed: Double = 1
    var thumbnails = [PCutThumbnail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NOTE: 这里的 timeScale 为缩放倍数，timeScale 增大说明在执行时间轴放大操作，需要抽出粒度更细的帧，反之说明在执行时间轴缩小操作，需要抽出粒度更粗的帧。
        
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
            let currentSecondes = CMTimeGetSeconds(currentTime)
            let duraion = self.player!.currentItem!.asset.duration
            let durationSeconds = CMTimeGetSeconds(duraion)
            self.timeSlider?.setValue(Float(currentSecondes/durationSeconds), animated: false)
        }
        
        thumbnailSrollView = UIScrollView(frame: CGRect(x: 0, y: 500, width: UIScreen.main.bounds.width, height: 50))
        thumbnailSrollView?.showsVerticalScrollIndicator = false
        thumbnailSrollView?.showsHorizontalScrollIndicator = false
        view.addSubview(thumbnailSrollView!)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gesture:)))
        thumbnailSrollView?.addGestureRecognizer(pinchGesture)
        
        thumbnailSrollView?.panGestureRecognizer.require(toFail: pinchGesture)
        
        let durationLabel = UILabel()
        durationLabel.text = String(format: "%.2fs", CMTimeGetSeconds(videoAsset.duration))
        durationLabel.font = UIFont.systemFont(ofSize: 11)
        durationLabel.sizeToFit()
        durationLabel.frame = CGRect(x: (UIScreen.main.bounds.width - durationLabel.frame.size.width) / 2, y: 20, width: durationLabel.frame.size.width, height: durationLabel.frame.size.height)
        view.addSubview(durationLabel)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if context == &PlayerItemStatusContext {
            let playerItem = object as! AVPlayerItem
            if playerItem.status == AVPlayerItem.Status.readyToPlay {
                player?.play()
                
                generateThumbnails()
            }
        }
    }
    
    func thumbnailCount() -> Int {
        let speed: Double = 1
        let duration = CMTimeGetSeconds(player!.currentItem!.asset.duration)
        
        return Int(ceil(duration * currentTimeScale / speed))
    }
    
    func generateThumbnails() {
        thumbnailGenarater = AVAssetImageGenerator(asset: player!.currentItem!.asset)
        thumbnailGenarater?.maximumSize = CGSize(width: 50, height: 50)
        let duration = player!.currentItem!.asset.duration
        
        var times = [NSValue]()
        let increment = duration.value / Int64(thumbnailCount())
        var currentValue = Int64(2 * duration.timescale)
        while currentValue <= duration.value {
            let time = CMTime(value: CMTimeValue(currentValue), timescale: duration.timescale)
            times.append(NSValue(time: time))
            currentValue += increment
        }
        
        var generateCount = times.count
        
        thumbnailGenarater?.generateCGImagesAsynchronously(forTimes: times, completionHandler: { requestTime, thumbnailImage, actualTime, generateResult, error in
            switch generateResult {
            case .succeeded:
                let thumbnail = PCutThumbnail(time: actualTime, image: thumbnailImage!)
                self.appendThumbnail(thumbnail)
            case .failed:
                if (error != nil) {
                    print(error!.localizedDescription)
                }
            case .cancelled: break
            @unknown default:
                fatalError("error enum value")
            }
            
            generateCount -= 1
            if (generateCount == 0) {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCutThumbnailGeneratorNotification"), object: nil)
                DispatchQueue.main.async {
                    self.refreshThumbnail()
                }
            }
        })
    }
    
    func refreshThumbnail() {
        let imageSize = CGSize(width: thumbnails.first!.image!.width,
                               height: thumbnails.first!.image!.height)
        var offsetX: CGFloat = 0
        let imageRect = CGRect(x: offsetX,
                               y: 0,
                               width: imageSize.width,
                               height: imageSize.height)
        let imageWidth = imageRect.width * CGFloat(thumbnails.count)
        thumbnailSrollView?.contentSize = CGSize(width: imageWidth,
                                                 height: imageRect.size.height)
        thumbnailSrollView?.frame = CGRect(x: 0,
                                           y: thumbnailSrollView!.frame.origin.y,
                                           width: thumbnailSrollView!.frame.size.width,
                                           height: imageSize.height)
        for thumbnail in thumbnails {
            thumbnail.frame = CGRect(x: offsetX,
                                     y: 0,
                                     width: imageRect.size.width,
                                     height: imageRect.size.height)
            thumbnailSrollView?.layer.addSublayer(thumbnail)
            offsetX += imageRect.size.width
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
    }
    
    @objc
    func sliderBegin(slider: UISlider) {
        player?.pause()
    }
    
    @objc
    func sliderTouchEnd(slider: UISlider) {
        player?.play()
    }
    
    @objc
    func pinchGesture(gesture: UIPinchGestureRecognizer) {
        currentTimeScale = gesture.scale
        generateThumbnails()
        print(currentTimeScale)
    }
}

extension ViewController {
    func appendThumbnail(_ thumbnail: PCutThumbnail) {
        let filterThumbnails = thumbnails.filter {
            return thumbnail.time == $0.time
        }
        if (filterThumbnails.count == 0) {
            thumbnails.append(thumbnail)
            return
        }
        
        let index = thumbnails.firstIndex(of: filterThumbnails.first!)
        thumbnails[index!] = thumbnail
    }
}
