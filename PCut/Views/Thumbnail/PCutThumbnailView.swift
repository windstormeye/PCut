//
//  PCutThumbnailView.swift
//  PCut
//
//  Created by PJHubs on 2021/10/28.
//

import UIKit

class PCutThumbnailView: UIView {
    var thumbnail: PCutThumbnail?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
