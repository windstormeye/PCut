//
//  PCutSegment.swift
//  PCut
//
//  Created by PJHubs on 2021/10/28.
//

import Foundation
import AVFoundation
import UIKit

protocol PCutSegment {
    var id: UUID { get }
}

struct PCutVideoSegment: PCutSegment, Equatable {
    let id: UUID = UUID()
    var asset: AVAsset
    var timeRange: CMTimeRange
    
    static func == (lhs: PCutVideoSegment, rhs: PCutVideoSegment) -> Bool {
        lhs.id == rhs.id
    }
}

struct PCutTextSegment: PCutSegment, Equatable {
    let id: UUID = UUID()
    var string: String = ""
    var fontSize: CGFloat = 0
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .black
    var duration: CMTime = .zero
    var startTime: CMTime = .zero
    
    static func == (lhs: PCutTextSegment, rhs: PCutTextSegment) -> Bool {
        lhs.id == rhs.id
    }
}
