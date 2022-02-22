//
//  PCutBottomBar.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/25.
//

import UIKit

class BottomSegmentBar: UISegmentedControl {
    /// 数据源
    var segmentItems = [PCutBottomItem]()
    /// 默认选中
    var defaultIndex: Int = 0
    /// item 选中回调
    var selectedIndexBlock: ((_ item: PCutBottomItem) -> ())?
    
    init() {
        super.init(items: [])
    }
    
    convenience init(items: [PCutBottomItem], defaultIndex: Int) {
        self.init()
        self.segmentItems = items
        self.defaultIndex = defaultIndex
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = .black
        selectedSegmentTintColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        
        
        for (itemIndex, item) in segmentItems.enumerated() {
            let action = UIAction(title: item.itemIdentifier,
                                  image: UIImage(systemName: item.itemImageName)?.withTintColor(.white, renderingMode: .alwaysOriginal),
                                  identifier: .init(rawValue: item.itemIdentifier),
                                  discoverabilityTitle: nil,
                                  attributes: [],
                                  state: .on) { [weak self] itemAction in
                guard let self = self else { return }
                if (self.selectedIndexBlock != nil) {
                    self.selectedIndexBlock!(item)
                }
            }
            insertSegment(action: action, at: itemIndex, animated: true)
        }
        
        selectedSegmentIndex = defaultIndex
    }
}

struct PCutBottomItem {
    var itemIdentifier = "item"
    var itemImageName = ""
}
