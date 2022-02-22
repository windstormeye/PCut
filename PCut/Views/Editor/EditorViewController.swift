//
//  EditorViewController.swift
//  PCut
//
//  Created by 翁培钧 on 2021/10/21.
//

import UIKit
import AVFoundation
import Vision
import Photos


class EditorViewController: UIViewController {

    let thumbnailWidth: CGFloat = 50
    let composition = AVMutableComposition()
    let videoOutput = AVPlayerItemVideoOutput()
    
    var thumbnailSrollView: UIScrollView?
    var thumbnailManager: ThumbnailManager?
    var indicator: TimelineIndicator?
    var playerControlView = PlayerCotrolView()
    var importVideoView = ImportVideoView()
    var imagePickerController = UIImagePickerController()
    var timelineImportVideoButton = TimelineImportVideoButton()
    var chaseTime = CMTime.zero
    var isSeekInProgress = false
    var playerCurrentItemStatus: AVPlayerItem.Status = .unknown
    var preview = Preview()
    var bottomBar = BottomBar()
    
    var core = Core()
    /// frame data source
    var thumbnails = [Thumbnail]()
    /// frame collections on the screen
    var screenThumbnails = [Thumbnail]()
    var videoTrackSegmentViews = [VideoTrackSegmentView]()
    var menu: MenuView = {
        let menu = MenuView()
        return menu
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initLayout()
        
        observe()
    }
    
    private func initView() {
        view.backgroundColor = UIColor.black
        
        thumbnailManager = ThumbnailManager(core)
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.movie"]
        
        view.addSubview(core.player)
        view.addSubview(preview)


        playerControlView = PlayerCotrolView(core: core)
        view.addSubview(playerControlView)
        
        view.addSubview(importVideoView)
        importVideoView.core = core
        importVideoView.deletega = self
        
        
        thumbnailSrollView = UIScrollView()
        view.addSubview(thumbnailSrollView!)
        thumbnailSrollView?.showsVerticalScrollIndicator = false
        thumbnailSrollView?.showsHorizontalScrollIndicator = false
        thumbnailSrollView?.delegate = self
        thumbnailSrollView?.bounces = false
        thumbnailSrollView?.isHidden = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gesture:)))
        thumbnailSrollView?.addGestureRecognizer(pinchGesture)
//        thumbnailSrollView?.panGestureRecognizer.require(toFail: pinchGesture)
    
        
        indicator = TimelineIndicator()
        view.addSubview(indicator!)
        indicator?.isHidden = true
        
        view.addSubview(timelineImportVideoButton)

        timelineImportVideoButton.isHidden = true
        timelineImportVideoButton.addTarget(self,
                                            action: #selector(EditorViewController.timelineImportVideo),
                                            for: .touchUpInside)
        
        let textItem = PCutBottomItem(itemIdentifier: BarItem.textItem.rawValue, itemImageName: "textformat.alt")
        let stickerItem = PCutBottomItem(itemIdentifier: BarItem.stickerItem.rawValue, itemImageName: "theatermasks.fill")
        let audioItem = PCutBottomItem(itemIdentifier: BarItem.audioItem.rawValue, itemImageName: "music.quarternote.3")
        let filterItem = PCutBottomItem(itemIdentifier: BarItem.effectItem.rawValue, itemImageName: "wand.and.stars.inverse")
        let videoItem = PCutBottomItem(itemIdentifier: BarItem.videoItem.rawValue, itemImageName: "crop")
        bottomBar = BottomBar(items: [videoItem, textItem, stickerItem, audioItem, filterItem], defaultIndex: 0)
        view.addSubview(bottomBar)
        bottomBar.selectedIndexBlock = { [weak self] item in
            guard let self = self else { return }
            self.itemAction(bottomBar: self.bottomBar, item)
        }
        
        view.addSubview(menu)
    }
    
    private func initLayout() {
        
        let playerHeight = CGFloat(UIScreen.main.bounds.size.width / 16 * 10)
        core.player.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalTo(playerHeight)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        preview.snp.makeConstraints({ make in
            make.size.equalTo(core.player)
            make.top.equalTo(core.player)
        })
        
        
        playerControlView.snp.makeConstraints { make in
            make.top.equalTo(core.player.snp.bottom)
            make.width.equalTo(view)
            make.height.equalTo(70)
        }
        
        importVideoView.snp.makeConstraints { make in
            make.top.equalTo(playerControlView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(100)
        }
        
        thumbnailSrollView?.snp.makeConstraints({ make in
            make.top.equalTo(importVideoView).offset(20)
            make.width.equalToSuperview()
            make.height.equalTo(thumbnailWidth)
        })
        
        indicator?.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(thumbnailSrollView!.snp.height).offset(40)
            make.top.equalTo(thumbnailSrollView!.snp.top).offset(-20)
        })
        
        timelineImportVideoButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.size.equalTo(50)
            make.centerY.equalTo(self.thumbnailSrollView!)
        }
        
        bottomBar.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        menu.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalTo(bottomBar.snp.top)
        }
    }
}

