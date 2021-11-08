//
//  PCutTimelineImportAssetView.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/8.
//

import Foundation
import UIKit

protocol PCutTimelineImportAssetViewDelegate {
    func touchUpInside(_ importAssetView: PCutTimelineImportAssetButton)
}

extension PCutTimelineImportAssetViewDelegate {
    func touchUpInside(_ importAssetView: PCutTimelineImportAssetButton) {}
}

class PCutTimelineImportAssetButton: UIButton {
    
    var delegate: PCutTimelineImportAssetViewDelegate?
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        setImage(UIImage(systemName: "plus.square.fill", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        addTarget(self, action: #selector(PCutTimelineImportAssetButton.touchEvent), for: .touchUpInside)
        
    }
}

extension PCutTimelineImportAssetButton {
    @objc
    func touchEvent() {
        if (delegate != nil) {
            self.delegate?.touchUpInside(self)
        }
    }
}
