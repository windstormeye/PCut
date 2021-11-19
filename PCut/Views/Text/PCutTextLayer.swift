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
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.cgColor
        string = textSegment.string
        fontSize = textSegment.fontSize;
        alignmentMode = CATextLayerAlignmentMode.center
        
        let width = textSegment.string.textAutoWidth(height: textSegment.fontSize,
                                                      font: UIFont.systemFont(ofSize: textSegment.fontSize))
        frame = CGRect(x: 0, y: 0, width: width, height: textSegment.fontSize)
    }
}
