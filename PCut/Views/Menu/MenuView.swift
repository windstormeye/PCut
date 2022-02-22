//
//  PCutMenuView.swift
//  PCut
//
//  Created by wengpeijun on 2022/2/22.
//

import UIKit

class MenuView: UIView {
    let reuseCellId = String(describing: MenuItemView.self)
    var items = [MenuItem]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 70, height: 60)
        let col = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        col.backgroundColor = .clear
        return col
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        
        collectionView.register(MenuItemView.self, forCellWithReuseIdentifier: reuseCellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
    }
    
    private func initLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MenuView: UICollectionViewDelegate {
    
}

extension MenuView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellId, for: indexPath) as! MenuItemView
        cell.updateItem(items[indexPath.row])
        return cell
    }
}
