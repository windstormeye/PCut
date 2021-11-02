//
//  ViewController.swift
//  PCut
//
//  Created by 翁培钧 on 2021/10/21.
//

import UIKit
import AVFoundation
import Vision
import Photos


class ViewController: UIViewController {

    let thumbnailWidth: CGFloat = 50
    let composition = AVMutableComposition()
    let videoOutput = AVPlayerItemVideoOutput()
    
    var timeSlider: UISlider?
    var thumbnailGenarater: AVAssetImageGenerator?
    var thumbnailSrollView: UIScrollView?
    var thumbnailView: PCutThumbnailView?
    var detectedFaceRectangleShapeLayer: CAShapeLayer?
    var trackingRequests: [VNTrackObjectRequest]?
    var detectionRequests: [VNDetectFaceRectanglesRequest]?
    var emoji: UILabel?
    var thumbnailManager: PCutThumbnailManager?
    
    var core = PCutCore()
    /// frame data source
    var thumbnails = [PCutThumbnail]()
    /// frame collections on the screen
    var screenThumbnails = [PCutThumbnail]()
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        let videoUrl_0 = Bundle.main.url(forResource: "test_video1", withExtension: "mov")
        let videoAsset_0 = AVAsset(url: videoUrl_0!)
        let videoUrl_1 = Bundle.main.url(forResource: "test_video_2", withExtension: "mov")
        let videoAsset_1 = AVAsset(url: videoUrl_1!)
        
        let videoSegment_0 = PCutSegmentVideo(asset: videoAsset_0, timeRange: CMTimeRange(start: .zero, duration: videoAsset_0.duration))
        let videoSegment_1 = PCutSegmentVideo(asset: videoAsset_1, timeRange: CMTimeRange(start: .zero, duration: videoAsset_1.duration))
        core.timeline.segmentVideos.append(videoSegment_0)
        core.timeline.segmentVideos.append(videoSegment_1)
        
        mixTimelineVideos()
        
        core.player.frame = CGRect(x: 0, y: statusBarHeight(), width: view.bounds.width, height: view.bounds.height/3)
        view.addSubview(core.player)
        
        core.avPlayer().currentItem?.add(videoOutput)
        core.player.delegate = self
        
