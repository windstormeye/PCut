//
//  PCutToast.swift
//  PCut
//
//  Created by wengpeijun on 2021/11/11.
//

import Toaster

class PCutToast {
    class func show(_ text: String) {
        if (!Thread.isMainThread) {
            DispatchQueue.main.async {
                Toast(text: text).show()
            }
        } else {
            Toast(text: text).show()
        }
    }
}
