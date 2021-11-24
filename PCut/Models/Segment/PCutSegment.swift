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

struct PCutVideoSegment: PCutSegment {
    let id: UUID = UUID()
    var asset: AVAsset
    var timeRange: CMTimeRange
}

struct PCutTextSegment: PCutSegment {
    let id: UUID = UUID()
    var string: String = ""
    var fontSize: CGFloat = 0
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .black
    var duration: CMTime = .zero
    var startTime: CMTime = .zero
}
