//
//  PCutThumbnail.swift
//  PCut
//
//  Created by 翁培钧 on 2021/10/24.
//

import UIKit
import AVFoundation

class PCutThumbnail: CALayer {
    var time: CMTime = CMTime.zero
    var image: CGImage?
    var id: String?
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(id: UUID, time: CMTime, image: CGImage) {
        self.init()
        contents = image
        
        self.id = id.uuidString + "\(CMTimeGetSeconds(time))"
        self.time = time
        self.image = image
    }
}
