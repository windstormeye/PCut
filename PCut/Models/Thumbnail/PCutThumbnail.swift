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
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(time: CMTime, image: CGImage) {
        self.init()
        contents = image
        
        self.time = time
        self.image = image
    }
}
