//
//  PreviewVideoViewController.swift
//  VideoCompress
//
//  Created by 何少博 on 16/12/1.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit

class PreviewVideoViewController: BaseViewController {

    var videoUrl:URL?
    var videoAsset:PHAsset?
    fileprivate var player:VideoPlayerView?
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge(rawValue: UInt(0))
        
        let backImage = UIImage(named: "back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style:.plain, target: self, action: #selector(disMissPreviewVC))
        view.backgroundColor = UIColor.black
        
        let needShowAD = needsShowAdView()
        if needShowAD == true{
            interstitialButton = NPInterstitialButton(type: .icon, viewController: self)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: interstitialButton)
        }
        
        let frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - 64)
        player = VideoPlayerView(frame:frame)
//        player?.shouQiBtn.isHidden = true
        player?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(player!)
        
        if videoAsset != nil {
            player?.playWithPHAsset(phasset: videoAsset!)
        }else{
            player?.playWithUrl(url: videoUrl!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navibarImage = UIImage(named: "navigation_bar")
        let stratchedNavibarImage = navibarImage?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        navigationController?.navigationBar.setBackgroundImage(stratchedNavibarImage, for: .default)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    func disMissPreviewVC()  {
//        if player != nil{
//            player?.stopPlay()
//            player?.removeFromSuperview()
//        }
        dismiss(animated: true, completion: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setAdEdgeInsets(_ contentInsets: UIEdgeInsets) {
        super.setAdEdgeInsets(contentInsets)
        var height = view.bounds.size.height
        height = height - contentInsets.bottom
        let frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: height)
        player?.frame = frame
    }
    
    deinit {
//        print("PreviewVideoViewControlle-\(#function)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
