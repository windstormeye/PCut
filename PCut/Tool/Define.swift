//
//  Define.swift
//  PCut
//
//  Created by wengpeijun on 2022/2/22.
//

import UIKit

/// 底部菜单栏配置
enum BarItem: String {
    case textItem = "text"
    case videoItem = "video"
    case audioItem = "audio"
    case effectItem = "effect"
    case stickerItem = "sticker"
}

// 文字菜单子项配置
enum TextBarItem: String {
    case subtitleItem = "subtitleItem"
}


func textBottomBarMenuItems() -> [MenuItem] {
    let subtitleItem = MenuItem(itemIdentifier: TextBarItem.subtitleItem.rawValue, itemTitleString: "字幕", itemSystemImageName: "character.textbox")
    return [subtitleItem]
}
