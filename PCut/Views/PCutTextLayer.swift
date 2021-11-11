//
//  PCutTextLayer.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/10.
//

import Foundation
import UIKit
import CoreMedia

class PCutTextLayer {
    //  Your converted code is limited to 2 KB.
    //  Refill your credit or upgrade your plan to remove this limitation.
    //
    //  Converted to Swift 5.5 by Swiftify v5.5.21910 - https://swiftify.com/
    class func buildLayerbuildTxt(
        _ text: String?,
        textSize: CGFloat,
        textColor: UIColor?,
        stroke strokeColor: UIColor?,
        opacity: Float,
        textRect: CGRect,
        fontPath: String?,
        viewBounds: CGSize,
        startTime: TimeInterval,
        duration: TimeInterval
    ) -> CALayer? {
        if text == nil || (text == "") {
            return nil
        }

        // Create a layer for the overall title animation.
        let animatedTitleLayer = CALayer()
        animatedTitleLayer.bounds = CGRect(x: 0, y: 0, width: viewBounds.width, height: viewBounds.height)
        animatedTitleLayer.position = CGPoint(x: viewBounds.width / 2, y: viewBounds.height / 2)
        
        // 1. Create a layer for the text of the title.
        let titleLayer = CATextLayer()
        titleLayer.string = text
        titleLayer.font = ("Helvetica") as? CFTypeRef
        titleLayer.fontSize = textSize
        titleLayer.alignmentMode = .center
        titleLayer.position = CGPoint(x: viewBounds.width / 2, y: viewBounds.height / 2)
        titleLayer.bounds = CGRect(x: 0, y: 0, width: textRect.size.width, height: textRect.size.height)
        titleLayer.foregroundColor = textColor?.cgColor
        titleLayer.backgroundColor = UIColor.clear.cgColor
        animatedTitleLayer.addSublayer(titleLayer)
//        [animatedTitleLayer addSublayer:titleLayer];

        // 添加文字以及边框效果
//        var font: UIFont? = nil
//        if fontPath != nil && ((fontPath?.count ?? 0) > 0) {
//            font = FLVideoEditFontManager.shared().font(withPath: fontPath, size: textSize)
//            if let fontName = font?.fontName as CFString? {
//                titleLayer.font = CGFont(fontName)
//            }
//        }
//        if font == nil {
//            titleLayer.font = ("Helvetica") as? CFTypeRef
//        }
//
//        var path: UIBezierPath? = nil
//        if let font = font {
//            path = FLLayerBuilderTool.createPath(forText: text, fontHeight: textSize, fontName: (font.fontName) as CFString)
//        } else {
//            path = FLLayerBuilderTool.createPath(forText: text, fontHeight: textSize, fontName: "Helvetica" as CFString)
//        }
//        let rectPath = path?.cgPath.boundingBox
        let textLayer = CAShapeLayer()
//        textLayer.path = path?.cgPath
        textLayer.lineWidth = 1
        if let strokeColor = strokeColor {
            textLayer.strokeColor = strokeColor.cgColor
        }
        //  Converted to Swift 5.5 by Swiftify v5.5.21910 - https://swiftify.com/
        if let textColor = textColor {
            textLayer.fillColor = textColor.cgColor
        }
        textLayer.lineJoin = .round
        textLayer.lineCap = .round
        textLayer.isGeometryFlipped = false
        textLayer.opacity = opacity
        textLayer.position = CGPoint(x: viewBounds.width / 2, y: viewBounds.height / 2)
        textLayer.bounds = CGRect(x: 0, y: 0, width: viewBounds.width, height: textSize + 10)
//        animatedTitleLayer.addSublayer(textLayer)

        // 动画图层位置
//        animatedTitleLayer.position = CGPoint(x: textRect.origin.x + textRect.size.width / 2, y: viewBounds.height - textRect.size.height / 2 - textRect.origin.y)

        let initAnimationDuration: TimeInterval = 0.1
        let animationDuration: TimeInterval = 0.1

        // 3.显示动画
        let animatedInStartTime = startTime + initAnimationDuration
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = NSNumber(value: 0.0)
        fadeInAnimation.toValue = NSNumber(value: 1.0)
        fadeInAnimation.isAdditive = false
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.beginTime = CFTimeInterval(animatedInStartTime)
        fadeInAnimation.duration = animationDuration
        fadeInAnimation.autoreverses = false
        fadeInAnimation.fillMode = .both
//        textLayer.add(fadeInAnimation, forKey: "opacity")

        let animatedOutStartTime = TimeInterval(startTime + duration - animationDuration)
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.fromValue = NSNumber(value: 1.0)
        fadeOutAnimation.toValue = NSNumber(value: 0.0)
        fadeOutAnimation.isAdditive = false
        fadeOutAnimation.isRemovedOnCompletion = false
        fadeOutAnimation.beginTime = CFTimeInterval(animatedOutStartTime)
        fadeOutAnimation.duration = animationDuration
        fadeOutAnimation.autoreverses = false
        fadeOutAnimation.fillMode = .both

//        animatedTitleLayer.add(fadeOutAnimation, forKey: "opacity")

        return animatedTitleLayer
    }
}

