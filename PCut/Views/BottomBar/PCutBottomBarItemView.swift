//
//  PCutBottomBarItemView.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/25.
//

import UIKit
import SnapKit

class PCutBottomBarItemView: UICollectionViewCell {
    var itemImageView = UIImageView()
    var item = PCutBottomItem() {
        didSet {
            layoutSubviews()
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    convenience init(item: PCutBottomItem) {
        self.init()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(itemImageView)
        
        itemImageView.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        itemImageView.image = UIImage(named: item.itemImageName)
    }
}
