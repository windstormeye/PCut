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
    
    var thumbnailSrollView: UIScrollView?
    var detectedFaceRectangleShapeLayer: CAShapeLayer?
    var trackingRequests: [VNTrackObjectRequest]?
    var detectionRequests: [VNDetectFaceRectanglesRequest]?
    var emoji: UILabel?
    var thumbnailManager: PCutThumbnailManager?
    var indicator: PCutTimelineIndicator?
    var playerControlView = PCutPlayerCotrolView()
    var importVideoView = PCutImportVideoView()
    var imagePickerController = UIImagePickerController()
    var timelineImportVideoButton = PCutTimelineImportVideoButton()
    var chaseTime = CMTime.zero
    var isSeekInProgress = false
    var playerCurrentItemStatus: AVPlayerItem.Status = .unknown
    
    var core = PCutCore()
    /// frame data source
    var thumbnails = [PCutThumbnail]()
    /// frame collections on the screen
    var screenThumbnails = [PCutThumbnail]()
    var videoTrackSegmentViews = [PCutVideoTrackSegmentView]()
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.movie"]
        
        view.addSubview(core.player)
        let playerHeight = CGFloat(UIScreen.main.bounds.size.width / 16 * 10)
        core.player.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalTo(playerHeight)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
//        core.avPlayer().currentItem?.add(videoOutput)
        core.player.delegate = self
        
        thumbnailManager = PCutThumbnailManager(core)
        
        // TODO: displayLink 方法内部逻辑会抢占 UI 线程导致卡顿，需要查一下为啥
//        let displayLink = CADisplayLink(target: self, selector: #selector(ViewController.displayLinkRefresh))
//        displayLink.add(to: .main, forMode: .common)
        
        let _playerControlView = PCutPlayerCotrolView(core: core)
        playerControlView = _playerControlView
        view.addSubview(playerControlView)
        playerControlView.snp.makeConstraints { make in
            make.top.equalTo(core.player.snp.bottom)
            make.width.equalTo(view)
            make.height.equalTo(70)
        }
        
        view.addSubview(importVideoView)
        importVideoView.core = core
        importVideoView.deletega = self
        importVideoView.snp.makeConstraints { make in
            make.top.equalTo(playerControlView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(100)
        }
        
        thumbnailSrollView = UIScrollView()
        view.addSubview(thumbnailSrollView!)
        thumbnailSrollView?.snp.makeConstraints({ make in
            make.top.equalTo(importVideoView).offset(20)
            make.width.equalToSuperview()
            make.height.equalTo(thumbnailWidth)
        })
        thumbnailSrollView?.showsVerticalScrollIndicator = false
        thumbnailSrollView?.showsHorizontalScrollIndicator = false
        thumbnailSrollView?.delegate = self
        thumbnailSrollView?.bounces = false
        thumbnailSrollView?.isHidden = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gesture:)))
        thumbnailSrollView?.addGestureRecognizer(pinchGesture)
//        thumbnailSrollView?.panGestureRecognizer.require(toFail: pinchGesture)
        
        emoji = UILabel()
        emoji?.text = "😆"
        emoji?.font = UIFont.boldSystemFont(ofSize: 100)
        emoji?.sizeToFit()
