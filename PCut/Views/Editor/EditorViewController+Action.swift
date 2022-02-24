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
    
    func itemAction(bottomBar: BottomBar, _ item: PCutBottomItem) {
        switch (item.itemIdentifier) {
        case BarItem.textItem.rawValue:
            menu.items = textBottomBarMenuItems()
            break
        case BarItem.videoItem.rawValue: break
        case BarItem.stickerItem.rawValue: break
        case BarItem.audioItem.rawValue: break
        case BarItem.effectItem.rawValue: break
        default:
            break
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
    
    func didSelectedMenuItem(_ item: MenuItem) {
        switch item.itemIdentifier {
        case TextBarItem.subtitleItem.rawValue:
            let textSegment = TextSegment(string: "自动添加的字母",
                                          fontSize: 15,
                                          textColor: .white,
                                          backgroundColor: .black,
                                          duration: CMTimeMake(value: 1, timescale: 1),
                                          startTime: CMTimeMake(value: 2, timescale: 1),
                                          inAnimationKey: "opacity",
                                          outAnimationKey: "opacity",
                                          animationDuration: 0.1)
            core.timeline.textSegments.append(textSegment)
            
            // TODO: 检查为什么没展示
            let titleLayer = TextLayer(textSegment)
            titleLayer.frame = CGRect(x: 0, y: 25, width: core.playerView.frame.size.width, height: 20)
            core.playerView.layer.addSublayer(titleLayer)
            PCutToast.show("字幕添加成功")
        default:
            break
        }
    }
}

extension EditorViewController: ImportVideoViewDelegate {
    func importVideo(_ view: ImportVideoView) {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
}

extension EditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let asset = AVAsset(url: info[UIImagePickerController.InfoKey.mediaURL] as! URL)
        let videoSegment = VideoSegment(asset: asset, timeRange: CMTimeRange(start: .zero, duration: asset.duration))
        let videoTrackSegmentView = VideoTrackSegmentView(videoSegment: videoSegment)
        thumbnailSrollView?.addSubview(videoTrackSegmentView)
        
        var insertTime = CMTime.zero
        if (core.timeline.videoSegments.count != 0) {
            insertTime = core.avPlayer().currentItem!.asset.duration
        }
        core.insertSegmentVideo(insertTime: insertTime,
                                trackIndex: 0,
                                segmentVideo: videoSegment)
        generateThumbnails(videoTrackSegmentView)
        
//        core.mixAssetsVideoExport()
        
        self.imagePickerController.dismiss(animated: true, completion: nil)
    }
}
