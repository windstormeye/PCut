//
//  PCutThumbnailManager.swift
//  PCut
//
//  Created by 翁培钧 on 2021/10/24.
//

import Foundation
import AVFoundation

class ThumbnailManager {
    let core: Core
    
    var thumbnails = [Thumbnail]()
    
    init(_ core: Core) {
        self.core = core
    }
}

/// MARK: - Generate thumbnail
extension ThumbnailManager {
    
}

/// MARK: - Helper
extension ThumbnailManager {
    func thumbnailCount(_ duration: CMTime) -> Int {
        let speed: Double = 1
        let duration = CMTimeGetSeconds(duration)
        
        return Int(ceil(duration * core.currentTimeScale / speed))
    }
    
    func containTime(_ thumbnail: Thumbnail) -> Bool {
        return thumbnails.filter { return $0.id == thumbnail.id }.count > 0
    }
}