        thumbnailManager = PCutThumbnailManager(core)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(ViewController.displayLinkRefresh))
        displayLink.add(to: .main, forMode: .common)
        
        timeSlider = UISlider(frame: CGRect(x: 50,
                                            y: core.player.frame.size.height + core.player.frame.origin.y + 50,
                                            width: UIScreen.main.bounds.width - 100,
                                            height: 50))
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
        
        // NOTE: 1/30, per frame callback once
        core.avPlayer().addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: DispatchQueue.main) { currentTime in
            let currentSecondes = CMTimeGetSeconds(currentTime)
            let duraion = self.core.avPlayer().currentItem!.asset.duration
            let durationSeconds = CMTimeGetSeconds(duraion)
            self.timeSlider?.setValue(Float(currentSecondes/durationSeconds), animated: false)
        }
        
        thumbnailSrollView = UIScrollView(frame: CGRect(x: 0, y: 500, width: UIScreen.main.bounds.width, height: thumbnailWidth))
        thumbnailSrollView?.showsVerticalScrollIndicator = false
        thumbnailSrollView?.showsHorizontalScrollIndicator = false
        view.addSubview(thumbnailSrollView!)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gesture:)))
        thumbnailSrollView?.addGestureRecognizer(pinchGesture)
        thumbnailSrollView?.panGestureRecognizer.require(toFail: pinchGesture)
        
        
        thumbnailView = PCutThumbnailView()
        thumbnailView?.frame = CGRect(x: 0, y: 0, width: 0, height: thumbnailSrollView!.frame.size.height)
        thumbnailView?.layer.borderColor = UIColor.white.cgColor
        thumbnailView?.layer.borderWidth = 0.5
        thumbnailView?.layer.cornerRadius = 4
        thumbnailSrollView?.addSubview(thumbnailView!)
        
        emoji = UILabel()
        emoji?.text = "😆"
        emoji?.font = UIFont.boldSystemFont(ofSize: 100)
        emoji?.sizeToFit()
        view.addSubview(emoji!)
        
        let durationLabel = UILabel()
        durationLabel.text = String(format: "%.2fs", CMTimeGetSeconds(self.composition.duration))
        durationLabel.font = UIFont.systemFont(ofSize: 11)
        durationLabel.sizeToFit()
        durationLabel.frame = CGRect(x: (UIScreen.main.bounds.width - durationLabel.frame.size.width) / 2, y: 20, width: durationLabel.frame.size.width, height: durationLabel.frame.size.height)
        view.addSubview(durationLabel)
        
        let faceRectangleShapeLayer = CAShapeLayer()
        faceRectangleShapeLayer.bounds = CGRect(x: -core.player.bounds.size.width/2,
                                                y: -core.player.bounds.size.height,
                                                width: core.player.bounds.size.width,
                                                height: core.player.bounds.size.height)
        faceRectangleShapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        faceRectangleShapeLayer.fillColor = nil
        faceRectangleShapeLayer.strokeColor = UIColor.green.cgColor
        faceRectangleShapeLayer.lineWidth = 2
        faceRectangleShapeLayer.shadowOpacity = 0.7
        faceRectangleShapeLayer.shadowRadius = 5
        detectedFaceRectangleShapeLayer = faceRectangleShapeLayer
        view.layer.addSublayer(detectedFaceRectangleShapeLayer!)
        // TODO: 坐标问题
        
        var requests = [VNTrackObjectRequest]()
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            
            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }
            
            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                  let results = faceDetectionRequest.results else {
                    return
            }
            DispatchQueue.main.async {
                // Add the observations to the tracking list
                for observation in results {
                    let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
                    requests.append(faceTrackingRequest)
                }
                self.trackingRequests = requests
            }
        })
        detectionRequests = [faceDetectionRequest]
        sequenceRequestHandler = VNSequenceRequestHandler()
        
        exportVideo()
    }
    
    @objc
    func displayLinkRefresh() {
        let itemTime = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
        if videoOutput.hasNewPixelBuffer(forItemTime: itemTime) {
            guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) else {
                return
            }
            pixelBufferRefresh(pixelBuffer)
        }
    }
    
    func pixelBufferRefresh(_ pixelBuffer: CVPixelBuffer) {
        guard let requests = self.trackingRequests, !requests.isEmpty else {
            // No tracking object detected, so perform initial detection
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: .up,
                                                            options: [:])
            
            do {
                guard let detectRequests = self.detectionRequests else {
                    return
                }
                try imageRequestHandler.perform(detectRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceRectangleRequest: %@", error)
            }
            return
        }
        
        do {
            try self.sequenceRequestHandler.perform(requests,
                                                    on: pixelBuffer,
                                                    orientation: .up)
        } catch let error as NSError {
            NSLog("Failed to perform SequenceRequest: %@", error)
        }
        
        // Setup the next round of tracking.
        var newTrackingRequests = [VNTrackObjectRequest]()
        for trackingRequest in requests {
            
            guard let results = trackingRequest.results else {
                return
            }
            
            guard let observation = results[0] as? VNDetectedObjectObservation else {
                return
            }
            
            if !trackingRequest.isLastFrame {
                if observation.confidence > 0.3 {
                    trackingRequest.inputObservation = observation
                } else {
                    trackingRequest.isLastFrame = true
                }
                newTrackingRequests.append(trackingRequest)
            }
        }
        self.trackingRequests = newTrackingRequests
        
        if newTrackingRequests.isEmpty {
            // Nothing to track, so abort.
            return
        }
        
        // Perform face landmark tracking on detected faces.
        var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()
        
        // Perform landmark detection on tracked faces.
        for trackingRequest in newTrackingRequests {
            
            let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in
                
                if error != nil {
                    print("FaceLandmarks error: \(String(describing: error)).")
                }
                
                guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
                      let results = landmarksRequest.results else {
                        return
                }
                
                // Perform all UI updates (drawing) on the main queue, not the background queue on which this handler is being called.
                DispatchQueue.main.async {
                    self.drawFaceObservations(results)
                }
            })
            
            guard let trackingResults = trackingRequest.results else {
                return
            }
            
            guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
                return
            }
            let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
            faceLandmarksRequest.inputFaceObservations = [faceObservation]
            
            // Continue to track detected facial landmarks.
            faceLandmarkRequests.append(faceLandmarksRequest)
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: .up,
                                                            options: [:])
            
            do {
                try imageRequestHandler.perform(faceLandmarkRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceLandmarkRequest: %@", error)
            }
        }
    }
    
    fileprivate func drawFaceObservations(_ faceObservations: [VNFaceObservation]) {
        CATransaction.begin()
        
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        let faceRectanglePath = CGMutablePath()
        for faceObservation in faceObservations {
            self.addIndicators(to: faceRectanglePath,
                               for: faceObservation)
        }
        
        detectedFaceRectangleShapeLayer?.path = faceRectanglePath
                
        CATransaction.commit()
    }
    
    fileprivate func addIndicators(to faceRectanglePath: CGMutablePath, for faceObservation: VNFaceObservation) {
        let faceBounds = VNImageRectForNormalizedRect(faceObservation.boundingBox,
                                                      Int(core.player.bounds.size.width),
                                                      Int(core.player.bounds.size.width))
        
        faceRectanglePath.addRect(faceBounds)
        emoji?.frame = CGRect(x: faceBounds.origin.x,
                              y: faceBounds.origin.y,
                              width: emoji!.bounds.size.width,
                              height: emoji!.bounds.size.height)
    }
    
    
    func generateThumbnails() {
        thumbnailGenarater = AVAssetImageGenerator(asset: core.avPlayer().currentItem!.asset)
        thumbnailGenarater?.maximumSize = CGSize(width: thumbnailWidth, height: thumbnailWidth)
        // NOTE: turn off AVAssetImageGenerator thumbnail generate buffer
        thumbnailGenarater?.requestedTimeToleranceAfter = .zero
        thumbnailGenarater?.requestedTimeToleranceBefore = .zero
        // NOTE: resize video angle
        thumbnailGenarater?.appliesPreferredTrackTransform = true
        let duration = core.avPlayer().currentItem!.asset.duration
        
        var times = [NSValue]()
        let increment = duration.value / Int64(thumbnailManager!.thumbnailCount())
        var currentValue = Int64(2 * duration.timescale)
        while currentValue <= duration.value {
            let time = CMTime(value: CMTimeValue(currentValue), timescale: duration.timescale)
            
            if (!thumbnailManager!.containTime(time)) {
                times.append(NSValue(time: time))
            }
            
            currentValue += increment
        }
        var generateCount = times.count
        var currentThumbnails = [PCutThumbnail]()
        
        DispatchQueue.global(qos: .background).async {
            self.thumbnailGenarater?.generateCGImagesAsynchronously(forTimes: times, completionHandler: { requestTime, thumbnailImage, actualTime, generateResult, error in
                switch generateResult {
                case .succeeded:
                    let thumbnail = PCutThumbnail(time: actualTime, image: thumbnailImage!)
                    if (!self.thumbnailManager!.containTime(thumbnail.time)) {
                        self.thumbnails.append(thumbnail)
                    }
                    currentThumbnails.append(thumbnail)
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
                        self.refreshThumbnail(currentThumbnails)
                    }
                }
            })
        }
    }
    
    func refreshThumbnail(_ newThumbnails: [PCutThumbnail]) {
        var offsetX: CGFloat = 0
        let imageRect = CGRect(x: offsetX,
                               y: 0,
                               width: thumbnailWidth,
                               height: thumbnailWidth)
        let imageWidth = imageRect.width * CGFloat(newThumbnails.count)
        thumbnailView?.frame = CGRect(x: 0,
                                      y: 0,
                                      width: imageWidth,
                                      height: thumbnailWidth)
        thumbnailSrollView?.contentSize = CGSize(width: thumbnailView!.frame.size.width,
                                                 height: 0)
        thumbnailView?.layer.sublayers?.removeAll()
        
        for thumbnail in newThumbnails {
            thumbnail.frame = CGRect(x: offsetX,
                                     y: 0,
                                     width: thumbnailWidth,
                                     height: thumbnailWidth)
            
            if let sublayers = thumbnailView!.layer.sublayers {
                var thumbnailLayer = sublayers.filter({ $0.frame.origin.x == offsetX }).first
                if (thumbnailLayer != nil) {
                    thumbnailLayer = thumbnail
                } else {
                    thumbnailView?.layer.addSublayer(thumbnail)
                }
            } else {
                thumbnailView?.layer.addSublayer(thumbnail)
            }
            
            offsetX += imageRect.size.width
        }
    }
    
    func containSublayer(_ offsetX: CGFloat) -> Bool {
        return thumbnailSrollView!.subviews.filter({ $0.frame.origin.x == offsetX }).count > 0
    }
    
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
    
    @objc
    func pinchGesture(gesture: UIPinchGestureRecognizer) {
        
        switch gesture.state {
        case .ended:
            core.currentTimeScale += (gesture.scale - 1)
            if (core.currentTimeScale < 0.1) {
                core.currentTimeScale = 0.1
            }
            if (core.currentTimeScale > 10) {
                core.currentTimeScale = 10
            }
            generateThumbnails()
        default:
            break;
        }
    }
}

