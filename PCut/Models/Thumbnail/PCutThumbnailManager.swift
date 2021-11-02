//
//  PCutThumbnailManager.swift
//  PCut
//
//  Created by 翁培钧 on 2021/10/24.
//

import Foundation
import AVFoundation

class PCutThumbnailManager {
    let core: PCutCore
    
    var thumbnails = [PCutThumbnail]()
    
    init(_ core: PCutCore) {
        self.core = core
    }
}

/// MARK: - Generate thumbnail
extension PCutThumbnailManager {
    
}

/// MARK: - Helper
extension PCutThumbnailManager {
    func thumbnailCount() -> Int {
        let speed: Double = 1
        let duration = CMTimeGetSeconds(core.avPlayer().currentItem!.asset.duration)
        
        return Int(ceil(duration * core.currentTimeScale / speed))
    }
    
    func containTime(_ time: CMTime) -> Bool {
        return thumbnails.filter { return $0.time == time }.count > 0
    }
}
