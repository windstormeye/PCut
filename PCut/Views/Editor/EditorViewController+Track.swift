//
//  EditorViewController+Track.swift
//  PCut
//
//  Created by wengpeijun on 2022/2/21.
//

import AVFoundation
import UIKit

extension EditorViewController {
    func generateThumbnails(_ videoSegmentView: VideoTrackSegmentView) {
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
        var currentThumbnails = [Thumbnail]()
        
        DispatchQueue.global(qos: .background).async {
            thumbnailGenarater.generateCGImagesAsynchronously(forTimes: times, completionHandler: { requestTime, thumbnailImage, actualTime, generateResult, error in
                switch generateResult {
                case .succeeded:
                    let thumbnail = Thumbnail(id:videoSegmentView.videoSegment!.id,
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
    
    func refreshThumbnail(newThumbnails: [Thumbnail],
                          segmentView: VideoTrackSegmentView) {
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
}

// MARK: UIScrollViewDelegate
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
