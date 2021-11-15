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
    var color: UIColor = .white
    var frame: CGRect = .zero // TODO: 这个属性需要调整，不应该传入 size，看看能不能读到 natureSize
}
