//
//  PCutTimelineImportVideoButtpn.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/8.
//

import Foundation
import UIKit

class PCutTimelineImportVideoButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 30)
        setImage(UIImage(systemName: "plus.square.fill", withConfiguration: buttonConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    }
}
