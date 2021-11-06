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

class PCutCore {
    var currentTime = CMTime.zero
    var player: PCutPlayer    
    var timeline = PCutTimeline()
    
    /// timeline scale
    var currentTimeScale: Double = 1
    /// segment speed
    var currentSpeed: Double = 1
    
    private var playerItem: AVPlayerItem?
    private let composition = AVMutableComposition()
    private var compositionVideoTrack: AVMutableCompositionTrack?
    
    let trackId = CMPersistentTrackID()
    
    
    init() {
        playerItem  = AVPlayerItem(asset: composition)
        compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackId)
        player = PCutPlayer(playerItem: playerItem!)
        
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
        let assetTrack = segmentVideo.asset.tracks(withMediaType: .video).first!
        do {
            try compositionVideoTrack?.insertTimeRange(segmentVideo.timeRange,
                                                       of: assetTrack,
                                                       at: insertTime)
        } catch {
            print("\(error)")
        }
    }
}

/// MARK: - Export Videos
extension PCutCore {
    func exportVideo() {
        let exportSession = AVAssetExportSession(asset: self.composition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.timeRange = CMTimeRange(start: playerItem!.reversePlaybackEndTime,
                                               duration: playerItem!.forwardPlaybackEndTime)
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
}

/// MARK: - Status
extension PCutCore {
    func isPlaying() -> Bool {
        return player.player?.timeControlStatus == .playing
    }
}
