//
//  PCutBottomBar.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/25.
//

import UIKit

class PCutBottomSegmentBar: UISegmentedControl {
    var segmentItems = [PCutBottomItem]()

    init() {
        super.init(items: [])
    }
    
    convenience init(items: [PCutBottomItem]) {
        self.init()
        self.segmentItems = items
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = .black
        selectedSegmentTintColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        
        
        for (itemIndex, item) in segmentItems.enumerated() {
            let action = UIAction(title: item.itemTitle,
                                  image: UIImage(systemName: item.itemImageName)?.withTintColor(.white, renderingMode: .alwaysOriginal),
                                  identifier: .init(rawValue: item.itemTitle),
                                  discoverabilityTitle: nil,
                                  attributes: [],
                                  state: .on) { a in
                print(itemIndex)
            }
            insertSegment(action: action, at: itemIndex, animated: true)
        }
        
        selectedSegmentIndex = 0
    }
}

struct PCutBottomItem {
    var itemTitle = "item"
    var itemImageName = ""
}
