//
//  PCutSegment.swift
//  PCut
//
//  Created by PJHubs on 2021/10/28.
//

import Foundation
import AVFoundation

protocol PCutSegment {
    var id: UUID { get }
}

struct PCutSegmentVideo: PCutSegment {
    let id: UUID = UUID()
    var asset: AVAsset
}
