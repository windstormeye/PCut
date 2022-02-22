//
//  PCutImportVideoView.swift
//  PCut
//
//  Created by bytedance on 2021/11/7.
//

import Foundation
import UIKit

protocol ImportVideoViewDelegate {
    func importVideo(_ view: ImportVideoView)
}

extension ImportVideoViewDelegate {
    func importVideo(_ view: ImportVideoView) {}
}

class ImportVideoView: UIView {
    var deletega: ImportVideoViewDelegate?
    
    var importVideoButton = UIButton()
    var importVideoTipsLabel = UILabel()
    var borderLayer = CAShapeLayer()
    
    var core: Core?
    
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
        addSubview(importVideoButton)
        addSubview(importVideoTipsLabel)
        
        let importVideoButtonConfig = UIImage.SymbolConfiguration(pointSize: 50)
        importVideoButton.setImage(UIImage(systemName: "square.and.arrow.down.fill", withConfiguration: importVideoButtonConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        importVideoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(50)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ImportVideoView.importVideo))
        addGestureRecognizer(tap)
        
        importVideoTipsLabel.text = "导入视频"
        importVideoTipsLabel.textColor = .white
        importVideoTipsLabel.font = UIFont.systemFont(ofSize: 15)
        importVideoTipsLabel.snp.makeConstraints { make in
            make.centerX.equalTo(importVideoButton)
            make.top.equalTo(importVideoButton.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineDashPattern = [2, 2]
        borderLayer.fillColor = nil
        layer.addSublayer(borderLayer)
    }
    
    override func layoutSubviews() {
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(rect: bounds).cgPath
    }
}

extension ImportVideoView {
    @objc
    private func importVideo() {
        if (deletega != nil) {
            deletega!.importVideo(self)
        }
    }
}
