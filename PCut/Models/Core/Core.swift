//
//  PCutCore.swift
//  PCut
//
//  Created by PJHubs on 2021/10/29.
//

import Foundation
import CoreMedia
import AVFoundation
import Photos
import Toaster

class Core {
    var currentTime = CMTime.zero
    var playerView: PlayerView    
    var timeline = Timeline()
    
    /// timeline scale
    var currentTimeScale: Double = 1
    /// segment speed
    var currentSpeed: Double = 1
    
    private let composition = AVMutableComposition()
    /// 单独的视频轨道
    private var compositionVideoTrack: AVMutableCompositionTrack?
    /// 单独的音频轨道
    private var compositionAudioTrack: AVMutableCompositionTrack?
    
    
    init() {
        // 创建出一个单独的视频轨道
        compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())
        // 创建出一个单独的音频轨道
        compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        playerView = PlayerView(playerItem: AVPlayerItem(asset: composition))
        
    }
    
    func avPlayer() -> AVPlayer {
        return playerView.player!
    }
}

// MARK: - Mix Segments
extension Core {
    func insertSegmentVideo(insertTime: CMTime,
                            trackIndex: Int,
                            segmentVideo: VideoSegment) {
        timeline.videoSegments.append(segmentVideo)
        let videoAssetTrack = segmentVideo.asset.tracks(withMediaType: .video).first!
        let audioAssetTrack = segmentVideo.asset.tracks(withMediaType: .audio).first!
        do {
            // 更新 segment 中的视频资源到播放器的视频轨道中
            try compositionVideoTrack!.insertTimeRange(segmentVideo.timeRange, of: videoAssetTrack, at: insertTime)
            // 更新 segment 中的音频资源到播放器的音频轨道中
            try compositionAudioTrack!.insertTimeRange(segmentVideo.timeRange, of: audioAssetTrack, at: insertTime)
            
            compositionVideoTrack!.preferredTransform = videoAssetTrack.preferredTransform
            avPlayer().replaceCurrentItem(with: AVPlayerItem(asset: composition))
        } catch {
            print("\(error)")
        }
    }
}

// MARK: - Export Videos
extension Core {
    func onlyVideoExport() {
        let exportSession = AVAssetExportSession(asset: self.composition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.timeRange = CMTimeRange(start: avPlayer().currentItem!.reversePlaybackEndTime,
                                               duration: avPlayer().currentItem!.forwardPlaybackEndTime)
        exportSession?.outputFileType = exportSession?.supportedFileTypes.first
        let exportPath = NSTemporaryDirectory().appending("video.mov")
        let exportUrl = URL(fileURLWithPath: exportPath)
        exportSession?.outputURL = exportUrl
        
        exportSession?.exportAsynchronously {
            PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportUrl)}) { saved, error in
                if saved {
                    print("Saved")
                }
            }
        }
    }
    
    func mixAssetsVideoExport() {
        let size = self.compositionVideoTrack!.naturalSize
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let videolayer = CALayer()
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.addSublayer(videolayer)
        
        for var textSegment in self.timeline.textSegments {
            let fontSize = size.width / (UIScreen.main.bounds.size.width / textSegment.fontSize)
            textSegment.fontSize = fontSize
            
            let titleLayer = TextLayer(textSegment, previewMode: false)
            titleLayer.frame.origin = CGPoint(x: (size.width - titleLayer.frame.size.width)/2,
                                              y: titleLayer.frame.origin.y)
            parentlayer.addSublayer(titleLayer)
        }

        // 视频混合器
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(value: 1, timescale: 60)
        layercomposition.renderSize = size
        // Core Animation 混合
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)

        // 视频修改器，必须有，作为视频混合器的配置项
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: self.composition.duration)
        let videotrack = self.composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        instruction.layerInstructions = [layerinstruction]
        layercomposition.instructions = [instruction]


        let assetExport = AVAssetExportSession(asset: self.composition, presetName:AVAssetExportPresetHighestQuality)
        assetExport?.outputFileType = AVFileType.mov
        assetExport?.videoComposition = layercomposition

        let exportPath = NSTemporaryDirectory().appending("video.mov")
        let exportUrl = URL(fileURLWithPath: exportPath)
        assetExport?.outputURL = exportUrl
        _ = try? FileManager().removeItem(at: exportUrl)
        
        assetExport?.exportAsynchronously(completionHandler: {
            switch assetExport!.status {
            case AVAssetExportSession.Status.failed:
                PCutToast.show("导出视频到相册失败\(assetExport!.error!.localizedDescription)")
            case AVAssetExportSession.Status.cancelled:
                PCutToast.show("导出视频到相册失败\(assetExport!.error!.localizedDescription)")
            default:
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportUrl as URL)
                }) { saved, error in
                    if saved {
                        PCutToast.show("导出视频到相册成功")
                    }
                }
            }
        })
    }
}

// MARK: Update UI
extension Core {
    func updateTextUI() {
        
    }
}

// MARK: - Status
extension Core {
    func isPlaying() -> Bool {
        return playerView.player?.timeControlStatus == .playing
    }
}
