//
//  PCutBottomBar.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/25.
//

import UIKit

class PCutBottomBar: UIView {

    let reuseId = "PCutButtonBarItemView"
    
    var itemCollectionView = UICollectionView()
    var items = [PCutBottomItem]()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    convenience init(items: [PCutBottomItem]) {
        self.init()
        self.items = items
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        itemCollectionView.register(PCutBottomBarItemView.self,
                                    forCellWithReuseIdentifier: reuseId)
    }
}

extension PCutBottomBar: UICollectionViewDelegate {
    
}

extension PCutBottomBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId,
                                                      for: indexPath) as! PCutBottomBarItemView
        cell.item = items[indexPath.row]
        return cell
    }
    
    
}


struct PCutBottomItem {
    var itemTitle = "item"
    var itemImageName = ""
}