extension ViewController {
    func mixTimelineVideos() {
        if core.timeline.segmentVideos.count == 0 {return }
        var cursorTime = CMTime.zero
        
        for segmentVideo in core.timeline.segmentVideos {
            core.insertSegmentVideo(insertTime: cursorTime, trackIndex: 0, segmentVideo: segmentVideo)
            cursorTime = cursorTime + segmentVideo.asset.duration
        }
    }
    
    func exportVideo() {
//        let exportSession = AVAssetExportSession(asset: self.composition, presetName: AVAssetExportPresetHighestQuality)
//        exportSession?.timeRange = CMTimeRange(start: playerItem!.reversePlaybackEndTime,
//                                               duration: playerItem!.forwardPlaybackEndTime)
//        exportSession?.outputFileType = exportSession?.supportedFileTypes.first
//        let exportPath = NSTemporaryDirectory().appending("video.mov")
//        let exportUrl = URL(fileURLWithPath: exportPath)
//        exportSession?.outputURL = exportUrl
//
//        exportSession?.exportAsynchronously {
//            PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportUrl)}) { saved, error in
//                if saved {
//                    print("Saved")
//                }
//            }
//        }
    }
}


extension ViewController: PCutPlayerProtocol {
    func readyToPlay(_ player: PCutPlayer) {
        generateThumbnails()
    }
}


extension ViewController {
    func statusBarHeight() -> CGFloat {
        let statusBarManager = UIApplication.shared.windows.first?.windowScene?.statusBarManager
        return statusBarManager!.statusBarFrame.size.height
    }
}
