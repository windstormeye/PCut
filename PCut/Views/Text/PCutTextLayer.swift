//
//  PCutTextLayer.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/15.
//

import Foundation
import UIKit

class PCutTextLayer: CATextLayer {
    var textSegment = PCutTextSegment()
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ textSegment: PCutTextSegment) {
        self.init()
        self.textSegment = textSegment
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.cgColor
        string = textSegment.string
        fontSize = textSegment.fontSize;
        alignmentMode = CATextLayerAlignmentMode.center
        frame = textSegment.frame
    }
}