//        view.addSubview(emoji!)
        
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
        
        indicator = PCutTimelineIndicator()
        view.addSubview(indicator!)
        indicator?.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(thumbnailSrollView!.snp.height).offset(40)
            make.top.equalTo(thumbnailSrollView!.snp.top).offset(-20)
        })
        indicator?.isHidden = true
        
        view.addSubview(timelineImportVideoButton)
        timelineImportVideoButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.size.equalTo(50)
            make.centerY.equalTo(self.thumbnailSrollView!)
        }
        timelineImportVideoButton.isHidden = true
        timelineImportVideoButton.addTarget(self,
                                            action: #selector(ViewController.timelineImportVideo),
                                            for: .touchUpInside)
        
        observe()
    }
    
    func observe() {
        // NOTE: 1/30, per frame callback once
        core.avPlayer().addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: DispatchQueue.main) { currentTime in
            if (!self.core.isPlaying()) {
                return
            }
            
            // TODO: 这个方法内容会做 scrollView 偏移，需要调整逻辑
            let currentSecondes = CMTimeGetSeconds(currentTime)
            let duraion = self.core.avPlayer().currentItem!.asset.duration
            let durationSeconds = CMTimeGetSeconds(duraion)
            let value = CGFloat(currentSecondes/durationSeconds)
            
            let contentOffsetX = value * (self.thumbnailSrollView!.contentSize.width - UIScreen.main.bounds.size.width)
            self.thumbnailSrollView?.contentOffset = CGPoint(x: contentOffsetX, y: 0)
        }
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
    
    
    func generateThumbnails(_ videoSegmentView: PCutVideoTrackSegmentView) {
        let thumbnailGenarater = AVAssetImageGenerator(asset: videoSegmentView.videoSegment!.asset)
        thumbnailGenarater.maximumSize = CGSize(width: thumbnailWidth, height: thumbnailWidth)
        // NOTE: turn off AVAssetImageGenerator thumbnail generate buffer
        thumbnailGenarater.requestedTimeToleranceAfter = .zero
        thumbnailGenarater.requestedTimeToleranceBefore = .zero
        // NOTE: resize video angle
        thumbnailGenarater.appliesPreferredTrackTransform = true
        let duration = videoSegmentView.videoSegment!.asset.duration
        
        var times = [NSValue]()
        let increment = duration.value / Int64(thumbnailManager!.thumbnailCount(videoSegmentView.videoSegment!.asset.duration))
        var currentValue = Int64(2 * duration.timescale)
        while currentValue <= duration.value {
            let time = CMTime(value: CMTimeValue(currentValue), timescale: duration.timescale)
            // TODO: 优化下少抽几帧
            times.append(NSValue(time: time))
            
            currentValue += increment
        }
        var generateCount = times.count
        var currentThumbnails = [PCutThumbnail]()
        
        DispatchQueue.global(qos: .background).async {
            thumbnailGenarater.generateCGImagesAsynchronously(forTimes: times, completionHandler: { requestTime, thumbnailImage, actualTime, generateResult, error in
                switch generateResult {
                case .succeeded:
                    let thumbnail = PCutThumbnail(id:videoSegmentView.videoSegment!.id,
                                                  time: actualTime,
                                                  image: thumbnailImage!)
                    thumbnail.frame.size = CGSize(width: self.thumbnailWidth, height: self.thumbnailWidth)
                    if (!self.thumbnailManager!.containTime(thumbnail)) {
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
                        self.refreshThumbnail(newThumbnails: currentThumbnails,
                                              segmentView: videoSegmentView)
                    }
                }
            })
        }
    }
    
    func refreshThumbnail(newThumbnails: [PCutThumbnail],
                          segmentView: PCutVideoTrackSegmentView) {
        var offsetX: CGFloat = 0
        let imageSize = CGSize(width: thumbnailWidth, height: thumbnailWidth)
        let imageWidth = imageSize.width * CGFloat(newThumbnails.count)
        segmentView.frame.size = CGSize(width: imageWidth, height: thumbnailWidth)
        segmentView.thumbnailView.layer.sublayers?.removeAll()
        
        for thumbnail in newThumbnails {
            thumbnail.frame.origin = CGPoint(x: offsetX, y: 0)
            
            if let sublayers = segmentView.thumbnailView.layer.sublayers {
                var thumbnailLayer = sublayers.filter({ $0.frame.origin.x == offsetX }).first
                if (thumbnailLayer != nil) {
                    thumbnailLayer = thumbnail
                } else {
                    segmentView.thumbnailView.layer.addSublayer(thumbnail)
                }
            } else {
                segmentView.thumbnailView.layer.addSublayer(thumbnail)
            }
            
            offsetX += imageSize.width
        }
        refreshUI()
    }
    
    func refreshUI() {
        var offsetX: CGFloat = UIScreen.main.bounds.size.width / 2
        var totalWidth: CGFloat = 0
        let space: CGFloat = 1
        for (index, subView) in thumbnailSrollView!.subviews.enumerated() {
            subView.frame.origin = CGPoint(x: offsetX, y: 0)
            totalWidth += (subView.frame.size.width + space)
            offsetX = subView.frame.origin.x + subView.frame.size.width + space
            if (index == thumbnailSrollView!.subviews.count - 1) {
                offsetX -= space
                totalWidth -= space
                totalWidth += UIScreen.main.bounds.size.width
            }
        }
        thumbnailSrollView?.contentSize = CGSize(width: totalWidth, height: 0)
        indicator?.isHidden = false
        importVideoView.isHidden = true
        timelineImportVideoButton.isHidden = false
        thumbnailSrollView?.isHidden = false
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
//            generateThumbnails()
        default:
            break;
        }
    }
}

/// MARK: - PCutPlayerProtocol
extension ViewController: PCutPlayerProtocol {
    func readyToPlay(_ player: PCutPlayer) {
//        generateThumbnails()
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (core.isPlaying()) {
            return
        }
        
        let offsetX = scrollView.contentOffset.x
        let seekPercent = offsetX / (scrollView.contentSize.width - UIScreen.main.bounds.size.width)
        // TODO: 估计与 offset 有关，导致滑动时间轴时不准
        let duraion = core.avPlayer().currentItem!.asset.duration
        let durationSeconds = CMTimeGetSeconds(duraion)
        let currentDurationSeconds = durationSeconds * Float64(seekPercent)
        let currentDuration = CMTimeMakeWithSeconds(currentDurationSeconds, preferredTimescale: duraion.timescale)
        core.avPlayer().seek(to: currentDuration, toleranceBefore: .zero, toleranceAfter: .zero)
        
        print(CMTimeGetSeconds(currentDuration))
        
    }
}

extension ViewController: PCutImportVideoViewDelegate {
    func importVideo(_ view: PCutImportVideoView) {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let asset = AVAsset(url: info[UIImagePickerController.InfoKey.mediaURL] as! URL)
        let videoSegment = PCutVideoSegment(asset: asset, timeRange: CMTimeRange(start: .zero, duration: asset.duration))
        let videoTrackSegmentView = PCutVideoTrackSegmentView(videoSegment: videoSegment)
        thumbnailSrollView?.addSubview(videoTrackSegmentView)
        
        var insertTime = CMTime.zero
        if (core.timeline.segmentVideos.count != 0) {
            insertTime = core.avPlayer().currentItem!.asset.duration
        }
        core.insertSegmentVideo(insertTime: insertTime,
                                trackIndex: 0,
                                segmentVideo: videoSegment)
        generateThumbnails(videoTrackSegmentView)
        
        let textLayer = PCutTextLayer.buildLayerbuildTxt("2333", textSize: 17, textColor: UIColor.white, stroke: UIColor.white, opacity: 1, textRect: CGRect(x: 100, y: 0, width: 100, height: 20), fontPath: nil, viewBounds: core.player.bounds.size, startTime: 0, duration: 5)
        
        
//        core.exportVideo()
        core.pppp()
        
        self.imagePickerController.dismiss(animated: true, completion: nil)
    }
}

extension ViewController {
    @objc
    private func timelineImportVideo() {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
}

