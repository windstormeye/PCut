//
//  PCutTimelineIndicator.swift
//  PCut
//
//  Created by PJHubs on 2021/11/5.
//

import Foundation
import UIKit

class TimelineIndicator: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
    }
}
