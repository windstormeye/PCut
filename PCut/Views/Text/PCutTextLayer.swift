//
//  PCutTextLayer.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/15.
//

import Foundation
import UIKit
import CoreMedia

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
        duration = CFTimeInterval(CMTimeGetSeconds(textSegment.duration))
        let width = textSegment.string.textAutoWidth(height: textSegment.fontSize,
                                                      font: UIFont.systemFont(ofSize: textSegment.fontSize))
        frame = CGRect(x: 0, y: 0, width: width, height: textSegment.fontSize)
        
        
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0
        fadeInAnimation.toValue = 1
        fadeInAnimation.isAdditive = false
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.beginTime = 0
        fadeInAnimation.duration = 1
        fadeInAnimation.autoreverses = false
        fadeInAnimation.fillMode = CAMediaTimingFillMode.both
        add(fadeInAnimation, forKey: "opacity")
        
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.fromValue = 1
        fadeOutAnimation.toValue = 0
        fadeOutAnimation.isAdditive = false
        fadeOutAnimation.isRemovedOnCompletion = false
        fadeOutAnimation.beginTime = 2
        fadeOutAnimation.duration = 1
        fadeOutAnimation.autoreverses = false
        fadeOutAnimation.fillMode = CAMediaTimingFillMode.both
        add(fadeOutAnimation, forKey: "opacity")
    }
}
