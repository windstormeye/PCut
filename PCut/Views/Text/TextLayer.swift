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
    private var previewMode = true
    
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ textSegment: TextSegment, previewMode: Bool) {
        self.init()
        self.textSegment = textSegment
        self.previewMode = previewMode
        setupUI()
    }
    
    private func setupUI() {
        addSublayer(textLayer)
        textLayer.backgroundColor = UIColor.black.cgColor
        textLayer.string = textSegment.string
        textLayer.fontSize = textSegment.fontSize;
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        let width = textSegment.string.textAutoWidth(height: textSegment.fontSize, font: UIFont.systemFont(ofSize: textSegment.fontSize))
        let height = textSegment.string.textAutoHeight(width: width, font: .systemFont(ofSize: textSegment.fontSize))
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        textLayer.frame = frame
        
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
        inAnimation.fillMode = .forwards
        // NOTE: 动画冲突，只能执行一个，故分别 add 到不同宿主上
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
        outAnimation.fillMode = .forwards
        // NOTE: 动画冲突，只能执行一个，故分别 add 到不同宿主上
        add(outAnimation, forKey: outAnimation.keyPath)
        
        if previewMode {
            speed = 0
        }
    }
}
