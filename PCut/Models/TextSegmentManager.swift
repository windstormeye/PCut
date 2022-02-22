//
//  PCutTextSegmentManager.swift
//  PCut
//
//  Created by wengpeijun on 2021/12/5.
//

import Foundation

class TextSegmentManager {
    var core: Core
    
    init(core: Core) {
        self.core = core
    }
    
    func updateTextSegment(_ textSegment: TextSegment) {
        var oldTextSegment = core.timeline.textSegments.filter { ts in
            return textSegment == ts
        }.first
        
        oldTextSegment = textSegment
        core.updateTextUI()
    }
}
