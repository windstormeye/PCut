//
//  PCutTextLayer.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/15.
//

import Foundation
import UIKit
import CoreMedia

class PCutTextLayer: CALayer {
    var textSegment = PCutTextSegment()
    var textLayer = CATextLayer()
    
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
        addSublayer(textLayer)
        textLayer.backgroundColor = UIColor.black.cgColor
        textLayer.string = textSegment.string
        textLayer.fontSize = textSegment.fontSize;
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        let width = textSegment.string.textAutoWidth(height: textSegment.fontSize,
                                                      font: UIFont.systemFont(ofSize: textSegment.fontSize))
        textLayer.frame = CGRect(x: 0, y: 0, width: width, height: textSegment.fontSize)
        
        
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0
        fadeInAnimation.toValue = 1
        fadeInAnimation.isAdditive = false
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.beginTime = CMTimeGetSeconds(textSegment.startTime)
        fadeInAnimation.duration = 0.1
        fadeInAnimation.autoreverses = false
        fadeInAnimation.fillMode = CAMediaTimingFillMode.both
        textLayer.add(fadeInAnimation, forKey: "opacity")
        
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.fromValue = 1
        fadeOutAnimation.toValue = 0
        fadeOutAnimation.isAdditive = false
        fadeOutAnimation.isRemovedOnCompletion = false
        fadeOutAnimation.beginTime = CMTimeGetSeconds(CMTimeAdd(textSegment.startTime,
                                                                textSegment.duration))
        fadeOutAnimation.duration = 0.1
        fadeOutAnimation.autoreverses = false
        fadeOutAnimation.fillMode = CAMediaTimingFillMode.both
        add(fadeOutAnimation, forKey: "opacity")
    }
}
