//
//  PCutMenuView.swift
//  PCut
//
//  Created by wengpeijun on 2022/2/22.
//

import UIKit

class MenuView: UIView {
    var collectionView: UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 70, height: 40)
        let col = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        col.delegate = self
        col.dataSource = self
        return col
    }
    
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
        
        addSubview(collectionView)
    }
    
    private func initLayout() {
        
    }
}

extension MenuView: UICollectionViewDelegate {
    
}

extension MenuView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
