//
//  EditorViewController+Action.swift
//  PCut
//
//  Created by wengpeijun on 2022/2/21.
//

import UIKit
import AVFoundation

extension EditorViewController {
    @objc
    func timelineImportVideo() {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    func itemAction(_ itemIndex: Int) {
        
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
