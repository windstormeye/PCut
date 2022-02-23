//
//  PCutTextLayer.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/15.
//

import Foundation
import UIKit
import CoreMedia

class TextLayer: CALayer {
    var textSegment = TextSegment()
    private var textLayer = CATextLayer()
    private var inAnimation = CABasicAnimation();
    private var outAnimation = CABasicAnimation();
    
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ textSegment: TextSegment) {
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
        
        
        inAnimation = CABasicAnimation(keyPath: textSegment.inAnimationKey)
        // 动画起始变换值
        inAnimation.fromValue = 0
        // 动画终止变换值
        inAnimation.toValue = 1
        inAnimation.isAdditive = false
        inAnimation.isRemovedOnCompletion = false
        inAnimation.beginTime = CMTimeGetSeconds(textSegment.startTime)
        inAnimation.duration = CFTimeInterval(textSegment.animationDuration)
        inAnimation.autoreverses = false
        inAnimation.fillMode = CAMediaTimingFillMode.both
        textLayer.add(inAnimation, forKey: inAnimation.keyPath)
        
        outAnimation = CABasicAnimation(keyPath: textSegment.outAnimationKey)
        // 动画起始变换值
        outAnimation.fromValue = 1
        // 动画终止变换值
        outAnimation.toValue = 0
        outAnimation.isAdditive = false
        outAnimation.isRemovedOnCompletion = false
        outAnimation.beginTime = CMTimeGetSeconds(CMTimeAdd(textSegment.startTime, textSegment.duration))
        outAnimation.duration = CFTimeInterval(textSegment.animationDuration)
        outAnimation.autoreverses = false
        outAnimation.fillMode = CAMediaTimingFillMode.both
        add(outAnimation, forKey: outAnimation.keyPath)
    }
    
    func updateUI() {
        textLayer.string = textSegment.string
        textLayer.fontSize = textSegment.fontSize;
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        let width = textSegment.string.textAutoWidth(height: textSegment.fontSize,
                                                      font: UIFont.systemFont(ofSize: textSegment.fontSize))
        textLayer.frame = CGRect(x: 0, y: 0, width: width, height: textSegment.fontSize)
        
        inAnimation.beginTime = CMTimeGetSeconds(textSegment.startTime)
        outAnimation.beginTime = CMTimeGetSeconds(CMTimeAdd(textSegment.startTime,
                                                                textSegment.duration))

    }
}
