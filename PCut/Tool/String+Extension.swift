//
//  String+Extension.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/19.
//

import UIKit

extension String {
    ///根据宽度跟字体，计算文字的高度
    func textAutoHeight(width: CGFloat, font: UIFont) -> CGFloat {
        let string = self as NSString
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let ssss = NSStringDrawingOptions.usesDeviceMetrics
        let rect = string.boundingRect(with:CGSize(width: width, height:0),
                                       options: [origin,lead,ssss],
                                       attributes: [NSAttributedString.Key.font:font], context:nil)

        return rect.height
    }

    ///根据高度跟字体，计算文字的宽度
    func textAutoWidth(height: CGFloat, font: UIFont) -> CGFloat{
        let string = self as NSString
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let rect = string.boundingRect(with:CGSize(width:0, height: height),
                                       options: [origin,lead],
                                       attributes: [NSAttributedString.Key.font:font], context:nil)
        return rect.width

    }
}
