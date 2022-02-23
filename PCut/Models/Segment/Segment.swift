//
//  PCutSegment.swift
//  PCut
//
//  Created by PJHubs on 2021/10/28.
//

import Foundation
import AVFoundation
import UIKit

// 基础片段
protocol Segment {
    var id: UUID { get }
}

// 动画
protocol Animation {
    var animationDuration: Float { get set }
    var inAnimationKey: String { get set }
    var outAnimationKey: String { get set }
}

// 视频片段
struct VideoSegment: Segment, Equatable {
    let id: UUID = UUID()
    var asset: AVAsset
    var timeRange: CMTimeRange
    
    static func == (lhs: VideoSegment, rhs: VideoSegment) -> Bool {
        lhs.id == rhs.id
    }
}

// 文字片段
struct TextSegment: Animation, Segment, Equatable {
    let id: UUID = UUID()
    var string: String = ""
    var fontSize: CGFloat = 0
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .black
    var duration: CMTime = .zero
    var startTime: CMTime = .zero
    
    var inAnimationKey: String = ""
    var outAnimationKey: String = ""
    var animationDuration: Float = 0
    
    static func == (lhs: TextSegment, rhs: TextSegment) -> Bool {
        lhs.id == rhs.id
    }
}