//- (CALayer *)buildLayerbuildTxt:(NSString*)text
//                       textSize:(CGFloat)textSize
//                      textColor:(UIColor*)textColor
//                    strokeColor:(UIColor*)strokeColor
//                        opacity:(CGFloat)opacity
//                       textRect:(CGRect)textRect
//                       fontPath:(NSString*)fontPath
//                     viewBounds:(CGSize)viewBounds
//                      startTime:(NSTimeInterval)startTime
//                       duration:(NSTimeInterval)duration
//{
//    if (!text || [text isEqualToString:@""])
//    {
//        return nil;
//    }
//
//    // Create a layer for the overall title animation.
//    CALayer *animatedTitleLayer = [CALayer layer];
//
//    // 1. Create a layer for the text of the title.
//    CATextLayer *titleLayer = [CATextLayer layer];
//    titleLayer.string = text;
//    titleLayer.font = (__bridge CFTypeRef)(@"Helvetica");
//    titleLayer.fontSize = textSize;
//    titleLayer.alignmentMode = kCAAlignmentCenter;
//    titleLayer.bounds = CGRectMake(0, 0, textRect.size.width, textRect.size.height);
//    titleLayer.foregroundColor = textColor.CGColor;
//    titleLayer.backgroundColor = [UIColor clearColor].CGColor;
//    // [animatedTitleLayer addSublayer:titleLayer];
//
//    // 添加文字以及边框效果
//    UIFont *font = nil;
//    if ((fontPath != nil) && (fontPath.length > 0)) {
//        font = [[FLVideoEditFontManager sharedFLVideoEditFontManager] fontWithPath:fontPath size:textSize];
//        titleLayer.font = CGFontCreateWithFontName((__bridge CFStringRef)font.fontName);
//    }
//    if (font == nil) {
//        titleLayer.font = (__bridge CFTypeRef)(@"Helvetica");
//    }
//
//    UIBezierPath *path = nil;
//    if (font) {
//        path = [FLLayerBuilderTool createPathForText:text fontHeight:textSize fontName:(__bridge CFStringRef)(font.fontName)];
//    }
//    else
//    {
//        path = [FLLayerBuilderTool createPathForText:text fontHeight:textSize fontName:CFSTR("Helvetica")];
//    }
//    CGRect rectPath = CGPathGetBoundingBox(path.CGPath);
//    CAShapeLayer *textLayer = [CAShapeLayer layer];
//    textLayer.path = path.CGPath;
//    textLayer.lineWidth = 1;
//    if (strokeColor != nil) {
//        textLayer.strokeColor = strokeColor.CGColor;
//    }
//    if (textColor != nil) {
//        textLayer.fillColor = textColor.CGColor;
//    }
//    textLayer.lineJoin = kCALineJoinRound;
//    textLayer.lineCap = kCALineCapRound;
//    textLayer.geometryFlipped = NO;
//    textLayer.opacity = opacity;
//    textLayer.bounds = CGRectMake(0, 0, rectPath.size.width, textSize+10);
//    [animatedTitleLayer addSublayer:textLayer];
//
//    // 动画图层位置
//    animatedTitleLayer.position = CGPointMake(textRect.origin.x+textRect.size.width/2, viewBounds.height - textRect.size.height/2 - textRect.origin.y);
//
//    NSTimeInterval initAnimationDuration = 0.1f;
//    NSTimeInterval animationDuration = 0.1f;
//
//    // 3.显示动画
//    NSTimeInterval animatedInStartTime = startTime + initAnimationDuration;
//    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeInAnimation.fromValue = @0.0f;
//    fadeInAnimation.toValue = @1.0f;
//    fadeInAnimation.additive = NO;
//    fadeInAnimation.removedOnCompletion = NO;
//    fadeInAnimation.beginTime = animatedInStartTime;
//    fadeInAnimation.duration = animationDuration;
//    fadeInAnimation.autoreverses = NO;
//    fadeInAnimation.fillMode = kCAFillModeBoth;
//    [textLayer addAnimation:fadeInAnimation forKey:@"opacity"];
//
//    NSTimeInterval animatedOutStartTime = startTime + duration - animationDuration;
//    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeOutAnimation.fromValue = @1.0f;
//    fadeOutAnimation.toValue = @0.0f;
//    fadeOutAnimation.additive = NO;
//    fadeOutAnimation.removedOnCompletion = NO;
//    fadeOutAnimation.beginTime = animatedOutStartTime;
//    fadeOutAnimation.duration = animationDuration;
//    fadeOutAnimation.autoreverses = NO;
//    fadeOutAnimation.fillMode = kCAFillModeBoth;
//
//    [animatedTitleLayer addAnimation:fadeOutAnimation forKey:@"opacity"];
//
//    return animatedTitleLayer;
//}
