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

class PCutCore {
    var currentTime = CMTime.zero
    var player: PCutPlayer    
    var timeline = PCutTimeline()
    
    /// timeline scale
    var currentTimeScale: Double = 1
    /// segment speed
    var currentSpeed: Double = 1
    
    private let composition = AVMutableComposition()
    private var compositionVideoTrack: AVMutableCompositionTrack?
    
    let trackId = CMPersistentTrackID()
    
    
    init() {
        compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackId)
        player = PCutPlayer(playerItem: AVPlayerItem(asset: composition))
        
    }
    
    func avPlayer() -> AVPlayer {
        return player.player!
    }
}

/// MARK: - Mix Segments
extension PCutCore {
    func insertSegmentVideo(insertTime: CMTime,
                            trackIndex: Int,
                            segmentVideo: PCutVideoSegment) {
        timeline.videoSegments.append(segmentVideo)
        let assetTrack = segmentVideo.asset.tracks(withMediaType: .video).first!
        do {
            try compositionVideoTrack!.insertTimeRange(segmentVideo.timeRange,
                                                       of: assetTrack,
                                                       at: insertTime)
            compositionVideoTrack!.preferredTransform = assetTrack.preferredTransform
            avPlayer().replaceCurrentItem(with: AVPlayerItem(asset: composition))
        } catch {
            print("\(error)")
        }
    }
}

/// MARK: - Export Videos
extension PCutCore {
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
        let textSegment = PCutTextSegment(string: "233",
                                          fontSize: 75,
                                          textColor: .white,
                                          backgroundColor: .black)
        let titleLayer = PCutTextLayer(textSegment)
        titleLayer.frame.origin = CGPoint(x: (size.width - titleLayer.frame.size.width)/2, y: titleLayer.frame.origin.y)

        let videolayer = CALayer()
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.addSublayer(videolayer)
        parentlayer.addSublayer(titleLayer)

        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)

        // instruction for watermark
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: self.composition.duration)
        let videotrack = self.composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        instruction.layerInstructions = [layerinstruction]
        layercomposition.instructions = [instruction]


        // use AVAssetExportSession to export video
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

/// MARK: - Status
extension PCutCore {
    func isPlaying() -> Bool {
        return player.player?.timeControlStatus == .playing
    }
}
