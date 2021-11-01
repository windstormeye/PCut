//
//  PCutCore.swift
//  PCut
//
//  Created by PJHubs on 2021/10/29.
//

import Foundation
import CoreMedia
import AVFoundation

class PJCutCore {
    var currentTime = CMTime.zero
    var player: PCutPlayer?
    var timeline: PCutTimeline?
    
    private var playerItem: AVPlayerItem?
    private let composition = AVMutableComposition()
    
    
    init() {
        playerItem  = AVPlayerItem(asset: composition)
        player = PCutPlayer(playerItem: playerItem!)
        
    }
}

/// MARK: - Mix Segments
extension PJCutCore {
    func insertSegmentVideo(insertTime: CMTime,
                            trackIndex: Int,
                            segmentVideo: PCutSegmentVideo) {
        let trackId = CMPersistentTrackID()
        let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackId)
        
        let assetTrack = segmentVideo.asset.tracks(withMediaType: .video).first!
        do {
            try compositionTrack?.insertTimeRange(segmentVideo.timeRange,
                                                  of: assetTrack,
                                                  at: insertTime)
        } catch {
            print("\(error)")
        }
    }
}
