//
//  PCutTextSegmentManager.swift
//  PCut
//
//  Created by wengpeijun on 2021/12/5.
//

import Foundation

class PCutTextSegmentManager {
    var core: PCutCore
    
    init(core: PCutCore) {
        self.core = core
    }
    
    func updateTextSegment(_ textSegment: PCutTextSegment) {
        var oldTextSegment = core.timeline.textSegments.filter { ts in
            return textSegment == ts
        }.first
        
        oldTextSegment = textSegment
        core.updateTextUI()
    }
}
