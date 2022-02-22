//
//  PCutSegment.swift
//  PCut
//
//  Created by PJHubs on 2021/10/28.
//

import Foundation
import AVFoundation
import UIKit

protocol Segment {
    var id: UUID { get }
}

struct VideoSegment: Segment, Equatable {
    let id: UUID = UUID()
    var asset: AVAsset
    var timeRange: CMTimeRange
    
    static func == (lhs: VideoSegment, rhs: VideoSegment) -> Bool {
        lhs.id == rhs.id
    }
}

struct TextSegment: Segment, Equatable {
    let id: UUID = UUID()
    var string: String = ""
    var fontSize: CGFloat = 0
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .black
    var duration: CMTime = .zero
    var startTime: CMTime = .zero
    
    static func == (lhs: TextSegment, rhs: TextSegment) -> Bool {
        lhs.id == rhs.id
    }
}
