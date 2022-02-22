//
//  MenuItemView.swift
//  PCut
//
//  Created by wengpeijun on 2022/2/22.
//

import UIKit

struct MenuItem {
    let itemIdentifier: String
    let itemTitleString: String
    let itemSystemImageName: String
}

class MenuItemView: UICollectionViewCell {
    var item = MenuItem(itemIdentifier: "", itemTitleString: "", itemSystemImageName: "")
    var itemImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    var itemTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        addSubview(itemImageView)
        itemImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
            make.size.equalTo(30)
        }
        itemImageView.contentMode = .scaleAspectFit
        
        addSubview(itemTitleLabel)
        itemTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(itemImageView.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }
    
    func updateItem(_ item: MenuItem) {
        self.item = item;
        itemImageView.image = UIImage(systemName: item.itemSystemImageName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        itemTitleLabel.text = item.itemTitleString
    }
}
