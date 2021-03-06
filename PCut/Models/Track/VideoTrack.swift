//
//  PCutTrackVideo.swift
//  PCut
//
//  Created by PJHubs on 2021/11/2.
//

import Foundation
import UIKit

class VideoTrack: UIScrollView {
    // TODO: 视频主轨还是要以 UICollectionView 为准吧
}

class VideoTrackSegmentView: UIView {
    var videoSegment: VideoSegment?
    var thumbnailView = ThumbnailView()
    
    override var frame: CGRect {
        set {
            super.frame = newValue
            thumbnailView.frame.size = newValue.size
        } get {
            return super.frame
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(videoSegment: VideoSegment) {
        self.init(frame: .zero)
        
        addSubview(thumbnailView)
        self.videoSegment = videoSegment
    }
}
