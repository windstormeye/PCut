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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        addSubview(itemImageView)
        
        itemImageView.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.center.equalToSuperview()
        }
        
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.tintColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        itemImageView.image = UIImage(systemName: item.itemImageName)
    }
}
