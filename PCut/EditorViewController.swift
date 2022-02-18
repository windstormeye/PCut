//
//  EditorViewController.swift
//  PCut
//
//  Created by 翁培钧 on 2021/10/21.
//

import UIKit
import AVFoundation
import Vision
import Photos


class EditorViewController: UIViewController {

    let thumbnailWidth: CGFloat = 50
    let composition = AVMutableComposition()
    let videoOutput = AVPlayerItemVideoOutput()
    
    var thumbnailSrollView: UIScrollView?
    var thumbnailManager: PCutThumbnailManager?
    var indicator: PCutTimelineIndicator?
    var playerControlView = PCutPlayerCotrolView()
    var importVideoView = PCutImportVideoView()
    var imagePickerController = UIImagePickerController()
    var timelineImportVideoButton = PCutTimelineImportVideoButton()
    var chaseTime = CMTime.zero
    var isSeekInProgress = false
    var playerCurrentItemStatus: AVPlayerItem.Status = .unknown
    var preview = PCutPreview()
    var bottomBar = PCutBottomSegmentBar()
    
    var core = PCutCore()
    /// frame data source
    var thumbnails = [PCutThumbnail]()
    /// frame collections on the screen
    var screenThumbnails = [PCutThumbnail]()
    var videoTrackSegmentViews = [PCutVideoTrackSegmentView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initLayout()
        
        observe()
    }
    
    private func initView() {
        view.backgroundColor = UIColor.black
        
        core.player.delegate = self
        thumbnailManager = PCutThumbnailManager(core)
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.movie"]
        
        view.addSubview(core.player)
        view.addSubview(preview)


        playerControlView = PCutPlayerCotrolView(core: core)
        view.addSubview(playerControlView)
        
        view.addSubview(importVideoView)
        importVideoView.core = core
        importVideoView.deletega = self
        
        
        thumbnailSrollView = UIScrollView()
        view.addSubview(thumbnailSrollView!)
        thumbnailSrollView?.showsVerticalScrollIndicator = false
        thumbnailSrollView?.showsHorizontalScrollIndicator = false
        thumbnailSrollView?.delegate = self
        thumbnailSrollView?.bounces = false
        thumbnailSrollView?.isHidden = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gesture:)))
        thumbnailSrollView?.addGestureRecognizer(pinchGesture)
//        thumbnailSrollView?.panGestureRecognizer.require(toFail: pinchGesture)
    
        
        indicator = PCutTimelineIndicator()
        view.addSubview(indicator!)
        indicator?.isHidden = true
        
        view.addSubview(timelineImportVideoButton)

        timelineImportVideoButton.isHidden = true
        timelineImportVideoButton.addTarget(self,
                                            action: #selector(EditorViewController.timelineImportVideo),
                                            for: .touchUpInside)
        
        let textItem = PCutBottomItem(itemTitle: "文字", itemImageName: "textformat.alt")
        let stickerItem = PCutBottomItem(itemTitle: "贴纸", itemImageName: "theatermasks.fill")
        let audioItem = PCutBottomItem(itemTitle: "音效", itemImageName: "music.quarternote.3")
        let filterItem = PCutBottomItem(itemTitle: "特效", itemImageName: "wand.and.stars.inverse")
        let videoItem = PCutBottomItem(itemTitle: "视频", itemImageName: "crop")
//        bottomBar = PCutBottomBar(items: [videoItem, textItem, stickerItem, audioItem, filterItem])
        bottomBar = PCutBottomSegmentBar(items: [videoItem, textItem, stickerItem, audioItem, filterItem])
        view.addSubview(bottomBar)
    }
    
    private func initLayout() {
        
        let playerHeight = CGFloat(UIScreen.main.bounds.size.width / 16 * 10)
        core.player.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalTo(playerHeight)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        preview.snp.makeConstraints({ make in
            make.size.equalTo(core.player)
            make.top.equalTo(core.player)
        })
        
        
        playerControlView.snp.makeConstraints { make in
            make.top.equalTo(core.player.snp.bottom)
            make.width.equalTo(view)
            make.height.equalTo(70)
        }
        
        importVideoView.snp.makeConstraints { make in
            make.top.equalTo(playerControlView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(100)
        }
        
        thumbnailSrollView?.snp.makeConstraints({ make in
            make.top.equalTo(importVideoView).offset(20)
            make.width.equalToSuperview()
            make.height.equalTo(thumbnailWidth)
        })
        
        indicator?.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(thumbnailSrollView!.snp.height).offset(40)
            make.top.equalTo(thumbnailSrollView!.snp.top).offset(-20)
        })
        
        timelineImportVideoButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.size.equalTo(50)
            make.centerY.equalTo(self.thumbnailSrollView!)
        }
        
        bottomBar.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
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
extension EditorViewController: PCutPlayerProtocol {
    func readyToPlay(_ player: PCutPlayer) {
//        generateThumbnails()
    }
}

extension EditorViewController: UIScrollViewDelegate {
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

extension EditorViewController: PCutImportVideoViewDelegate {
    func importVideo(_ view: PCutImportVideoView) {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
}


extension EditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let asset = AVAsset(url: info[UIImagePickerController.InfoKey.mediaURL] as! URL)
        let videoSegment = PCutVideoSegment(asset: asset, timeRange: CMTimeRange(start: .zero, duration: asset.duration))
        let videoTrackSegmentView = PCutVideoTrackSegmentView(videoSegment: videoSegment)
        thumbnailSrollView?.addSubview(videoTrackSegmentView)
        
        var insertTime = CMTime.zero
        if (core.timeline.videoSegments.count != 0) {
            insertTime = core.avPlayer().currentItem!.asset.duration
        }
        core.insertSegmentVideo(insertTime: insertTime,
                                trackIndex: 0,
                                segmentVideo: videoSegment)
        generateThumbnails(videoTrackSegmentView)
        
        let textSegment = PCutTextSegment(string: "233",
                                          fontSize: 75,
                                          textColor: .white,
                                          backgroundColor: .black,
                                          duration: CMTimeMake(value: 1, timescale: 1),
                                          startTime: CMTimeMake(value: 2, timescale: 1))
        core.timeline.textSegments.append(textSegment)
        
//        core.mixAssetsVideoExport()
        
        self.imagePickerController.dismiss(animated: true, completion: nil)
    }
}

extension EditorViewController {
    @objc
    private func timelineImportVideo() {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
}

